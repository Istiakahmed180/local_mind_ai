import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get modelId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

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

@DriftDatabase(
  tables: [Conversations, Messages, InstalledModels, ContentReports],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'localmind'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> clearAll() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });
}
