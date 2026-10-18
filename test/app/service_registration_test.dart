import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `x = Get.put(Foo())` where `x` is nullable registers `Foo?`, and
/// `Get.find<Foo>()` then fails at runtime. Require an explicit type argument
/// whenever Get.put's result is assigned to a field.
void main() {
  test('Get.put assigned to a field has an explicit type', () {
    final src = File('lib/main.dart').readAsStringSync();
    final assignedPut = RegExp(r'\w+\.\w+\s*=\s*Get\.put\(');
    // The pattern catches the form that caused the bug ...
    expect(
      assignedPut.hasMatch(
        'documents.semantic = Get.put(\n  EmbeddingService(',
      ),
      isTrue,
    );
    // ... and allows the fixed form.
    expect(
      assignedPut.hasMatch('documents.semantic = Get.put<EmbeddingService>('),
      isFalse,
    );
    expect(assignedPut.hasMatch(src), isFalse);
  });
}
