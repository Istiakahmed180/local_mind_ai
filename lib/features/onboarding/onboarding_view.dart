import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../services/settings_service.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _page = PageController();
  int _index = 0;
  final _settings = Get.find<SettingsService>();

  static const _pages = [
    (Icons.lock_outline, 'onb_private_title', 'onb_private_body'),
    (
      Icons.download_for_offline_outlined,
      'onb_models_title',
      'onb_models_body',
    ),
    (Icons.wifi_off_outlined, 'onb_offline_title', 'onb_offline_body'),
  ];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await _settings.setOnboarded();
    Get.offAllNamed(Routes.shell);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Text(AppConfig.appName, style: theme.textTheme.titleMedium),
                  const Spacer(),
                  Obx(
                    () => SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('English')),
                        ButtonSegment(value: 'bn', label: Text('বাংলা')),
                      ],
                      selected: {_settings.localeCode.value},
                      onSelectionChanged: (s) => _settings.setLocale(s.first),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final (icon, title, body) = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 72, color: theme.colorScheme.primary),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          title.tr,
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          body.tr,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!last)
                    TextButton(onPressed: _finish, child: Text('skip'.tr)),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: last
                        ? _finish
                        : () => _page.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                    child: Text(last ? 'get_started'.tr : 'next'.tr),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
