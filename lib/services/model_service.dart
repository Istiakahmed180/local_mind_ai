import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/gguf.dart';
import '../data/local/database.dart';
import '../data/repositories/model_repository.dart';
import '../domain/model_definition.dart';
import 'device/device_info_service.dart';
import 'downloads/model_downloader.dart';

enum DownloadStatus { idle, downloading, paused, verifying, failed }

class DownloadState {
  const DownloadState({
    this.status = DownloadStatus.idle,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.failure,
    this.detail,
  });

  final DownloadStatus status;
  final int receivedBytes;
  final int totalBytes;
  final DownloadFailure? failure;
  final String? detail;

  double get fraction => totalBytes == 0 ? 0 : receivedBytes / totalBytes;
}

/// Why an installed model cannot be loaded.
enum LoadBlock { none, fileMissing, sizeMismatch, notGguf, notVerified }

/// Catalog, downloads, imports and deletion of model files.
class ModelService extends GetxService {
  ModelService(this._repo, this._device, {ModelDownloader? downloader})
    : _downloaderOverride = downloader;

  final ModelRepository _repo;
  final DeviceInfoService _device;
  final ModelDownloader? _downloaderOverride;
  late final ModelDownloader _downloader =
      _downloaderOverride ??
      ModelDownloader(freeBytes: _device.freeStorageBytes);

  final catalog = const ModelCatalog([]).obs;
  final installed = <InstalledModel>[].obs;
  final downloads = <String, DownloadState>{}.obs;
  final _cancels = <String, CancelSignal>{};
  late final Directory modelsDir;
  StreamSubscription<List<InstalledModel>>? _sub;

  Future<ModelService> init() async {
    final support = await getApplicationSupportDirectory();
    modelsDir = Directory(p.join(support.path, 'models'));
    await modelsDir.create(recursive: true);
    final raw = await rootBundle.loadString('assets/models/catalog.json');
    catalog.value = ModelCatalog.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    _sub = _repo.watchInstalled().listen(installed.assignAll);
    for (final m in catalog.value.models) {
      final partial = await _downloader.partialBytes(_targetPath(m));
      if (partial > 0) {
        downloads[m.id] = DownloadState(
          status: DownloadStatus.paused,
          receivedBytes: partial,
          totalBytes: m.sizeBytes,
        );
      }
    }
    return this;
  }

  String _targetPath(ModelDefinition m) => p.join(modelsDir.path, m.fileName);

  InstalledModel? installedById(String id) =>
      installed.firstWhereOrNull((m) => m.id == id);

  String displayName(String id) =>
      installedById(id)?.displayName ?? catalog.value.byId(id)?.name ?? id;

  Future<void> startDownload(ModelDefinition m) async {
    if (installedById(m.id) != null) return;
    final current = downloads[m.id]?.status;
    if (current == DownloadStatus.downloading ||
        current == DownloadStatus.verifying) {
      return;
    }
    final cancel = CancelSignal();
    _cancels[m.id] = cancel;
    downloads[m.id] = DownloadState(
      status: DownloadStatus.downloading,
      receivedBytes: downloads[m.id]?.receivedBytes ?? 0,
      totalBytes: m.sizeBytes,
    );
    try {
      final target = _targetPath(m);
      await _downloader.download(
        url: m.downloadUrl,
        targetPath: target,
        expectedBytes: m.sizeBytes,
        expectedSha256: m.sha256,
        cancel: cancel,
        onProgress: (prog) => downloads[m.id] = DownloadState(
          status: prog.verifying
              ? DownloadStatus.verifying
              : DownloadStatus.downloading,
          receivedBytes: prog.receivedBytes,
          totalBytes: prog.totalBytes,
        ),
      );
      await _repo.upsert(
        InstalledModelsCompanion.insert(
          id: m.id,
          displayName: m.name,
          source: 'catalog',
          filePath: target,
          sizeBytes: m.sizeBytes,
          sha256: Value(m.sha256),
          verified: true,
          installedAt: DateTime.now(),
        ),
      );
      downloads.remove(m.id);
    } on DownloadException catch (e) {
      if (e.failure == DownloadFailure.cancelled) {
        final partial = await _downloader.partialBytes(_targetPath(m));
        if (partial > 0) {
          downloads[m.id] = DownloadState(
            status: DownloadStatus.paused,
            receivedBytes: partial,
            totalBytes: m.sizeBytes,
          );
        } else {
          downloads.remove(m.id);
        }
      } else {
        downloads[m.id] = DownloadState(
          status: DownloadStatus.failed,
          receivedBytes: await _downloader.partialBytes(_targetPath(m)),
          totalBytes: m.sizeBytes,
          failure: e.failure,
          detail: e.detail,
        );
      }
    } catch (e) {
      downloads[m.id] = DownloadState(
        status: DownloadStatus.failed,
        totalBytes: m.sizeBytes,
        failure: DownloadFailure.network,
        detail: '$e',
      );
    } finally {
      _cancels.remove(m.id);
    }
  }

  /// Stops the transfer and keeps the partial file for resuming.
  void pauseDownload(String id) => _cancels[id]?.cancel();

  /// Stops the transfer and deletes the partial file.
  Future<void> discardDownload(ModelDefinition m) async {
    _cancels[m.id]?.cancel();
    final part = File(ModelDownloader.partPath(_targetPath(m)));
    if (await part.exists()) await part.delete();
    downloads.remove(m.id);
  }

  /// Copies a user-selected file into app storage after a header check.
  /// Imported files are never treated as verified catalog models.
  Future<InstalledModel> importFile(String sourcePath) async {
    final check = await checkGgufFile(sourcePath);
    if (check != GgufCheck.ok) throw ImportException(check);
    final source = File(sourcePath);
    final size = await source.length();
    if (await _device.freeStorageBytes() < size + storageSafetyMarginBytes) {
      throw const ImportException(null, insufficientStorage: true);
    }
    final id = 'import-${const Uuid().v4()}';
    final target = p.join(modelsDir.path, '$id.gguf');
    await source.copy(target);
    final digest = await sha256OfFile(target);
    final name = p.basenameWithoutExtension(sourcePath);
    await _repo.upsert(
      InstalledModelsCompanion.insert(
        id: id,
        displayName: name,
        source: 'import',
        filePath: target,
        sizeBytes: size,
        sha256: Value(digest),
        verified: false,
        installedAt: DateTime.now(),
      ),
    );
    return (await _repo.byId(id))!;
  }

  Future<LoadBlock> checkLoadable(InstalledModel m) async {
    final file = File(m.filePath);
    if (!await file.exists()) return LoadBlock.fileMissing;
    if (await file.length() != m.sizeBytes) return LoadBlock.sizeMismatch;
    if (await checkGgufFile(m.filePath) != GgufCheck.ok) {
      return LoadBlock.notGguf;
    }
    if (m.source == 'catalog' && !m.verified) return LoadBlock.notVerified;
    return LoadBlock.none;
  }

  Future<void> delete(String id) => _repo.remove(id);

  Future<int> storageUsedBytes() async {
    var total = 0;
    await for (final e in modelsDir.list()) {
      if (e is File) total += await e.length();
    }
    return total;
  }

  @override
  void onClose() {
    _sub?.cancel();
    for (final c in _cancels.values) {
      c.cancel();
    }
    super.onClose();
  }
}

class ImportException implements Exception {
  const ImportException(this.check, {this.insufficientStorage = false});

  final GgufCheck? check;
  final bool insufficientStorage;
}
