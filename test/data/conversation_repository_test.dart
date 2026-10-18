import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/conversation_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late ConversationRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ConversationRepository(db);
  });

  tearDown(() => db.close());

  test('creates conversations and stores messages in order', () async {
    final c = await repo.create(title: 'Hello', modelId: 'm');
    await repo.addMessage(conversationId: c.id, role: 'user', content: 'Hi');
    await repo.addMessage(
      conversationId: c.id,
      role: 'assistant',
      content: 'Hello!',
      tokensPerSecond: 12.5,
      timeToFirstTokenMs: 300,
    );
    final msgs = await repo.messages(c.id);
    expect(msgs.map((m) => m.role), ['user', 'assistant']);
    expect(msgs.last.tokensPerSecond, 12.5);
  });

  test('rename and search by title or message content', () async {
    final a = await repo.create(title: 'Cooking');
    final b = await repo.create(title: 'Travel');
    await repo.addMessage(
      conversationId: b.id,
      role: 'user',
      content: 'ঢাকা থেকে সিলেট',
    );
    await repo.rename(a.id, 'Recipes');

    expect((await repo.watchAll(query: 'recip').first).single.id, a.id);
    expect((await repo.watchAll(query: 'সিলেট').first).single.id, b.id);
    expect(
      await repo.watchAll(query: '%').first,
      isEmpty,
      reason: 'LIKE wildcards are escaped',
    );
  });

  test('searchMessages binds the query and escapes wildcards', () async {
    final c = await repo.create(title: 'Trip');
    await repo.addMessage(conversationId: c.id, role: 'user', content: 'Train at 9');
    await repo.addMessage(conversationId: c.id, role: 'user', content: '100% sure');
    expect(await repo.searchMessages('train'), [('Trip', 'Train at 9')]);
    expect(await repo.searchMessages('%'), [('Trip', '100% sure')]);
    expect(await repo.searchMessages("'; DROP TABLE messages; --"), isEmpty);
    expect(await repo.messages(c.id), hasLength(2));
  });

  test('deleting a conversation cascades to messages', () async {
    final c = await repo.create(title: 'x');
    await repo.addMessage(conversationId: c.id, role: 'user', content: 'hi');
    await repo.delete(c.id);
    expect(await repo.messages(c.id), isEmpty);
  });

  test('reports are stored locally with truncated excerpts', () async {
    await repo.report(
      messageId: 'm1',
      modelId: 'x',
      reason: 'report_other',
      excerpt: 'a' * 5000,
    );
    final r = (await repo.reports()).single;
    expect(r.excerpt.length, 2000);
  });

  test('clearAll removes everything', () async {
    final c = await repo.create(title: 'x');
    await repo.addMessage(conversationId: c.id, role: 'user', content: 'hi');
    await db.clearAll();
    expect(await repo.watchAll().first, isEmpty);
  });
}
