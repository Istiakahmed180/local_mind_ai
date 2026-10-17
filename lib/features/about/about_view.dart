import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';
import '../../services/model_service.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = Get.find<ModelService>().catalog.value;
    return Scaffold(
      appBar: AppBar(title: Text('about_and_licenses'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SectionCard(
            title: AppConfig.appName,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow('version'.tr, AppConfig.version),
                InfoRow('inference_engine'.tr, 'llama.cpp (llamadart 0.14.0)'),
                const SizedBox(height: AppSpacing.sm),
                Text('about_body'.tr),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: 'model_licenses'.tr,
            child: Column(
              children: [
                for (final m in catalog.models) InfoRow(m.name, m.license),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonal(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: AppConfig.appName,
              applicationVersion: AppConfig.version,
            ),
            child: Text('open_source_licenses'.tr),
          ),
        ],
      ),
    );
  }
}
