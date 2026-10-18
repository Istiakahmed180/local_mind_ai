import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

class BenchmarkRepository {
  BenchmarkRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Stream<List<BenchmarkRecord>> watchAll() => (_db.select(
    _db.benchmarkResults,
  )..orderBy([(b) => OrderingTerm.desc(b.createdAt)])).watch();

  Future<BenchmarkRecord> add(BenchmarkResultsCompanion row) => _db
      .into(_db.benchmarkResults)
      .insertReturning(row.copyWith(id: Value(_uuid.v4())));

  Future<void> delete(String id) =>
      (_db.delete(_db.benchmarkResults)..where((b) => b.id.equals(id))).go();

  Future<void> deleteAll() => _db.delete(_db.benchmarkResults).go();
}
