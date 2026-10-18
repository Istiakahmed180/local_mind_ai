import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Static guard: only the model downloader may perform network I/O.
/// Inference, chat, persistence and UI code must not import HTTP clients.
void main() {
  const allowed = {'lib/services/downloads/model_downloader.dart'};
  final networkApis = RegExp(
    r"package:http/|HttpClient\(|Socket\.connect|WebSocket|package:dio/",
  );

  test('no network APIs outside the model downloader', () {
    final offenders = <String>[];
    for (final f in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      final path = f.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') || allowed.contains(path)) continue;
      if (networkApis.hasMatch(f.readAsStringSync())) offenders.add(path);
    }
    expect(offenders, isEmpty);
  });

  test('inference runtime loads models only from local paths', () {
    final src = File('lib/services/inference/llamadart_runtime.dart')
        .readAsStringSync();
    expect(src, contains('ModelSource.path('));
    expect(src, isNot(contains('ModelSource.url')));
    expect(src, isNot(contains('ModelSource.huggingFace')));
    expect(src, isNot(contains('hf://')));
  });

  test('manifest requests only the reviewed permissions', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final perms = RegExp(r'uses-permission android:name="([^"]+)"')
        .allMatches(manifest)
        .map((m) => m.group(1))
        .toSet();
    expect(perms, {
      'android.permission.INTERNET',
      'android.permission.ACCESS_NETWORK_STATE',
      // Background model downloads (foreground service + its notification).
      'android.permission.FOREGROUND_SERVICE',
      'android.permission.FOREGROUND_SERVICE_DATA_SYNC',
      'android.permission.POST_NOTIFICATIONS',
      // Optional voice input (push-to-talk, runtime permission).
      'android.permission.RECORD_AUDIO',
    });
    expect(manifest, contains('android:allowBackup="false"'));
  });
}
