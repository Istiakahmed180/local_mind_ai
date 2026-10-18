import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/composer.dart';
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
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.xs,
                    AppSpacing.page,
                    AppSpacing.lg,
                  ),
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
        NoticeText(
          'agent_limits_notice'.trParams({
            'steps': '${AgentController.limits.maxSteps}',
          }),
          tone: PillTone.warning,
          icon: Icons.science_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'agent_tools'.tr,
          icon: Icons.handyman_outlined,
          child: Column(
            children: [
              for (final t in registry.tools)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: IconBadge(
                    _toolIcon(t.name),
                    size: 34,
                    iconSize: 18,
                    background: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHigh,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(t.labelKey.tr),
                  trailing: t.requiresApproval
                      ? StatusPill(
                          'agent_approval_pill'.tr,
                          icon: Icons.lock_outline_rounded,
                          tone: PillTone.warning,
                        )
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
        SectionLabel('agent_examples'.tr),
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
                avatar: Icon(
                  Icons.north_west_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
        padding: const EdgeInsets.all(AppSpacing.ms),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(
                  icon,
                  size: 28,
                  iconSize: 16,
                  color: color,
                  background: color.withValues(alpha: 0.12),
                ),
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
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: SelectableText(
                  body,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md + 2,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.md + 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BrandLogo(size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'agent_answer'.tr,
                      style: theme.textTheme.titleMedium,
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
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: SelectableText(answer, style: theme.textTheme.bodyLarge),
              ),
              if (answerLacksDocumentEvidence(c.steps)) ...[
                const SizedBox(height: AppSpacing.ms),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: NoticeText(
                    'agent_answer_no_doc_evidence'.tr,
                    tone: PillTone.error,
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.ms),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: theme.colorScheme.error, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(
                    Icons.error_outline_rounded,
                    size: 32,
                    iconSize: 18,
                    background: theme.colorScheme.errorContainer,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'agent_failed'.tr,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
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
      return NoticeText('agent_cancelled'.tr, tone: PillTone.neutral);
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
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SectionCard(
        title: 'agent_workspace'.tr,
        icon: Icons.folder_outlined,
        child: files.isEmpty
            ? Text(
                'agent_workspace_empty'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : Column(
                children: [
                  for (final f in files)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const IconBadge(
                        Icons.description_outlined,
                        size: 32,
                        iconSize: 18,
                      ),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: AppColors.of(context).hairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.ms,
          AppSpacing.sm,
          AppSpacing.ms,
          AppSpacing.sm,
        ),
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
                      decoration: composerDecoration(
                        context,
                        'agent_task_hint'.tr,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  busy
                      ? FilledButton.tonalIcon(
                          onPressed: c.loadingModel.value ? null : c.cancel,
                          icon: const Icon(Icons.stop_rounded),
                          label: Text('cancel'.tr),
                        )
                      : FilledButton.icon(
                          onPressed: c.start,
                          icon: const Icon(Icons.play_arrow_rounded),
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

IconData _toolIcon(String name) => switch (name) {
  'calculator' => Icons.calculate_outlined,
  'current_datetime' => Icons.schedule_rounded,
  'read_file' => Icons.file_open_outlined,
  'write_file' => Icons.save_outlined,
  'summarize' => Icons.short_text_rounded,
  'search_history' => Icons.history_rounded,
  'search_documents' => Icons.manage_search_rounded,
  _ => Icons.build_outlined,
};
