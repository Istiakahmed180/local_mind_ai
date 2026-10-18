import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Value;
import 'package:integration_test/integration_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/conversation_repository.dart';
import 'package:localmind_ai/data/repositories/memory_repository.dart';
import 'package:localmind_ai/data/repositories/model_repository.dart';
import 'package:localmind_ai/features/chat/chat_controller.dart';
import 'package:localmind_ai/services/device/device_info_service.dart';
import 'package:localmind_ai/services/inference/llamadart_runtime.dart';
import 'package:localmind_ai/services/inference/model_runtime_service.dart';
import 'package:localmind_ai/services/model_service.dart';
import 'package:localmind_ai/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Long-chat summarization with the real model. Push the model first:
///   `adb push qwen2.5-0.5b-instruct-q4_k_m.gguf /data/local/tmp/`
/// Records what the model recalls; it does not assert answer quality.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const modelPath = '/data/local/tmp/qwen2.5-0.5b-instruct-q4_k_m.gguf';

  const filler = [
    'Explain in detail how rain forms, including evaporation, condensation and precipitation.',
    'Rain forms when water evaporates from oceans and lakes, rises as vapour, cools, condenses into droplets around dust particles and falls when the droplets grow heavy enough.',
    'Now describe how a refrigerator keeps food cold, step by step, with the role of the compressor.',
    'A refrigerator moves heat out using a refrigerant: the compressor squeezes it, it releases heat outside through coils, then expands and absorbs heat inside the cabinet.',
    'Tell me about the history of the printing press and why it mattered for literacy in Europe.',
    'Gutenberg built a movable-type press around 1440; books became cheaper and faster to make, which spread ideas and helped literacy grow across Europe.',
    'What are the main differences between a lake and a river in terms of water flow and ecosystems?',
    'Rivers flow in one direction with currents and oxygen-rich water, while lakes are still bodies with layered temperatures and different plants and fish.',
  ];

  Future<(ChatController, ConversationRepository, AppDatabase)> setUpChat({
    required bool summarize,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({
      'contextSize': 512,
      'maxTokens': 96,
      'temperature': 0.0,
      'activeModelId': 'qwen',
      'summarizeLongChats': summarize,
    });
    final settings = SettingsService(await SharedPreferences.getInstance());
    final modelRepo = ModelRepository(db);
    final models = ModelService(modelRepo, DeviceInfoService());
    await modelRepo.upsert(
      InstalledModelsCompanion.insert(
        id: 'qwen',
        displayName: 'Qwen2.5 0.5B',
        source: 'catalog',
        filePath: modelPath,
        sizeBytes: await File(modelPath).length(),
        sha256: const Value('pushed'),
        verified: true,
        installedAt: DateTime.now(),
      ),
    );
    models.installed.add((await modelRepo.byId('qwen'))!);
    final convs = ConversationRepository(db);
    Get
      ..put(settings)
      ..put(convs)
      ..put(modelRepo)
      ..put(MemoryRepository(db))
      ..put(models)
      ..put(
        ModelRuntimeService(LlamadartRuntime(), models, modelRepo, settings),
      );
    final c = await convs.create(title: 'long', modelId: 'qwen');
    await convs.addMessage(
      conversationId: c.id,
      role: 'user',
      content: 'My name is Rahim and my favourite colour is green.',
    );
    await convs.addMessage(
      conversationId: c.id,
      role: 'assistant',
      content: 'Nice to meet you, Rahim! Green is a lovely colour.',
    );
    for (var i = 0; i < filler.length; i++) {
      await convs.addMessage(
        conversationId: c.id,
        role: i.isEven ? 'user' : 'assistant',
        content: filler[i],
      );
    }
    final chat = ChatController(conversationId: c.id)..onInit();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return (chat, convs, db);
  }

  Future<void> run(bool summarize) async {
    final (chat, convs, db) = await setUpChat(summarize: summarize);
    final watch = Stopwatch()..start();
    chat.input.text = 'What is my name and my favourite colour?';
    await chat.send();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final conv = (await convs.byId(chat.conversation.value!.id))!;
    final reply = chat.messages.last.content;
    // ignore: avoid_print
    print(
      '[summarize=$summarize] ${watch.elapsedMilliseconds}ms '
      'summarized=${chat.summarizedCount.value} dropped=${chat.droppedTurns.value}\n'
      '  summary: ${conv.summary}\n  reply: $reply\n'
      '  recalls name=${reply.contains('Rahim')} colour=${reply.toLowerCase().contains('green')}',
    );
    expect(chat.messages.last.role, 'assistant');
    expect(reply.trim(), isNotEmpty);
    if (summarize) {
      expect(conv.summary, isNotNull);
      expect(chat.droppedTurns.value, 0);
    } else {
      expect(conv.summary, isNull);
      expect(chat.droppedTurns.value, greaterThan(0));
    }
    await Get.find<ModelRuntimeService>().unload();
    Get.reset();
    await db.close();
  }

  testWidgets('summarization on', semanticsEnabled: false, (_) => run(true));
  testWidgets('summarization off', semanticsEnabled: false, (_) => run(false));
}
