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
    isScrollControlled: true,
    builder: (_) => const SafeArea(child: _OcrSheet()),
  );
}

class _OcrSheet extends StatelessWidget {
  const _OcrSheet();

  @override
  Widget build(BuildContext context) {
    final ocr = Get.find<OcrService>();
    return Obx(() {
      final states = Map.of(ocr.states);
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
            icon: Icons.document_scanner_outlined,
            title: 'ocr_title'.tr,
            body: 'ocr_explainer'.tr,
          ),
          for (final l in ocr.languages)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: IconBadge(
                  states[l.id] == OcrLangState.installed
                      ? Icons.check_rounded
                      : Icons.translate_rounded,
                  size: 36,
                  iconSize: 18,
                ),
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
          const SizedBox(height: AppSpacing.sm),
          NoticeText('ocr_limits'.tr, tone: PillTone.neutral),
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
      final theme = Theme.of(context);
      return SectionCard(
        title: 'ocr_title'.tr,
        icon: Icons.document_scanner_outlined,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.ms),
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
        color: Theme.of(context).colorScheme.primaryContainer,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
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
