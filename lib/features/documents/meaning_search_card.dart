import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/model_definition.dart';
import '../../services/documents/embedding_service.dart';
import '../../services/model_service.dart';
import '../../services/settings_service.dart';

/// Status of meaning-based search and the way to set it up.
class MeaningSearchCard extends StatelessWidget {
  const MeaningSearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    final e = Get.find<EmbeddingService>();
    final settings = Get.find<SettingsService>();
    final theme = Theme.of(context);
    return Obx(() {
      settings.embeddingModelId.value; // rebuild on change
      Get.find<ModelService>().installed.length;
      final def = e.activeModel;
      final children = <Widget>[];
      if (def == null) {
        children.add(
          Text(
            'doc_meaning_off'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      } else {
        final done = e.embedded.value;
        final total = e.total.value;
        children
          ..add(InfoRow('doc_meaning_model'.tr, def.name))
          ..add(
            InfoRow(
              'doc_meaning_indexed'.tr,
              'doc_meaning_progress'.trParams({
                'done': '$done',
                'total': '$total',
              }),
            ),
          );
        if (e.indexing.value) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: LinearProgressIndicator(
                value: total == 0 ? null : done / total,
              ),
            ),
          );
        }
        if (e.error.value != null) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: NoticeText(
                'doc_meaning_error'.tr,
                tone: PillTone.error,
                icon: Icons.error_outline_rounded,
              ),
            ),
          );
        }
      }
      children.add(const SizedBox(height: AppSpacing.ms));
      children.add(
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (def != null &&
                !e.indexing.value &&
                e.embedded.value < e.total.value)
              FilledButton.tonal(
                onPressed: e.indexMissing,
                child: Text('doc_meaning_index_now'.tr),
              ),
            if (e.indexing.value)
              TextButton(onPressed: e.stopIndexing, child: Text('pause'.tr)),
            OutlinedButton(
              onPressed: () => _chooseModel(context),
              child: Text(
                def == null ? 'doc_meaning_set_up'.tr : 'doc_meaning_change'.tr,
              ),
            ),
          ],
        ),
      );
      return SectionCard(
        title: 'doc_meaning_title'.tr,
        icon: Icons.hub_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
    });
  }

  void _chooseModel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SafeArea(child: _ModelSheet()),
    );
  }
}

class _ModelSheet extends StatelessWidget {
  const _ModelSheet();

  @override
  Widget build(BuildContext context) {
    final models = Get.find<ModelService>();
    final e = Get.find<EmbeddingService>();
    final settings = Get.find<SettingsService>();
    return Obx(() {
      final defs = models.catalog.value.embeddingModels;
      final selected = settings.embeddingModelId.value;
      final downloads = Map.of(models.downloads);
      return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.lg,
        ),
        children: [
          SheetHeader(
            icon: Icons.hub_outlined,
            title: 'doc_meaning_title'.tr,
            body: 'doc_meaning_explainer'.tr,
          ),
          for (final d in defs)
            _ModelTile(
              def: d,
              installed: models.installedById(d.id) != null,
              selected: selected == d.id,
              download: downloads[d.id],
              onDownload: () => _confirmDownload(context, models, d),
              onUse: () => e.selectModel(d.id),
              onPause: () => models.pauseDownload(d.id),
            ),
          if (selected != null)
            TextButton(
              onPressed: () {
                e.selectModel(null);
                Navigator.pop(context);
              },
              child: Text('doc_meaning_turn_off'.tr),
            ),
        ],
      );
    });
  }

  Future<void> _confirmDownload(
    BuildContext context,
    ModelService models,
    ModelDefinition d,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('confirm_download_title'.tr),
        content: Text(
          '${'confirm_download_body'.trParams({'name': d.name, 'size': formatBytes(d.sizeBytes), 'host': d.downloadUrl.host})}\n\n${'license'.tr}: ${d.license}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('download'.tr),
          ),
        ],
      ),
    );
    if (ok == true) await models.startDownload(d);
  }
}

class _ModelTile extends StatelessWidget {
  const _ModelTile({
    required this.def,
    required this.installed,
    required this.selected,
    required this.download,
    required this.onDownload,
    required this.onUse,
    required this.onPause,
  });

  final ModelDefinition def;
  final bool installed;
  final bool selected;
  final DownloadState? download;
  final VoidCallback onDownload;
  final VoidCallback onUse;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = download;
    final busy =
        d != null &&
        (d.status == DownloadStatus.downloading ||
            d.status == DownloadStatus.verifying);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.ms),
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(def.name, style: theme.textTheme.titleMedium),
                ),
                if (selected)
                  StatusPill('active'.tr, tone: PillTone.primary)
                else if (installed)
                  StatusPill('installed'.tr),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${formatBytes(def.sizeBytes)} · ${def.license} · ${'bengali_${def.bengali.name}'.tr}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(def.notes, style: theme.textTheme.bodyMedium),
            if (busy) ...[
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: d.status == DownloadStatus.verifying ? null : d.fraction,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: busy
                  ? TextButton(onPressed: onPause, child: Text('pause'.tr))
                  : installed
                  ? (selected
                        ? const SizedBox.shrink()
                        : FilledButton(
                            onPressed: onUse,
                            child: Text('doc_meaning_use'.tr),
                          ))
                  : FilledButton.tonal(
                      onPressed: onDownload,
                      child: Text(
                        d?.status == DownloadStatus.paused
                            ? 'resume'.tr
                            : 'download_size_btn'.trParams({
                                'size': formatBytes(def.sizeBytes),
                              }),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
