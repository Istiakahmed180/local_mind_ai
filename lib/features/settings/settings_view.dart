import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';
import '../../data/local/database.dart';
import '../../services/documents/document_service.dart';
import '../../services/inference/model_runtime_service.dart';
import '../../services/model_service.dart';
import '../../services/settings_service.dart';
import '../../services/voice/voice_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const _contextOptions = [512, 1024, 2048, 4096, 8192];
  static const _maxTokenOptions = [128, 256, 512, 1024, 2048];

  @override
  Widget build(BuildContext context) {
    final s = Get.find<SettingsService>();
    final theme = Theme.of(context);
    Widget header(String key) => SectionLabel(key.tr);

    return Scaffold(
      appBar: AppBar(title: Text('nav_settings'.tr)),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          children: [
            header('appearance'),
            _Group(
              children: [
                ListTile(
                  leading: const Icon(Icons.translate_rounded),
                  title: Text('language'.tr),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('EN')),
                      ButtonSegment(value: 'bn', label: Text('বাং')),
                    ],
                    selected: {s.localeCode.value},
                    onSelectionChanged: (v) => s.setLocale(v.first),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.contrast_rounded),
                  title: Text('theme'.tr),
                  trailing: DropdownButton<ThemeMode>(
                    value: s.themeMode.value,
                    underline: const SizedBox.shrink(),
                    onChanged: (m) => m == null ? null : s.setThemeMode(m),
                    items: [
                      for (final m in ThemeMode.values)
                        DropdownMenuItem(
                          value: m,
                          child: Text('theme_${m.name}'.tr),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            header('generation'),
            _Group(
              children: [
                _SliderTile(
                  title: 'temperature'.tr,
                  value: s.temperature.value,
                  min: 0,
                  max: 1.5,
                  divisions: 15,
                  onChanged: s.setTemperature,
                ),
                _SliderTile(
                  title: 'top_p'.tr,
                  value: s.topP.value,
                  min: 0.1,
                  max: 1,
                  divisions: 9,
                  onChanged: s.setTopP,
                ),
                ListTile(
                  title: Text('max_tokens'.tr),
                  trailing: DropdownButton<int>(
                    value: s.maxTokens.value,
                    underline: const SizedBox.shrink(),
                    onChanged: (v) => v == null ? null : s.setMaxTokens(v),
                    items: [
                      for (final v in _maxTokenOptions)
                        DropdownMenuItem(value: v, child: Text('$v')),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('context_length'.tr),
                  subtitle: Text('context_length_hint'.tr),
                  trailing: DropdownButton<int>(
                    value: s.contextSize.value,
                    underline: const SizedBox.shrink(),
                    onChanged: (v) => v == null ? null : s.setContextSize(v),
                    items: [
                      for (final v in _contextOptions)
                        DropdownMenuItem(value: v, child: Text('$v')),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: Text('summarize_long_chats'.tr),
                  subtitle: Text('summarize_long_chats_hint'.tr),
                  value: s.summarizeLongChats.value,
                  onChanged: s.setSummarizeLongChats,
                ),
                SwitchListTile(
                  title: Text('low_resource_mode'.tr),
                  subtitle: Text('low_resource_hint'.tr),
                  value: s.lowResource.value,
                  onChanged: s.setLowResource,
                ),
                ListTile(
                  title: Text('system_prompt'.tr),
                  subtitle: Text(
                    s.systemPrompt.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _editPrompt(context, s),
                ),
              ],
            ),
            header('voice'),
            _Group(children: [const _VoiceSettings()]),
            header('privacy_section'),
            _Group(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: Text('privacy_and_permissions'.tr),
                  onTap: () => Get.toNamed(Routes.privacy),
                ),
                ListTile(
                  leading: const Icon(Icons.psychology_alt_outlined),
                  title: Text('memory'.tr),
                  subtitle: Text(
                    s.useMemory.value ? 'memory_on'.tr : 'memory_off'.tr,
                  ),
                  onTap: () => Get.toNamed(Routes.memory),
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text('my_reports'.tr),
                  onTap: () => Get.toNamed(Routes.reports),
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'clear_all_data'.tr,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: Text('clear_all_data_hint'.tr),
                  onTap: () => _clearAll(context),
                ),
              ],
            ),
            header('about'),
            _Group(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text('about_and_licenses'.tr),
                  onTap: () => Get.toNamed(Routes.about),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _editPrompt(BuildContext context, SettingsService s) async {
    final ctrl = TextEditingController(text: s.systemPrompt.value);
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('system_prompt'.tr),
        content: TextField(controller: ctrl, maxLines: 6, maxLength: 2000),
        actions: [
          TextButton(
            onPressed: () => ctrl.text = SettingsService.defaultSystemPromptEn,
            child: Text('reset'.tr),
          ),
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
    if (value != null && value.isNotEmpty) await s.setSystemPrompt(value);
  }

  Future<void> _clearAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('clear_all_data'.tr),
        content: Text('clear_all_data_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('delete_everything'.tr),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final runtime = Get.find<ModelRuntimeService>();
    final models = Get.find<ModelService>();
    await runtime.unload();
    for (final m in models.installed.toList()) {
      await models.delete(m.id);
    }
    for (final def in models.catalog.value.models) {
      await models.discardDownload(def);
    }
    await Get.find<DocumentService>().removeAll();
    await Get.find<AppDatabase>().clearAll();
    await Get.find<SettingsService>().clear();
    Get.offAllNamed(Routes.onboarding);
  }
}

class _VoiceSettings extends StatelessWidget {
  const _VoiceSettings();

  @override
  Widget build(BuildContext context) {
    final s = Get.find<SettingsService>();
    final v = Get.find<VoiceService>();
    final theme = Theme.of(context);
    return Obx(() {
      final on = s.voiceEnabled.value;
      final stt = v.stt.value;
      final tts = v.ttsAvailable.value;
      return Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.mic_none_rounded),
            title: Text('voice_enable'.tr),
            subtitle: Text('voice_enable_hint'.tr),
            value: on,
            onChanged: s.setVoiceEnabled,
          ),
          if (on) ...[
            ListTile(
              dense: true,
              title: Text('voice_input_status'.tr),
              subtitle: Text('voice_stt_${stt.name}'.tr),
              trailing: stt == SttAvailability.downloadable
                  ? TextButton(
                      onPressed: () => _download(context, v),
                      child: Text('download'.tr),
                    )
                  : null,
            ),
            ListTile(
              dense: true,
              title: Text('voice_output_status'.tr),
              subtitle: Text(
                tts == null
                    ? 'voice_stt_checking'.tr
                    : tts
                    ? 'voice_tts_ok'.tr
                    : 'voice_tts_missing'.tr,
              ),
              trailing: IconButton(
                tooltip: 'voice_recheck'.tr,
                onPressed: v.refresh,
                icon: const Icon(Icons.refresh),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                'voice_privacy_note'.tr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Future<void> _download(BuildContext context, VoiceService v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('voice_download_title'.tr),
        content: Text('voice_download_body'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('download'.tr),
          ),
        ],
      ),
    );
    if (ok == true) await v.downloadLanguage();
  }
}

/// Settings rows grouped in one card, separated by hairlines.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        for (final (i, c) in children.indexed) ...[
          if (i > 0)
            const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
          c,
        ],
      ],
    ),
  );
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.ms,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: theme.listTileTheme.titleTextStyle),
              ),
              StatusPill(value.toStringAsFixed(1), tone: PillTone.primary),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(1),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.ms),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
