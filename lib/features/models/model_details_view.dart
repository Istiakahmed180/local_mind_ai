import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import 'gpu_card.dart';
import '../../core/format.dart';
import '../../core/widgets/state_views.dart';
import '../../data/local/database.dart';
import '../../domain/model_definition.dart';
import '../../services/inference/model_runtime_service.dart';
import '../../services/model_service.dart';
import '../../services/settings_service.dart';

class ModelDetailsView extends StatelessWidget {
  const ModelDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String;
    final models = Get.find<ModelService>();
    final runtime = Get.find<ModelRuntimeService>();
    final settings = Get.find<SettingsService>();
    final def = models.catalog.value.byId(id);

    return Scaffold(
      appBar: AppBar(title: Text(def?.name ?? models.displayName(id))),
      body: Obx(() {
        final inst = models.installedById(id);
        if (def == null && inst == null) {
          return MessageState(
            icon: Icons.error_outline,
            title: 'model_not_found'.tr,
          );
        }
        final dl = models.downloads[id];
        final active = settings.activeModelId.value == id;
        final loaded = runtime.loadedModelId.value == id;
        final chat = def?.isEmbedding != true;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xs,
            AppSpacing.page,
            AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            _Hero(
              def: def,
              inst: inst,
              active: active,
              loaded: loaded,
              runtime: runtime,
            ),
            const SizedBox(height: AppSpacing.md),
            if (inst == null && def != null)
              _DownloadControls(def: def, state: dl, models: models)
            else if (inst != null)
              _InstalledControls(
                model: inst,
                active: active,
                loaded: loaded,
                runtime: runtime,
                models: models,
                settings: settings,
              ),
            if (inst != null) ...[
              SectionLabel('measured_on_device'.tr),
              _Measured(inst, loaded: loaded, runtime: runtime),
              if (chat) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () =>
                      Get.toNamed(Routes.benchmark, arguments: inst.id),
                  icon: const Icon(Icons.speed_rounded),
                  label: Text('benchmark_open'.tr),
                ),
                const SizedBox(height: AppSpacing.md),
                GpuCard(modelId: inst.id),
              ],
            ],
            SectionLabel('model_info'.tr),
            if (def != null) _CatalogInfo(def, settings.effectiveContextSize),
            if (def == null && inst != null) _ImportedInfo(inst),
          ],
        );
      }),
    );
  }
}

/// Name, key numbers and status at the top of the screen.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.def,
    required this.inst,
    required this.active,
    required this.loaded,
    required this.runtime,
  });

  final ModelDefinition? def;
  final InstalledModel? inst;
  final bool active;
  final bool loaded;
  final ModelRuntimeService runtime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = def;
    final size = d?.sizeBytes ?? inst?.sizeBytes ?? 0;
    Widget stat(String value, String label) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.titleMedium),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(
                  d?.isEmbedding == true
                      ? Icons.hub_outlined
                      : Icons.memory_rounded,
                  size: 48,
                  iconSize: 26,
                ),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d?.publisher ?? 'imported_unverified'.tr,
                        style: theme.textTheme.bodySmall,
                      ),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (active)
                            StatusPill('active'.tr, tone: PillTone.primary)
                          else if (inst != null)
                            StatusPill('installed'.tr),
                          if (loaded)
                            StatusPill(
                              'runtime_${runtime.status.value.name}'.tr,
                              tone: PillTone.success,
                            ),
                          if (d != null)
                            StatusPill(
                              'bengali_${d.bengali.name}'.tr,
                              icon: Icons.translate_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                stat(formatBytes(size), 'file_size'.tr),
                if (d != null) ...[
                  stat(d.parameters, 'parameters'.tr),
                  stat(d.quantization, 'quantization'.tr),
                ],
              ],
            ),
            if (d != null) ...[
              const SizedBox(height: AppSpacing.ms),
              Text(d.notes, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _CatalogInfo extends StatelessWidget {
  const _CatalogInfo(this.m, this.contextSize);

  final ModelDefinition m;
  final int contextSize;

  @override
  Widget build(BuildContext context) {
    final ram = m.estimatedRamBytes(contextSize);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow('publisher'.tr, m.publisher),
          InfoRow('parameters'.tr, m.parameters),
          InfoRow('quantization'.tr, m.quantization),
          InfoRow('download_size'.tr, formatBytes(m.sizeBytes)),
          InfoRow(
            'estimated_ram'.tr,
            '${formatBytes(ram.low)} – ${formatBytes(ram.high)} (${'estimate_ctx'.trParams({'ctx': '$contextSize'})})',
          ),
          InfoRow('min_ram'.tr, '${m.minRamGb} GB'),
          InfoRow('runtime'.tr, '${m.runtime} (${m.format.toUpperCase()})'),
          InfoRow('max_context'.tr, '${m.maxContext}'),
          InfoRow('language_support'.tr, 'bengali_${m.bengali.name}'.tr),
          InfoRow('license'.tr, m.license),
          InfoRow('source'.tr, m.sourcePage.toString()),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'ram_estimate_note'.tr,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ImportedInfo extends StatelessWidget {
  const _ImportedInfo(this.m);

  final InstalledModel m;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow('file_size'.tr, formatBytes(m.sizeBytes)),
          InfoRow('sha256'.tr, m.sha256 ?? '—'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'imported_warning'.tr,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Measured extends StatelessWidget {
  const _Measured(this.m, {required this.loaded, required this.runtime});

  final InstalledModel m;
  final bool loaded;
  final ModelRuntimeService runtime;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      InfoRow(
        'status'.tr,
        loaded ? 'runtime_${runtime.status.value.name}'.tr : 'not_loaded'.tr,
      ),
      if (m.lastLoadMs != null)
        InfoRow(
          'load_time'.tr,
          formatDuration(Duration(milliseconds: m.lastLoadMs!)),
        ),
      if (m.lastTtftMs != null) InfoRow('first_token'.tr, '${m.lastTtftMs} ms'),
      if (m.lastTokensPerSecond != null)
        InfoRow(
          'speed'.tr,
          '${m.lastTokensPerSecond!.toStringAsFixed(1)} ${'tok_per_s'.tr}',
        ),
      if (m.lastError != null) InfoRow('last_error'.tr, m.lastError!),
    ];
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...rows,
          if (m.lastLoadMs == null && m.lastTokensPerSecond == null)
            Text(
              'no_measurements'.tr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

class _DownloadControls extends StatelessWidget {
  const _DownloadControls({
    required this.def,
    required this.state,
    required this.models,
  });

  final ModelDefinition def;
  final DownloadState? state;
  final ModelService models;

  Future<void> _start(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDownloadDialog(def),
    );
    if (ok == true) models.startDownload(def);
  }

  @override
  Widget build(BuildContext context) {
    final s = state;
    final theme = Theme.of(context);
    final status = s?.status ?? DownloadStatus.idle;
    return SectionCard(
      title: 'download'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (s != null && status != DownloadStatus.idle) ...[
            LinearProgressIndicator(
              value: status == DownloadStatus.verifying ? null : s.fraction,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${'download_${status.name}'.tr} · ${formatBytes(s.receivedBytes)} / ${formatBytes(s.totalBytes)}',
              style: theme.textTheme.bodySmall,
            ),
            if (s.failure != null)
              Text(
                'download_error_${s.failure!.name}'.tr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text('network_notice'.tr, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: switch (status) {
              DownloadStatus.idle => [
                FilledButton.icon(
                  onPressed: () => _start(context),
                  icon: const Icon(Icons.download_rounded),
                  label: Text(
                    'download_size_btn'.trParams({
                      'size': formatBytes(def.sizeBytes),
                    }),
                  ),
                ),
              ],
              DownloadStatus.downloading => [
                OutlinedButton(
                  onPressed: () => models.pauseDownload(def.id),
                  child: Text('pause'.tr),
                ),
                TextButton(
                  onPressed: () => models.discardDownload(def),
                  child: Text('cancel'.tr),
                ),
              ],
              DownloadStatus.verifying => [Text('verifying_checksum'.tr)],
              DownloadStatus.paused || DownloadStatus.failed => [
                FilledButton(
                  onPressed: () => models.startDownload(def),
                  child: Text(
                    status == DownloadStatus.failed ? 'retry'.tr : 'resume'.tr,
                  ),
                ),
                TextButton(
                  onPressed: () => models.discardDownload(def),
                  child: Text('discard'.tr),
                ),
              ],
            },
          ),
        ],
      ),
    );
  }
}

class _ConfirmDownloadDialog extends StatefulWidget {
  const _ConfirmDownloadDialog(this.def);

  final ModelDefinition def;

  @override
  State<_ConfirmDownloadDialog> createState() => _ConfirmDownloadDialogState();
}

class _ConfirmDownloadDialogState extends State<_ConfirmDownloadDialog> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.def;
    final needsAccept = m.requiresLicenseAcceptance;
    return AlertDialog(
      title: Text('confirm_download_title'.tr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'confirm_download_body'.trParams({
                'name': m.name,
                'size': formatBytes(m.sizeBytes),
                'host': m.downloadUrl.host,
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('${'license'.tr}: ${m.license}'),
            SelectableText(
              m.licenseUrl.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextButton.icon(
              onPressed: () => Clipboard.setData(
                ClipboardData(text: m.licenseUrl.toString()),
              ),
              icon: const Icon(Icons.copy, size: 16),
              label: Text('copy_link'.tr),
            ),
            if (needsAccept)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v ?? false),
                title: Text('accept_license'.trParams({'license': m.license})),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('cancel'.tr),
        ),
        FilledButton(
          onPressed: needsAccept && !_accepted
              ? null
              : () => Navigator.pop(context, true),
          child: Text('download'.tr),
        ),
      ],
    );
  }
}

class _InstalledControls extends StatelessWidget {
  const _InstalledControls({
    required this.model,
    required this.active,
    required this.loaded,
    required this.runtime,
    required this.models,
    required this.settings,
  });

  final InstalledModel model;
  final bool active;
  final bool loaded;
  final ModelRuntimeService runtime;
  final ModelService models;
  final SettingsService settings;

  Future<void> _load() async {
    await settings.setActiveModel(model.id);
    try {
      await runtime.ensureLoaded(model.id);
    } on LoadFailure catch (e) {
      Get.snackbar('load_failed_title'.tr, e.reason.tr);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_model_title'.tr),
        content: Text(
          'delete_model_body'.trParams({
            'name': model.displayName,
            'size': formatBytes(model.sizeBytes),
          }),
        ),
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
    if (ok != true) return;
    if (runtime.loadedModelId.value == model.id) await runtime.unload();
    if (settings.activeModelId.value == model.id) {
      await settings.setActiveModel(null);
    }
    await models.delete(model.id);
    Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    final loading = runtime.status.value == RuntimeStatus.loading;
    final generating = runtime.status.value == RuntimeStatus.generating;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (!loaded)
          FilledButton.icon(
            onPressed: loading || generating ? null : _load,
            icon: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(active ? 'load_model'.tr : 'use_and_load'.tr),
          )
        else
          OutlinedButton.icon(
            onPressed: generating ? null : runtime.unload,
            icon: const Icon(Icons.eject_rounded),
            label: Text('unload_model'.tr),
          ),
        if (!active)
          OutlinedButton(
            onPressed: () => settings.setActiveModel(model.id),
            child: Text('set_active'.tr),
          ),
        TextButton.icon(
          onPressed: generating ? null : () => _delete(context),
          icon: const Icon(Icons.delete_outline),
          label: Text('delete'.tr),
        ),
      ],
    );
  }
}
