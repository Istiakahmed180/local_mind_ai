import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
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
              icon: const Icon(Icons.refresh),
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
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    _AnswerCard(controller),
                    _StorageCard(controller),
                    const SizedBox(height: AppSpacing.sm),
                    const MeaningSearchCard(),
                    const SizedBox(height: AppSpacing.sm),
                    const OcrCard(),
                    const SizedBox(height: AppSpacing.sm),
                    for (final d in controller.documents)
                      _DocumentTile(d, onRemove: () => _remove(context, d)),
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
    final theme = Theme.of(context);
    return SectionCard(
      title: 'doc_storage_title'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow('doc_count'.tr, '${c.documents.length}'),
          InfoRow('doc_files_size'.tr, formatBytes(c.totalBytes)),
          InfoRow('doc_indexed_chars'.tr, '${c.totalChars}'),
          Obx(() {
            Get.find<SettingsService>().embeddingModelId.value;
            final keyword = c.service.usesFts5
                ? 'doc_search_fts5'.tr
                : 'doc_search_like'.tr;
            final meaning = c.service.semantic?.ready ?? false;
            return InfoRow(
              'doc_search_mode'.tr,
              meaning ? '$keyword ${'doc_search_plus_meaning'.tr}' : keyword,
            );
          }),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'doc_privacy_note'.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
    return Card(
      child: ListTile(
        leading: Icon(
          d.kind == 'pdf'
              ? Icons.picture_as_pdf_outlined
              : Icons.article_outlined,
        ),
        title: Text(d.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          failed
              ? '${'doc_status_error'.tr}: ${(d.error ?? '').tr}'
              : parts.join(' · '),
          style: failed
              ? TextStyle(color: Theme.of(context).colorScheme.error)
              : null,
        ),
        trailing: IconButton(
          tooltip: 'doc_remove'.tr,
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline),
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
        if (q != null) Text(q, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
      ];
      if (err != null) {
        children.add(
          Text(err.tr, style: TextStyle(color: theme.colorScheme.error)),
        );
      } else if (phase == AskPhase.searching) {
        children.add(Text('doc_searching'.tr));
      } else if (phase == AskPhase.loadingModel) {
        children.add(Text('loading_model'.tr));
      } else if (phase == AskPhase.generating) {
        final t = c.streamingText.value;
        children.add(SelectableText(t.isEmpty ? 'thinking'.tr : t));
      } else if (a != null && a.notEnoughEvidence) {
        children.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.search_off, color: theme.colorScheme.tertiary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('doc_not_enough_evidence'.tr)),
            ],
          ),
        );
      } else if (a != null) {
        children.add(SelectableText(a.text));
        children.add(const SizedBox(height: AppSpacing.sm));
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
            style: theme.textTheme.labelLarge,
          ),
        );
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
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Card(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
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
    return InkWell(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          builder: (_, scroll) => ListView(
            controller: scroll,
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                '[$n] $label',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              SelectableText(passage.text),
            ],
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            const Icon(Icons.format_quote, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: Text('[$n] $label')),
          ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: c.question,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => c.ask(),
              decoration: InputDecoration(hintText: 'doc_ask_hint'.tr),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Obx(() {
            switch (c.phase.value) {
              case AskPhase.generating:
                return IconButton.filledTonal(
                  tooltip: 'stop'.tr,
                  onPressed: c.stop,
                  icon: const Icon(Icons.stop),
                );
              case AskPhase.searching:
              case AskPhase.loadingModel:
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              case AskPhase.idle:
                return IconButton.filled(
                  tooltip: 'doc_ask'.tr,
                  onPressed: c.ask,
                  icon: const Icon(Icons.arrow_upward),
                );
            }
          }),
        ],
      ),
    );
  }
}
