import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:get/get.dart';

import '../../data/repositories/document_repository.dart';
import '../../domain/model_definition.dart';
import '../inference/embedding_runtime.dart';
import '../inference/inference_runtime.dart';
import '../inference/model_runtime_service.dart';
import '../model_service.dart';
import '../settings_service.dart';
import 'retrieval.dart';
import 'vectors.dart';

/// Embedding models larger than this are not kept in memory next to a chat
/// model: the chat model is unloaded first and the embedding model is
/// released after use.
const largeEmbeddingModelBytes = 300 * 1024 * 1024;

/// Above this many vectors, similarity search runs in a background isolate.
const _isolateThreshold = 3000;

/// Meaning-based search over document passages with a local embedding model.
class EmbeddingService extends GetxService {
  EmbeddingService(
    this._repo,
    this._models,
    this._settings,
    this._chat,
    this._runtime,
  );

  final DocumentRepository _repo;
  final ModelService _models;
  final SettingsService _settings;
  final ModelRuntimeService _chat;
  final EmbeddingRuntime _runtime;

  final indexing = false.obs;
  final embedded = 0.obs;
  final total = 0.obs;
  final error = RxnString();

  String? _loadedId;
  bool _stop = false;
  Future<void>? _indexRun;
  Timer? _idle;
  Future<void> _lock = Future.value();

  /// The chosen embedding model if it is installed, otherwise null.
  ModelDefinition? get activeModel {
    final id = _settings.embeddingModelId.value;
    if (id == null) return null;
    final def = _models.catalog.value.byId(id);
    if (def == null || !def.isEmbedding) return null;
    return _models.installedById(id) == null ? null : def;
  }

  bool get ready => activeModel != null;

  /// Similarity at or above which a passage counts as evidence.
  double? get minSimilarity => activeModel?.minSimilarity;

  bool _isLarge(ModelDefinition def) =>
      def.sizeBytes > largeEmbeddingModelBytes;

  /// Whether a query would unload the chat model (large embedding model).
  bool get unloadsChatModel {
    final def = activeModel;
    return def != null && _isLarge(def);
  }

  Future<T> _serial<T>(Future<T> Function() action) {
    final next = _lock.then((_) => action());
    _lock = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<void> refreshCounts() async {
    final def = activeModel;
    total.value = await _repo.chunkCount();
    embedded.value = def == null ? 0 : await _repo.embeddedCount(def.id);
  }

  /// Switches the meaning-search model and drops vectors from other models.
  Future<void> selectModel(String? id) async {
    _stop = true;
    await _indexRun;
    await _serial(() async {
      await _release();
      await _settings.setEmbeddingModelId(id);
      await _repo.deleteEmbeddingsExcept(id);
    });
    await refreshCounts();
    if (ready) unawaited(indexMissing());
  }

  Future<void> _ensureLoaded(ModelDefinition def) async {
    _idle?.cancel();
    if (_loadedId == def.id && _runtime.isLoaded) return;
    await _release();
    // Never hold a large embedding model next to a chat model.
    if (_isLarge(def)) await _chat.unload();
    final installed = _models.installedById(def.id)!;
    await _runtime.load(installed.filePath);
    _loadedId = def.id;
  }

  Future<void> _release() async {
    _idle?.cancel();
    if (_runtime.isLoaded) await _runtime.unload();
    _loadedId = null;
  }

  /// Large models are released right away; small ones stay loaded for a
  /// while for follow-up questions.
  Future<void> _scheduleRelease(ModelDefinition def) async {
    _idle?.cancel();
    if (_isLarge(def)) {
      await _serial(_release);
    } else {
      _idle = Timer(const Duration(minutes: 2), () => _serial(_release));
    }
  }

  /// Embeds every passage that has no vector yet. Safe to call repeatedly:
  /// while a run is in progress, callers get that run.
  Future<void> indexMissing() {
    final running = _indexRun;
    if (running != null) return running;
    final def = activeModel;
    if (def == null) return Future.value();
    final run = _index(def).whenComplete(() => _indexRun = null);
    return _indexRun = run;
  }

  Future<void> _index(ModelDefinition def) async {
    indexing.value = true;
    error.value = null;
    _stop = false;
    try {
      await _serial(() async {
        await refreshCounts();
        await _ensureLoaded(def);
        while (!_stop) {
          final batch = await _repo.chunksMissingEmbedding(def.id, limit: 16);
          if (batch.isEmpty) break;
          final vectors = await _runtime.embed([
            for (final (_, body) in batch) '${def.documentPrefix}$body',
          ]);
          await _repo.saveEmbeddings(def.id, [
            for (var i = 0; i < batch.length; i++)
              (batch[i].$1, encodeVector(normalize(vectors[i]))),
          ]);
          embedded.value += batch.length;
        }
      });
    } on InferenceException catch (e) {
      error.value = e.message;
    } finally {
      indexing.value = false;
      await refreshCounts();
      await _scheduleRelease(def);
    }
  }

  void stopIndexing() => _stop = true;

  /// Passages closest in meaning to [query], best first, with similarity.
  Future<List<RetrievedPassage>> search(
    String query, {
    int k = 12,
    Set<String>? documentIds,
  }) async {
    final def = activeModel;
    if (def == null) return const [];
    final q = await _serial(() async {
      await _ensureLoaded(def);
      final v = await _runtime.embed(['${def.queryPrefix}$query']);
      return normalize(v.single);
    });
    await _scheduleRelease(def);
    final stored = await _repo.embeddings(def.id, documentIds: documentIds);
    if (stored.isEmpty) return const [];
    final top = stored.length > _isolateThreshold
        ? await Isolate.run(() => _rank(q, stored, k))
        : _rank(q, stored, k);
    final sims = {for (final (id, s) in top) id: s};
    final passages = await _repo.passagesByIds(top.map((t) => t.$1).toList());
    return [for (final p in passages) p.withSimilarity(sims[p.chunkId])];
  }

  @override
  void onClose() {
    _idle?.cancel();
    _runtime.unload();
    super.onClose();
  }
}

List<(int, double)> _rank(
  List<double> query,
  List<(int, Uint8List)> stored,
  int k,
) =>
    topSimilar(query, [for (final (id, b) in stored) (id, decodeVector(b))], k);
