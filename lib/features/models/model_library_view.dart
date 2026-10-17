import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/gguf.dart';
import '../../core/widgets/state_views.dart';
import '../../services/device/device_info_service.dart';
import '../../services/model_service.dart';
import '../../services/recommendation.dart';
import '../../services/settings_service.dart';

class ModelLibraryView extends StatelessWidget {
  const ModelLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final models = Get.find<ModelService>();
    final device = Get.find<DeviceInfoService>();
    final settings = Get.find<SettingsService>();
    return Scaffold(
      appBar: AppBar(
        title: Text('model_library'.tr),
        actions: [
          IconButton(
            tooltip: 'import_model'.tr,
            icon: const Icon(Icons.file_open_outlined),
            onPressed: () => _import(models),
          ),
        ],
      ),
      body: Obx(() {
        final info = device.info.value;
        final fits = recommendModels(
          catalog: models.catalog.value.models,
          totalRamBytes: info?.totalRamBytes,
          freeStorageBytes: info?.freeStorageBytes,
          preferBengali: settings.localeCode.value == 'bn',
        );
        final imported = models.installed
            .where((m) => m.source == 'import')
            .toList();
        final activeId = settings.activeModelId.value;
        final downloads = Map.of(models.downloads);
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (info != null) _DeviceCard(info),
            if (info != null && !info.supportsArm64)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text('abi_unsupported'.tr),
              ),
            const SizedBox(height: AppSpacing.md),
            for (final f in fits) ...[
              _ModelTile(
                fit: f,
                installed: models.installedById(f.model.id) != null,
                active: activeId == f.model.id,
                download: downloads[f.model.id],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (imported.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'imported_models'.tr,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final m in imported)
                Card(
                  child: ListTile(
                    title: Text(m.displayName),
                    subtitle: Text(
                      '${formatBytes(m.sizeBytes)} · ${'imported_unverified'.tr}',
                    ),
                    trailing: activeId == m.id
                        ? const Icon(Icons.check_circle)
                        : null,
                    onTap: () =>
                        Get.toNamed(Routes.modelDetails, arguments: m.id),
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'model_source_note'.tr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }),
    );
  }

  Future<void> _import(ModelService models) async {
    final file = await FilePicker.pickFile();
    final path = file?.path;
    if (path == null) return;
    if (!path.toLowerCase().endsWith('.gguf')) {
      Get.snackbar('import_model'.tr, 'import_not_gguf'.tr);
      return;
    }
    try {
      final m = await models.importFile(path);
      Get.snackbar(
        'import_model'.tr,
        'import_done'.trParams({'name': m.displayName}),
      );
      await FilePicker.clearTemporaryFiles();
    } on ImportException catch (e) {
      final msg = e.insufficientStorage
          ? 'error_insufficient_storage'.tr
          : switch (e.check) {
              GgufCheck.tooSmall => 'import_too_small'.tr,
              GgufCheck.unsupportedVersion => 'import_bad_version'.tr,
              _ => 'import_not_gguf'.tr,
            };
      Get.snackbar('import_model'.tr, msg);
    }
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard(this.info);

  final DeviceInfo info;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'your_device'.tr,
      child: Column(
        children: [
          InfoRow('device'.tr, '${info.manufacturer} ${info.model}'),
          InfoRow('total_ram'.tr, formatBytes(info.totalRamBytes)),
          InfoRow('free_storage'.tr, formatBytes(info.freeStorageBytes)),
          InfoRow('cpu_cores'.tr, '${info.cpuCores}'),
          if (info.isEmulator) InfoRow('note'.tr, 'emulator_note'.tr),
        ],
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  const _ModelTile({
    required this.fit,
    required this.installed,
    required this.active,
    required this.download,
  });

  final ModelFit fit;
  final bool installed;
  final bool active;
  final DownloadState? download;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = fit.model;
    final (fitLabel, fitColor) = switch (fit.fit) {
      Fit.recommended => ('fit_recommended'.tr, theme.colorScheme.primary),
      Fit.possible => ('fit_possible'.tr, theme.colorScheme.tertiary),
      Fit.tooLarge => ('fit_too_large'.tr, theme.colorScheme.error),
      Fit.unknown => ('fit_unknown'.tr, theme.colorScheme.outline),
    };
    final d = download;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.modelDetails, arguments: m.id),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(m.name, style: theme.textTheme.titleMedium),
                  ),
                  if (active)
                    Chip(
                      label: Text('active'.tr),
                      visualDensity: VisualDensity.compact,
                    )
                  else if (installed)
                    Chip(
                      label: Text('installed'.tr),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              Text(
                '${m.parameters} · ${m.quantization} · ${formatBytes(m.sizeBytes)} · ${m.license}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 10, color: fitColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(fitLabel, style: theme.textTheme.labelMedium),
                    ],
                  ),
                  Text(
                    'bengali_${m.bengali.name}'.tr,
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              if (d != null && d.status != DownloadStatus.idle) ...[
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: d.status == DownloadStatus.verifying
                      ? null
                      : d.fraction,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${'download_${d.status.name}'.tr} · ${formatBytes(d.receivedBytes)} / ${formatBytes(d.totalBytes)}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
