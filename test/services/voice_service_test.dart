import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/app/translations.dart';
import 'package:localmind_ai/services/settings_service.dart';
import 'package:localmind_ai/services/voice/voice_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('localmind/voice');
  const events = EventChannel('localmind/voice/events');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  group('pure helpers', () {
    test('availability parsing', () {
      expect(parseSttAvailability(null), SttAvailability.noRecognizer);
      expect(
        parseSttAvailability({'onDevice': false, 'reason': 'sdk'}),
        SttAvailability.sdkTooOld,
      );
      expect(
        parseSttAvailability({'onDevice': true, 'languageStatus': 'installed'}),
        SttAvailability.installed,
      );
      expect(
        parseSttAvailability({
          'onDevice': true,
          'languageStatus': 'unsupported',
        }),
        SttAvailability.unsupportedLanguage,
      );
      expect(
        parseSttAvailability({'onDevice': true}),
        SttAvailability.unknownLanguage,
      );
    });

    test('only installed or unknown languages may be tried', () {
      expect(canTryListening(SttAvailability.installed), isTrue);
      expect(canTryListening(SttAvailability.unknownLanguage), isTrue);
      expect(canTryListening(SttAvailability.downloadable), isFalse);
      expect(canTryListening(SttAvailability.noRecognizer), isFalse);
    });

    test('every status and error has en and bn text', () {
      final keys = [
        for (final a in SttAvailability.values) 'voice_stt_${a.name}',
        for (final code in [-1, 1, 2, 6, 7, 8, 9, 12, 13]) sttErrorKey(code),
      ];
      for (final k in keys) {
        expect(AppTranslations.en, contains(k));
        expect(AppTranslations.bn, contains(k));
      }
    });

    test('speech text drops code and Markdown symbols', () {
      const md =
          '# Title\n- **Bold** item\n```dart\nprint(1);\n```\nSee [docs](https://x.y) and `code`.';
      final t = textForSpeech(md);
      expect(t, isNot(contains('print')));
      expect(t, isNot(contains('**')));
      expect(t, isNot(contains('https')));
      expect(t, contains('Bold item'));
      expect(t, contains('docs'));
      expect(t, contains('code'));
      expect(t, isNot(contains(r'$1')));
    });
  });

  group('VoiceService', () {
    late List<MethodCall> calls;
    late Map<String, Object?> replies;
    late void Function(Object?) sendEvent;

    setUp(() {
      calls = [];
      replies = {
        'sttAvailability': {'onDevice': true, 'languageStatus': 'installed'},
        'ttsVoices': ['en-us-x-voice'],
        'requestMicPermission': true,
        'startListening': true,
      };
      messenger.setMockMethodCallHandler(channel, (c) async {
        calls.add(c);
        return replies[c.method] ?? true;
      });
      messenger.setMockStreamHandler(
        events,
        MockStreamHandler.inline(
          onListen: (_, sink) => sendEvent = sink.success,
        ),
      );
    });

    Future<VoiceService> make({bool enabled = true}) async {
      SharedPreferences.setMockInitialValues({'voiceEnabled': enabled});
      final settings = SettingsService(await SharedPreferences.getInstance());
      final v = VoiceService(settings, channel: channel, events: events);
      v.onInit();
      await Future<void>.delayed(Duration.zero);
      return v;
    }

    test('does not touch the native side while voice is off', () async {
      await make(enabled: false);
      expect(calls.map((c) => c.method), isNot(contains('sttAvailability')));
    });

    test('reports availability for the UI language', () async {
      final v = await make();
      expect(v.stt.value, SttAvailability.installed);
      expect(v.ttsAvailable.value, isTrue);
      expect(calls.first.arguments, {'lang': 'en-US'});
    });

    test('refused permission never starts the recognizer', () async {
      replies['requestMicPermission'] = false;
      final v = await make();
      expect(await v.listen(), isNull);
      expect(v.lastError.value, 'voice_err_permission');
      expect(calls.map((c) => c.method), isNot(contains('startListening')));
      expect(v.listening.value, isFalse);
    });

    test('final transcript completes listen()', () async {
      final v = await make();
      final future = v.listen();
      await Future<void>.delayed(Duration.zero);
      expect(v.listening.value, isTrue);
      sendEvent({'type': 'partial', 'text': 'hello'});
      sendEvent({'type': 'final', 'text': 'hello world'});
      expect(await future, 'hello world');
      expect(v.listening.value, isFalse);
    });

    test('recognizer error keeps partial text and maps the error', () async {
      final v = await make();
      final future = v.listen();
      await Future<void>.delayed(Duration.zero);
      sendEvent({'type': 'partial', 'text': 'half a sentence'});
      sendEvent({'type': 'error', 'code': 7});
      expect(await future, 'half a sentence');
      expect(v.lastError.value, 'voice_err_no_speech');
    });

    test('going to the background closes the microphone', () async {
      final v = await make();
      final future = v.listen();
      await Future<void>.delayed(Duration.zero);
      v.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(await future, isNull);
      expect(calls.map((c) => c.method), contains('cancelListening'));
      expect(v.listening.value, isFalse);
    });

    test('read aloud toggles and clears when done', () async {
      final v = await make();
      expect(await v.toggleSpeak('m1', '**Hi** there'), isTrue);
      final speak = calls.lastWhere((c) => c.method == 'speak');
      expect((speak.arguments as Map)['text'], 'Hi there');
      expect(v.speakingId.value, 'm1');
      sendEvent({'type': 'ttsDone', 'id': 'm1'});
      await Future<void>.delayed(Duration.zero);
      expect(v.speakingId.value, isNull);
    });

    test('no offline voice reports an error', () async {
      replies['speak'] = false;
      final v = await make();
      expect(await v.toggleSpeak('m1', 'text'), isFalse);
      expect(v.lastError.value, 'voice_err_no_voice');
    });
  });
}
