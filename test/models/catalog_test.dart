import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/domain/model_definition.dart';

Map<String, dynamic> _validEntry() => {
  'id': 'm1',
  'name': 'M1',
  'publisher': 'P',
  'parameters': '1B',
  'quantization': 'Q4_K_M',
  'format': 'gguf',
  'runtime': 'llama.cpp',
  'host': 'hf',
  'repo': 'org/repo',
  'file': 'model-q4.gguf',
  'sizeBytes': 100,
  'sha256': 'a' * 64,
  'license': 'Apache-2.0',
  'licenseUrl': 'https://example.com/license',
  'maxContext': 4096,
  'defaultContext': 2048,
  'minRamGb': 2,
  'languages': ['en'],
  'bengali': 'not_listed',
  'notes': 'n',
};

ModelCatalog _catalog(
  List<Map<String, dynamic>> models, {
  String host = 'https://hf.example',
}) => ModelCatalog.fromJson({
  'schemaVersion': 1,
  'hosts': {'hf': host},
  'models': models,
});

void main() {
  test('bundled catalog parses and every entry is valid', () {
    final raw = File('assets/models/catalog.json').readAsStringSync();
    final catalog = ModelCatalog.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    expect(catalog.models, isNotEmpty);
    expect(catalog.models.where((m) => m.starter), hasLength(1));
    for (final m in catalog.models) {
      expect(m.downloadUrl.scheme, 'https');
      expect(m.downloadUrl.path, endsWith('/resolve/main/${m.fileName}'));
      expect(m.sizeBytes, greaterThan(100 * 1024 * 1024), reason: m.id);
      expect(m.defaultContext, lessThanOrEqualTo(m.maxContext));
    }
  });

  test('catalog is declared as a bundled asset', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      pubspec,
      contains(RegExp(r'^\s+- assets/models/catalog\.json', multiLine: true)),
    );
  });

  test('download URL is built from host, repo and file', () {
    final m = _catalog([_validEntry()]).models.single;
    expect(
      m.downloadUrl.toString(),
      'https://hf.example/org/repo/resolve/main/model-q4.gguf',
    );
  });

  test('rejects non-https hosts', () {
    expect(
      () => _catalog([_validEntry()], host: 'http://hf.example'),
      throwsFormatException,
    );
  });

  test('rejects path traversal in file names', () {
    final e = _validEntry()..['file'] = '../evil.gguf';
    expect(() => _catalog([e]), throwsFormatException);
  });

  test('rejects malformed sha256', () {
    final e = _validEntry()..['sha256'] = 'xyz';
    expect(() => _catalog([e]), throwsFormatException);
  });

  test('rejects duplicate ids', () {
    expect(
      () => _catalog([_validEntry(), _validEntry()]),
      throwsFormatException,
    );
  });

  test('rejects unknown hosts and unsupported formats', () {
    expect(
      () => _catalog([_validEntry()..['host'] = 'nope']),
      throwsFormatException,
    );
    expect(
      () => _catalog([_validEntry()..['format'] = 'safetensors']),
      throwsFormatException,
    );
  });

  test('rejects defaultContext larger than maxContext', () {
    final e = _validEntry()..['defaultContext'] = 8192;
    expect(() => _catalog([e]), throwsFormatException);
  });

  test('RAM estimate is larger than file size and grows with context', () {
    final m = _catalog([_validEntry()..['sizeBytes'] = 500000000])
        .models
        .single;
    final small = m.estimatedRamBytes(1024);
    final large = m.estimatedRamBytes(8192);
    expect(small.low, greaterThan(m.sizeBytes));
    expect(small.high, greaterThan(small.low));
    expect(large.high, greaterThan(small.high));
  });
}
