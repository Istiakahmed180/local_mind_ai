import 'dart:io';
import 'dart:typed_data';

const _ggufMagic = [0x47, 0x47, 0x55, 0x46]; // "GGUF"

/// Smallest file we accept as a model. Real chat models are far larger.
const minModelBytes = 16 * 1024 * 1024;

enum GgufCheck { ok, missing, tooSmall, notGguf, unsupportedVersion }

/// Cheap structural check before handing a file to the native parser.
/// This is not a security boundary: llama.cpp still parses untrusted input.
Future<GgufCheck> checkGgufFile(String path) async {
  final file = File(path);
  if (!await file.exists()) return GgufCheck.missing;
  if (await file.length() < minModelBytes) return GgufCheck.tooSmall;
  final raf = await file.open();
  try {
    final header = await raf.read(8);
    return checkGgufHeader(header);
  } finally {
    await raf.close();
  }
}

GgufCheck checkGgufHeader(Uint8List header) {
  if (header.length < 8) return GgufCheck.tooSmall;
  for (var i = 0; i < 4; i++) {
    if (header[i] != _ggufMagic[i]) return GgufCheck.notGguf;
  }
  final version = ByteData.sublistView(
    header,
    4,
    8,
  ).getUint32(0, Endian.little);
  if (version < 2 || version > 3) return GgufCheck.unsupportedVersion;
  return GgufCheck.ok;
}
