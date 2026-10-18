import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../downloads/model_downloader.dart';
import 'text_extraction.dart';

/// One Tesseract language file from `assets/models/catalog.json`.
class OcrLanguage {
  const OcrLanguage({
    required this.id,
    required this.name,
    required this.url,
    required this.sizeBytes,
    required this.sha256,
    required this.license,
  });

  final String id;
  final String name;
  final Uri url;
  final int sizeBytes;
  final String sha256;
  final String license;

  String get fileName => '$id.traineddata';

  static final _id = RegExp(r'^[a-z_]{2,16}$');
  static final _sha = RegExp(r'^[0-9a-f]{64}$');

  factory OcrLanguage.fromJson(
    Map<String, dynamic> j,
    Map<String, String> hosts,
  ) {
    final id = j['id'];
    final host = hosts[j['host']];
    final path = j['path'];
    final size = j['sizeBytes'];
    final sha = j['sha256'];
    if (id is! String || !_id.hasMatch(id)) {
      throw FormatException('Bad OCR language id: $id');
    }
    if (host == null || !host.startsWith('https://')) {
      throw FormatException('OCR language $id needs an https host');
    }
    if (path is! String || !path.endsWith('/$id.traineddata')) {
      throw FormatException('OCR language $id has an unexpected path');
    }
    if (size is! int || size <= 0) {
      throw FormatException('OCR language $id has a bad size');
    }
    if (sha is! String || !_sha.hasMatch(sha)) {
      throw FormatException('OCR language $id has a bad sha256');
    }
    return OcrLanguage(
      id: id,
      name: j['name'] as String,
      url: Uri.parse(host).resolve(path),
      sizeBytes: size,
      sha256: sha,
      license: j['license'] as String,
    );
  }
}

List<OcrLanguage> parseOcrLanguages(Map<String, dynamic> catalog) {
  final hosts = (catalog['hosts'] as Map).cast<String, String>();
  final list = (catalog['ocrLanguages'] as List?) ?? const [];
  return [
    for (final j in list.cast<Map<String, dynamic>>())
      OcrLanguage.fromJson(j, hosts),
  ];
}

/// Tesseract language string: English first when present, then the rest.
String ocrLanguageString(Iterable<String> installed) {
  final ids = installed.toList()..sort();
  if (ids.remove('eng')) ids.insert(0, 'eng');
  return ids.join('+');
}

enum OcrLangState { notInstalled, downloading, installed, failed }

/// Offline OCR for scanned PDFs: language files plus the native Tesseract
/// bridge. Nothing leaves the device; only language files are downloaded.
class OcrService extends GetxService implements PageOcr {
  OcrService({
    required Future<int> Function() freeBytes,
    MethodChannel? channel,
    Future<Directory> Function()? baseDir,
    ModelDownloader? downloader,
  }) : _channel = channel ?? const MethodChannel('localmind/ocr'),
       _baseDir = baseDir ?? getApplicationSupportDirectory,
       _downloader = downloader ?? ModelDownloader(freeBytes: freeBytes);

  final MethodChannel _channel;
  final Future<Directory> Function() _baseDir;
  final ModelDownloader _downloader;

  final languages = <OcrLanguage>[].obs;
  final states = <String, OcrLangState>{}.obs;
  final _cancels = <String, CancelSignal>{};
  late String _dataPath;

  /// Folder that contains `tessdata/`, as Tesseract expects.
  String get dataPath => _dataPath;
  String get _tessdata => p.join(_dataPath, 'tessdata');

  Future<OcrService> init({Map<String, dynamic>? catalog}) async {
    _dataPath = p.join((await _baseDir()).path, 'ocr');
    await Directory(_tessdata).create(recursive: true);
    final json =
        catalog ??
        jsonDecode(await rootBundle.loadString('assets/models/catalog.json'))
            as Map<String, dynamic>;
    languages.assignAll(parseOcrLanguages(json));
    await refresh();
    return this;
  }

  /// A language counts as installed only if its file has the catalog size;
  /// downloads are checked against SHA-256 before they are kept.
  Future<void> refresh() async {
    for (final l in languages) {
      if (states[l.id] == OcrLangState.downloading) continue;
      final f = File(p.join(_tessdata, l.fileName));
      states[l.id] = await f.exists() && await f.length() == l.sizeBytes
          ? OcrLangState.installed
          : OcrLangState.notInstalled;
    }
  }

  List<String> get installedIds => [
    for (final l in languages)
      if (states[l.id] == OcrLangState.installed) l.id,
  ];

  @override
  bool get ready => installedIds.isNotEmpty;

  Future<void> download(OcrLanguage l) async {
    if (states[l.id] == OcrLangState.downloading) return;
    states[l.id] = OcrLangState.downloading;
    final cancel = _cancels[l.id] = CancelSignal();
    try {
      await _downloader.download(
        url: l.url,
        targetPath: p.join(_tessdata, l.fileName),
        expectedBytes: l.sizeBytes,
        expectedSha256: l.sha256,
        onProgress: (_) {},
        cancel: cancel,
      );
      states[l.id] = OcrLangState.installed;
      await _release();
    } on DownloadException catch (e) {
      states[l.id] = e.failure == DownloadFailure.cancelled
          ? OcrLangState.notInstalled
          : OcrLangState.failed;
    } finally {
      _cancels.remove(l.id);
    }
  }

  void cancelDownload(String id) => _cancels[id]?.cancel();

  Future<void> remove(OcrLanguage l) async {
    await _release();
    final f = File(p.join(_tessdata, l.fileName));
    if (await f.exists()) await f.delete();
    states[l.id] = OcrLangState.notInstalled;
  }

  @override
  Future<String> recognize(PageImage image) async {
    final langs = ocrLanguageString(installedIds);
    if (langs.isEmpty) return '';
    final r = await _channel.invokeMapMethod<String, Object?>('recognize', {
      'dataPath': _dataPath,
      'langs': langs,
      'width': image.width,
      'height': image.height,
      'pixels': image.gray,
    });
    return (r?['text'] as String?) ?? '';
  }

  /// Frees the native engine so it reloads with the current languages.
  Future<void> _release() async {
    try {
      await _channel.invokeMethod<bool>('release');
    } on MissingPluginException {
      // Not on Android (unit tests).
    }
  }
}
