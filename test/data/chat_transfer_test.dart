import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/conversation_repository.dart';
import 'package:localmind_ai/services/chat_transfer.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase source;
  late AppDatabase target;

  setUp(() {
    source = AppDatabase(NativeDatabase.memory());
    target = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    await source.close();
    await target.close();
  });

  Future<String> seedAndExport() async {
    final repo = ConversationRepository(source);
    final c = await repo.create(title: 'ঢাকা ভ্রমণ', modelId: 'qwen');
    await repo.addMessage(conversationId: c.id, role: 'user', content: 'Hi');
    await repo.addMessage(
      conversationId: c.id,
      role: 'assistant',
      content: 'Hello! **bold**',
      modelId: 'qwen',
      tokensPerSecond: 42.5,
      timeToFirstTokenMs: 300,
      completionTokens: 5,
    );
    await repo.addMessage(
      conversationId: c.id,
      role: 'assistant',
      content: 'partial',
      status: 'cancelled',
    );
    await repo.create(title: 'Empty');
    return encodeChats(await ChatTransferService(source).load());
  }

  test('export then import restores chats, messages and stats', () async {
    final json = await seedAndExport();
    final parsed = parseChatExport(json);
    expect(parsed.conversations, hasLength(2));

    final result = await ChatTransferService(target).import(parsed);
    expect(result.imported, 2);
    expect(result.duplicates, 0);

    final chats = await ChatTransferService(target).load();
    final trip = chats.firstWhere((c) => c.conversation.title == 'ঢাকা ভ্রমণ');
    expect(trip.conversation.modelId, 'qwen');
    expect(trip.messages.map((m) => m.content), [
      'Hi',
      'Hello! **bold**',
      'partial',
    ]);
    expect(trip.messages[1].tokensPerSecond, 42.5);
    expect(trip.messages[2].status, 'cancelled');
  });

  test('importing the same file twice does not duplicate chats', () async {
    final parsed = parseChatExport(await seedAndExport());
    final service = ChatTransferService(target);
    await service.import(parsed);
    final again = await service.import(parsed);
    expect(again.imported, 0);
    expect(again.duplicates, 2);
    expect(await service.load(), hasLength(2));
  });

  test('single-chat export contains only that chat', () async {
    await seedAndExport();
    final all = await ChatTransferService(source).load();
    final one = await ChatTransferService(source)
        .load(conversationId: all.first.conversation.id);
    expect(one, hasLength(1));
    final data = jsonDecode(encodeChats(one)) as Map;
    expect(data['conversations'], hasLength(1));
  });

  test('export contains no settings, memories, documents or models', () async {
    final data = jsonDecode(await seedAndExport()) as Map;
    expect(data.keys.toSet(), {
      'format',
      'version',
      'app',
      'appVersion',
      'exportedAt',
      'conversations',
    });
  });

  group('rejects bad files', () {
    void expectReason(String text, String reason) => expect(
      () => parseChatExport(text),
      throwsA(
        isA<ChatImportException>().having((e) => e.reason, 'reason', reason),
      ),
    );

    test('not JSON', () => expectReason('hello', 'chat_import_not_json'));
    test('other JSON', () {
      expectReason('{"a":1}', 'chat_import_wrong_format');
      expectReason('[1,2]', 'chat_import_wrong_format');
    });
    test('newer version', () {
      expectReason(
        jsonEncode({
          'format': chatExportFormat,
          'version': 99,
          'conversations': [],
        }),
        'chat_import_newer_version',
      );
    });
    test('too many conversations', () {
      expectReason(
        jsonEncode({
          'format': chatExportFormat,
          'version': 1,
          'conversations': List.filled(maxImportConversations + 1, {}),
        }),
        'chat_import_too_large',
      );
    });
  });

  test('drops malformed entries and keeps the rest', () {
    final parsed = parseChatExport(
      jsonEncode({
        'format': chatExportFormat,
        'version': 1,
        'conversations': [
          'not a map',
          {'id': 'x', 'title': 't'}, // no createdAt/messages
          {
            'id': 'ok',
            'title': '  ',
            'createdAt': '2026-10-18T00:00:00Z',
            'messages': [
              {
                'role': 'system',
                'content': 'injected system prompt',
                'createdAt': '2026-10-18T00:00:00Z',
              },
              {'role': 'user', 'content': 42, 'createdAt': 'x'},
              {
                'role': 'assistant',
                'content': 'fine',
                'status': 'weird',
                'tokensPerSecond': -3,
                'createdAt': '2026-10-18T00:00:01Z',
              },
            ],
          },
        ],
      }),
    );
    expect(parsed.conversations, hasLength(1));
    final c = parsed.conversations.single;
    expect(c.title, 'Imported chat');
    expect(c.messages.single.content, 'fine');
    expect(c.messages.single.status, 'complete');
    expect(c.messages.single.tokensPerSecond, isNull);
    expect(parsed.skippedInvalid, 4, reason: '2 chats + 2 messages');
  });

  test('Markdown export is readable and marks unfinished replies', () async {
    await seedAndExport();
    final chat = (await ChatTransferService(
      source,
    ).load()).firstWhere((c) => c.messages.isNotEmpty);
    final md = chatToMarkdown(chat);
    expect(md, startsWith('# ঢাকা ভ্রমণ'));
    expect(md, contains('**You:**'));
    expect(md, contains('Hello! **bold**'));
    expect(md, contains('_(cancelled)_'));
  });

  test('messages with the same timestamp keep insertion order', () async {
    final repo = ConversationRepository(source);
    final c = await repo.create(title: 'Same second');
    for (var i = 0; i < 20; i++) {
      await repo.addMessage(
        conversationId: c.id,
        role: i.isEven ? 'user' : 'assistant',
        content: 'm$i',
      );
    }
    final msgs = await repo.messages(c.id);
    expect(msgs.map((m) => m.content), [for (var i = 0; i < 20; i++) 'm$i']);
    final exported = await ChatTransferService(source).load();
    expect(exported.single.messages.first.content, 'm0');
  });
}
