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
import '../../services/voice/voice_service.dart';
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
            _SummaryNote(controller),
            const _VoiceBar(),
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
                  : phase == ChatPhase.summarizing
                  ? 'chat_summarizing'.tr
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
            if (m.role == 'assistant' &&
                m.content.isNotEmpty &&
                Get.find<VoiceService>().enabled)
              ListTile(
                leading: Icon(
                  Get.find<VoiceService>().speakingId.value == m.id
                      ? Icons.stop_circle_outlined
                      : Icons.volume_up_outlined,
                ),
                title: Text(
                  Get.find<VoiceService>().speakingId.value == m.id
                      ? 'voice_stop_reading'.tr
                      : 'voice_read_aloud'.tr,
                ),
                onTap: () async {
                  Get.back<void>();
                  final v = Get.find<VoiceService>();
                  final ok = await v.toggleSpeak(m.id, m.content);
                  if (!ok && v.lastError.value != null) {
                    Get.snackbar('voice'.tr, v.lastError.value!.tr);
                  }
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
                  // Plain Text so long-press opens the message menu (which
                  // has Copy); SelectableText would swallow the gesture.
                  Text(
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

/// Shows that older messages are represented by a summary, with a way to
/// read or remove it.
class _SummaryNote extends StatelessWidget {
  const _SummaryNote(this.c);

  final ChatController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = c.conversation.value?.summary;
      if (summary == null) return const SizedBox.shrink();
      return InkWell(
        onTap: () => _show(context, summary),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              const Icon(Icons.summarize_outlined, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'chat_summary_in_use'.tr,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _show(BuildContext context, String summary) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('chat_summary_title'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'chat_summary_note'.tr,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('chat_summary_remove'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
    if (remove == true) await c.clearSummary();
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
          const _MicButton(),
          const SizedBox(width: AppSpacing.sm),
          Obx(() {
            switch (c.phase.value) {
              case ChatPhase.generating || ChatPhase.summarizing:
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

/// Microphone button, shown only when voice is switched on in settings.
class _MicButton extends StatelessWidget {
  const _MicButton();

  @override
  Widget build(BuildContext context) {
    final voice = Get.find<VoiceService>();
    final c = Get.find<ChatController>();
    return Obx(() {
      if (!voice.enabled || c.phase.value != ChatPhase.idle) {
        return const SizedBox.shrink();
      }
      final on = voice.listening.value;
      return Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: IconButton(
          tooltip: on ? 'voice_stop_listening'.tr : 'voice_speak'.tr,
          isSelected: on,
          style: on
              ? IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          onPressed: () => on ? voice.stopListening() : _listen(voice, c),
          icon: Icon(on ? Icons.stop : Icons.mic_none),
        ),
      );
    });
  }

  Future<void> _listen(VoiceService voice, ChatController c) async {
    if (!canTryListening(voice.stt.value)) {
      Get.snackbar('voice'.tr, 'voice_stt_${voice.stt.value.name}'.tr);
      return;
    }
    final text = await voice.listen();
    if (text != null) {
      final current = c.input.text.trim();
      c.input.text = current.isEmpty ? text : '$current $text';
      c.input.selection = TextSelection.collapsed(offset: c.input.text.length);
    } else if (voice.lastError.value != null) {
      Get.snackbar('voice'.tr, voice.lastError.value!.tr);
    }
  }
}

/// Visible while the microphone is open or a reply is being read aloud.
class _VoiceBar extends StatelessWidget {
  const _VoiceBar();

  @override
  Widget build(BuildContext context) {
    final voice = Get.find<VoiceService>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      if (voice.listening.value) {
        final heard = voice.partial.value;
        return Container(
          width: double.infinity,
          color: scheme.errorContainer,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(Icons.mic, color: scheme.onErrorContainer),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      heard.isEmpty ? 'voice_listening'.tr : heard,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: voice.level.value,
                      color: scheme.onErrorContainer,
                      backgroundColor: scheme.errorContainer,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: voice.cancelListening,
                child: Text('cancel'.tr),
              ),
            ],
          ),
        );
      }
      if (voice.speakingId.value != null) {
        return Container(
          width: double.infinity,
          color: scheme.secondaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.volume_up, color: scheme.onSecondaryContainer),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'voice_reading'.tr,
                  style: TextStyle(color: scheme.onSecondaryContainer),
                ),
              ),
              TextButton(onPressed: voice.stopSpeaking, child: Text('stop'.tr)),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
