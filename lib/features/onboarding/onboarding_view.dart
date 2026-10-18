import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_config.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/widgets/brand.dart';
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
    (Icons.lock_outline_rounded, 'onb_private_title', 'onb_private_body'),
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
    final s = theme.colorScheme;
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                0,
              ),
              child: Row(
                children: [
                  const BrandLogo(size: 32),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      AppConfig.appName,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Obx(
                    () => SegmentedButton<String>(
                      showSelectedIcon: false,
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                      ),
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('EN')),
                        ButtonSegment(value: 'bn', label: Text('বাংলা')),
                      ],
                      selected: {_settings.localeCode.value},
                      onSelectionChanged: (v) => _settings.setLocale(v.first),
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
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height * 0.55,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Hero(icon: icon),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            title.tr,
                            style: theme.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.ms),
                          Text(
                            body.tr,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: s.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: i == _index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: i == _index ? s.primary : s.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: last
                          ? _finish
                          : () => _page.nextPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                            ),
                      child: Text(last ? 'get_started'.tr : 'next'.tr),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    height: 44,
                    child: last
                        ? null
                        : TextButton(
                            onPressed: _finish,
                            child: Text('skip'.tr),
                          ),
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

/// Soft concentric rings around an icon tile.
class _Hero extends StatelessWidget {
  const _Hero({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      width: 168,
      height: 168,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: s.primaryContainer.withValues(alpha: 0.45),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: s.primaryContainer.withValues(alpha: 0.8),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppPalette.brandGradient,
            ),
          ),
          child: Icon(icon, size: 36, color: Colors.white),
        ),
      ),
    );
  }
}
