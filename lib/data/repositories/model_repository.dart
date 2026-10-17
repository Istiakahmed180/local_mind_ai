import 'dart:io';

import 'package:drift/drift.dart';

import '../local/database.dart';

class ModelRepository {
  ModelRepository(this._db);

  final AppDatabase _db;

  Stream<List<InstalledModel>> watchInstalled() => (_db.select(
    _db.installedModels,
  )..orderBy([(m) => OrderingTerm.desc(m.installedAt)])).watch();

  Future<List<InstalledModel>> installed() =>
      _db.select(_db.installedModels).get();

  Future<InstalledModel?> byId(String id) => (_db.select(
    _db.installedModels,
  )..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<void> upsert(InstalledModelsCompanion row) =>
      _db.into(_db.installedModels).insertOnConflictUpdate(row);

  Future<void> markUsed(String id) =>
      (_db.update(_db.installedModels)..where((m) => m.id.equals(id))).write(
        InstalledModelsCompanion(lastUsedAt: Value(DateTime.now())),
      );

  Future<void> recordLoad(String id, {int? loadMs, String? error}) =>
      (_db.update(_db.installedModels)..where((m) => m.id.equals(id))).write(
        InstalledModelsCompanion(
          lastLoadMs: loadMs == null ? const Value.absent() : Value(loadMs),
          lastError: Value(error),
        ),
      );

  Future<void> recordGeneration(String id, {int? ttftMs, double? tps}) =>
      (_db.update(_db.installedModels)..where((m) => m.id.equals(id))).write(
        InstalledModelsCompanion(
          lastTtftMs: ttftMs == null ? const Value.absent() : Value(ttftMs),
          lastTokensPerSecond: tps == null ? const Value.absent() : Value(tps),
        ),
      );

  /// Deletes the database row and the model file.
  Future<void> remove(String id) async {
    final row = await byId(id);
    if (row != null) {
      final file = File(row.filePath);
      if (await file.exists()) await file.delete();
    }
    await (_db.delete(_db.installedModels)..where((m) => m.id.equals(id))).go();
  }
}
