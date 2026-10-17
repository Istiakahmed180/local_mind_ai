import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localmind_ai/domain/model_definition.dart';
import 'package:localmind_ai/services/downloads/model_downloader.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';
import 'package:localmind_ai/services/inference/llamadart_runtime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Real on-device inference. Models are fetched with the app's own verified
/// downloader when missing (needs network for that step only), because
/// `flutter test` reinstalls the app and clears its storage.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final runtime = LlamadartRuntime();
  late ModelCatalog catalog;
  late Directory modelsDir;

  setUpAll(() async {
    catalog = ModelCatalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/models/catalog.json'))
          as Map<String, dynamic>,
    );
    modelsDir = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'models'),
    );
    await modelsDir.create(recursive: true);
  });

  tearDownAll(runtime.dispose);

  Future<String> ensureModel(String id) async {
    final m = catalog.byId(id)!;
    final path = p.join(modelsDir.path, m.fileName);
    if (File(path).existsSync()) return path;
    // A copy pushed with `adb push` avoids re-downloading on every run.
    final pushed = File('/data/local/tmp/${m.fileName}');
    try {
      if (pushed.existsSync() && await sha256OfFile(pushed.path) == m.sha256) {
        await pushed.copy(path);
        log('[model] copied verified file from ${pushed.path}');
        return path;
      }
    } on FileSystemException catch (e) {
      log('[model] cannot read ${pushed.path}: ${e.message}');
    }
    final downloader = ModelDownloader(freeBytes: () async => 1 << 40);
    final watch = Stopwatch()..start();
    await downloader.download(
      url: m.downloadUrl,
      targetPath: path,
      expectedBytes: m.sizeBytes,
      expectedSha256: m.sha256,
      onProgress: (_) {},
      cancel: CancelSignal(),
    );
    log('[download] $id verified in ${watch.elapsed.inSeconds}s');
    return path;
  }

  Future<(String, GenerationStats?)> ask(String prompt) async {
    final buffer = StringBuffer();
    GenerationStats? stats;
    await for (final e in runtime.generate([
      const ChatTurn(
        ChatRole.system,
        'You are a helpful assistant. Answer concisely.',
      ),
      ChatTurn(ChatRole.user, prompt),
    ], const GenerationSettings(temperature: 0, maxTokens: 128))) {
      switch (e) {
        case TokenEvent(:final text):
          buffer.write(text);
        case DoneEvent(stats: final s):
          stats = s;
      }
    }
    final s = stats;
    log(
      '[answer] ttft=${s?.timeToFirstToken?.inMilliseconds}ms '
      'tokens=${s?.completionTokens} tps=${s?.tokensPerSecond?.toStringAsFixed(1)}\n'
      '${buffer.toString().trim()}',
    );
    return (buffer.toString(), stats);
  }

  Future<void> load(String id) async {
    final path = await ensureModel(id);
    final watch = Stopwatch()..start();
    await runtime.load(path, const RuntimeLoadConfig(contextSize: 1024));
    log('[load] $id ${watch.elapsedMilliseconds}ms');
  }

  const bengaliPrompt =
      'বাংলাদেশের রাজধানীর নাম কী? এক বাক্যে বাংলায় উত্তর দিন।';

  testWidgets(
    'Qwen2.5 0.5B: English answer, Bengali sample, cancel',
    semanticsEnabled: false,
    (tester) async {
      await load('qwen2.5-0.5b-instruct-q4_k_m');
      expect(runtime.isLoaded, isTrue);

      final (en, stats) = await ask(
        'What is the capital of France? Answer in one sentence.',
      );
      expect(en.toLowerCase(), contains('paris'));
      expect(stats?.completionTokens, greaterThan(0));

      final (bn, _) = await ask(bengaliPrompt);
      expect(bn.trim(), isNotEmpty);
      log('[bn-contains-dhaka] ${bn.contains('ঢাকা')}');

      var chunks = 0;
      await for (final e in runtime.generate(const [
        ChatTurn(ChatRole.user, 'Count from 1 to 1000, one per line.'),
      ], const GenerationSettings(temperature: 0, maxTokens: 1500))) {
        if (e is TokenEvent && ++chunks == 20) runtime.cancel();
      }
      log('[cancel] stopped after $chunks chunks');
      expect(chunks, lessThan(200));
      await runtime.unload();
      expect(runtime.isLoaded, isFalse);
    },
  );

  testWidgets('Qwen3 0.6B: Bengali sample', semanticsEnabled: false, (
    tester,
  ) async {
    await load('qwen3-0.6b-q8_0');
    final (bn, _) = await ask(bengaliPrompt);
    expect(bn.trim(), isNotEmpty);
    log('[bn-contains-dhaka] ${bn.contains('ঢাকা')}');
    await runtime.unload();
  });
}

// ignore: avoid_print
void log(String s) => print(s);
