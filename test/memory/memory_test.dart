import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/memory_repository.dart';
import 'package:localmind_ai/services/memory_prompt.dart';

MemoryEntry entry(String content, {bool enabled = true}) => MemoryEntry(
  id: content,
  content: content,
  enabled: enabled,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late MemoryRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MemoryRepository(db);
  });
  tearDown(() => db.close());

  test('add, edit, disable and delete entries', () async {
    final a = await repo.add('  I live in   Sylhet  ');
    expect(a.content, 'I live in Sylhet');
    await repo.add('আমি ছোট উত্তর পছন্দ করি');
    await repo.edit(a.id, 'I live in Dhaka');
    await repo.setEnabled(a.id, false);
    final enabled = await repo.enabled();
    expect(enabled.map((e) => e.content), ['আমি ছোট উত্তর পছন্দ করি']);
    await repo.delete(a.id);
    expect(await repo.watchAll().first, hasLength(1));
    await repo.deleteAll();
    expect(await repo.watchAll().first, isEmpty);
  });

  test('rejects empty and truncates long entries', () async {
    expect(() => repo.add('   '), throwsArgumentError);
    final long = await repo.add('x' * 900);
    expect(long.content.length, maxMemoryLength);
  });

  test('clearAll also removes memories', () async {
    await repo.add('fact');
    await db.clearAll();
    expect(await repo.watchAll().first, isEmpty);
  });

  test('prompt block lists only enabled entries', () {
    final b = buildMemoryBlock([
      entry('likes tea'),
      entry('old', enabled: false),
    ]);
    expect(b!.text, contains('- likes tea'));
    expect(b.text, isNot(contains('old')));
    expect(b.used, 1);
  });

  test('prompt block is null when nothing is enabled', () {
    expect(buildMemoryBlock([]), isNull);
    expect(buildMemoryBlock([entry('a', enabled: false)]), isNull);
  });

  test('prompt block stays within the character budget', () {
    final entries = [
      for (var i = 0; i < 50; i++) entry('fact number $i ${'y' * 40}'),
    ];
    final b = buildMemoryBlock(entries, maxChars: 300)!;
    expect(b.used, lessThan(50));
    expect(b.used + b.omitted, 50);
    final listed = b.text.split('\n').where((l) => l.startsWith('- '));
    expect(listed.join('\n').length, lessThanOrEqualTo(300));
  });
}
