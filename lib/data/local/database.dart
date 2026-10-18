import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get modelId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// AI-written summary of the oldest messages, used once the chat no longer
  /// fits the context window.
  TextColumn get summary => text().nullable()();

  /// Last message the summary covers. If that message is deleted the summary
  /// is discarded.
  TextColumn get summaryThroughMessageId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// `status`: complete, cancelled, error.
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId =>
      text().references(Conversations, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get status => text().withDefault(const Constant('complete'))();
  TextColumn get modelId => text().nullable()();
  IntColumn get completionTokens => integer().nullable()();
  IntColumn get timeToFirstTokenMs => integer().nullable()();
  RealColumn get tokensPerSecond => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// `source`: catalog or import.
class InstalledModels extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get source => text()();
  TextColumn get filePath => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get sha256 => text().nullable()();
  BoolColumn get verified => boolean()();
  DateTimeColumn get installedAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  IntColumn get lastLoadMs => integer().nullable()();
  IntColumn get lastTtftMs => integer().nullable()();
  RealColumn get lastTokensPerSecond => real().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Meaning vector for one document passage, from one embedding model.
/// Stored as little-endian float32, L2-normalized.
class ChunkEmbeddings extends Table {
  IntColumn get chunkId =>
      integer().references(DocumentChunks, #id, onDelete: KeyAction.cascade)();
  TextColumn get modelId => text()();
  BlobColumn get vector => blob()();

  @override
  Set<Column> get primaryKey => {chunkId, modelId};
}

/// Facts the user explicitly asked the app to remember. Separate from chat
/// history; only enabled entries are added to prompts, and only when memory
/// is switched on in settings.
class MemoryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One benchmark of one model on this device (median of the measured runs).
@DataClassName('BenchmarkRecord')
class BenchmarkResults extends Table {
  TextColumn get id => text()();
  TextColumn get modelId => text()();
  TextColumn get modelName => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get contextSize => integer()();
  IntColumn get runs => integer()();
  IntColumn get loadMs => integer()();
  IntColumn get timeToFirstTokenMs => integer().nullable()();
  IntColumn get promptTokens => integer()();
  IntColumn get completionTokens => integer()();
  RealColumn get promptTokensPerSecond => real().nullable()();
  RealColumn get generationTokensPerSecond => real().nullable()();
  RealColumn get generationMin => real().nullable()();
  RealColumn get generationMax => real().nullable()();
  IntColumn get rssAfterLoadBytes => integer().nullable()();
  IntColumn get rssPeakBytes => integer().nullable()();

  /// Compute backend the engine reported, e.g. "CPU" or "Vulkan".
  TextColumn get backend => text().nullable()();

  /// e.g. "Google Pixel 7 · Android 14 · 8 cores · 8.0 GB".
  TextColumn get device => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class ContentReports extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text()();
  TextColumn get modelId => text().nullable()();
  TextColumn get reason => text()();
  TextColumn get excerpt => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// An imported file, copied into app-private storage.
/// `kind`: txt, md or pdf. `status`: ready, no_text (e.g. scanned PDF) or error.
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()();
  TextColumn get filePath => text()();
  IntColumn get sizeBytes => integer()();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get chunkCount => integer().withDefault(const Constant(0))();
  IntColumn get charCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  TextColumn get error => text().nullable()();
  DateTimeColumn get importedAt => dateTime()();
  DateTimeColumn get indexedAt => dateTime().nullable()();

  /// Pages whose text came from OCR; their text may contain errors.
  IntColumn get ocrPages => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A passage of extracted text. PDFs set [page]; TXT and Markdown set the
/// line range instead, because those files have no pages.
class DocumentChunks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get ordinal => integer()();
  IntColumn get page => integer().nullable()();
  IntColumn get lineStart => integer().nullable()();
  IntColumn get lineEnd => integer().nullable()();
  TextColumn get body => text()();
}

@DriftDatabase(
  tables: [
    Conversations,
    Messages,
    InstalledModels,
    ContentReports,
    Documents,
    DocumentChunks,
    MemoryEntries,
    ChunkEmbeddings,
    BenchmarkResults,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'localmind'));

  @override
  int get schemaVersion => 7;

  /// Whether the SQLite build has FTS5. Set when the database opens.
  bool hasFts5 = false;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(documents);
        await m.createTable(documentChunks);
      }
      if (from < 3) {
        await m.createTable(memoryEntries);
      }
      if (from < 4) {
        await m.addColumn(conversations, conversations.summary);
        await m.addColumn(conversations, conversations.summaryThroughMessageId);
      }
      if (from < 5) {
        await m.createTable(chunkEmbeddings);
      }
      // Before v2 the documents table did not exist; createTable above
      // already made it with every current column.
      if (from >= 2 && from < 6) {
        await m.addColumn(documents, documents.ocrPages);
      }
      if (from < 7) {
        await m.createTable(benchmarkResults);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      hasFts5 = await _ensureFts();
    },
  );

  /// Keyword index over [DocumentChunks.body], kept in sync by triggers.
  /// Returns false when FTS5 is not compiled in; search then falls back to LIKE.
  Future<bool> _ensureFts() async {
    try {
      await customStatement(
        'CREATE VIRTUAL TABLE IF NOT EXISTS document_chunks_fts USING fts5('
        "body, content='document_chunks', content_rowid='id', "
        "tokenize='unicode61 remove_diacritics 2')",
      );
    } on Object {
      return false;
    }
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS document_chunks_ai AFTER INSERT ON '
      'document_chunks BEGIN INSERT INTO document_chunks_fts(rowid, body) '
      'VALUES (new.id, new.body); END',
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS document_chunks_ad AFTER DELETE ON '
      'document_chunks BEGIN INSERT INTO document_chunks_fts('
      "document_chunks_fts, rowid, body) VALUES ('delete', old.id, old.body); "
      'END',
    );
    return true;
  }

  Future<void> rebuildFts() async {
    if (hasFts5) {
      await customStatement(
        "INSERT INTO document_chunks_fts(document_chunks_fts) VALUES('rebuild')",
      );
    }
  }

  Future<void> clearAll() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });
}
