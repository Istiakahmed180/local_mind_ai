import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart' show Value;
import 'package:get/get.dart' hide Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/database.dart';
import '../../data/repositories/document_repository.dart';
import 'chunker.dart';
import 'embedding_service.dart';
import 'retrieval.dart';
import 'text_extraction.dart';
import 'vectors.dart';

/// Imports, indexes and searches the user's documents. Files are copied into
/// app-private storage and never leave the device.
class DocumentService extends GetxService {
  DocumentService(
    this._repo, {
    TextExtractor? extractor,
    Future<Directory> Function()? baseDir,
    Uuid? uuid,
  }) : _extractor = extractor ?? TextExtractor(),
       _baseDir = baseDir ?? getApplicationSupportDirectory,
       _uuid = uuid ?? const Uuid();

  static const maxFileBytes = 50 * 1024 * 1024;

  /// Below this many characters a PDF is treated as having no text layer.
  static const minTextChars = 20;

  final DocumentRepository _repo;
  final TextExtractor _extractor;
  final Future<Directory> Function() _baseDir;
  final Uuid _uuid;

  final busy = false.obs;

  /// OCR progress while importing a scanned PDF: (pages done, total).
  final ocrProgress = Rxn<(int, int)>();
  ExtractionCancel? _cancel;

  /// Turns on OCR for pages without a text layer.
  set ocr(PageOcr? value) => _extractor.ocr = value;

  bool get ocrReady => _extractor.ocr?.ready ?? false;

  /// Stops an import that is reading pages with OCR.
  void cancelImport() => _cancel?.cancel();

  /// Meaning search, set once the embedding service exists. Null or not
  /// ready means keyword search only.
  EmbeddingService? semantic;

  Stream<List<Document>> watchAll() => _repo.watchAll();

  Future<int> documentCount() async => (await _repo.all()).length;

  bool get usesFts5 => _repo.usesFts5;

  Future<Directory> _docsDir() async {
    final dir = Directory(p.join((await _baseDir()).path, 'documents'));
    await dir.create(recursive: true);
    return dir;
  }

  /// Copies [sourcePath] into app storage and indexes it. Throws
  /// [ExtractionException] with a translation key when the file is unusable;
  /// nothing is kept in that case.
  Future<Document> import(String sourcePath, String name) async {
    final kind = kindForFileName(name);
    if (kind == null) throw const ExtractionException('doc_error_type');
    final source = File(sourcePath);
    final size = await source.length();
    if (size > maxFileBytes) {
      throw const ExtractionException('doc_error_too_large');
    }
    final id = _uuid.v4();
    final target = p.join((await _docsDir()).path, '$id.${kind.name}');
    await source.copy(target);
    try {
      final indexed = await _index(target, kind);
      final now = DateTime.now();
      await _repo.insert(
        DocumentsCompanion.insert(
          id: id,
          name: name,
          kind: kind.name,
          filePath: target,
          sizeBytes: size,
          pageCount: Value(indexed.pageCount),
          chunkCount: Value(indexed.chunks.length),
          charCount: Value(indexed.charCount),
          status: 'ready',
          importedAt: now,
          indexedAt: Value(now),
          ocrPages: Value(indexed.ocrPages == 0 ? null : indexed.ocrPages),
        ),
      );
      await _repo.replaceChunks(id, indexed.chunks);
      _indexMeaningInBackground();
      return (await _repo.byId(id))!;
    } catch (_) {
      await _deleteFile(target);
      await _repo.delete(id);
      rethrow;
    }
  }

  Future<_Indexed> _index(String path, DocumentKind kind) async {
    final cancel = _cancel = ExtractionCancel();
    final ExtractionResult extracted;
    try {
      extracted = await _extractor.extract(
        path,
        kind,
        cancel: cancel,
        onOcrProgress: (done, total) => ocrProgress.value = (done, total),
      );
    } finally {
      ocrProgress.value = null;
      _cancel = null;
    }
    if (kind == DocumentKind.pdf && extracted.charCount < minTextChars) {
      throw ExtractionException(
        ocrReady ? 'doc_error_ocr_no_text' : 'doc_error_no_text_pdf',
      );
    }
    if (extracted.charCount == 0) {
      throw const ExtractionException('doc_error_empty');
    }
    final segments = extracted.segments;
    final chunks = await _chunkInIsolate(segments);
    return _Indexed(
      chunks,
      extracted.pageCount,
      extracted.charCount,
      extracted.ocrPages,
    );
  }

  Future<void> remove(String id) async {
    final doc = await _repo.byId(id);
    if (doc == null) return;
    await _repo.delete(id);
    await _deleteFile(doc.filePath);
  }

  Future<void> removeAll() async {
    for (final d in await _repo.all()) {
      await remove(d.id);
    }
    final dir = await _docsDir();
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// Re-extracts and re-chunks every stored copy, then rebuilds the keyword
  /// index. Returns the number of documents that failed.
  Future<int> rebuildIndex() async {
    var failed = 0;
    for (final d in await _repo.all()) {
      final kind = DocumentKind.values.byName(d.kind);
      try {
        final indexed = await _index(d.filePath, kind);
        await _repo.replaceChunks(d.id, indexed.chunks);
        await _repo.update(
          d.id,
          DocumentsCompanion(
            status: const Value('ready'),
            error: const Value(null),
            pageCount: Value(indexed.pageCount),
            chunkCount: Value(indexed.chunks.length),
            charCount: Value(indexed.charCount),
            indexedAt: Value(DateTime.now()),
            ocrPages: Value(indexed.ocrPages == 0 ? null : indexed.ocrPages),
          ),
        );
      } on Object catch (e) {
        failed++;
        await _repo.replaceChunks(d.id, const []);
        await _repo.update(
          d.id,
          DocumentsCompanion(
            status: const Value('error'),
            error: Value(e is ExtractionException ? e.reason : '$e'),
            chunkCount: const Value(0),
          ),
        );
      }
    }
    await _repo.rebuildKeywordIndex();
    _indexMeaningInBackground();
    return failed;
  }

  void _indexMeaningInBackground() {
    final s = semantic;
    if (s != null && s.ready) unawaited(s.indexMissing());
  }

  /// Keyword search, fused with meaning search when a search model is set
  /// up. If meaning search fails, keyword results are returned alone.
  Future<List<RetrievedPassage>> search(
    String query, {
    int limit = 5,
    Set<String>? documentIds,
    bool keepChatModel = false,
  }) async {
    final s = semantic;
    // A large embedding model would unload the chat model mid-run (agent),
    // so callers that still need it fall back to keyword search.
    if (s == null || !s.ready || (keepChatModel && s.unloadsChatModel)) {
      return _repo.search(query, limit: limit, documentIds: documentIds);
    }
    final keyword = await _repo.search(
      query,
      limit: limit * 3,
      documentIds: documentIds,
    );
    try {
      final meaning = await s.search(
        query,
        k: limit * 3,
        documentIds: documentIds,
      );
      return fuseRankings(keyword, meaning, limit: limit);
    } on Object {
      return keyword.take(limit).toList();
    }
  }

  /// Similarity threshold for evidence, when meaning search is active.
  double? get minSimilarity =>
      semantic != null && semantic!.ready ? semantic!.minSimilarity : null;

  Future<void> _deleteFile(String path) async {
    final f = File(path);
    if (await f.exists()) await f.delete();
  }
}

class _Indexed {
  const _Indexed(this.chunks, this.pageCount, this.charCount, this.ocrPages);

  final List<TextChunk> chunks;
  final int? pageCount;
  final int charCount;
  final int ocrPages;
}

/// Top level so the isolate closure captures only [segments], not the
/// service (which holds Futures and cannot be sent to another isolate).
Future<List<TextChunk>> _chunkInIsolate(List<SourceSegment> segments) =>
    Isolate.run(() => chunkSegments(segments));
