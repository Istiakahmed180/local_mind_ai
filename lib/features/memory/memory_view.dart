import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';
import '../../data/local/database.dart';
import '../../data/repositories/memory_repository.dart';
import '../../services/settings_service.dart';

/// Review, add, edit and delete what the app remembers. Memory is separate
/// from chat history and is only used when switched on.
class MemoryView extends StatelessWidget {
  const MemoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<MemoryRepository>();
    final settings = Get.find<SettingsService>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('memory'.tr),
        actions: [
          IconButton(
            tooltip: 'memory_clear'.tr,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _clearAll(context, repo),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => editMemoryDialog(context),
        icon: const Icon(Icons.add),
        label: Text('memory_add'.tr),
      ),
      body: StreamBuilder<List<MemoryEntry>>(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? const [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              96,
            ),
            children: [
              Obx(
                () => Card(
                  child: SwitchListTile(
                    title: Text('memory_use'.tr),
                    subtitle: Text('memory_use_hint'.tr),
                    value: settings.useMemory.value,
                    onChanged: settings.setUseMemory,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'memory_explainer'.tr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (items.isEmpty)
                MessageState(
                  icon: Icons.psychology_alt_outlined,
                  title: 'memory_empty_title'.tr,
                  body: 'memory_empty_body'.tr,
                )
              else
                for (final m in items)
                  Card(
                    child: ListTile(
                      leading: Checkbox(
                        value: m.enabled,
                        onChanged: (v) => repo.setEnabled(m.id, v ?? false),
                      ),
                      title: Text(m.content),
                      subtitle: m.enabled ? null : Text('memory_disabled'.tr),
                      onTap: () => editMemoryDialog(context, entry: m),
                      trailing: IconButton(
                        tooltip: 'delete'.tr,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => repo.delete(m.id),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _clearAll(BuildContext context, MemoryRepository repo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('memory_clear'.tr),
        content: Text('memory_clear_confirm'.tr),
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
    if (ok == true) await repo.deleteAll();
  }
}

/// Adds a new memory, or edits [entry]. [initial] prefills a new one, e.g.
/// from a chat message, so the user reviews the text before saving.
Future<void> editMemoryDialog(
  BuildContext context, {
  MemoryEntry? entry,
  String? initial,
}) async {
  final repo = Get.find<MemoryRepository>();
  final ctrl = TextEditingController(text: entry?.content ?? initial ?? '');
  final text = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(entry == null ? 'memory_add'.tr : 'memory_edit'.tr),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        minLines: 2,
        maxLines: 5,
        maxLength: maxMemoryLength,
        decoration: InputDecoration(hintText: 'memory_hint'.tr),
      ),
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
  if (text == null || text.isEmpty) return;
  entry == null ? await repo.add(text) : await repo.edit(entry.id, text);
}
