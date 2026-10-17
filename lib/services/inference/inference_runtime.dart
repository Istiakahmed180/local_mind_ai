enum ChatRole { system, user, assistant }

class ChatTurn {
  const ChatTurn(this.role, this.text);

  final ChatRole role;
  final String text;
}

class RuntimeLoadConfig {
  const RuntimeLoadConfig({required this.contextSize, this.threads = 0});

  final int contextSize;

  /// 0 lets the runtime choose.
  final int threads;
}

class GenerationSettings {
  const GenerationSettings({
    this.temperature = 0.7,
    this.topP = 0.9,
    this.maxTokens = 512,
  });

  final double temperature;
  final double topP;
  final int maxTokens;
}

/// Measured numbers for one generation. Null means the runtime did not report it.
class GenerationStats {
  const GenerationStats({
    required this.completionTokens,
    required this.promptTokens,
    required this.timeToFirstToken,
    required this.duration,
    required this.stoppedAtLimit,
  });

  final int completionTokens;
  final int promptTokens;
  final Duration? timeToFirstToken;
  final Duration? duration;
  final bool stoppedAtLimit;

  double? get tokensPerSecond {
    final d = duration;
    final ttft = timeToFirstToken;
    if (d == null || completionTokens <= 1) return null;
    final decode = ttft == null ? d : d - ttft;
    if (decode.inMicroseconds <= 0) return null;
    return (completionTokens - 1) / (decode.inMicroseconds / 1e6);
  }
}

sealed class GenerationEvent {
  const GenerationEvent();
}

class TokenEvent extends GenerationEvent {
  const TokenEvent(this.text);
  final String text;
}

class DoneEvent extends GenerationEvent {
  const DoneEvent(this.stats);
  final GenerationStats? stats;
}

class InferenceException implements Exception {
  const InferenceException(this.message, {this.outOfMemory = false});

  final String message;
  final bool outOfMemory;

  @override
  String toString() => message;
}

/// The only boundary between the app and a native inference engine.
abstract interface class InferenceRuntime {
  bool get isLoaded;

  Future<void> load(String path, RuntimeLoadConfig config);

  Future<void> unload();

  Stream<GenerationEvent> generate(
    List<ChatTurn> turns,
    GenerationSettings settings,
  );

  void cancel();

  /// Exact token count if a model is loaded, otherwise null.
  Future<int?> countTokens(String text);

  Future<void> dispose();
}
