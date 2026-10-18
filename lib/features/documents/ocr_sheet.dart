import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/state_views.dart';
import '../../services/documents/document_service.dart';
import '../../services/documents/ocr_service.dart';

/// Language files for reading scanned PDFs.
void showOcrSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const SafeArea(child: _OcrSheet()),
  );
}

class _OcrSheet extends StatelessWidget {
  const _OcrSheet();

  @override
  Widget build(BuildContext context) {
    final ocr = Get.find<OcrService>();
    final theme = Theme.of(context);
    return Obx(() {
      final states = Map.of(ocr.states);
      return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        children: [
          Text('ocr_title'.tr, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text('ocr_explainer'.tr, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          for (final l in ocr.languages)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text('ocr_lang_${l.id}'.tr),
                subtitle: Text(
                  '${formatBytes(l.sizeBytes)} · ${l.license}'
                  '${states[l.id] == OcrLangState.failed ? ' · ${'download_failed'.tr}' : ''}',
                ),
                trailing: switch (states[l.id]) {
                  OcrLangState.downloading => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  OcrLangState.installed => TextButton(
                    onPressed: () => ocr.remove(l),
                    child: Text('delete'.tr),
                  ),
                  _ => FilledButton.tonal(
                    onPressed: () => _download(context, ocr, l),
                    child: Text('download'.tr),
                  ),
                },
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text('ocr_limits'.tr, style: theme.textTheme.bodySmall),
        ],
      );
    });
  }

  Future<void> _download(
    BuildContext context,
    OcrService ocr,
    OcrLanguage l,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('confirm_download_title'.tr),
        content: Text(
          'ocr_download_body'.trParams({
            'name': 'ocr_lang_${l.id}'.tr,
            'size': formatBytes(l.sizeBytes),
            'host': l.url.host,
          }),
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
    if (ok == true) await ocr.download(l);
  }
}

/// Short OCR status for the Documents screen.
class OcrCard extends StatelessWidget {
  const OcrCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ocr = Get.find<OcrService>();
    return Obx(() {
      ocr.states.length;
      final installed = ocr.installedIds;
      return SectionCard(
        title: 'ocr_title'.tr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              installed.isEmpty
                  ? 'ocr_off'.tr
                  : 'ocr_on'.trParams({
                      'langs': installed
                          .map((id) => 'ocr_lang_$id'.tr)
                          .join(', '),
                    }),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => showOcrSheet(context),
              child: Text(
                installed.isEmpty ? 'doc_meaning_set_up'.tr : 'ocr_manage'.tr,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Shown while an import reads scanned pages.
class OcrProgressBar extends StatelessWidget {
  const OcrProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final docs = Get.find<DocumentService>();
    return Obx(() {
      final progress = docs.ocrProgress.value;
      if (progress == null) return const SizedBox.shrink();
      final (done, total) = progress;
      return Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ocr_progress'.trParams({
                      'done': '${done + (done < total ? 1 : 0)}',
                      'total': '$total',
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  LinearProgressIndicator(
                    value: total == 0 ? null : done / total,
                  ),
                ],
              ),
            ),
            TextButton(onPressed: docs.cancelImport, child: Text('cancel'.tr)),
          ],
        ),
      );
    });
  }
}
