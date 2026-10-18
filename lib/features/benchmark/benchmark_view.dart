import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/state_views.dart';
import '../../data/local/database.dart';
import '../../services/benchmark/benchmark.dart';
import 'benchmark_controller.dart';

class BenchmarkView extends GetView<BenchmarkController> {
  const BenchmarkView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      appBar: AppBar(
        title: Text('benchmark_title'.tr),
        actions: [
          Obx(
            () => c.history.isEmpty || c.running.value
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'benchmark_delete_all'.tr,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () => _confirmDeleteAll(context),
                  ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Obx(() {
        final chat = c.models.installedChat;
        if (chat.isEmpty && c.history.isEmpty) {
          return MessageState(
            icon: Icons.speed_rounded,
            title: 'benchmark_no_models'.tr,
            body: 'benchmark_no_models_body'.tr,
          );
        }
        return ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xs,
            AppSpacing.page,
            AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            if (chat.isNotEmpty) _RunCard(c),
            if (c.history.isNotEmpty) ...[
              SectionLabel('benchmark_results'.tr),
              for (final b in c.history) ...[
                _ResultCard(
                  b,
                  latest: b.id == c.latestId.value,
                  onDelete: c.running.value ? null : () => c.delete(b.id),
                ),
                const SizedBox(height: AppSpacing.ms),
              ],
            ],
          ],
        );
      }),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('benchmark_delete_all'.tr),
        content: Text('benchmark_delete_all_body'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            style: dangerButtonStyle(context),
            onPressed: () => Navigator.pop(context, true),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
    if (ok == true) await controller.deleteAll();
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard(this.c);

  final BenchmarkController c;

  @override
  Widget build(BuildContext context) => Obx(() => _build(context));

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final chat = c.models.installedChat;
    final running = c.running.value;
    final cfg = BenchmarkController.config;
    final colors = AppColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const IconBadge(Icons.speed_rounded),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: Text(
                    'benchmark_open'.tr,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.ms),
            Text(
              'benchmark_explainer'.trParams({
                'runs': '${cfg.runs}',
                'tokens': '${cfg.maxTokens}',
              }),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.ms),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                StatusPill(
                  'benchmark_pill_runs'.trParams({'n': '${cfg.runs}'}),
                  icon: Icons.repeat_rounded,
                ),
                StatusPill(
                  'benchmark_pill_tokens'.trParams({'n': '${cfg.maxTokens}'}),
                  icon: Icons.notes_rounded,
                ),
                StatusPill(
                  'benchmark_context'.trParams({
                    'n': '${c.settings.effectiveContextSize}',
                  }),
                  icon: Icons.memory_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: c.modelId.value,
              isExpanded: true,
              decoration: InputDecoration(labelText: 'benchmark_model'.tr),
              items: [
                for (final m in chat)
                  DropdownMenuItem(
                    value: m.id,
                    child: Text(
                      c.models.displayName(m.id),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: running ? null : (v) => c.modelId.value = v,
            ),
            const SizedBox(height: AppSpacing.md),
            if (running) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.ms),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _phaseText(c.phase.value, c.run.value, cfg.runs),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(value: _progress(c, cfg)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'benchmark_keep_open'.tr,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.ms),
              OutlinedButton(onPressed: c.cancel, child: Text('cancel'.tr)),
            ] else
              FilledButton.icon(
                onPressed: c.modelId.value == null ? null : c.start,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('benchmark_run'.tr),
              ),
            if (c.cancelled.value) ...[
              const SizedBox(height: AppSpacing.ms),
              NoticeText('benchmark_cancelled'.tr, tone: PillTone.neutral),
            ],
            if (c.error.value != null) ...[
              const SizedBox(height: AppSpacing.ms),
              NoticeText(
                [
                  c.error.value!.tr,
                  if (c.errorDetail.value != null) c.errorDetail.value!,
                ].join('\n'),
                tone: PillTone.error,
                icon: Icons.error_outline_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _phaseText(BenchmarkPhase? p, int run, int runs) => switch (p) {
    BenchmarkPhase.loading || null => 'benchmark_phase_loading'.tr,
    BenchmarkPhase.warmup => 'benchmark_phase_warmup'.tr,
    BenchmarkPhase.measuring => 'benchmark_phase_run'.trParams({
      'i': '$run',
      'n': '$runs',
    }),
    BenchmarkPhase.done => 'benchmark_phase_saving'.tr,
  };

  /// Load, warm-up and each run are counted as equal steps.
  static double? _progress(BenchmarkController c, BenchmarkConfig cfg) {
    final steps = cfg.runs + 2;
    return switch (c.phase.value) {
      BenchmarkPhase.loading || null => null,
      BenchmarkPhase.warmup => 1 / steps,
      BenchmarkPhase.measuring => (1 + c.run.value) / steps,
      BenchmarkPhase.done => 1,
    };
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard(this.b, {required this.latest, required this.onDelete});

  final BenchmarkRecord b;
  final bool latest;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String tps(double? v) =>
        v == null ? '—' : '${v.toStringAsFixed(1)} ${'tok_per_s'.tr}';
    final date = DateFormat.yMMMd().add_Hm().format(b.createdAt);
    final gen = b.generationTokensPerSecond;
    return Card(
      shape: latest
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md + 2,
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.md + 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.modelName, style: theme.textTheme.titleMedium),
                      Text(date, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'copy'.tr,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: benchmarkAsText(b)),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('benchmark_copied'.tr)),
                      );
                    }
                  },
                ),
                IconButton(
                  tooltip: 'delete'.tr,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        gen == null ? '—' : gen.toStringAsFixed(1),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text('tok_per_s'.tr, style: theme.textTheme.titleMedium),
                    ],
                  ),
                  Text(
                    b.generationMin == null
                        ? 'benchmark_generation'.tr
                        : '${'benchmark_generation'.tr} · '
                              '${b.generationMin!.toStringAsFixed(1)}–'
                              '${b.generationMax!.toStringAsFixed(1)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatRow([
                    (tps(b.promptTokensPerSecond), 'benchmark_prompt'.tr),
                    (
                      b.timeToFirstTokenMs == null
                          ? '—'
                          : formatDuration(
                              Duration(milliseconds: b.timeToFirstTokenMs!),
                            ),
                      'first_token'.tr,
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.ms),
                  StatRow([
                    (
                      formatDuration(Duration(milliseconds: b.loadMs)),
                      'load_time'.tr,
                    ),
                    (
                      b.rssPeakBytes == null
                          ? '—'
                          : formatBytes(b.rssPeakBytes!),
                      'benchmark_memory'.tr,
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.ms),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (b.backend != null)
                        StatusPill(
                          b.backend!,
                          icon: Icons.developer_board_rounded,
                          tone: PillTone.primary,
                        ),
                      StatusPill(
                        'benchmark_workload_value'.trParams({
                          'ctx': '${b.contextSize}',
                          'runs': '${b.runs}',
                          'prompt': '${b.promptTokens}',
                          'gen': '${b.completionTokens}',
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(b.device, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
