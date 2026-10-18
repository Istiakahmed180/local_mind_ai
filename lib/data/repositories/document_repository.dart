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
      for (final t in terms) Variable.withString('%${_escapeLike(t)}%'),
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
