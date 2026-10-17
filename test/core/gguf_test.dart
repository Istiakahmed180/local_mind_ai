import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/core/gguf.dart';

import '../fakes.dart';

void main() {
  test('accepts GGUF v2 and v3 headers', () {
    expect(
      checkGgufHeader(Uint8List.fromList([0x47, 0x47, 0x55, 0x46, 3, 0, 0, 0])),
      GgufCheck.ok,
    );
    expect(
      checkGgufHeader(Uint8List.fromList([0x47, 0x47, 0x55, 0x46, 2, 0, 0, 0])),
      GgufCheck.ok,
    );
  });

  test('rejects other magic and versions', () {
    expect(
      checkGgufHeader(Uint8List.fromList([0x50, 0x4B, 3, 4, 0, 0, 0, 0])),
      GgufCheck.notGguf,
    );
    expect(
      checkGgufHeader(Uint8List.fromList([0x47, 0x47, 0x55, 0x46, 9, 0, 0, 0])),
      GgufCheck.unsupportedVersion,
    );
    expect(checkGgufHeader(Uint8List(3)), GgufCheck.tooSmall);
  });

  test('checks files on disk', () async {
    final dir = await Directory.systemTemp.createTemp('gguf');
    addTearDown(() => dir.delete(recursive: true));
    expect(await checkGgufFile('${dir.path}/missing.gguf'), GgufCheck.missing);
    final small = File('${dir.path}/small.gguf')
      ..writeAsBytesSync([0x47, 0x47, 0x55, 0x46, 3, 0, 0, 0]);
    expect(await checkGgufFile(small.path), GgufCheck.tooSmall);
    final ok = await writeFakeGguf('${dir.path}/ok.gguf');
    expect(await checkGgufFile(ok.path), GgufCheck.ok);
  });
}
