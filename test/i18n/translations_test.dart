import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/app/translations.dart';

void main() {
  test('English and Bengali have exactly the same keys', () {
    final en = AppTranslations.en.keys.toSet();
    final bn = AppTranslations.bn.keys.toSet();
    expect(en.difference(bn), isEmpty, reason: 'missing in bn');
    expect(bn.difference(en), isEmpty, reason: 'missing in en');
  });

  test('every literal key used with .tr exists', () {
    final pattern = RegExp(r"'([a-z0-9_]+)'\.tr(Params)?\b");
    final missing = <String>{};
    for (final f in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      for (final m in pattern.allMatches(f.readAsStringSync())) {
        if (!AppTranslations.en.containsKey(m.group(1))) {
          missing.add(m.group(1)!);
        }
      }
    }
    expect(missing, isEmpty);
  });

  test('placeholders match between languages', () {
    final ph = RegExp(r'@[a-z]+');
    for (final key in AppTranslations.en.keys) {
      final a = ph
          .allMatches(AppTranslations.en[key]!)
          .map((m) => m[0])
          .toSet();
      final b = ph
          .allMatches(AppTranslations.bn[key]!)
          .map((m) => m[0])
          .toSet();
      expect(b, a, reason: key);
    }
  });
}
