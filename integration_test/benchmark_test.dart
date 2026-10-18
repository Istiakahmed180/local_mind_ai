import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localmind_ai/domain/model_definition.dart';
import 'package:localmind_ai/services/benchmark/benchmark.dart';
import 'package:localmind_ai/services/downloads/model_downloader.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';
import 'package:localmind_ai/services/inference/llamadart_runtime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The benchmark workload against the real engine.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final runtime = LlamadartRuntime();
  tearDownAll(runtime.dispose);

  testWidgets('Qwen2.5 0.5B benchmark', semanticsEnabled: false, (_) async {
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
      // Same verified download the app uses (SHA-256 and size checked).
      await ModelDownloader(freeBytes: () async => 1 << 40).download(
        url: m.downloadUrl,
        targetPath: path,
        expectedBytes: m.sizeBytes,
        expectedSha256: m.sha256,
        onProgress: (_) {},
        cancel: CancelSignal(),
      );
    }
    final runner = BenchmarkRunner(
      coldLoad: () async {
        await runtime.unload();
        final w = Stopwatch()..start();
        await runtime.load(path, const RuntimeLoadConfig(contextSize: 2048));
        return w.elapsed;
      },
      generate: runtime.generate,
      cancelGeneration: runtime.cancel,
      rss: () => ProcessInfo.currentRss,
    );
    final r = await runner.run();
    // ignore: avoid_print
    print(
      '[bench] load=${r.loadTime.inMilliseconds}ms '
      'prompt=${r.promptTokens} tok @ ${r.promptTokensPerSecond?.toStringAsFixed(1)} tok/s '
      'gen=${r.completionTokens} tok @ ${r.generationTokensPerSecond?.toStringAsFixed(1)} tok/s '
      '(${r.generationMin?.toStringAsFixed(1)}–${r.generationMax?.toStringAsFixed(1)}) '
      'ttft=${r.timeToFirstToken?.inMilliseconds}ms '
      'rss=${r.rssAfterLoadBytes}/${r.rssPeakBytes}',
    );
    expect(r.runs, hasLength(3));
    expect(r.completionTokens, greaterThan(32));
    expect(r.generationTokensPerSecond, greaterThan(0));
    await runtime.unload();
  });
}
