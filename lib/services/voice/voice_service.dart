import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../settings_service.dart';

/// Whether on-device speech input works for the current language.
enum SttAvailability {
  checking,

  /// Android older than 12 has no on-device recognizer API.
  sdkTooOld,

  /// The phone has no on-device recognizer.
  noRecognizer,

  /// The recognizer exists but has no model for this language.
  unsupportedLanguage,

  /// A language pack exists but is not installed.
  downloadable,

  /// A language pack download is in progress.
  pending,

  installed,

  /// Android 12 cannot report languages; trying is the only way to know.
  unknownLanguage,
}

SttAvailability parseSttAvailability(Map<Object?, Object?>? m) {
  if (m == null) return SttAvailability.noRecognizer;
  if (m['onDevice'] != true) {
    return m['reason'] == 'sdk'
        ? SttAvailability.sdkTooOld
        : SttAvailability.noRecognizer;
  }
  return switch (m['languageStatus']) {
    'installed' => SttAvailability.installed,
    'pending' => SttAvailability.pending,
    'downloadable' => SttAvailability.downloadable,
    'unsupported' => SttAvailability.unsupportedLanguage,
    _ => SttAvailability.unknownLanguage,
  };
}

bool canTryListening(SttAvailability a) =>
    a == SttAvailability.installed || a == SttAvailability.unknownLanguage;

/// Translation key for an Android `SpeechRecognizer.ERROR_*` code.
String sttErrorKey(int code) => switch (code) {
  6 || 7 => 'voice_err_no_speech', // SPEECH_TIMEOUT, NO_MATCH
  9 => 'voice_err_permission', // INSUFFICIENT_PERMISSIONS
  12 || 13 => 'voice_err_language', // LANGUAGE_NOT_SUPPORTED / UNAVAILABLE
  2 || 4 || 1 => 'voice_err_network', // network-only engine refused offline
  8 => 'voice_err_busy', // RECOGNIZER_BUSY
  _ => 'voice_err_generic',
};

/// Plain text for reading aloud: drops code blocks and Markdown symbols.
String textForSpeech(String s) => s
    .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
    .replaceAllMapped(RegExp(r'`([^`]*)`'), (m) => m[1]!)
    .replaceAllMapped(RegExp(r'!?\[([^\]]*)\]\([^)]*\)'), (m) => m[1]!)
    .replaceAll(RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true), '')
    .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '')
    .replaceAll(RegExp(r'[*_~>|]'), '')
    .replaceAll(RegExp(r'[ \t]+'), ' ')
    .trim();

/// Optional on-device voice input and read-aloud. Off by default.
class VoiceService extends GetxService with WidgetsBindingObserver {
  VoiceService(this._settings, {MethodChannel? channel, EventChannel? events})
    : _channel = channel ?? const MethodChannel('localmind/voice'),
      _events = events ?? const EventChannel('localmind/voice/events');

  /// Longest single recording; listening always stops after this.
  static const maxListen = Duration(seconds: 30);

  final SettingsService _settings;
  final MethodChannel _channel;
  final EventChannel _events;

  final stt = SttAvailability.checking.obs;
  final ttsAvailable = RxnBool();
  final listening = false.obs;
  final partial = ''.obs;
  final level = 0.0.obs;
  final speakingId = RxnString();
  final lastError = RxnString();

  StreamSubscription<dynamic>? _sub;
  Timer? _cap;
  Completer<String?>? _result;

  String get languageTag =>
      _settings.localeCode.value == 'bn' ? 'bn-BD' : 'en-US';

  bool get enabled => _settings.voiceEnabled.value;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _sub = _events.receiveBroadcastStream().listen(_onEvent, onError: (_) {});
    ever(_settings.localeCode, (_) => refresh());
    ever(_settings.voiceEnabled, (_) => refresh());
    refresh();
  }

  Future<void> refresh() async {
    if (!enabled) return;
    stt.value = SttAvailability.checking;
    try {
      final m = await _channel.invokeMapMethod<Object?, Object?>(
        'sttAvailability',
        {'lang': languageTag},
      );
      stt.value = parseSttAvailability(m);
      final voices = await _channel.invokeListMethod<String>('ttsVoices', {
        'lang': languageTag,
      });
      ttsAvailable.value = voices?.isNotEmpty ?? false;
    } on MissingPluginException {
      stt.value = SttAvailability.noRecognizer;
      ttsAvailable.value = false;
    }
  }

  /// Starts listening. Completes with the final transcript, or null if
  /// nothing was recognised, permission was refused or it was cancelled.
  Future<String?> listen() async {
    if (listening.value) return null;
    lastError.value = null;
    await stopSpeaking();
    try {
      final granted =
          await _channel.invokeMethod<bool>('requestMicPermission') ?? false;
      if (!granted) {
        lastError.value = 'voice_err_permission';
        return null;
      }
      partial.value = '';
      final started =
          await _channel.invokeMethod<bool>('startListening', {
            'lang': languageTag,
          }) ??
          false;
      if (!started) {
        lastError.value = 'voice_err_unavailable';
        return null;
      }
    } on MissingPluginException {
      lastError.value = 'voice_err_unavailable';
      return null;
    }
    listening.value = true;
    _result = Completer<String?>();
    _cap = Timer(maxListen, stopListening);
    return _result!.future;
  }

  /// Stops recording and lets the recognizer return what it heard.
  Future<void> stopListening() async {
    _cap?.cancel();
    if (!listening.value) return;
    await _invoke('stopListening');
  }

  /// Stops recording and discards the result.
  Future<void> cancelListening() async {
    _cap?.cancel();
    if (!listening.value) return;
    await _invoke('cancelListening');
    _finish(null);
  }

  Future<void> downloadLanguage() async {
    await _invoke('downloadSpeechLanguage', {'lang': languageTag});
    await refresh();
  }

  /// Reads [text] aloud, or stops if [id] is already being read.
  Future<bool> toggleSpeak(String id, String text) async {
    if (speakingId.value == id) {
      await stopSpeaking();
      return true;
    }
    await cancelListening();
    final clean = textForSpeech(text);
    if (clean.isEmpty) return false;
    try {
      final ok =
          await _channel.invokeMethod<bool>('speak', {
            'text': clean,
            'lang': languageTag,
            'id': id,
          }) ??
          false;
      speakingId.value = ok ? id : null;
      if (!ok) lastError.value = 'voice_err_no_voice';
      return ok;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> stopSpeaking() async {
    if (speakingId.value == null) return;
    speakingId.value = null;
    await _invoke('stopSpeaking');
  }

  void _onEvent(dynamic e) {
    if (e is! Map) return;
    switch (e['type']) {
      case 'partial':
        partial.value = '${e['text'] ?? ''}';
      case 'level':
        level.value = ((e['db'] as num?)?.toDouble() ?? 0).clamp(0, 12) / 12;
      case 'final':
        final text = '${e['text'] ?? ''}'.trim();
        _finish(text.isEmpty ? null : text);
      case 'error':
        lastError.value = sttErrorKey((e['code'] as num?)?.toInt() ?? -1);
        _finish(partial.value.trim().isEmpty ? null : partial.value.trim());
      case 'ttsDone' || 'ttsError':
        if (speakingId.value == e['id']) speakingId.value = null;
    }
  }

  void _finish(String? text) {
    _cap?.cancel();
    listening.value = false;
    level.value = 0;
    final r = _result;
    _result = null;
    if (r != null && !r.isCompleted) r.complete(text);
  }

  Future<void> _invoke(String method, [Map<String, Object?>? args]) async {
    try {
      await _channel.invokeMethod<Object?>(method, args);
    } on MissingPluginException {
      // Not on Android (unit tests).
    }
  }

  /// Never keep the microphone or speech running in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      cancelListening();
      stopSpeaking();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _cap?.cancel();
    super.onClose();
  }
}
