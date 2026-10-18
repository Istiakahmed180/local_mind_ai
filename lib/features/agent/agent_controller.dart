import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/repositories/conversation_repository.dart';
import '../../services/agent/agent_orchestrator.dart';
import '../../services/agent/agent_tool.dart';
import '../../services/agent/tools.dart';
import '../../services/inference/inference_runtime.dart';
import '../../services/inference/model_runtime_service.dart';
import '../../services/model_service.dart';
import '../../services/settings_service.dart';
import 'approval_dialog.dart';

class AgentController extends GetxController {
  final runtime = Get.find<ModelRuntimeService>();
  final models = Get.find<ModelService>();
  final settings = Get.find<SettingsService>();
  final _conversations = Get.find<ConversationRepository>();

  final input = TextEditingController();
  final state = AgentState.idle.obs;
  final steps = <AgentStep>[].obs;
  final answer = RxnString();
  final failure = Rxn<AgentFailure>();
  final failureDetail = RxnString();
  final error = RxnString();
  final loadingModel = false.obs;
  final grammarFellBack = false.obs;
  final workspaceFiles = <File>[].obs;

  AgentOrchestrator? _run;

  static const limits = AgentLimits();

  bool get busy =>
      loadingModel.value ||
      !(state.value == AgentState.idle || state.value.isTerminal);

  @override
  void onInit() {
    super.onInit();
    refreshWorkspace();
  }

  static Future<Directory> workspaceDir() async => Directory(
    p.join((await getApplicationDocumentsDirectory()).path, 'agent_workspace'),
  );

  ToolRegistry buildRegistry() => ToolRegistry([
    CalculatorTool(),
    DateTimeTool(),
    ReadFileTool(_pickFile),
    WriteFileTool(workspaceDir),
    SummarizeTool(_summarize),
    if (settings.agentHistorySearch.value)
      HistorySearchTool(
        _searchHistory,
        isEnabled: () => settings.agentHistorySearch.value,
      ),
  ]);

  Future<void> start() async {
    final task = input.text.trim();
    if (task.isEmpty || busy) return;
    final mid = settings.activeModelId.value;
    if (mid == null || models.installedById(mid) == null) {
      error.value = 'error_no_model_selected';
      return;
    }
    error.value = null;
    loadingModel.value = true;
    try {
      await runtime.ensureLoaded(mid);
    } on LoadFailure catch (e) {
      error.value = e.reason;
      return;
    } finally {
      loadingModel.value = false;
    }

    final run = AgentOrchestrator(
      registry: buildRegistry(),
      generate: (turns, s, {jsonSchema}) =>
          runtime.generate(turns, settings: s, jsonSchema: jsonSchema),
      cancelGeneration: runtime.cancel,
      approve: (tool, call) => showApprovalDialog(tool, call),
      limits: limits,
      onChange: () => _sync(),
    );
    _run = run;
    answer.value = null;
    failure.value = null;
    failureDetail.value = null;
    grammarFellBack.value = false;
    try {
      await run.run(task);
    } on LoadFailure catch (e) {
      error.value = e.reason;
      run.cancel();
    }
    _sync();
    await refreshWorkspace();
  }

  void _sync() {
    final run = _run;
    if (run == null) return;
    state.value = run.state;
    steps.assignAll(run.steps);
    answer.value = run.answer;
    failure.value = run.failure;
    failureDetail.value = run.failureDetail;
    grammarFellBack.value = !run.useGrammar;
    if (run.state == AgentState.cancelled && (Get.isDialogOpen ?? false)) {
      Get.back<bool>(result: false);
    }
  }

  void cancel() => _run?.cancel();

  void reset() {
    if (busy) return;
    _run = null;
    state.value = AgentState.idle;
    steps.clear();
    answer.value = null;
    failure.value = null;
    failureDetail.value = null;
    error.value = null;
  }

  Future<void> refreshWorkspace() async {
    final dir = await workspaceDir();
    if (!await dir.exists()) {
      workspaceFiles.clear();
      return;
    }
    final files = await dir.list().where((e) => e is File).cast<File>().toList();
    files.sort((a, b) => a.path.compareTo(b.path));
    workspaceFiles.assignAll(files);
  }

  Future<void> deleteWorkspaceFile(File f) async {
    final root = p.canonicalize((await workspaceDir()).path);
    if (p.dirname(p.canonicalize(f.path)) != root) return;
    await f.delete();
    await refreshWorkspace();
  }

  Future<PickedFile?> _pickFile() async {
    final f = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ReadFileTool.extensions,
    );
    final path = f?.path;
    if (f == null || path == null) return null;
    return PickedFile(
      name: f.name,
      size: await File(path).length(),
      readBytes: () async {
        try {
          return await File(path).readAsBytes();
        } finally {
          await FilePicker.clearTemporaryFiles();
        }
      },
    );
  }

  Future<String> _summarize(String text) async {
    final b = StringBuffer();
    await for (final e in runtime.generate(
      [
        const ChatTurn(
          ChatRole.system,
          'Summarize the text in at most three sentences. Use only facts '
          'from the text. Reply in the language of the text.',
        ),
        ChatTurn(ChatRole.user, text),
      ],
      settings: const GenerationSettings(temperature: 0.2, maxTokens: 200),
    )) {
      if (e is TokenEvent) b.write(e.text);
    }
    return b.toString();
  }

  Future<List<HistoryHit>> _searchHistory(String query, int limit) async {
    final rows = await _conversations.searchMessages(query, limit: limit);
    return [
      for (final (title, content) in rows)
        HistoryHit(title: title, snippet: _snippet(content, query)),
    ];
  }

  static String _snippet(String content, String query) {
    final flat = content.replaceAll(RegExp(r'\s+'), ' ');
    final i = flat.toLowerCase().indexOf(query.toLowerCase());
    final start = (i < 0 ? 0 : i - 60).clamp(0, flat.length);
    final end = (start + 200).clamp(0, flat.length);
    return '${start > 0 ? '…' : ''}${flat.substring(start, end)}${end < flat.length ? '…' : ''}';
  }

  @override
  void onClose() {
    _run?.cancel();
    input.dispose();
    super.onClose();
  }
}
