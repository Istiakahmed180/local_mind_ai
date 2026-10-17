import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';
import '../../data/local/database.dart';
import '../../data/repositories/conversation_repository.dart';

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
    final dateFmt = DateFormat.yMMMd(Get.locale?.toLanguageTag());
    return Scaffold(
      appBar: AppBar(title: Text('nav_chats'.tr)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.chat),
        icon: const Icon(Icons.add),
        label: Text('new_chat'.tr),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_chats'.tr,
                prefixIcon: const Icon(Icons.search),
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
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: c.conversations.length,
                itemBuilder: (context, i) {
                  final conv = c.conversations[i];
                  return ListTile(
                    title: Text(
                      conv.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(dateFmt.format(conv.updatedAt)),
                    onTap: () => Get.toNamed(Routes.chat, arguments: conv.id),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) => action == 'rename'
                          ? _rename(context, c, conv)
                          : _delete(context, c, conv),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'rename',
                          child: Text('rename'.tr),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('delete'.tr),
                        ),
                      ],
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
            onPressed: () => Navigator.pop(context, true),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
    if (ok == true) await c.repo.delete(conv.id);
  }
}
