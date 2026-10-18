import 'package:llamadart/llamadart.dart';

import 'inference_runtime.dart';

/// llama.cpp through llamadart. Inference runs in llamadart's worker isolate,
/// so the UI thread is not blocked.
class LlamadartRuntime implements InferenceRuntime {
  LlamaEngine? _engine;

  @override
  bool get isLoaded => _engine?.isReady ?? false;

  @override
  Future<void> load(String path, RuntimeLoadConfig config) async {
    await unload();
    try {
      _engine = await LlamaEngine.load(
        LlamaModel(ModelSource.path(path, format: ModelFormat.gguf)),
        params: ModelParams(
          contextSize: config.contextSize,
          // CPU only until GPU paths are validated on real devices.
          device: ComputeDevice.cpu,
          gpuLayers: 0,
          numberOfThreads: config.threads,
          numberOfThreadsBatch: config.threads,
        ),
      );
    } on LlamaException catch (e) {
      _engine = null;
      throw InferenceException(
        e.message,
        outOfMemory: _looksLikeOom(e.toString()),
      );
    }
  }

  @override
  Future<void> unload() async {
    final engine = _engine;
    _engine = null;
    if (engine != null) await engine.dispose();
  }

  @override
  Stream<GenerationEvent> generate(
    List<ChatTurn> turns,
    GenerationSettings settings, {
    Map<String, Object?>? jsonSchema,
  }) async* {
    final engine = _engine;
    if (engine == null || !engine.isReady) {
      throw const InferenceException('No model is loaded.');
    }
    final messages = [
      for (final t in turns)
        LlamaChatMessage.fromText(role: _role(t.role), text: t.text),
    ];
    LlamaGenerationUsage? usage;
    String? finishReason;
    try {
      await for (final chunk in engine.create(
        messages,
        params: GenerationParams(
          maxTokens: settings.maxTokens,
          temp: settings.temperature,
          topP: settings.topP,
        ),
        enableThinking: false,
        responseFormat: jsonSchema == null
            ? null
            : {
                'type': 'json_schema',
                'json_schema': {'schema': jsonSchema},
              },
      )) {
        final text = chunk.text;
        if (text.isNotEmpty) yield TokenEvent(text);
        usage = chunk.usage ?? usage;
        finishReason = chunk.choices.firstOrNull?.finishReason ?? finishReason;
      }
    } on LlamaException catch (e) {
      throw InferenceException(
        e.message,
        outOfMemory: _looksLikeOom(e.toString()),
      );
    }
    final u = usage;
    yield DoneEvent(
      u == null
          ? null
          : GenerationStats(
              completionTokens: u.completionTokens,
              promptTokens: u.promptTokens,
              timeToFirstToken: u.timeToFirstToken,
              duration: u.duration,
              stoppedAtLimit: finishReason == 'length',
            ),
    );
  }

  @override
  void cancel() => _engine?.cancelGeneration();

  @override
  Future<int?> countTokens(String text) async {
    final engine = _engine;
    if (engine == null || !engine.isReady) return null;
    return engine.getTokenCount(text);
  }

  @override
  Future<void> dispose() => unload();

  static LlamaChatRole _role(ChatRole role) => switch (role) {
    ChatRole.system => LlamaChatRole.system,
    ChatRole.user => LlamaChatRole.user,
    ChatRole.assistant => LlamaChatRole.assistant,
  };

  static bool _looksLikeOom(String message) {
    final m = message.toLowerCase();
    return m.contains('out of memory') ||
        m.contains('failed to allocate') ||
        m.contains('bad_alloc');
  }
}
