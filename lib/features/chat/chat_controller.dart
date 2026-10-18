import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/database.dart';
import '../../data/repositories/conversation_repository.dart';
import '../../data/repositories/model_repository.dart';
import '../../services/inference/context_budget.dart';
import '../../services/inference/inference_runtime.dart';
import '../../services/inference/model_runtime_service.dart';
import '../../services/model_service.dart';
import '../../services/settings_service.dart';

enum ChatPhase { idle, loadingModel, generating }

class ChatController extends GetxController {
  ChatController({String? conversationId}) : _initialId = conversationId;

  final String? _initialId;
  final _repo = Get.find<ConversationRepository>();
  final _modelRepo = Get.find<ModelRepository>();
  final runtime = Get.find<ModelRuntimeService>();
  final models = Get.find<ModelService>();
  final settings = Get.find<SettingsService>();

  final conversation = Rxn<Conversation>();
  final messages = <Message>[].obs;
  final phase = ChatPhase.idle.obs;
  final streamingText = ''.obs;
  final error = RxnString();
  final droppedTurns = 0.obs;
  final input = TextEditingController();
  final scroll = ScrollController();

  /// Model used for this conversation; falls back to the active model.
  final modelId = RxnString();

  StreamSubscription<List<Message>>? _msgSub;
  bool _cancelled = false;

  @override
  void onInit() {
    super.onInit();
    modelId.value = settings.activeModelId.value;
    if (_initialId != null) _open(_initialId);
  }

  Future<void> _open(String id) async {
    final c = await _repo.byId(id);
    if (c == null) return;
    conversation.value = c;
    if (c.modelId != null && models.installedById(c.modelId!) != null) {
      modelId.value = c.modelId;
    }
    _watch(c.id);
  }

  void _watch(String id) {
    _msgSub?.cancel();
    _msgSub = _repo.watchMessages(id).listen((list) {
      messages.assignAll(list);
      _scrollToEnd();
    });
  }

  bool get busy => phase.value != ChatPhase.idle;

  Future<void> selectModel(String id) async {
    modelId.value = id;
    await settings.setActiveModel(id);
    final c = conversation.value;
    if (c != null) await _repo.setModel(c.id, id);
  }

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty || busy) return;
    final mid = modelId.value;
    if (mid == null || models.installedById(mid) == null) {
      error.value = 'error_no_model_selected';
      return;
    }
    error.value = null;
    input.clear();

    var c = conversation.value;
    if (c == null) {
      c = await _repo.create(title: _titleFrom(text), modelId: mid);
      conversation.value = c;
      _watch(c.id);
    }
    final history = await _repo.messages(c.id);
    await _repo.addMessage(conversationId: c.id, role: 'user', content: text);

    phase.value = ChatPhase.loadingModel;
    try {
      await runtime.ensureLoaded(mid);
    } on LoadFailure catch (e) {
      phase.value = ChatPhase.idle;
      error.value = e.reason;
      return;
    }

    final turns = _buildTurns(history, text);
    final budget = fitToContext(
      turns: turns,
      contextSize: runtime.loadedContextSize,
      reservedForOutput: settings.generation.maxTokens,
    );
    droppedTurns.value = budget.droppedCount;

    phase.value = ChatPhase.generating;
    streamingText.value = '';
    _cancelled = false;
    GenerationStats? stats;
    String? failure;
    try {
      await for (final event in runtime.generate(budget.turns)) {
        switch (event) {
          case TokenEvent(:final text):
            streamingText.value += text;
            _scrollToEnd();
          case DoneEvent(stats: final s):
            stats = s;
        }
      }
    } on InferenceException catch (e) {
      failure = e.outOfMemory
          ? 'error_out_of_memory'
          : 'error_generation_failed';
    } on LoadFailure catch (e) {
      failure = e.reason;
    }

    final reply = streamingText.value;
    final status = failure != null
        ? 'error'
        : _cancelled
        ? 'cancelled'
        : 'complete';
    if (reply.isNotEmpty || failure != null) {
      final tps = stats?.tokensPerSecond;
      final ttft = stats?.timeToFirstToken?.inMilliseconds;
      await _repo.addMessage(
        conversationId: c.id,
        role: 'assistant',
        content: reply,
        status: status,
        modelId: mid,
        completionTokens: stats?.completionTokens,
        timeToFirstTokenMs: ttft,
        tokensPerSecond: tps,
      );
      if (status == 'complete') {
        await _modelRepo.recordGeneration(mid, ttftMs: ttft, tps: tps);
      }
    }
    streamingText.value = '';
    error.value = failure;
    phase.value = ChatPhase.idle;
  }

  void stop() {
    if (phase.value != ChatPhase.generating) return;
    _cancelled = true;
    runtime.cancel();
  }

  List<ChatTurn> _buildTurns(List<Message> history, String userText) {
    final system = StringBuffer(settings.systemPrompt.value);
    if (settings.localeCode.value == 'bn') {
      system.write(
        ' The user may write in Bengali (বাংলা). Reply in the language the user writes in.',
      );
    }
    return [
      ChatTurn(ChatRole.system, system.toString()),
      for (final m in history)
        if (m.status != 'error' && m.content.isNotEmpty)
          ChatTurn(
            m.role == 'user' ? ChatRole.user : ChatRole.assistant,
            m.content,
          ),
      ChatTurn(ChatRole.user, userText),
    ];
  }

  Future<ContentReport> report(Message m, String reason) => _repo.report(
    messageId: m.id,
    modelId: m.modelId,
    reason: reason,
    excerpt: m.content,
  );

  Future<void> deleteMessage(Message m) => _repo.deleteMessage(m.id);

  static String _titleFrom(String text) {
    final line = text.split('\n').first.trim();
    return line.length <= 40 ? line : '${line.substring(0, 40)}…';
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.jumpTo(scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void onClose() {
    if (phase.value == ChatPhase.generating) runtime.cancel();
    _msgSub?.cancel();
    input.dispose();
    scroll.dispose();
    super.onClose();
  }
}
