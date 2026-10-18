import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../../app/theme.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/state_views.dart';
import '../../services/model_service.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalog = Get.find<ModelService>().catalog.value;
    return Scaffold(
      appBar: AppBar(title: Text('about_and_licenses'.tr)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xs,
          AppSpacing.page,
          AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const BrandLogo(size: 72),
                  const SizedBox(height: AppSpacing.md),
                  Text(AppConfig.appName, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  StatusPill(
                    '${'version'.tr} ${AppConfig.version}',
                    tone: PillTone.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'about_body'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  InfoRow(
                    'inference_engine'.tr,
                    'llama.cpp (llamadart 0.14.0)',
                  ),
                ],
              ),
            ),
          ),
          SectionLabel('model_licenses'.tr),
          Card(
            child: Column(
              children: [
                for (final (i, m) in catalog.models.indexed) ...[
                  if (i > 0)
                    const Divider(
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                    ),
                  ListTile(
                    title: Text(m.name),
                    subtitle: Text(m.publisher),
                    trailing: StatusPill(m.license),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: AppConfig.appName,
              applicationVersion: AppConfig.version,
              applicationIcon: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: BrandLogo(size: 48),
              ),
            ),
            icon: const Icon(Icons.gavel_rounded),
            label: Text('open_source_licenses'.tr),
          ),
        ],
      ),
    );
  }
}
