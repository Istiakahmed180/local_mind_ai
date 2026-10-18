import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/database.dart';
import '../../data/repositories/conversation_repository.dart';
import '../../data/repositories/memory_repository.dart';
import '../../data/repositories/model_repository.dart';
import '../../services/inference/context_budget.dart';
import '../../services/inference/inference_runtime.dart';
import '../../services/inference/model_runtime_service.dart';
import '../../services/inference/summary_planner.dart';
import '../../services/memory_prompt.dart';
import '../../services/model_service.dart';
import '../../services/settings_service.dart';

enum ChatPhase { idle, loadingModel, summarizing, generating }

class ChatController extends GetxController {
  ChatController({String? conversationId}) : _initialId = conversationId;

  final String? _initialId;
  final _repo = Get.find<ConversationRepository>();
  final _modelRepo = Get.find<ModelRepository>();
  final _memory = Get.find<MemoryRepository>();
  final runtime = Get.find<ModelRuntimeService>();
  final models = Get.find<ModelService>();
  final settings = Get.find<SettingsService>();

  final conversation = Rxn<Conversation>();
  final messages = <Message>[].obs;
  final phase = ChatPhase.idle.obs;
  final streamingText = ''.obs;
  final error = RxnString();
  final droppedTurns = 0.obs;

  /// Messages folded into the chat's summary for the last reply.
  final summarizedCount = 0.obs;

  /// Memories added to the last prompt; 0 when memory is off or empty.
  final memoriesUsed = 0.obs;
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

    final memoryBlock = settings.useMemory.value
        ? buildMemoryBlock(await _memory.enabled())
        : null;
    memoriesUsed.value = memoryBlock?.used ?? 0;
    final usable = [
      for (final m in history)
        if (m.status != 'error' && m.content.isNotEmpty) m,
    ];
    final systemText = _systemText(memoryBlock?.text);
    var (summary, covered) = await _currentSummary(c.id, usable);

    if (settings.summarizeLongChats.value) {
      final plan = planSummary(
        systemText: systemText,
        summary: summary,
        history: [for (final m in usable) _turn(m)],
        coveredCount: covered,
        newUserText: text,
        contextSize: runtime.loadedContextSize,
        reservedForOutput: settings.generation.maxTokens,
      );
      if (plan != null) {
        phase.value = ChatPhase.summarizing;
        _cancelled = false;
        final updated = await _summarize(summary, plan.toSummarize);
        if (_cancelled) {
          phase.value = ChatPhase.idle;
          return;
        }
        if (updated != null) {
          summary = updated;
          covered = plan.newCoveredCount;
          await _repo.setSummary(c.id, updated, usable[covered - 1].id);
          conversation.value = await _repo.byId(c.id);
        }
      }
    }
    summarizedCount.value = summary == null ? 0 : covered;

    final turns = [
      ChatTurn(
        ChatRole.system,
        summary == null ? systemText : systemText + summaryBlock(summary),
      ),
      for (final m in usable.skip(covered)) _turn(m),
      ChatTurn(ChatRole.user, text),
    ];
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
    if (phase.value != ChatPhase.generating &&
        phase.value != ChatPhase.summarizing) {
      return;
    }
    _cancelled = true;
    runtime.cancel();
  }

  String _systemText(String? memoryBlock) {
    final system = StringBuffer(settings.systemPrompt.value);
    if (settings.localeCode.value == 'bn') {
      system.write(
        ' The user may write in Bengali (বাংলা). Reply in the language the user writes in.',
      );
    }
    if (memoryBlock != null) system.write(memoryBlock);
    return system.toString();
  }

  static ChatTurn _turn(Message m) => ChatTurn(
    m.role == 'user' ? ChatRole.user : ChatRole.assistant,
    m.content,
  );

  /// The stored summary and how many of [usable] it covers. A summary whose
  /// last covered message was deleted is discarded.
  Future<(String?, int)> _currentSummary(
    String id,
    List<Message> usable,
  ) async {
    final conv = await _repo.byId(id);
    final summary = conv?.summary;
    final through = conv?.summaryThroughMessageId;
    if (summary == null || through == null) return (null, 0);
    final index = usable.indexWhere((m) => m.id == through);
    if (index < 0) {
      await _repo.clearSummary(id);
      return (null, 0);
    }
    return (summary, index + 1);
  }

  /// Folds [messages] into [previous] chunk by chunk. Returns null if the
  /// model fails or the user stops it; the caller then falls back to
  /// dropping old messages.
  Future<String?> _summarize(String? previous, List<ChatTurn> messages) async {
    var current = previous;
    final chunks = chunkForSummary(
      messages,
      summaryInputBudget(runtime.loadedContextSize, previous),
    );
    for (final chunk in chunks) {
      final out = StringBuffer();
      try {
        await for (final e in runtime.generate(
          buildSummaryPrompt(current, chunk),
          settings: const GenerationSettings(
            temperature: 0.2,
            topP: 0.9,
            maxTokens: summaryMaxTokens,
          ),
        )) {
          if (e is TokenEvent) out.write(e.text);
        }
      } on InferenceException {
        return null;
      }
      if (_cancelled) return null;
      final text = out.toString().trim();
      if (text.isEmpty) return null;
      current = text;
    }
    return current;
  }

  Future<void> clearSummary() async {
    final c = conversation.value;
    if (c == null) return;
    await _repo.clearSummary(c.id);
    conversation.value = await _repo.byId(c.id);
    summarizedCount.value = 0;
  }

  Future<ContentReport> report(Message m, String reason) => _repo.report(
    messageId: m.id,
    modelId: m.modelId,
    reason: reason,
    excerpt: m.content,
  );

  Future<void> remember(String text) => _memory.add(text);

  /// Deleting a message the summary already covers also removes the
  /// summary, so deleted content does not live on inside it.
  Future<void> deleteMessage(Message m) async {
    final c = conversation.value;
    final through = c?.summaryThroughMessageId;
    if (c != null && through != null) {
      final all = messages.toList();
      final anchor = all.indexWhere((x) => x.id == through);
      final index = all.indexWhere((x) => x.id == m.id);
      if (anchor >= 0 && index >= 0 && index <= anchor) await clearSummary();
    }
    await _repo.deleteMessage(m.id);
  }

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
    if (phase.value == ChatPhase.generating ||
        phase.value == ChatPhase.summarizing) {
      runtime.cancel();
    }
    _msgSub?.cancel();
    input.dispose();
    scroll.dispose();
    super.onClose();
  }
}
