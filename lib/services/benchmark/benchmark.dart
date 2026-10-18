import 'dart:async';

import '../inference/inference_runtime.dart';

/// Fixed workload so results are comparable between models and devices.
/// Greedy decoding and a prompt that asks for long output, so every run
/// should produce [maxTokens] tokens.
class BenchmarkConfig {
  const BenchmarkConfig({
    this.runs = 3,
    this.maxTokens = 128,
    this.warmupTokens = 8,
  });

  final int runs;
  final int maxTokens;
  final int warmupTokens;

  static const settingsTemperature = 0.0;

  /// Each run gets a different first line so the engine cannot reuse the
  /// previous run's prompt cache and make prompt processing look faster.
  List<ChatTurn> turns(int run) => [
    ChatTurn(
      ChatRole.system,
      'Benchmark run $run. You are a helpful assistant that writes clear, '
      'detailed English prose.',
    ),
    const ChatTurn(ChatRole.user, benchmarkPrompt),
  ];

  GenerationSettings settings(int maxTokens) => GenerationSettings(
    temperature: settingsTemperature,
    topP: 1,
    maxTokens: maxTokens,
  );
}

const benchmarkPrompt =
    'Write a long, detailed story of at least 400 words about a lighthouse '
    'keeper on a small island who finds an old map inside a glass bottle. '
    'Describe the island, the weather, the keeper\'s daily routine, the map, '
    'and the journey the keeper decides to take. Use full paragraphs and do '
    'not use lists or headings. Begin the story now and keep writing until '
    'the story is complete.';

/// One measured generation.
class BenchmarkRun {
  const BenchmarkRun({
    required this.promptTokens,
    required this.completionTokens,
    required this.timeToFirstToken,
    required this.total,
  });

  final int promptTokens;
  final int completionTokens;

  /// Prompt processing plus the first token.
  final Duration timeToFirstToken;
  final Duration total;

  /// Approximate: time to first token also includes one decode step.
  double? get promptTokensPerSecond => timeToFirstToken.inMicroseconds <= 0
      ? null
      : promptTokens / (timeToFirstToken.inMicroseconds / 1e6);

  double? get generationTokensPerSecond {
    final decode = total - timeToFirstToken;
    if (completionTokens <= 1 || decode.inMicroseconds <= 0) return null;
    return (completionTokens - 1) / (decode.inMicroseconds / 1e6);
  }
}

class BenchmarkResult {
  const BenchmarkResult({
    required this.loadTime,
    required this.runs,
    required this.rssAfterLoadBytes,
    required this.rssPeakBytes,
  });

  final Duration loadTime;
  final List<BenchmarkRun> runs;
  final int? rssAfterLoadBytes;
  final int? rssPeakBytes;

  double? get promptTokensPerSecond =>
      median(runs.map((r) => r.promptTokensPerSecond));
  double? get generationTokensPerSecond =>
      median(runs.map((r) => r.generationTokensPerSecond));
  double? get generationMin => _bound(true);
  double? get generationMax => _bound(false);
  Duration? get timeToFirstToken {
    final ms = median(
      runs.map((r) => r.timeToFirstToken.inMicroseconds.toDouble()),
    );
    return ms == null ? null : Duration(microseconds: ms.round());
  }

  int get promptTokens => runs.isEmpty ? 0 : runs.first.promptTokens;
  int get completionTokens =>
      median(runs.map((r) => r.completionTokens.toDouble()))?.round() ?? 0;

  double? _bound(bool min) {
    final v = runs.map((r) => r.generationTokensPerSecond).nonNulls.toList();
    if (v.isEmpty) return null;
    return v.reduce((a, b) => (min ? a < b : a > b) ? a : b);
  }
}

/// Median of the non-null values, or null if there are none.
double? median(Iterable<double?> values) {
  final v = values.nonNulls.toList()..sort();
  if (v.isEmpty) return null;
  final mid = v.length ~/ 2;
  return v.length.isOdd ? v[mid] : (v[mid - 1] + v[mid]) / 2;
}

enum BenchmarkPhase { loading, warmup, measuring, done }

class BenchmarkCancelled implements Exception {
  const BenchmarkCancelled();
}

class BenchmarkException implements Exception {
  const BenchmarkException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Runs the benchmark against an engine through plain callbacks, so it can
/// be tested without native code.
class BenchmarkRunner {
  BenchmarkRunner({
    required this.coldLoad,
    required this.generate,
    required this.cancelGeneration,
    this.rss,
    this.config = const BenchmarkConfig(),
    Stopwatch Function()? stopwatch,
  }) : _stopwatch = stopwatch ?? Stopwatch.new;

  /// Unloads and loads the model again; returns how long the load took.
  final Future<Duration> Function() coldLoad;
  final Stream<GenerationEvent> Function(
    List<ChatTurn> turns,
    GenerationSettings settings,
  )
  generate;
  final void Function() cancelGeneration;

  /// Resident memory of the app process, if available.
  final int? Function()? rss;
  final BenchmarkConfig config;
  final Stopwatch Function() _stopwatch;

  bool _cancelled = false;

  void cancel() {
    _cancelled = true;
    cancelGeneration();
  }

  Future<BenchmarkResult> run({
    void Function(BenchmarkPhase phase, int run)? onProgress,
  }) async {
    int? peak;
    void sample() {
      final v = rss?.call();
      if (v != null && (peak == null || v > peak!)) peak = v;
    }

    onProgress?.call(BenchmarkPhase.loading, 0);
    final load = await coldLoad();
    _check();
    sample();
    final afterLoad = rss?.call();

    onProgress?.call(BenchmarkPhase.warmup, 0);
    await _generateOnce(0, config.warmupTokens, sample);

    final runs = <BenchmarkRun>[];
    for (var i = 1; i <= config.runs; i++) {
      onProgress?.call(BenchmarkPhase.measuring, i);
      runs.add(await _generateOnce(i, config.maxTokens, sample));
    }
    onProgress?.call(BenchmarkPhase.done, config.runs);
    return BenchmarkResult(
      loadTime: load,
      runs: runs,
      rssAfterLoadBytes: afterLoad,
      rssPeakBytes: peak,
    );
  }

  Future<BenchmarkRun> _generateOnce(
    int run,
    int maxTokens,
    void Function() sample,
  ) async {
    _check();
    final watch = _stopwatch()..start();
    Duration? first;
    GenerationStats? stats;
    var pieces = 0;
    await for (final e in generate(
      config.turns(run),
      config.settings(maxTokens),
    )) {
      switch (e) {
        case TokenEvent(:final text):
          if (text.isNotEmpty) {
            first ??= watch.elapsed;
            pieces++;
            if (pieces % 16 == 0) sample();
          }
        case DoneEvent(stats: final s):
          stats = s;
      }
    }
    watch.stop();
    sample();
    _check();
    if (stats == null && pieces == 0) {
      throw const BenchmarkException('The model produced no output.');
    }
    return BenchmarkRun(
      promptTokens: stats?.promptTokens ?? 0,
      completionTokens: stats?.completionTokens ?? pieces,
      // Prefer the engine's own timing; fall back to what we observed.
      timeToFirstToken: stats?.timeToFirstToken ?? first ?? watch.elapsed,
      total: stats?.duration ?? watch.elapsed,
    );
  }

  void _check() {
    if (_cancelled) throw const BenchmarkCancelled();
  }
}
