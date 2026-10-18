import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/composer.dart';
import '../../core/widgets/state_views.dart';
import '../../data/local/database.dart';
import '../../services/documents/retrieval.dart';
import '../../services/settings_service.dart';
import 'documents_controller.dart';
import 'meaning_search_card.dart';
import 'ocr_sheet.dart';

class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('documents'.tr),
        actions: [
          IconButton(
            tooltip: 'ocr_title'.tr,
            onPressed: () => showOcrSheet(context),
            icon: const Icon(Icons.document_scanner_outlined),
          ),
          Obx(
            () => IconButton(
              tooltip: 'doc_rebuild_index'.tr,
              onPressed:
                  controller.documents.isEmpty ||
                      controller.rebuilding.value ||
                      controller.busy
                  ? null
                  : () => _rebuild(context),
              icon: const Icon(Icons.sync_rounded),
            ),
          ),
          Obx(
            () => IconButton(
              tooltip: 'doc_import'.tr,
              onPressed: controller.importing.value
                  ? null
                  : () => _import(context),
              icon: const Icon(Icons.note_add_outlined),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.documents.isEmpty) {
            if (controller.importing.value) {
              return const Column(
                children: [
                  OcrProgressBar(),
                  Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }
            return MessageState(
              icon: Icons.description_outlined,
              title: 'doc_empty_title'.tr,
              body: 'doc_empty_body'.tr,
              action: controller.importing.value
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                      onPressed: () => _import(context),
                      icon: const Icon(Icons.note_add_outlined),
                      label: Text('doc_import'.tr),
                    ),
            );
          }
          return Column(
            children: [
              const OcrProgressBar(),
              if (controller.importing.value || controller.rebuilding.value)
                const LinearProgressIndicator(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.xs,
                    AppSpacing.page,
                    AppSpacing.lg,
                  ),
                  children: [
                    _AnswerCard(controller),
                    _StorageCard(controller),
                    SectionLabel(
                      'doc_your_files'.trParams({
                        'n': '${controller.documents.length}',
                      }),
                    ),
                    for (final d in controller.documents) ...[
                      _DocumentTile(d, onRemove: () => _remove(context, d)),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    SectionLabel('doc_search_tools'.tr),
                    const MeaningSearchCard(),
                    const SizedBox(height: AppSpacing.ms),
                    const OcrCard(),
                  ],
                ),
              ),
              _AskBar(controller),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _import(BuildContext context) async {
    final key = await controller.pickAndImport();
    if (key == null) return;
    Get.showSnackbar(
      GetSnackBar(message: key.tr, duration: const Duration(seconds: 4)),
    );
  }

  Future<void> _remove(BuildContext context, Document d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('doc_remove'.tr),
        content: Text('doc_remove_confirm'.trParams({'name': d.name})),
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
    if (ok == true) await controller.remove(d);
  }

  Future<void> _rebuild(BuildContext context) async {
    final failed = await controller.rebuild();
    Get.showSnackbar(
      GetSnackBar(
        message: failed == 0
            ? 'doc_rebuild_done'.tr
            : 'doc_rebuild_failed'.trParams({'n': '$failed'}),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard(this.c);

  final DocumentsController c;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatRow([
              ('${c.documents.length}', 'doc_count'.tr),
              (formatBytes(c.totalBytes), 'doc_files_size'.tr),
              ('${c.totalChars}', 'doc_indexed_chars'.tr),
            ]),
            const SizedBox(height: AppSpacing.ms),
            Obx(() {
              Get.find<SettingsService>().embeddingModelId.value;
              final keyword = c.service.usesFts5
                  ? 'doc_search_fts5'.tr
                  : 'doc_search_like'.tr;
              final meaning = c.service.semantic?.ready ?? false;
              return Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  StatusPill(keyword, icon: Icons.search_rounded),
                  if (meaning)
                    StatusPill(
                      'doc_search_plus_meaning'.tr,
                      icon: Icons.hub_outlined,
                      tone: PillTone.primary,
                    ),
                ],
              );
            }),
            const SizedBox(height: AppSpacing.ms),
            NoticeText(
              'doc_privacy_note'.tr,
              tone: PillTone.neutral,
              icon: Icons.lock_outline_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile(this.d, {required this.onRemove});

  final Document d;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final parts = [
      d.kind.toUpperCase(),
      if (d.pageCount != null) 'doc_pages'.trParams({'n': '${d.pageCount}'}),
      'doc_passages'.trParams({'n': '${d.chunkCount}'}),
      formatBytes(d.sizeBytes),
      if (d.ocrPages != null) 'doc_ocr_pages'.trParams({'n': '${d.ocrPages}'}),
    ];
    final failed = d.status == 'error';
    final s = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.xs,
        ),
        leading: IconBadge(
          failed
              ? Icons.error_outline_rounded
              : d.kind == 'pdf'
              ? Icons.picture_as_pdf_outlined
              : Icons.article_outlined,
          background: failed ? s.errorContainer : null,
          color: failed ? s.onErrorContainer : null,
        ),
        title: Text(d.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          failed
              ? '${'doc_status_error'.tr}: ${(d.error ?? '').tr}'
              : parts.join(' · '),
          style: failed ? TextStyle(color: s.error) : null,
        ),
        trailing: IconButton(
          tooltip: 'doc_remove'.tr,
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard(this.c);

  final DocumentsController c;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final q = c.askedQuestion.value;
      final err = c.error.value;
      if (q == null && err == null) return const SizedBox.shrink();
      final phase = c.phase.value;
      final a = c.answer.value;
      final children = <Widget>[
        if (q != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandLogo(size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(q, style: theme.textTheme.titleMedium)),
            ],
          ),
        const SizedBox(height: AppSpacing.ms),
      ];
      Widget progress(String label) => Row(
        children: [
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label)),
        ],
      );
      if (err != null) {
        children.add(
          NoticeText(
            err.tr,
            tone: PillTone.error,
            icon: Icons.error_outline_rounded,
          ),
        );
      } else if (phase == AskPhase.searching) {
        children.add(progress('doc_searching'.tr));
      } else if (phase == AskPhase.loadingModel) {
        children.add(progress('loading_model'.tr));
      } else if (phase == AskPhase.generating) {
        final t = c.streamingText.value;
        children.add(
          t.isEmpty
              ? progress('thinking'.tr)
              : SelectableText(t, style: theme.textTheme.bodyLarge),
        );
      } else if (a != null && a.notEnoughEvidence) {
        children.add(
          NoticeText(
            'doc_not_enough_evidence'.tr,
            icon: Icons.search_off_rounded,
          ),
        );
      } else if (a != null) {
        children.add(SelectableText(a.text, style: theme.textTheme.bodyLarge));
        children.add(const SizedBox(height: AppSpacing.ms));
        final sources = a.hasCitations
            ? a.cited
            : a.matched.isNotEmpty
            ? a.matched
            : c.passages.toList();
        children.add(
          Text(
            a.hasCitations
                ? 'doc_sources'.tr
                : a.matched.isNotEmpty
                ? 'doc_sources_matched'.tr
                : 'doc_uncited'.tr,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
        children.add(const SizedBox(height: AppSpacing.xs));
        for (final p in sources) {
          final n = c.passages.indexOf(p) + 1;
          children.add(_SourceRow(n: n, label: c.label(p), passage: p));
        }
        if (a.invalidCitations.isNotEmpty) {
          children.add(
            Text(
              'doc_invalid_citations'.trParams({
                'list': a.invalidCitations.map((i) => '[$i]').join(', '),
              }),
              style: theme.textTheme.bodySmall,
            ),
          );
        }
        children.add(const SizedBox(height: AppSpacing.xs));
        children.add(
          Text(
            'doc_check_answer'.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      );
    });
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.n,
    required this.label,
    required this.passage,
  });

  final int n;
  final String label;
  final RetrievedPassage passage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final badge = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: s.primaryContainer,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '$n',
        style: theme.textTheme.labelMedium?.copyWith(
          color: s.onPrimaryContainer,
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: s.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => DraggableScrollableSheet(
              expand: false,
              builder: (_, scroll) => ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.xl,
                ),
                children: [
                  Row(
                    children: [
                      badge,
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(label, style: theme.textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SelectableText(
                    passage.text,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                badge,
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: s.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AskBar extends StatelessWidget {
  const _AskBar(this.c);

  final DocumentsController c;

  @override
  Widget build(BuildContext context) {
    return ComposerBar(
      field: TextField(
        controller: c.question,
        minLines: 1,
        maxLines: 4,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => c.ask(),
        decoration: composerDecoration(context, 'doc_ask_hint'.tr),
      ),
      trailing: [
        Obx(() {
          switch (c.phase.value) {
            case AskPhase.generating:
              return IconButton.filledTonal(
                tooltip: 'stop'.tr,
                onPressed: c.stop,
                icon: const Icon(Icons.stop_rounded),
              );
            case AskPhase.searching:
            case AskPhase.loadingModel:
              return const ComposerSpinner();
            case AskPhase.idle:
              return IconButton.filled(
                tooltip: 'doc_ask'.tr,
                onPressed: c.ask,
                icon: const Icon(Icons.arrow_upward_rounded),
              );
          }
        }),
      ],
    );
  }
}
