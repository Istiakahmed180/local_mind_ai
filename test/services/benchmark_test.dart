import 'dart:async';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/benchmark_repository.dart';
import 'package:localmind_ai/features/benchmark/benchmark_controller.dart';
import 'package:localmind_ai/services/benchmark/benchmark.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';

/// Replies with [tokens] pieces and engine stats derived from them:
/// 100 ms to the first token, then 50 ms per token (20 tok/s).
class FakeEngine {
  FakeEngine({this.tokens = 5, this.promptTokens = 200});

  final int tokens;
  final int promptTokens;
  final calls = <(List<ChatTurn>, GenerationSettings)>[];
  void Function()? onCall;
  var cancelled = 0;

  Stream<GenerationEvent> generate(
    List<ChatTurn> turns,
    GenerationSettings s,
  ) async* {
    calls.add((turns, s));
    onCall?.call();
    final n = s.maxTokens < tokens ? s.maxTokens : tokens;
    for (var i = 0; i < n; i++) {
      yield TokenEvent('t$i ');
    }
    yield DoneEvent(
      GenerationStats(
        completionTokens: n,
        promptTokens: promptTokens,
        timeToFirstToken: const Duration(milliseconds: 100),
        duration: Duration(milliseconds: 100 + 50 * (n - 1)),
        stoppedAtLimit: n == s.maxTokens,
      ),
    );
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('median', () {
    expect(median([3, null, 1, 2]), 2);
    expect(median([4, 1, 3, 2]), 2.5);
    expect(median(const <double?>[null]), isNull);
  });

  test('run speeds come from engine timings', () {
    const r = BenchmarkRun(
      promptTokens: 200,
      completionTokens: 11,
      timeToFirstToken: Duration(milliseconds: 500),
      total: Duration(milliseconds: 1500),
    );
    expect(r.promptTokensPerSecond, 400);
    expect(r.generationTokensPerSecond, 10);
  });

  test('cold load, warm-up, then measured runs with fixed settings', () async {
    final engine = FakeEngine(tokens: 200);
    var loads = 0;
    final phases = <(BenchmarkPhase, int)>[];
    var mem = 100;
    final runner = BenchmarkRunner(
      coldLoad: () async {
        loads++;
        mem = 500;
        return const Duration(milliseconds: 1234);
      },
      generate: engine.generate,
      cancelGeneration: () => engine.cancelled++,
      rss: () => mem,
      config: const BenchmarkConfig(runs: 3, maxTokens: 21, warmupTokens: 4),
    );
    engine.onCall = () => mem += 10;
    final r = await runner.run(onProgress: (p, i) => phases.add((p, i)));

    expect(loads, 1);
    expect(phases, [
      (BenchmarkPhase.loading, 0),
      (BenchmarkPhase.warmup, 0),
      (BenchmarkPhase.measuring, 1),
      (BenchmarkPhase.measuring, 2),
      (BenchmarkPhase.measuring, 3),
      (BenchmarkPhase.done, 3),
    ]);
    expect(engine.calls.map((c) => c.$2.maxTokens), [4, 21, 21, 21]);
    expect(engine.calls.every((c) => c.$2.temperature == 0), isTrue);
    // A different first line every run, so no prompt cache is reused.
    final systems = engine.calls.map((c) => c.$1.first.text).toSet();
    expect(systems, hasLength(4));
    expect(r.runs, hasLength(3), reason: 'warm-up is not counted');
    expect(r.loadTime, const Duration(milliseconds: 1234));
    expect(r.generationTokensPerSecond, closeTo(20, 0.001));
    expect(r.promptTokensPerSecond, closeTo(2000, 0.001));
    expect(r.timeToFirstToken, const Duration(milliseconds: 100));
    expect(r.completionTokens, 21);
    expect(r.rssAfterLoadBytes, 500);
    expect(r.rssPeakBytes, 540);
  });

  test('cancel stops the run and asks the engine to stop', () async {
    final engine = FakeEngine();
    late BenchmarkRunner runner;
    runner = BenchmarkRunner(
      coldLoad: () async => Duration.zero,
      generate: engine.generate,
      cancelGeneration: () => engine.cancelled++,
    );
    engine.onCall = () {
      if (engine.calls.length == 2) runner.cancel();
    };
    await expectLater(runner.run(), throwsA(isA<BenchmarkCancelled>()));
    expect(engine.cancelled, 1);
    expect(engine.calls, hasLength(2));
  });

  test('no output is an error, not a zero result', () async {
    final runner = BenchmarkRunner(
      coldLoad: () async => Duration.zero,
      generate: (_, _) => const Stream.empty(),
      cancelGeneration: () {},
    );
    await expectLater(runner.run(), throwsA(isA<BenchmarkException>()));
  });

  test('records are stored newest first and copy as text', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = BenchmarkRepository(db);
    BenchmarkResultsCompanion row(String name, DateTime at) =>
        BenchmarkResultsCompanion.insert(
          id: '',
          modelId: 'm',
          modelName: name,
          createdAt: at,
          contextSize: 2048,
          runs: 3,
          loadMs: 900,
          promptTokens: 120,
          completionTokens: 128,
          generationTokensPerSecond: const Value(12.34),
          generationMin: const Value(11.0),
          generationMax: const Value(13.0),
          rssPeakBytes: const Value(600 << 20),
          device: 'Pixel · Android API 34',
        );
    await repo.add(row('Old', DateTime(2026, 1, 1)));
    final saved = await repo.add(row('New', DateTime(2026, 2, 1)));
    expect(saved.id, isNotEmpty);
    final all = await repo.watchAll().first;
    expect(all.map((b) => b.modelName), ['New', 'Old']);

    final text = benchmarkAsText(saved);
    expect(text, contains('Generation: 12.3 tok/s'));
    expect(text, contains('Prompt processing: n/a'));
    expect(text, contains('App memory peak: 600 MB'));

    await repo.delete(saved.id);
    expect(await repo.watchAll().first, hasLength(1));
    await repo.deleteAll();
    expect(await repo.watchAll().first, isEmpty);
  });
}
