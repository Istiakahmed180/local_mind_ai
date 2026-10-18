import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/conversation_repository.dart';

/// Schema of version 1 (commit e2e62a6), as drift created it.
const _v1 = [
  'CREATE TABLE IF NOT EXISTS "conversations" ("id" TEXT NOT NULL, "title" '
      'TEXT NOT NULL, "model_id" TEXT NULL, "created_at" INTEGER NOT NULL, '
      '"updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"))',
  'CREATE TABLE IF NOT EXISTS "messages" ("id" TEXT NOT NULL, '
      '"conversation_id" TEXT NOT NULL REFERENCES conversations (id) ON DELETE '
      'CASCADE, "role" TEXT NOT NULL, "content" TEXT NOT NULL, "status" TEXT '
      "NOT NULL DEFAULT 'complete', \"model_id\" TEXT NULL, "
      '"completion_tokens" INTEGER NULL, "time_to_first_token_ms" INTEGER '
      'NULL, "tokens_per_second" REAL NULL, "created_at" INTEGER NOT NULL, '
      'PRIMARY KEY ("id"))',
  'CREATE TABLE IF NOT EXISTS "installed_models" ("id" TEXT NOT NULL, '
      '"display_name" TEXT NOT NULL, "source" TEXT NOT NULL, "file_path" TEXT '
      'NOT NULL, "size_bytes" INTEGER NOT NULL, "sha256" TEXT NULL, "verified" '
      'INTEGER NOT NULL CHECK ("verified" IN (0, 1)), "installed_at" INTEGER '
      'NOT NULL, "last_used_at" INTEGER NULL, "last_load_ms" INTEGER NULL, '
      '"last_ttft_ms" INTEGER NULL, "last_tokens_per_second" REAL NULL, '
      '"last_error" TEXT NULL, PRIMARY KEY ("id"))',
  'CREATE TABLE IF NOT EXISTS "content_reports" ("id" TEXT NOT NULL, '
      '"message_id" TEXT NOT NULL, "model_id" TEXT NULL, "reason" TEXT NOT '
      'NULL, "excerpt" TEXT NOT NULL, "created_at" INTEGER NOT NULL, PRIMARY '
      'KEY ("id"))',
];

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('v1 fixture has the same columns as the unchanged v1 tables', () async {
    // The four v1 tables are unchanged in v2, so a fresh database must agree
    // with the fixture column for column.
    Future<Map<String, List<String>>> columns(AppDatabase db) async => {
      for (final t in [
        'conversations',
        'messages',
        'installed_models',
        'content_reports',
      ])
        t: (await db.customSelect('PRAGMA table_info("$t")').get())
            .map(
              (r) =>
                  '${r.read<String>('name')}:${r.read<String>('type')}:'
                  '${r.read<int>('notnull')}:${r.read<int>('pk')}',
            )
            .toList(),
    };
    final fresh = AppDatabase(NativeDatabase.memory());
    final old = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          for (final s in _v1) {
            raw.execute(s);
          }
          raw.userVersion = 1;
        },
      ),
    );
    addTearDown(fresh.close);
    addTearDown(old.close);
    expect(await columns(old), await columns(fresh));
  });

  test('upgrading from v1 keeps data and adds later tables', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          for (final s in _v1) {
            raw.execute(s);
          }
          raw.execute(
            "INSERT INTO conversations VALUES ('c1', 'Old chat', NULL, 1, 2)",
          );
          raw.execute(
            "INSERT INTO messages (id, conversation_id, role, content, "
            "created_at) VALUES ('m1', 'c1', 'user', 'hello', 3)",
          );
          raw.userVersion = 1;
        },
      ),
    );
    addTearDown(db.close);

    final chats = await db.select(db.conversations).get();
    expect(chats.single.title, 'Old chat');
    expect((await db.select(db.messages).get()).single.content, 'hello');

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), db.schemaVersion);
    expect(await db.select(db.memoryEntries).get(), isEmpty);
    expect(await db.select(db.chunkEmbeddings).get(), isEmpty);
    // v4 columns exist on the upgraded conversations table.
    await ConversationRepository(db).setSummary('c1', 'old summary', 'm1');
    expect(
      (await db.select(db.conversations).get()).single.summary,
      'old summary',
    );

    await db
        .into(db.documents)
        .insert(
          DocumentsCompanion.insert(
            id: 'd1',
            name: 'a.txt',
            kind: 'txt',
            filePath: '/x',
            sizeBytes: 3,
            status: 'ready',
            importedAt: DateTime(2026),
          ),
        );
    await db
        .into(db.documentChunks)
        .insert(
          DocumentChunksCompanion.insert(
            documentId: 'd1',
            ordinal: 0,
            body: 'abc',
          ),
        );
    expect(db.hasFts5, isTrue);
    final hit = await db
        .customSelect(
          "SELECT rowid FROM document_chunks_fts WHERE document_chunks_fts "
          "MATCH 'abc'",
        )
        .get();
    expect(hit, hasLength(1));

    await (db.delete(db.documents)..where((d) => d.id.equals('d1'))).go();
    expect(await db.select(db.documentChunks).get(), isEmpty);
  });

  test('a fresh install creates every table', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final names =
        (await db
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type='table'",
                )
                .get())
            .map((r) => r.read<String>('name'))
            .toSet();
    expect(
      names,
      containsAll([
        'conversations',
        'messages',
        'installed_models',
        'content_reports',
        'documents',
        'document_chunks',
        'document_chunks_fts',
        'memory_entries',
        'chunk_embeddings',
      ]),
    );
  });

  test('v5 database gains documents.ocr_pages and keeps documents', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          // Build the current schema, then step back to v5.
          raw.execute(
            'CREATE TABLE documents (id TEXT NOT NULL PRIMARY KEY, name TEXT '
            'NOT NULL, kind TEXT NOT NULL, file_path TEXT NOT NULL, size_bytes '
            'INTEGER NOT NULL, page_count INTEGER NULL, chunk_count INTEGER NOT '
            'NULL DEFAULT 0, char_count INTEGER NOT NULL DEFAULT 0, status TEXT '
            'NOT NULL, error TEXT NULL, imported_at INTEGER NOT NULL, indexed_at '
            'INTEGER NULL)',
          );
          raw.execute(
            "INSERT INTO documents (id, name, kind, file_path, size_bytes, "
            "status, imported_at) VALUES ('d1', 'old.pdf', 'pdf', '/x', 1, "
            "'ready', 0)",
          );
          for (final s in _v1) {
            raw.execute(s);
          }
          raw.execute(
            'CREATE TABLE document_chunks (id INTEGER NOT NULL PRIMARY KEY '
            'AUTOINCREMENT, document_id TEXT NOT NULL REFERENCES documents (id) '
            'ON DELETE CASCADE, ordinal INTEGER NOT NULL, page INTEGER NULL, '
            'line_start INTEGER NULL, line_end INTEGER NULL, body TEXT NOT NULL)',
          );
          raw.execute(
            'CREATE TABLE memory_entries (id TEXT NOT NULL PRIMARY KEY, content '
            "TEXT NOT NULL, enabled INTEGER NOT NULL DEFAULT 1, created_at "
            'INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
          );
          raw.execute('ALTER TABLE conversations ADD COLUMN summary TEXT NULL');
          raw.execute(
            'ALTER TABLE conversations ADD COLUMN summary_through_message_id '
            'TEXT NULL',
          );
          raw.execute(
            'CREATE TABLE chunk_embeddings (chunk_id INTEGER NOT NULL '
            'REFERENCES document_chunks (id) ON DELETE CASCADE, model_id TEXT '
            'NOT NULL, vector BLOB NOT NULL, PRIMARY KEY (chunk_id, model_id))',
          );
          raw.userVersion = 5;
        },
      ),
    );
    addTearDown(db.close);
    final doc = (await db.select(db.documents).get()).single;
    expect(doc.name, 'old.pdf');
    expect(doc.ocrPages, isNull);
  });
}
