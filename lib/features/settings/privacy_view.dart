import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    const sections = [
      ('privacy_local_title', 'privacy_local_body'),
      ('privacy_network_title', 'privacy_network_body'),
      ('privacy_permissions_title', 'privacy_permissions_body'),
      ('privacy_files_title', 'privacy_files_body'),
      ('privacy_backup_title', 'privacy_backup_body'),
      ('privacy_limits_title', 'privacy_limits_body'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('privacy_and_permissions'.tr)),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => SectionCard(
          title: sections[i].$1.tr,
          child: Text(sections[i].$2.tr),
        ),
      ),
    );
  }
}
