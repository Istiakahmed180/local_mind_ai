import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Longest single memory entry, in characters.
const maxMemoryLength = 500;

class MemoryRepository {
  MemoryRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Stream<List<MemoryEntry>> watchAll() => (_db.select(
    _db.memoryEntries,
  )..orderBy([(m) => OrderingTerm.desc(m.updatedAt)])).watch();

  Future<List<MemoryEntry>> enabled() =>
      (_db.select(_db.memoryEntries)
            ..where((m) => m.enabled.equals(true))
            ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
          .get();

  Future<MemoryEntry> add(String content) {
    final now = DateTime.now();
    return _db
        .into(_db.memoryEntries)
        .insertReturning(
          MemoryEntriesCompanion.insert(
            id: _uuid.v4(),
            content: _clean(content),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> edit(String id, String content) =>
      (_db.update(_db.memoryEntries)..where((m) => m.id.equals(id))).write(
        MemoryEntriesCompanion(
          content: Value(_clean(content)),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> setEnabled(String id, bool enabled) =>
      (_db.update(_db.memoryEntries)..where((m) => m.id.equals(id))).write(
        MemoryEntriesCompanion(enabled: Value(enabled)),
      );

  Future<void> delete(String id) =>
      (_db.delete(_db.memoryEntries)..where((m) => m.id.equals(id))).go();

  Future<void> deleteAll() => _db.delete(_db.memoryEntries).go();

  static String _clean(String s) {
    final t = s.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.isEmpty) throw ArgumentError('Memory cannot be empty');
    return t.length > maxMemoryLength ? t.substring(0, maxMemoryLength) : t;
  }
}
