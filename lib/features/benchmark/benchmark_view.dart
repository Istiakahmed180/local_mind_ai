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
        ],
      ),
      body: Obx(() {
        final chat = c.models.installedChat;
        if (chat.isEmpty && c.history.isEmpty) {
          return MessageState(
            icon: Icons.speed,
            title: 'benchmark_no_models'.tr,
            body: 'benchmark_no_models_body'.tr,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (chat.isNotEmpty) _RunCard(c),
            const SizedBox(height: AppSpacing.sm),
            if (c.history.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'benchmark_results'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final b in c.history)
                _ResultCard(
                  b,
                  latest: b.id == c.latestId.value,
                  onDelete: c.running.value ? null : () => c.delete(b.id),
                ),
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
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'benchmark_explainer'.trParams({
              'runs': '${cfg.runs}',
              'tokens': '${cfg.maxTokens}',
            }),
            style: theme.textTheme.bodySmall,
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
          const SizedBox(height: AppSpacing.sm),
          Text(
            'benchmark_context'.trParams({
              'n': '${c.settings.effectiveContextSize}',
            }),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (running) ...[
            Text(_phaseText(c.phase.value, c.run.value, cfg.runs)),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: _progress(c, cfg)),
            const SizedBox(height: AppSpacing.sm),
            Text('benchmark_keep_open'.tr, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(onPressed: c.cancel, child: Text('cancel'.tr)),
          ] else
            FilledButton.icon(
              onPressed: c.modelId.value == null ? null : c.start,
              icon: const Icon(Icons.speed),
              label: Text('benchmark_run'.tr),
            ),
          if (c.cancelled.value) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('benchmark_cancelled'.tr),
          ],
          if (c.error.value != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              [
                c.error.value!.tr,
                if (c.errorDetail.value != null) c.errorDetail.value!,
              ].join('\n'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
        ],
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
    return Card(
      color: latest ? theme.colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(b.modelName, style: theme.textTheme.titleSmall),
                ),
                IconButton(
                  tooltip: 'copy'.tr,
                  icon: const Icon(Icons.copy, size: 18),
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
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                ),
              ],
            ),
            Text('$date · ${b.device}', style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            InfoRow(
              'benchmark_generation'.tr,
              b.generationMin == null
                  ? tps(b.generationTokensPerSecond)
                  : '${tps(b.generationTokensPerSecond)}\n'
                        '(${b.generationMin!.toStringAsFixed(1)}–'
                        '${b.generationMax!.toStringAsFixed(1)})',
            ),
            InfoRow('benchmark_prompt'.tr, tps(b.promptTokensPerSecond)),
            if (b.timeToFirstTokenMs != null)
              InfoRow(
                'first_token'.tr,
                formatDuration(Duration(milliseconds: b.timeToFirstTokenMs!)),
              ),
            InfoRow(
              'load_time'.tr,
              formatDuration(Duration(milliseconds: b.loadMs)),
            ),
            if (b.rssPeakBytes != null)
              InfoRow('benchmark_memory'.tr, formatBytes(b.rssPeakBytes!)),
            InfoRow(
              'benchmark_workload'.tr,
              'benchmark_workload_value'.trParams({
                'ctx': '${b.contextSize}',
                'runs': '${b.runs}',
                'prompt': '${b.promptTokens}',
                'gen': '${b.completionTokens}',
              }),
            ),
          ],
        ),
      ),
    );
  }
}
