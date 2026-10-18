import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/state_views.dart';
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
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          children: [
            Row(
              children: [
                const BrandLogo(size: 36),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: Text(
                    AppConfig.appName,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const _ConnectivityPill(),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('home_headline'.tr, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'ai_runs_locally'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _ModelCard(),
            const SizedBox(height: AppSpacing.md),
            _ActionTile(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'new_chat'.tr,
              subtitle: 'home_chat_sub'.tr,
              primary: true,
              onTap: () => Get.toNamed(Routes.chat),
            ),
            const SizedBox(height: AppSpacing.ms),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.auto_awesome_outlined,
                      label: 'agent'.tr,
                      subtitle: 'home_agent_sub'.tr,
                      onTap: () => Get.toNamed(Routes.agent),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.ms),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.description_outlined,
                      label: 'documents'.tr,
                      subtitle: 'home_docs_sub'.tr,
                      onTap: () => Get.toNamed(Routes.documents),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<List<Conversation>>(
              stream: conversations.watchAll(),
              builder: (context, snap) {
                final items = (snap.data ?? const []).take(5).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(
                      'recent_chats'.tr,
                      trailing: items.isEmpty
                          ? null
                          : TextButton(
                              onPressed: () =>
                                  Get.find<ShellController>().index.value = 1,
                              child: Text('see_all'.tr),
                            ),
                    ),
                    if (items.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md + 2),
                          child: Row(
                            children: [
                              const IconBadge(Icons.forum_outlined),
                              const SizedBox(width: AppSpacing.ms),
                              Expanded(
                                child: Text(
                                  'no_chats_yet'.tr,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Card(
                        child: Column(
                          children: [
                            for (final (i, c) in items.indexed) ...[
                              if (i > 0)
                                const Divider(indent: 68, endIndent: 16),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: 2,
                                ),
                                leading: IconBadge(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 36,
                                  iconSize: 18,
                                  background:
                                      theme.colorScheme.surfaceContainerHigh,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                title: Text(
                                  c.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(formatWhen(c.updatedAt)),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                                onTap: () =>
                                    Get.toNamed(Routes.chat, arguments: c.id),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectivityPill extends StatelessWidget {
  const _ConnectivityPill();

  @override
  Widget build(BuildContext context) {
    final device = Get.find<DeviceInfoService>();
    return Obx(
      () => Tooltip(
        message: device.online.value ? 'status_online'.tr : 'status_offline'.tr,
        child: StatusPill(
          device.online.value ? 'pill_online'.tr : 'pill_offline'.tr,
          icon: device.online.value
              ? Icons.wifi_rounded
              : Icons.wifi_off_rounded,
          tone: device.online.value ? PillTone.neutral : PillTone.success,
        ),
      ),
    );
  }
}

/// Active model, its state and the device's headroom.
class _ModelCard extends StatelessWidget {
  const _ModelCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final device = Get.find<DeviceInfoService>();
    final runtime = Get.find<ModelRuntimeService>();
    final models = Get.find<ModelService>();
    final settings = Get.find<SettingsService>();
    return Obx(() {
      final activeId = settings.activeModelId.value;
      final active = activeId == null ? null : models.installedById(activeId);
      final info = device.info.value;
      final status = runtime.loadedModelId.value == activeId
          ? runtime.status.value
          : RuntimeStatus.idle;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(
                  Icons.memory_rounded,
                  background: theme.colorScheme.surface.withValues(alpha: 0.7),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'active_model'.tr,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.75),
                        ),
                      ),
                      Text(
                        active?.displayName ?? 'no_active_model'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                if (active != null)
                  StatusPill(
                    'runtime_${status.name}'.tr,
                    tone: switch (status) {
                      RuntimeStatus.ready ||
                      RuntimeStatus.generating => PillTone.success,
                      RuntimeStatus.error => PillTone.error,
                      _ => PillTone.neutral,
                    },
                  ),
              ],
            ),
            if (info != null) ...[
              const SizedBox(height: AppSpacing.ms),
              Text(
                'device_summary'.trParams({
                  'ram': formatBytes(info.totalRamBytes),
                  'storage': formatBytes(info.freeStorageBytes),
                }),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.75,
                  ),
                ),
              ),
            ],
            if (active == null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => Get.find<ShellController>().index.value = 2,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text('choose_model'.tr),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final fg = primary ? Colors.white : s.onSurface;
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: primary
          ? Row(
              children: [
                IconBadge(
                  icon,
                  background: Colors.white.withValues(alpha: 0.16),
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.ms),
                Expanded(child: _texts(theme, fg)),
                Icon(Icons.arrow_forward_rounded, color: fg),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(icon, size: 36, iconSize: 20),
                const SizedBox(height: AppSpacing.ms),
                _texts(theme, fg),
              ],
            ),
    );
    if (primary) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppPalette.brandGradient,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onTap, child: content),
        ),
      );
    }
    return Material(
      color: s.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: primary
            ? BorderSide.none
            : BorderSide(color: AppColors.of(context).hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }

  Widget _texts(ThemeData theme, Color fg) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: theme.textTheme.titleMedium?.copyWith(color: fg)),
      const SizedBox(height: 2),
      Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: fg.withValues(alpha: 0.72),
        ),
      ),
    ],
  );
}
