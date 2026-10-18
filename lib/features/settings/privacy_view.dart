import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const sections = [
      (Icons.smartphone_rounded, 'privacy_local_title', 'privacy_local_body'),
      (Icons.wifi_rounded, 'privacy_network_title', 'privacy_network_body'),
      (
        Icons.verified_user_outlined,
        'privacy_permissions_title',
        'privacy_permissions_body',
      ),
      (Icons.folder_outlined, 'privacy_files_title', 'privacy_files_body'),
      (Icons.cloud_off_outlined, 'privacy_backup_title', 'privacy_backup_body'),
      (
        Icons.info_outline_rounded,
        'privacy_limits_title',
        'privacy_limits_body',
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('privacy_and_permissions'.tr)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xs,
          AppSpacing.page,
          AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
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
            child: Row(
              children: [
                IconBadge(
                  Icons.shield_outlined,
                  size: 48,
                  iconSize: 26,
                  background: theme.colorScheme.surface.withValues(alpha: 0.7),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: Text(
                    'privacy_headline'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final (icon, title, body) in sections) ...[
            SectionCard(
              title: title.tr,
              icon: icon,
              child: Text(
                body.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.ms),
          ],
        ],
      ),
    );
  }
}
