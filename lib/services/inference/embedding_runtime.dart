import 'package:llamadart/llamadart.dart';

import 'inference_runtime.dart';

/// Turns text into meaning vectors with a local embedding model.
abstract interface class EmbeddingRuntime {
  bool get isLoaded;

  Future<void> load(String path);

  /// One L2-normalized vector per text, in order.
  Future<List<List<double>>> embed(List<String> texts);

  Future<void> unload();
}

/// Longest text sent for embedding; passages are shorter than this already.
const maxEmbedChars = 2000;

/// llama.cpp embeddings through a second llamadart engine.
class LlamadartEmbeddingRuntime implements EmbeddingRuntime {
  LlamaEngine? _engine;

  @override
  bool get isLoaded => _engine?.isReady ?? false;

  @override
  Future<void> load(String path) async {
    await unload();
    try {
      _engine = await LlamaEngine.load(
        LlamaModel(ModelSource.path(path, format: ModelFormat.gguf)),
        params: const ModelParams(
          contextSize: 2048,
          // Encoder models embed a whole input in one pass, so the batch
          // sizes must cover the longest input.
          batchSize: 2048,
          microBatchSize: 2048,
          device: ComputeDevice.cpu,
          gpuLayers: 0,
        ),
      );
    } on LlamaException catch (e) {
      _engine = null;
      throw InferenceException(e.message);
    }
  }

  @override
  Future<List<List<double>>> embed(List<String> texts) async {
    final engine = _engine;
    if (engine == null || !engine.isReady) {
      throw const InferenceException('No embedding model is loaded.');
    }
    try {
      return await engine.embedBatch([
        for (final t in texts)
          t.length > maxEmbedChars ? t.substring(0, maxEmbedChars) : t,
      ]);
    } on LlamaException catch (e) {
      throw InferenceException(e.message);
    }
  }

  @override
  Future<void> unload() async {
    final engine = _engine;
    _engine = null;
    if (engine != null) await engine.dispose();
  }
}
