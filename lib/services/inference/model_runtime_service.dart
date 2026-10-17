import 'dart:async';

import 'package:get/get.dart';

import '../../data/repositories/model_repository.dart';
import '../model_service.dart';
import '../settings_service.dart';
import 'inference_runtime.dart';

enum RuntimeStatus { idle, loading, ready, generating, error }

class LoadFailure implements Exception {
  const LoadFailure(this.reason, [this.detail]);

  final String reason; // translation key
  final String? detail;
}

/// Owns the single loaded model. Loading another model unloads this one first.
class ModelRuntimeService extends GetxService {
  ModelRuntimeService(this._runtime, this._models, this._repo, this._settings);

  final InferenceRuntime _runtime;
  final ModelService _models;
  final ModelRepository _repo;
  final SettingsService _settings;

  final status = RuntimeStatus.idle.obs;
  final loadedModelId = RxnString();
  final lastError = RxnString();
  final lastLoadDuration = Rxn<Duration>();
  int _loadedContext = 0;
  Future<void>? _pendingLoad;

  int get loadedContextSize => _loadedContext;

  Future<void> ensureLoaded(String modelId) async {
    final ctx = _settings.effectiveContextSize;
    if (loadedModelId.value == modelId &&
        _runtime.isLoaded &&
        _loadedContext == ctx) {
      return;
    }
    while (_pendingLoad != null) {
      await _pendingLoad;
    }
    if (loadedModelId.value == modelId &&
        _runtime.isLoaded &&
        _loadedContext == ctx) {
      return;
    }
    final completer = Completer<void>();
    _pendingLoad = completer.future;
    try {
      await _load(modelId, ctx);
      completer.complete();
    } catch (e) {
      completer.complete();
      rethrow;
    } finally {
      _pendingLoad = null;
    }
  }

  Future<void> _load(String modelId, int contextSize) async {
    final model = _models.installedById(modelId);
    if (model == null) throw const LoadFailure('error_model_not_installed');
    final block = await _models.checkLoadable(model);
    if (block != LoadBlock.none) {
      throw LoadFailure('error_model_${block.name}');
    }
    status.value = RuntimeStatus.loading;
    lastError.value = null;
    await unload();
    status.value = RuntimeStatus.loading;
    final watch = Stopwatch()..start();
    try {
      await _runtime.load(
        model.filePath,
        RuntimeLoadConfig(contextSize: contextSize),
      );
      watch.stop();
      loadedModelId.value = modelId;
      _loadedContext = contextSize;
      lastLoadDuration.value = watch.elapsed;
      status.value = RuntimeStatus.ready;
      await _repo.recordLoad(modelId, loadMs: watch.elapsedMilliseconds);
      await _repo.markUsed(modelId);
    } on InferenceException catch (e) {
      status.value = RuntimeStatus.error;
      lastError.value = e.message;
      await _repo.recordLoad(modelId, error: e.message);
      throw LoadFailure(
        e.outOfMemory ? 'error_out_of_memory' : 'error_load_failed',
        e.message,
      );
    }
  }

  Future<void> unload() async {
    _runtime.cancel();
    await _runtime.unload();
    loadedModelId.value = null;
    _loadedContext = 0;
    if (status.value != RuntimeStatus.error) status.value = RuntimeStatus.idle;
  }

  Stream<GenerationEvent> generate(List<ChatTurn> turns) async* {
    if (!_runtime.isLoaded) throw const LoadFailure('error_no_model_loaded');
    status.value = RuntimeStatus.generating;
    try {
      yield* _runtime.generate(turns, _settings.generation);
    } finally {
      if (status.value == RuntimeStatus.generating) {
        status.value = _runtime.isLoaded
            ? RuntimeStatus.ready
            : RuntimeStatus.idle;
      }
    }
  }

  void cancel() => _runtime.cancel();

  Future<int?> countTokens(String text) => _runtime.countTokens(text);

  @override
  void onClose() {
    _runtime.dispose();
    super.onClose();
  }
}
