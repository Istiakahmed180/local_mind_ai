import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';
import '../../data/local/database.dart';
import '../shell/shell_view.dart';
import '../memory/memory_view.dart';
import '../settings/reports_view.dart';
import 'chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.conversation.value?.title ?? 'new_chat'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [_ModelChip(controller)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _MessageList(controller)),
            _MemoryNote(controller),
            _Banner(controller),
            _Composer(controller),
          ],
        ),
      ),
    );
  }
}

class _ModelChip extends StatelessWidget {
  const _ModelChip(this.c);

  final ChatController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Obx(() {
        final id = c.modelId.value;
        final label = id == null ? 'choose_model'.tr : c.models.displayName(id);
        return ActionChip(
          avatar: const Icon(Icons.memory, size: 18),
          label: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(label, overflow: TextOverflow.ellipsis),
          ),
          onPressed: c.busy ? null : () => _pickModel(context),
        );
      }),
    );
  }

  void _pickModel(BuildContext context) {
    final installed = c.models.installed;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: installed.isEmpty
            ? MessageState(
                icon: Icons.download_outlined,
                title: 'no_models_installed'.tr,
                action: FilledButton(
                  onPressed: () {
                    Get.back<void>();
                    Get.until((r) => r.settings.name == Routes.shell);
                    Get.find<ShellController>().index.value = 2;
                  },
                  child: Text('open_model_library'.tr),
                ),
              )
            : RadioGroup<String>(
                groupValue: c.modelId.value,
                onChanged: (v) {
                  if (v != null) c.selectModel(v);
                  Get.back<void>();
                },
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final m in installed)
                      RadioListTile<String>(
                        value: m.id,
                        title: Text(m.displayName),
                        subtitle: Text(
                          m.source == 'import'
                              ? 'imported_unverified'.tr
                              : 'verified_download'.tr,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList(this.c);

  final ChatController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msgs = c.messages.toList();
      final streaming = c.streamingText.value;
      final phase = c.phase.value;
      if (msgs.isEmpty && phase == ChatPhase.idle) {
        return MessageState(
          icon: Icons.chat_bubble_outline,
          title: 'chat_empty_title'.tr,
          body: 'chat_empty_body'.tr,
        );
      }
      final showPending = phase != ChatPhase.idle;
      return ListView.builder(
        controller: c.scroll,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: msgs.length + (showPending ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == msgs.length) {
            return _Bubble(
              text: streaming,
              isUser: false,
              pendingLabel: phase == ChatPhase.loadingModel
                  ? 'loading_model'.tr
                  : streaming.isEmpty
                  ? 'thinking'.tr
                  : null,
            );
          }
          final m = msgs[i];
          return _Bubble(
            text: m.content,
            isUser: m.role == 'user',
            message: m,
            onLongPress: () => _actions(context, m),
          );
        },
      );
    });
  }

  void _actions(BuildContext context, Message m) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text('copy'.tr),
              onTap: () {
                Clipboard.setData(ClipboardData(text: m.content));
                Get.back<void>();
              },
            ),
            if (m.role == 'user')
              ListTile(
                leading: const Icon(Icons.psychology_alt_outlined),
                title: Text('memory_remember_this'.tr),
                onTap: () {
                  Get.back<void>();
                  editMemoryDialog(context, initial: m.content);
                },
              ),
            if (m.role == 'assistant')
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text('report_response'.tr),
                onTap: () {
                  Get.back<void>();
                  _report(context, m);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text('delete'.tr),
              onTap: () {
                c.deleteMessage(m);
                Get.back<void>();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _report(BuildContext context, Message m) {
    const reasons = [
      'report_harmful',
      'report_offensive',
      'report_sexual',
      'report_wrong',
      'report_other',
    ];
    showDialog<void>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('report_response'.tr),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text('report_explainer'.tr),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final r in reasons)
            SimpleDialogOption(
              child: Text(r.tr),
              onPressed: () async {
                final saved = await c.report(m, r);
                Get.back<void>();
                Get.snackbar(
                  'report_saved_title'.tr,
                  'report_saved_body'.tr,
                  duration: const Duration(seconds: 6),
                  mainButton: TextButton(
                    onPressed: () {
                      Get.closeCurrentSnackbar();
                      showReportSendDialog(context, saved);
                    },
                    child: Text('report_send'.tr),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.isUser,
    this.message,
    this.pendingLabel,
    this.onLongPress,
  });

  final String text;
  final bool isUser;
  final Message? message;
  final String? pendingLabel;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final m = message;
    final meta = <String>[
      if (m?.status == 'cancelled') 'stopped'.tr,
      if (m?.status == 'error') 'generation_error'.tr,
      if (m?.tokensPerSecond != null)
        '${m!.tokensPerSecond!.toStringAsFixed(1)} ${'tok_per_s'.tr}',
      if (m?.timeToFirstTokenMs != null)
        '${'first_token'.tr} ${m!.timeToFirstTokenMs} ms',
    ];
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pendingLabel != null && text.isEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(pendingLabel!),
                    ],
                  )
                else
                  SelectableText(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isUser
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                    ),
                  ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    meta.join(' · '),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tells the user when saved memories were added to the last prompt.
class _MemoryNote extends StatelessWidget {
  const _MemoryNote(this.c);

  final ChatController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final n = c.memoriesUsed.value;
      if (n == 0) return const SizedBox.shrink();
      return InkWell(
        onTap: () => Get.toNamed(Routes.memory),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology_alt_outlined, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                n == 1
                    ? 'memory_in_use_one'.tr
                    : 'memory_in_use'.trParams({'n': '$n'}),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Banner extends StatelessWidget {
  const _Banner(this.c);

  final ChatController c;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final err = c.error.value;
      final dropped = c.droppedTurns.value;
      if (err == null && dropped == 0) return const SizedBox.shrink();
      final isError = err != null;
      return Container(
        width: double.infinity,
        color: isError ? scheme.errorContainer : scheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          isError ? err.tr : 'context_trimmed'.trParams({'n': '$dropped'}),
          style: TextStyle(
            color: isError
                ? scheme.onErrorContainer
                : scheme.onSecondaryContainer,
          ),
        ),
      );
    });
  }
}

class _Composer extends StatelessWidget {
  const _Composer(this.c);

  final ChatController c;

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
              controller: c.input,
              minLines: 1,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(hintText: 'message_hint'.tr),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Obx(() {
            switch (c.phase.value) {
              case ChatPhase.generating:
                return IconButton.filledTonal(
                  tooltip: 'stop'.tr,
                  onPressed: c.stop,
                  icon: const Icon(Icons.stop),
                );
              case ChatPhase.loadingModel:
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              case ChatPhase.idle:
                return IconButton.filled(
                  tooltip: 'send'.tr,
                  onPressed: c.send,
                  icon: const Icon(Icons.arrow_upward),
                );
            }
          }),
        ],
      ),
    );
  }
}
