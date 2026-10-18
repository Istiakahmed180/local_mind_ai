import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:localmind_ai/services/inference/inference_runtime.dart';

/// Test double for unit tests only. The app always uses LlamadartRuntime.
class FakeRuntime implements InferenceRuntime {
  FakeRuntime({
    this.tokens = const ['Hello', ' world'],
    this.loadError,
    List<String>? responses,
    this.respond,
    this.gpuError,
    this.gpuRespond,
  }) : responses = responses ?? [];

  /// Thrown by a GPU load (e.g. no Vulkan device).
  final InferenceException? gpuError;

  /// Reply while loaded on the GPU; defaults to the normal reply.
  final String Function(List<ChatTurn> turns)? gpuRespond;

  /// Load configs in order.
  final configs = <RuntimeLoadConfig>[];
  bool _onGpu = false;

  @override
  String? get backendName =>
      _loaded == null ? null : (_onGpu ? 'Vulkan' : 'CPU');

  /// Computes the whole reply from the prompt; takes priority over
  /// [responses] and [tokens].
  final String Function(List<ChatTurn> turns)? respond;

  final List<String> tokens;

  /// Scripted outputs, one per generate() call, consumed in order. When empty,
  /// [tokens] is streamed instead.
  final List<String> responses;
  final schemas = <Map<String, Object?>?>[];
  int generateCalls = 0;
  final InferenceException? loadError;
  final loads = <String>[];
  int unloads = 0;
  String? _loaded;
  bool _cancel = false;
  List<ChatTurn>? lastTurns;

  /// Prompts of every generate() call, in order.
  final calls = <List<ChatTurn>>[];

  @override
  bool get isLoaded => _loaded != null;

  @override
  Future<void> load(String path, RuntimeLoadConfig config) async {
    if (loadError != null) throw loadError!;
    if (config.gpu && gpuError != null) throw gpuError!;
    configs.add(config);
    _onGpu = config.gpu;
    loads.add(path);
    _loaded = path;
  }

  @override
  Future<void> unload() async {
    if (_loaded != null) unloads++;
    _loaded = null;
  }

  @override
  Stream<GenerationEvent> generate(
    List<ChatTurn> turns,
    GenerationSettings settings, {
    Map<String, Object?>? jsonSchema,
  }) async* {
    lastTurns = turns;
    calls.add(turns);
    schemas.add(jsonSchema);
    generateCalls++;
    _cancel = false;
    var n = 0;
    final out = _onGpu && gpuRespond != null
        ? [gpuRespond!(turns)]
        : respond != null
        ? [respond!(turns)]
        : responses.isNotEmpty
        ? [responses.removeAt(0)]
        : tokens;
    for (final t in out) {
      await Future<void>.delayed(Duration.zero);
      if (_cancel) break;
      n++;
      yield TokenEvent(t);
    }
    yield DoneEvent(
      GenerationStats(
        completionTokens: n,
        promptTokens: 10,
        timeToFirstToken: const Duration(milliseconds: 100),
        duration: const Duration(milliseconds: 1100),
        stoppedAtLimit: false,
      ),
    );
  }

  @override
  void cancel() => _cancel = true;

  @override
  Future<int?> countTokens(String text) async => text.length;

  @override
  Future<void> dispose() => unload();
}

/// Writes a file with a valid GGUF v3 header, padded to [size] bytes.
Future<File> writeFakeGguf(String path, {int size = 17 * 1024 * 1024}) async {
  final bytes = Uint8List(size);
  bytes.setAll(0, [0x47, 0x47, 0x55, 0x46, 3, 0, 0, 0]);
  final f = File(path);
  await f.writeAsBytes(bytes, flush: true);
  return f;
}
