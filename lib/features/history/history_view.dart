import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/state_views.dart';
import '../../data/local/database.dart';
import '../../data/repositories/conversation_repository.dart';
import 'chat_transfer_actions.dart';

class HistoryController extends GetxController {
  final repo = Get.find<ConversationRepository>();
  final query = ''.obs;
  final conversations = <Conversation>[].obs;
  Worker? _debounce;
  dynamic _sub;

  @override
  void onInit() {
    super.onInit();
    _listen('');
    _debounce = debounce(
      query,
      _listen,
      time: const Duration(milliseconds: 250),
    );
  }

  void _listen(String q) {
    _sub?.cancel();
    _sub = repo.watchAll(query: q).listen(conversations.assignAll);
  }

  @override
  void onClose() {
    _sub?.cancel();
    _debounce?.dispose();
    super.onClose();
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HistoryController());
    return Scaffold(
      appBar: AppBar(
        title: Text('nav_chats'.tr),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'chat_transfer_menu'.tr,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (a) =>
                a == 'export' ? exportChats(context) : importChats(context),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'export', child: Text('chat_export_all'.tr)),
              PopupMenuItem(value: 'import', child: Text('chat_import'.tr)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.chat),
        icon: const Icon(Icons.add_rounded),
        label: Text('new_chat'.tr),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.xs,
              AppSpacing.page,
              AppSpacing.ms,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_chats'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (v) => c.query.value = v,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (c.conversations.isEmpty) {
                return MessageState(
                  icon: Icons.forum_outlined,
                  title: c.query.value.isEmpty
                      ? 'no_chats_yet'.tr
                      : 'no_results'.tr,
                );
              }
              final theme = Theme.of(context);
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  96,
                ),
                itemCount: c.conversations.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final conv = c.conversations[i];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.xs,
                        AppSpacing.xs,
                      ),
                      leading: IconBadge(
                        Icons.chat_bubble_outline_rounded,
                        size: 40,
                        iconSize: 20,
                        background: theme.colorScheme.surfaceContainerHigh,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        conv.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(formatWhen(conv.updatedAt)),
                      onTap: () => Get.toNamed(Routes.chat, arguments: conv.id),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) => switch (action) {
                          'rename' => _rename(context, c, conv),
                          'json' => exportChats(
                            context,
                            conversationId: conv.id,
                          ),
                          'md' => exportChats(
                            context,
                            conversationId: conv.id,
                            markdown: true,
                          ),
                          _ => _delete(context, c, conv),
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'rename',
                            child: Text('rename'.tr),
                          ),
                          PopupMenuItem(
                            value: 'json',
                            child: Text('chat_export_json'.tr),
                          ),
                          PopupMenuItem(
                            value: 'md',
                            child: Text('chat_export_md'.tr),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('delete'.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    HistoryController c,
    Conversation conv,
  ) async {
    final ctrl = TextEditingController(text: conv.title);
    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('rename'.tr),
        content: TextField(controller: ctrl, autofocus: true, maxLength: 80),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text('save'.tr),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (title != null && title.isNotEmpty) await c.repo.rename(conv.id, title);
  }

  Future<void> _delete(
    BuildContext context,
    HistoryController c,
    Conversation conv,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_chat_title'.tr),
        content: Text('delete_chat_body'.tr),
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
    if (ok == true) await c.repo.delete(conv.id);
  }
}
