import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Value;
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/conversation_repository.dart';
import 'package:localmind_ai/data/repositories/memory_repository.dart';
import 'package:localmind_ai/data/repositories/model_repository.dart';
import 'package:localmind_ai/features/chat/chat_controller.dart';
import 'package:localmind_ai/services/device/device_info_service.dart';
import 'package:localmind_ai/services/inference/model_runtime_service.dart';
import 'package:localmind_ai/services/model_service.dart';
import 'package:localmind_ai/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory dir;
  late AppDatabase db;
  late ConversationRepository convs;
  late FakeRuntime runtime;

  Future<ChatController> setUpChat({
    bool summarize = true,
    String summaryText = 'User and assistant discussed messages 0 to 9.',
  }) async {
    dir = await Directory.systemTemp.createTemp('chat');
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({
      'contextSize': 512,
      'maxTokens': 128,
      'activeModelId': 'm',
      'summarizeLongChats': summarize,
    });
    final settings = SettingsService(await SharedPreferences.getInstance());
    final modelRepo = ModelRepository(db);
    final models = ModelService(modelRepo, DeviceInfoService());
    final path = '${dir.path}/m.gguf';
    await writeFakeGguf(path);
    await modelRepo.upsert(
      InstalledModelsCompanion.insert(
        id: 'm',
        displayName: 'm',
        source: 'catalog',
        filePath: path,
        sizeBytes: await File(path).length(),
        sha256: const Value('x'),
        verified: true,
        installedAt: DateTime.now(),
      ),
    );
    models.installed.add((await modelRepo.byId('m'))!);
    runtime = FakeRuntime(
      respond: (turns) =>
          turns.first.text.startsWith('You summarize') ? summaryText : 'Reply.',
    );
    convs = ConversationRepository(db);
    Get
      ..put(settings)
      ..put(convs)
      ..put(modelRepo)
      ..put(MemoryRepository(db))
      ..put(models)
      ..put(ModelRuntimeService(runtime, models, modelRepo, settings));
    final c = await convs.create(title: 'long', modelId: 'm');
    // 12 long messages ≈ far more than a 512-token context.
    for (var i = 0; i < 12; i++) {
      await convs.addMessage(
        conversationId: c.id,
        role: i.isEven ? 'user' : 'assistant',
        content: 'message $i ${'word ' * 60}',
      );
    }
    final chat = ChatController(conversationId: c.id);
    chat.onInit();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return chat;
  }

  tearDown(() async {
    Get.reset();
    await db.close();
    await dir.delete(recursive: true);
  });

  test('long chat is summarized, stored and used in the prompt', () async {
    final chat = await setUpChat();
    chat.input.text = 'What did we discuss?';
    await chat.send();

    final conv = (await convs.byId(chat.conversation.value!.id))!;
    expect(conv.summary, 'User and assistant discussed messages 0 to 9.');
    expect(conv.summaryThroughMessageId, isNotNull);

    final summaryCalls = runtime.calls
        .where((t) => t.first.text.startsWith('You summarize'))
        .toList();
    expect(summaryCalls, isNotEmpty);
    expect(summaryCalls.first.last.text, contains('User: message 0'));
    if (summaryCalls.length > 1) {
      expect(
        summaryCalls[1].last.text,
        contains('Summary so far:'),
        reason: 'later chunks build on the earlier summary',
      );
    }
    expect(runtime.calls.length, summaryCalls.length + 1);

    final replyPrompt = runtime.calls.last;
    expect(replyPrompt.first.text, contains('discussed messages 0 to 9'));
    expect(
      replyPrompt.any((t) => t.text.startsWith('message 0 ')),
      isFalse,
      reason: 'summarized messages are not sent again',
    );
    expect(replyPrompt.last.text, 'What did we discuss?');
    expect(chat.summarizedCount.value, greaterThan(0));
    expect(chat.droppedTurns.value, 0);
  });

  test(
    'turning summarization off falls back to dropping old messages',
    () async {
      final chat = await setUpChat(summarize: false);
      chat.input.text = 'Hi';
      await chat.send();
      expect(runtime.calls, hasLength(1));
      expect((await convs.byId(chat.conversation.value!.id))!.summary, isNull);
      expect(chat.droppedTurns.value, greaterThan(0));
    },
  );

  test('deleting a summarized message removes the summary', () async {
    final chat = await setUpChat(summaryText: 'A summary.');
    chat.input.text = 'Hi';
    await chat.send();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(chat.conversation.value!.summary, 'A summary.');
    await chat.deleteMessage(chat.messages.first);
    expect((await convs.byId(chat.conversation.value!.id))!.summary, isNull);
  });

  test('an empty summary from the model is not stored', () async {
    final chat = await setUpChat(summaryText: '   ');
    chat.input.text = 'Hi';
    await chat.send();
    expect((await convs.byId(chat.conversation.value!.id))!.summary, isNull);
    expect(chat.droppedTurns.value, greaterThan(0));
  });
}
