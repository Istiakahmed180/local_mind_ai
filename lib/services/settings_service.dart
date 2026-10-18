import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'inference/inference_runtime.dart';

class SettingsService extends GetxService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _kOnboarded = 'onboarded';
  static const _kLocale = 'locale';
  static const _kTheme = 'themeMode';
  static const _kActiveModel = 'activeModelId';
  static const _kTemperature = 'temperature';
  static const _kTopP = 'topP';
  static const _kMaxTokens = 'maxTokens';
  static const _kContext = 'contextSize';
  static const _kSystemPrompt = 'systemPrompt';
  static const _kLowResource = 'lowResource';
  static const _kAgentHistorySearch = 'agentHistorySearch';
  static const _kUseMemory = 'useMemory';
  static const _kVoice = 'voiceEnabled';
  static const _kSummarize = 'summarizeLongChats';
  static const _kEmbeddingModel = 'embeddingModelId';

  static const defaultSystemPromptEn =
      'You are a helpful assistant running entirely on the user\'s phone. '
      'Answer concisely. If you are unsure, say so. '
      'Refuse requests for harmful, hateful, sexual or illegal content.';

  late final onboarded = (_prefs.getBool(_kOnboarded) ?? false).obs;
  late final localeCode = (_prefs.getString(_kLocale) ?? 'en').obs;
  late final themeMode =
      ThemeMode.values[_prefs.getInt(_kTheme) ?? ThemeMode.system.index].obs;
  late final activeModelId = RxnString(_prefs.getString(_kActiveModel));
  late final temperature = (_prefs.getDouble(_kTemperature) ?? 0.7).obs;
  late final topP = (_prefs.getDouble(_kTopP) ?? 0.9).obs;
  late final maxTokens = (_prefs.getInt(_kMaxTokens) ?? 512).obs;
  late final contextSize = (_prefs.getInt(_kContext) ?? 2048).obs;
  late final systemPrompt =
      (_prefs.getString(_kSystemPrompt) ?? defaultSystemPromptEn).obs;
  late final lowResource = (_prefs.getBool(_kLowResource) ?? false).obs;

  /// Off by default: the agent may only search chat history after opt-in.
  late final agentHistorySearch =
      (_prefs.getBool(_kAgentHistorySearch) ?? false).obs;

  /// Off by default: saved memories are used in prompts only when enabled.
  late final useMemory = (_prefs.getBool(_kUseMemory) ?? false).obs;

  /// Off by default: no microphone button or read-aloud until switched on.
  late final voiceEnabled = (_prefs.getBool(_kVoice) ?? false).obs;

  /// On by default: long chats are summarized instead of silently dropping
  /// the oldest messages.
  late final summarizeLongChats = (_prefs.getBool(_kSummarize) ?? true).obs;

  /// Model used for meaning-based document search; null means keyword only.
  late final embeddingModelId = RxnString(_prefs.getString(_kEmbeddingModel));

  Locale get locale => localeCode.value == 'bn'
      ? const Locale('bn', 'BD')
      : const Locale('en', 'US');

  GenerationSettings get generation => GenerationSettings(
    temperature: temperature.value,
    topP: topP.value,
    maxTokens: lowResource.value
        ? maxTokens.value.clamp(64, 256)
        : maxTokens.value,
  );

  int get effectiveContextSize => lowResource.value
      ? contextSize.value.clamp(512, 1024)
      : contextSize.value;

  Future<void> setOnboarded() async {
    onboarded.value = true;
    await _prefs.setBool(_kOnboarded, true);
  }

  Future<void> setLocale(String code) async {
    localeCode.value = code;
    await _prefs.setString(_kLocale, code);
    Get.updateLocale(locale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs.setInt(_kTheme, mode.index);
    Get.changeThemeMode(mode);
  }

  Future<void> setActiveModel(String? id) async {
    activeModelId.value = id;
    id == null
        ? await _prefs.remove(_kActiveModel)
        : await _prefs.setString(_kActiveModel, id);
  }

  Future<void> setTemperature(double v) async {
    temperature.value = v;
    await _prefs.setDouble(_kTemperature, v);
  }

  Future<void> setTopP(double v) async {
    topP.value = v;
    await _prefs.setDouble(_kTopP, v);
  }

  Future<void> setMaxTokens(int v) async {
    maxTokens.value = v;
    await _prefs.setInt(_kMaxTokens, v);
  }

  Future<void> setContextSize(int v) async {
    contextSize.value = v;
    await _prefs.setInt(_kContext, v);
  }

  Future<void> setSystemPrompt(String v) async {
    systemPrompt.value = v;
    await _prefs.setString(_kSystemPrompt, v);
  }

  Future<void> setLowResource(bool v) async {
    lowResource.value = v;
    await _prefs.setBool(_kLowResource, v);
  }

  Future<void> setAgentHistorySearch(bool v) async {
    agentHistorySearch.value = v;
    await _prefs.setBool(_kAgentHistorySearch, v);
  }

  Future<void> setUseMemory(bool v) async {
    useMemory.value = v;
    await _prefs.setBool(_kUseMemory, v);
  }

  Future<void> setVoiceEnabled(bool v) async {
    voiceEnabled.value = v;
    await _prefs.setBool(_kVoice, v);
  }

  Future<void> setSummarizeLongChats(bool v) async {
    summarizeLongChats.value = v;
    await _prefs.setBool(_kSummarize, v);
  }

  Future<void> setEmbeddingModelId(String? id) async {
    embeddingModelId.value = id;
    id == null
        ? await _prefs.remove(_kEmbeddingModel)
        : await _prefs.setString(_kEmbeddingModel, id);
  }

  Future<void> clear() async {
    await _prefs.clear();
    onboarded.value = false;
    activeModelId.value = null;
    agentHistorySearch.value = false;
    useMemory.value = false;
    voiceEnabled.value = false;
    summarizeLongChats.value = true;
    embeddingModelId.value = null;
  }
}
