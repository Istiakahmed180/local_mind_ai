import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:localmind_ai/services/inference/inference_runtime.dart';

/// Test double for unit tests only. The app always uses LlamadartRuntime.
class FakeRuntime implements InferenceRuntime {
  FakeRuntime({this.tokens = const ['Hello', ' world'], this.loadError});

  final List<String> tokens;
  final InferenceException? loadError;
  final loads = <String>[];
  int unloads = 0;
  String? _loaded;
  bool _cancel = false;
  List<ChatTurn>? lastTurns;

  @override
  bool get isLoaded => _loaded != null;

  @override
  Future<void> load(String path, RuntimeLoadConfig config) async {
    if (loadError != null) throw loadError!;
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
    GenerationSettings settings,
  ) async* {
    lastTurns = turns;
    _cancel = false;
    var n = 0;
    for (final t in tokens) {
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
