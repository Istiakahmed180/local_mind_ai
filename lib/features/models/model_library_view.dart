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
            tooltip: 'benchmark_title'.tr,
            icon: const Icon(Icons.speed_rounded),
            onPressed: () => Get.toNamed(Routes.benchmark),
          ),
          IconButton(
            tooltip: 'import_model'.tr,
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: () => _import(models),
          ),
        ],
      ),
      body: Obx(() {
        final info = device.info.value;
        final fits = recommendModels(
          catalog: models.catalog.value.chatModels,
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xs,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          children: [
            if (info != null) _DeviceCard(info),
            if (info != null && !info.supportsArm64) ...[
              const SizedBox(height: AppSpacing.sm),
              NoticeText('abi_unsupported'.tr, tone: PillTone.error),
            ],
            SectionLabel('catalog_models'.tr),
            for (final f in fits) ...[
              _ModelTile(
                fit: f,
                installed: models.installedById(f.model.id) != null,
                active: activeId == f.model.id,
                download: downloads[f.model.id],
              ),
              const SizedBox(height: AppSpacing.ms),
            ],
            if (imported.isNotEmpty) ...[
              SectionLabel('imported_models'.tr),
              for (final m in imported) ...[
                Card(
                  child: ListTile(
                    leading: const IconBadge(Icons.upload_file_rounded),
                    title: Text(m.displayName),
                    subtitle: Text(
                      '${formatBytes(m.sizeBytes)} · ${'imported_unverified'.tr}',
                    ),
                    trailing: activeId == m.id
                        ? StatusPill('active'.tr, tone: PillTone.primary)
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        Get.toNamed(Routes.modelDetails, arguments: m.id),
                  ),
                ),
                const SizedBox(height: AppSpacing.ms),
              ],
            ],
            const SizedBox(height: AppSpacing.sm),
            NoticeText(
              'model_source_note'.tr,
              tone: PillTone.neutral,
              icon: Icons.verified_user_outlined,
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
    final theme = Theme.of(context);
    Widget stat(String label, String value) => Expanded(
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
                const IconBadge(Icons.smartphone_rounded),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('your_device'.tr, style: theme.textTheme.bodySmall),
                      Text(
                        '${info.manufacturer} ${info.model}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                if (info.isEmulator) StatusPill('emulator'.tr),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                stat('total_ram'.tr, formatBytes(info.totalRamBytes)),
                stat('free_storage'.tr, formatBytes(info.freeStorageBytes)),
                stat('cpu_cores'.tr, '${info.cpuCores}'),
              ],
            ),
          ],
        ),
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
    final (fitLabel, fitTone) = switch (fit.fit) {
      Fit.recommended => ('fit_recommended'.tr, PillTone.success),
      Fit.possible => ('fit_possible'.tr, PillTone.warning),
      Fit.tooLarge => ('fit_too_large'.tr, PillTone.error),
      Fit.unknown => ('fit_unknown'.tr, PillTone.neutral),
    };
    final d = download;
    return Card(
      shape: active
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            )
          : null,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.modelDetails, arguments: m.id),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBadge(
                    installed ? Icons.check_rounded : Icons.download_rounded,
                    background: installed
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHigh,
                    color: installed
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.ms),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${m.parameters} · ${m.quantization} · ${formatBytes(m.sizeBytes)} · ${m.license}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (active)
                    StatusPill('active'.tr, tone: PillTone.primary)
                  else if (installed)
                    StatusPill('installed'.tr),
                ],
              ),
              const SizedBox(height: AppSpacing.ms),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  StatusPill(fitLabel, tone: fitTone),
                  StatusPill(
                    'bengali_${m.bengali.name}'.tr,
                    icon: Icons.translate_rounded,
                  ),
                ],
              ),
              if (d != null && d.status != DownloadStatus.idle) ...[
                const SizedBox(height: AppSpacing.ms),
                LinearProgressIndicator(
                  value: d.status == DownloadStatus.verifying
                      ? null
                      : d.fraction,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${'download_${d.status.name}'.tr} · ${formatBytes(d.receivedBytes)} / ${formatBytes(d.totalBytes)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
