import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localmind_ai/domain/model_definition.dart';
import 'package:localmind_ai/services/benchmark/benchmark.dart';
import 'package:localmind_ai/services/downloads/model_downloader.dart';
import 'package:localmind_ai/services/inference/gpu_check.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';
import 'package:localmind_ai/services/inference/llamadart_runtime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Real llama.cpp CPU vs Vulkan on this device, with the app's own verdict.
/// Whatever the device does (no GPU, wrong text, slower, faster) is logged.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final runtime = LlamadartRuntime();
  tearDownAll(runtime.dispose);

  Future<(String, double?)> answer() async {
    const cfg = BenchmarkConfig();
    Future<(String, double?)> once(int n) async {
      final b = StringBuffer();
      GenerationStats? stats;
      await for (final e in runtime.generate(cfg.turns(1), cfg.settings(n))) {
        switch (e) {
          case TokenEvent(:final text):
            b.write(text);
          case DoneEvent(stats: final s):
            stats = s;
        }
      }
      return (b.toString(), stats?.tokensPerSecond);
    }

    await once(4);
    return once(48);
  }

  testWidgets('Qwen2.5 0.5B CPU vs GPU', semanticsEnabled: false, (_) async {
    final catalog = ModelCatalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/models/catalog.json'))
          as Map<String, dynamic>,
    );
    final m = catalog.byId('qwen2.5-0.5b-instruct-q4_k_m')!;
    final dir = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'models'),
    );
    await dir.create(recursive: true);
    final path = p.join(dir.path, m.fileName);
    if (!File(path).existsSync()) {
      await ModelDownloader(freeBytes: () async => 1 << 40).download(
        url: m.downloadUrl,
        targetPath: path,
        expectedBytes: m.sizeBytes,
        expectedSha256: m.sha256,
        onProgress: (_) {},
        cancel: CancelSignal(),
      );
    }

    await runtime.load(path, const RuntimeLoadConfig(contextSize: 2048));
    final cpuBackend = runtime.backendName;
    final cpu = await answer();
    log('[gpu] cpu backend=$cpuBackend tps=${cpu.$2}\n  text: ${cpu.$1}');
    expect(cpu.$1.trim(), isNotEmpty);
    await runtime.unload();

    try {
      await runtime.load(
        path,
        const RuntimeLoadConfig(contextSize: 2048, gpu: true),
      );
    } on InferenceException catch (e) {
      log('[gpu] GPU load refused: ${e.message}');
      return;
    }
    final gpuBackend = runtime.backendName;
    final gpu = await answer();
    final verdict = judgeGpu(
      cpuText: cpu.$1,
      gpuText: gpu.$1,
      cpuTps: cpu.$2,
      gpuTps: gpu.$2,
    );
    log(
      '[gpu] gpu backend=$gpuBackend tps=${gpu.$2} verdict=${verdict.name}\n'
      '  text: ${gpu.$1}',
    );
    await runtime.unload();
  });
}

// ignore: avoid_print
void log(String s) => print(s);
