import 'package:drift/drift.dart';

import '../../services/documents/chunker.dart';
import '../../services/documents/retrieval.dart';
import '../local/database.dart';

class DocumentRepository {
  DocumentRepository(this._db);

  final AppDatabase _db;

  bool get usesFts5 => _db.hasFts5;

  Stream<List<Document>> watchAll() => (_db.select(
    _db.documents,
  )..orderBy([(d) => OrderingTerm.desc(d.importedAt)])).watch();

  Future<List<Document>> all() => _db.select(_db.documents).get();

  Future<Document?> byId(String id) => (_db.select(
    _db.documents,
  )..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<void> insert(DocumentsCompanion row) =>
      _db.into(_db.documents).insert(row);

  Future<void> update(String id, DocumentsCompanion row) =>
      (_db.update(_db.documents)..where((d) => d.id.equals(id))).write(row);

  Future<void> delete(String id) =>
      (_db.delete(_db.documents)..where((d) => d.id.equals(id))).go();

  /// Replaces the document's chunks; FTS rows follow through triggers.
  Future<void> replaceChunks(String documentId, List<TextChunk> chunks) =>
      _db.transaction(() async {
        await (_db.delete(
          _db.documentChunks,
        )..where((c) => c.documentId.equals(documentId))).go();
        await _db.batch((b) {
          b.insertAll(_db.documentChunks, [
            for (final c in chunks)
              DocumentChunksCompanion.insert(
                documentId: documentId,
                ordinal: c.ordinal,
                page: Value(c.page),
                lineStart: Value(c.lineStart),
                lineEnd: Value(c.lineEnd),
                body: c.text,
              ),
          ]);
        });
      });

  Future<int> chunkCount() async {
    final count = _db.documentChunks.id.count();
    final row = await (_db.selectOnly(
      _db.documentChunks,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> rebuildKeywordIndex() => _db.rebuildFts();

  /// Ranked passages for [query]. FTS5 narrows the candidates when available,
  /// otherwise LIKE does; both paths are ranked by [rankPassages].
  Future<List<RetrievedPassage>> search(
    String query, {
    int limit = 5,
    int candidateLimit = 200,
    Set<String>? documentIds,
    bool forceLike = false,
  }) async {
    final terms = queryTerms(query);
    if (terms.isEmpty) return const [];
    List<RetrievedPassage>? candidates;
    if (_db.hasFts5 && !forceLike) {
      try {
        candidates = await _ftsCandidates(terms, candidateLimit, documentIds);
      } on Object {
        candidates = null;
      }
    }
    candidates ??= await _likeCandidates(terms, candidateLimit, documentIds);
    return rankPassages(
      candidates,
      terms,
      totalChunks: await chunkCount(),
      limit: limit,
    );
  }

  static const _columns =
      'c.id, c.document_id, c.page, c.line_start, c.line_end, c.body, '
      'd.name';

  String _docFilter(Set<String>? ids, List<Variable> vars) {
    if (ids == null) return '';
    vars.addAll(ids.map(Variable.withString));
    return ' AND c.document_id IN (${List.filled(ids.length, '?').join(',')})';
  }

  Future<List<RetrievedPassage>> _ftsCandidates(
    List<String> terms,
    int limit,
    Set<String>? ids,
  ) async {
    final vars = <Variable>[Variable.withString(ftsMatchExpression(terms))];
    final filter = _docFilter(ids, vars);
    vars.add(Variable.withInt(limit));
    final rows = await _db
        .customSelect(
          'SELECT $_columns FROM document_chunks_fts f '
          'JOIN document_chunks c ON c.id = f.rowid '
          'JOIN documents d ON d.id = c.document_id '
          'WHERE document_chunks_fts MATCH ?$filter '
          'ORDER BY bm25(document_chunks_fts) LIMIT ?',
          variables: vars,
          readsFrom: {_db.documentChunks, _db.documents},
        )
        .get();
    return rows.map(_toPassage).toList();
  }

  Future<List<RetrievedPassage>> _likeCandidates(
    List<String> terms,
    int limit,
    Set<String>? ids,
  ) async {
    final vars = <Variable>[
      for (final t in terms) Variable.withString('%${_escapeLike(searchPrefix(t))}%'),
    ];
    final like = terms.map((_) => r"c.body LIKE ? ESCAPE '\'").join(' OR ');
    final filter = _docFilter(ids, vars);
    vars.add(Variable.withInt(limit));
    final rows = await _db
        .customSelect(
          'SELECT $_columns FROM document_chunks c '
          'JOIN documents d ON d.id = c.document_id '
          'WHERE ($like)$filter ORDER BY c.id LIMIT ?',
          variables: vars,
          readsFrom: {_db.documentChunks, _db.documents},
        )
        .get();
    return rows.map(_toPassage).toList();
  }

  // ---- Embeddings ----

  /// Chunks that have no vector from [modelId] yet, oldest first.
  Future<List<(int id, String body)>> chunksMissingEmbedding(
    String modelId, {
    int limit = 32,
  }) async {
    final rows = await _db
        .customSelect(
          'SELECT c.id, c.body FROM document_chunks c '
          'LEFT JOIN chunk_embeddings e ON e.chunk_id = c.id AND e.model_id = ? '
          'WHERE e.chunk_id IS NULL ORDER BY c.id LIMIT ?',
          variables: [Variable.withString(modelId), Variable.withInt(limit)],
          readsFrom: {_db.documentChunks, _db.chunkEmbeddings},
        )
        .get();
    return [for (final r in rows) (r.read<int>('id'), r.read<String>('body'))];
  }

  Future<void> saveEmbeddings(
    String modelId,
    List<(int chunkId, Uint8List vector)> vectors,
  ) => _db.batch((b) {
    for (final (id, v) in vectors) {
      b.insert(
        _db.chunkEmbeddings,
        ChunkEmbeddingsCompanion.insert(
          chunkId: id,
          modelId: modelId,
          vector: v,
        ),
        mode: InsertMode.insertOrReplace,
      );
    }
  });

  Future<int> embeddedCount(String modelId) async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM chunk_embeddings WHERE model_id = ?',
          variables: [Variable.withString(modelId)],
          readsFrom: {_db.chunkEmbeddings},
        )
        .getSingle();
    return row.read<int>('n');
  }

  /// Vectors from [modelId], optionally only for [documentIds].
  Future<List<(int chunkId, Uint8List vector)>> embeddings(
    String modelId, {
    Set<String>? documentIds,
  }) async {
    final vars = <Variable>[Variable.withString(modelId)];
    final filter = _docFilter(documentIds, vars);
    final rows = await _db
        .customSelect(
          'SELECT e.chunk_id, e.vector FROM chunk_embeddings e '
          'JOIN document_chunks c ON c.id = e.chunk_id '
          'WHERE e.model_id = ?$filter',
          variables: vars,
          readsFrom: {_db.chunkEmbeddings, _db.documentChunks},
        )
        .get();
    return [
      for (final r in rows)
        (r.read<int>('chunk_id'), r.read<Uint8List>('vector')),
    ];
  }

  /// Removes vectors made by other models, e.g. after switching models.
  Future<void> deleteEmbeddingsExcept(String? modelId) =>
      (_db.delete(_db.chunkEmbeddings)..where(
            (e) => modelId == null
                ? const Constant(true)
                : e.modelId.equals(modelId).not(),
          ))
          .go();

  Future<List<RetrievedPassage>> passagesByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await _db
        .customSelect(
          'SELECT $_columns FROM document_chunks c '
          'JOIN documents d ON d.id = c.document_id '
          'WHERE c.id IN (${List.filled(ids.length, '?').join(',')})',
          variables: ids.map(Variable.withInt).toList(),
          readsFrom: {_db.documentChunks, _db.documents},
        )
        .get();
    final byId = {for (final r in rows) r.read<int>('id'): _toPassage(r)};
    return [for (final id in ids) ?byId[id]];
  }

  static RetrievedPassage _toPassage(QueryRow r) => RetrievedPassage(
    chunkId: r.read<int>('id'),
    documentId: r.read<String>('document_id'),
    documentName: r.read<String>('name'),
    text: r.read<String>('body'),
    page: r.readNullable<int>('page'),
    lineStart: r.readNullable<int>('line_start'),
    lineEnd: r.readNullable<int>('line_end'),
  );

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
