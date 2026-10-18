import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/state_views.dart';
import '../../services/agent/agent_orchestrator.dart';
import '../../services/agent/tools.dart';
import 'agent_controller.dart';

class AgentView extends GetView<AgentController> {
  const AgentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('agent'.tr),
        actions: [
          Obx(
            () => controller.steps.isEmpty || controller.busy
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'agent_new_task'.tr,
                    icon: const Icon(Icons.restart_alt),
                    onPressed: controller.reset,
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    if (controller.state.value == AgentState.idle) ...[
                      _Intro(controller),
                    ] else ...[
                      _StatusBar(controller),
                      for (final s in controller.steps) _StepTile(s),
                      _Outcome(controller),
                    ],
                    _Workspace(controller),
                  ],
                ),
              ),
            ),
            _Composer(controller),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro(this.c);

  final AgentController c;

  @override
  Widget build(BuildContext context) {
    final registry = c.buildRegistry();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'agent_limits_notice'.trParams({
                      'steps': '${AgentController.limits.maxSteps}',
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        SectionCard(
          title: 'agent_tools'.tr,
          child: Column(
            children: [
              for (final t in registry.tools)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    t.requiresApproval
                        ? Icons.lock_outline
                        : Icons.build_outlined,
                  ),
                  title: Text(t.labelKey.tr),
                  subtitle: t.requiresApproval
                      ? Text('agent_needs_approval'.tr)
                      : null,
                ),
              Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('agent_allow_history'.tr),
                  subtitle: Text('agent_allow_history_body'.tr),
                  value: c.settings.agentHistorySearch.value,
                  onChanged: c.settings.setAgentHistorySearch,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'agent_no_dangerous_tools'.tr,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'agent_examples'.tr,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final k in [
              'agent_example_calc',
              'agent_example_date',
              'agent_example_write',
            ])
              ActionChip(
                label: Text(k.tr),
                onPressed: () => c.input.text = k.tr,
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar(this.c);

  final AgentController c;

  @override
  Widget build(BuildContext context) {
    final s = c.state.value;
    final running = !s.isTerminal;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          if (running)
            const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (running) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'agent_state_${s.name}'.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text(
            'agent_steps_used'.trParams({
              'n':
                  '${c.steps.where((x) => x.kind != AgentStepKind.note).length}',
            }),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile(this.step);

  final AgentStep step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tool = step.tool == null ? '' : _toolLabel(step.tool!);
    final (icon, color, title) = switch (step.kind) {
      AgentStepKind.toolCall => (
        Icons.play_arrow,
        scheme.primary,
        'agent_step_call'.trParams({'tool': tool}),
      ),
      AgentStepKind.toolResult => (
        Icons.check_circle_outline,
        scheme.primary,
        'agent_step_result'.trParams({'tool': tool}),
      ),
      AgentStepKind.toolError => (
        Icons.error_outline,
        scheme.error,
        'agent_step_tool_error'.trParams({'tool': tool}),
      ),
      AgentStepKind.approvalDenied => (
        Icons.block,
        scheme.error,
        'agent_step_denied'.trParams({'tool': tool}),
      ),
      AgentStepKind.invalidOutput => (
        Icons.warning_amber,
        scheme.tertiary,
        'agent_step_invalid'.tr,
      ),
      AgentStepKind.note => (
        Icons.info_outline,
        scheme.onSurfaceVariant,
        'agent_step_grammar_fallback'.tr,
      ),
      AgentStepKind.finalAnswer => (
        Icons.flag_outlined,
        scheme.primary,
        'agent_step_final'.tr,
      ),
    };
    final args = step.args;
    final body = switch (step.kind) {
      AgentStepKind.toolCall =>
        args == null || args.isEmpty
            ? ''
            : const JsonEncoder.withIndent('  ').convert(args),
      AgentStepKind.note || AgentStepKind.finalAnswer => '',
      _ => step.text,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (step.elapsed != null)
                  Text(
                    '${step.elapsed!.inMilliseconds} ms',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              SelectableText(
                body,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _toolLabel(String name) => switch (name) {
    'calculator' => 'tool_calculator'.tr,
    'current_datetime' => 'tool_datetime'.tr,
    'read_file' => 'tool_read_file'.tr,
    'write_file' => 'tool_write_file'.tr,
    'summarize' => 'tool_summarize'.tr,
    'search_history' => 'tool_history_search'.tr,
    'search_documents' => 'tool_doc_search'.tr,
    _ => name,
  };
}

class _Outcome extends StatelessWidget {
  const _Outcome(this.c);

  final AgentController c;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = c.state.value;
    final answer = c.answer.value;
    if (state == AgentState.completed && answer != null) {
      return Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'agent_answer'.tr,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'copy'.tr,
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: answer)),
                  ),
                ],
              ),
              SelectableText(answer),
              if (answerLacksDocumentEvidence(c.steps)) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'agent_answer_no_doc_evidence'.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text('agent_answer_caveat'.tr, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
    }
    if (state == AgentState.failed) {
      final f = c.failure.value;
      final detail = c.failureDetail.value;
      return Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('agent_failed'.tr, style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(switch (f) {
                AgentFailure.stepLimit => 'agent_fail_step_limit'.trParams({
                  'steps': '${AgentController.limits.maxSteps}',
                }),
                AgentFailure.invalidModelOutput => 'agent_fail_invalid'.tr,
                AgentFailure.outOfMemory => 'error_out_of_memory'.tr,
                _ => 'agent_fail_model'.tr,
              }),
              if (f == AgentFailure.invalidModelOutput && detail != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('agent_raw_output'.tr, style: theme.textTheme.labelLarge),
                SelectableText(
                  detail,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (state == AgentState.cancelled) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Text('agent_cancelled'.tr, style: theme.textTheme.bodyMedium),
      );
    }
    return const SizedBox.shrink();
  }
}

class _Workspace extends StatelessWidget {
  const _Workspace(this.c);

  final AgentController c;

  @override
  Widget build(BuildContext context) {
    final files = c.workspaceFiles;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: SectionCard(
        title: 'agent_workspace'.tr,
        child: files.isEmpty
            ? Text('agent_workspace_empty'.tr)
            : Column(
                children: [
                  for (final f in files)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.description_outlined),
                      title: Text(p.basename(f.path)),
                      subtitle: Text(formatBytes(_size(f))),
                      onTap: () => _preview(f),
                      trailing: IconButton(
                        tooltip: 'delete'.tr,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => c.deleteWorkspaceFile(f),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  static int _size(File f) {
    try {
      return f.lengthSync();
    } on FileSystemException {
      return 0;
    }
  }

  Future<void> _preview(File f) async {
    final text = await f.readAsString();
    await Get.dialog<void>(
      AlertDialog(
        title: Text(p.basename(f.path)),
        content: SingleChildScrollView(child: SelectableText(text)),
        actions: [
          TextButton(onPressed: Get.back<void>, child: Text('agent_close'.tr)),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer(this.c);

  final AgentController c;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Obx(() {
          final busy = c.busy;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (c.error.value != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    c.error.value!.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (c.loadingModel.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('loading_model'.tr),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: c.input,
                      enabled: !busy,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'agent_task_hint'.tr,
                        counterText: '',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  busy
                      ? FilledButton.tonalIcon(
                          onPressed: c.loadingModel.value ? null : c.cancel,
                          icon: const Icon(Icons.stop),
                          label: Text('cancel'.tr),
                        )
                      : FilledButton.icon(
                          onPressed: c.start,
                          icon: const Icon(Icons.play_arrow),
                          label: Text('agent_run'.tr),
                        ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
