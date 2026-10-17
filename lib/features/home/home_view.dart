import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/format.dart';
import '../../data/local/database.dart';
import '../../data/repositories/conversation_repository.dart';
import '../../services/device/device_info_service.dart';
import '../../services/inference/model_runtime_service.dart';
import '../../services/model_service.dart';
import '../../services/settings_service.dart';
import '../shell/shell_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conversations = Get.find<ConversationRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppConfig.appName)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const _StatusCard(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.chat_bubble_outline,
                  label: 'new_chat'.tr,
                  onTap: () => Get.toNamed(Routes.chat),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionTile(
                  icon: Icons.smart_toy_outlined,
                  label: 'agent'.tr,
                  onTap: () => Get.toNamed(Routes.agent),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionTile(
                  icon: Icons.description_outlined,
                  label: 'documents'.tr,
                  onTap: () => Get.toNamed(Routes.documents),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('recent_chats'.tr, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          StreamBuilder<List<Conversation>>(
            stream: conversations.watchAll(),
            builder: (context, snap) {
              final items = (snap.data ?? const []).take(5).toList();
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'no_chats_yet'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return Card(
                child: Column(
                  children: [
                    for (final c in items)
                      ListTile(
                        leading: const Icon(Icons.chat_outlined),
                        title: Text(
                          c.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Get.toNamed(Routes.chat, arguments: c.id),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final device = Get.find<DeviceInfoService>();
    final runtime = Get.find<ModelRuntimeService>();
    final models = Get.find<ModelService>();
    final settings = Get.find<SettingsService>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Obx(() {
          final online = device.online.value;
          final activeId = settings.activeModelId.value;
          final active = activeId == null
              ? null
              : models.installedById(activeId);
          final info = device.info.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    online ? Icons.wifi : Icons.wifi_off,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      online ? 'status_online'.tr : 'status_offline'.tr,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'ai_runs_locally'.tr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  const Icon(Icons.memory, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      active == null
                          ? 'no_active_model'.tr
                          : '${active.displayName} · ${'runtime_${runtime.status.value.name}'.tr}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (active == null)
                    TextButton(
                      onPressed: () =>
                          Get.find<ShellController>().index.value = 2,
                      child: Text('choose_model'.tr),
                    ),
                ],
              ),
              if (info != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'device_summary'.trParams({
                    'ram': formatBytes(info.totalRamBytes),
                    'storage': formatBytes(info.freeStorageBytes),
                  }),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(label, textAlign: TextAlign.center, maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}
