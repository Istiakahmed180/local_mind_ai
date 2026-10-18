import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Long-press on a message must reach the app's message menu (copy, report,
/// delete, remember, read aloud). SelectableText inside the bubble swallows
/// the gesture, which made reporting unreachable.
void main() {
  test('chat bubbles do not use SelectableText', () {
    final src = File('lib/features/chat/chat_view.dart').readAsStringSync();
    final bubble = src.substring(src.indexOf('class _Bubble'));
    final end = bubble.indexOf('\nclass ', 1);
    expect(bubble.substring(0, end), isNot(contains('SelectableText(')));
  });
}
