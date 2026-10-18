import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localmind_ai/domain/model_definition.dart';
import 'package:localmind_ai/services/downloads/model_downloader.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';
import 'package:localmind_ai/services/inference/llamadart_runtime.dart';

/// Small Bengali check with known answers. It records results; it does not
/// decide whether a model is "good at Bengali". Models must be pushed first:
///   `adb push MODEL.gguf /data/local/tmp/`
/// and selected with --dart-define=BN_MODELS=id1,id2 (one at a time on
/// small devices).
const _cases = [
  ('বাংলাদেশের রাজধানীর নাম কী? এক বাক্যে বাংলায় উত্তর দিন।', ['ঢাকা']),
  ('৭ + ৫ = কত? শুধু সংখ্যাটি বাংলায় লিখুন।', ['১২', '12']),
  ('সূর্য কোন দিকে ওঠে? এক শব্দে বাংলায় উত্তর দিন।', ['পূর্ব']),
  ('Translate to Bengali: "I like to eat rice."', ['ভাত']),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const ids = String.fromEnvironment('BN_MODELS');

  for (final id in ids.split(',').where((s) => s.isNotEmpty)) {
    testWidgets('Bengali eval: $id', semanticsEnabled: false, (tester) async {
      final catalog = ModelCatalog.fromJson(
        jsonDecode(await rootBundle.loadString('assets/models/catalog.json'))
            as Map<String, dynamic>,
      );
      final m = catalog.byId(id)!;
      // Loaded in place to avoid a second copy on small test devices.
      final path = '/data/local/tmp/${m.fileName}';
      expect(File(path).existsSync(), isTrue, reason: 'push ${m.fileName}');
      expect(await sha256OfFile(path), m.sha256);

      final runtime = LlamadartRuntime();
      final watch = Stopwatch()..start();
      await runtime.load(path, const RuntimeLoadConfig(contextSize: 1024));
      log('[$id] load ${watch.elapsedMilliseconds}ms');
      var correct = 0;
      for (final (prompt, expected) in _cases) {
        final out = StringBuffer();
        GenerationStats? stats;
        await for (final e in runtime.generate([
          const ChatTurn(
            ChatRole.system,
            'You are a helpful assistant. Answer concisely.',
          ),
          ChatTurn(ChatRole.user, prompt),
        ], const GenerationSettings(temperature: 0, maxTokens: 96))) {
          switch (e) {
            case TokenEvent(:final text):
              out.write(text);
            case DoneEvent(stats: final s):
              stats = s;
          }
        }
        final answer = out.toString().trim();
        final ok = expected.any(answer.contains);
        if (ok) correct++;
        log(
          '[$id] ${ok ? 'PASS' : 'FAIL'} '
          'tps=${stats?.tokensPerSecond?.toStringAsFixed(1)}\n'
          '  Q: $prompt\n  A: ${answer.replaceAll('\n', ' ')}',
        );
      }
      log('[$id] score $correct/${_cases.length}');
      await runtime.dispose();
    });
  }
}

// ignore: avoid_print
void log(String s) => print(s);
