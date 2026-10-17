import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Extra free space kept after a download so the device is not filled up.
const storageSafetyMarginBytes = 200 * 1024 * 1024;

enum DownloadFailure {
  insufficientStorage,
  network,
  httpError,
  sizeMismatch,
  checksumMismatch,
  cancelled,
}

class DownloadException implements Exception {
  const DownloadException(this.failure, [this.detail]);

  final DownloadFailure failure;
  final String? detail;

  @override
  String toString() =>
      'DownloadException($failure${detail == null ? '' : ': $detail'})';
}

class DownloadProgress {
  const DownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
    this.verifying = false,
  });

  final int receivedBytes;
  final int totalBytes;
  final bool verifying;

  double get fraction => totalBytes == 0 ? 0 : receivedBytes / totalBytes;
}

class CancelSignal {
  bool _cancelled = false;
  final _completer = Completer<void>();

  bool get isCancelled => _cancelled;
  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _completer.complete();
  }
}

/// Downloads one file to `<target>.part`, resuming with HTTP Range when a
/// partial file exists, then verifies size and SHA-256 before renaming it to
/// `<target>`. A file that fails verification is deleted.
class ModelDownloader {
  ModelDownloader({
    http.Client Function()? clientFactory,
    required this.freeBytes,
  }) : _clientFactory = clientFactory ?? http.Client.new;

  final http.Client Function() _clientFactory;

  /// Free bytes on the volume that holds the models directory.
  final Future<int> Function() freeBytes;

  static String partPath(String target) => '$target.part';

  Future<int> partialBytes(String target) async {
    final part = File(partPath(target));
    return await part.exists() ? part.length() : 0;
  }

  Future<void> download({
    required Uri url,
    required String targetPath,
    required int expectedBytes,
    required String expectedSha256,
    required void Function(DownloadProgress) onProgress,
    required CancelSignal cancel,
  }) async {
    final part = File(partPath(targetPath));
    await part.parent.create(recursive: true);
    var existing = await part.exists() ? await part.length() : 0;
    if (existing > expectedBytes) {
      await part.delete();
      existing = 0;
    }

    final needed = expectedBytes - existing + storageSafetyMarginBytes;
    if (await freeBytes() < needed) {
      throw DownloadException(DownloadFailure.insufficientStorage);
    }

    if (existing < expectedBytes) {
      await _fetch(url, part, existing, expectedBytes, onProgress, cancel);
    }

    final actualSize = await part.length();
    if (actualSize != expectedBytes) {
      await part.delete();
      throw DownloadException(
        DownloadFailure.sizeMismatch,
        'expected $expectedBytes, got $actualSize',
      );
    }

    onProgress(
      DownloadProgress(
        receivedBytes: expectedBytes,
        totalBytes: expectedBytes,
        verifying: true,
      ),
    );
    final digest = await sha256OfFile(part.path);
    if (cancel.isCancelled) throw DownloadException(DownloadFailure.cancelled);
    if (digest != expectedSha256) {
      await part.delete();
      throw DownloadException(DownloadFailure.checksumMismatch);
    }
    await part.rename(targetPath);
  }

  Future<void> _fetch(
    Uri url,
    File part,
    int existing,
    int expectedBytes,
    void Function(DownloadProgress) onProgress,
    CancelSignal cancel,
  ) async {
    final client = _clientFactory();
    IOSink? sink;
    try {
      final request = http.Request('GET', url);
      if (existing > 0) request.headers['Range'] = 'bytes=$existing-';
      final response = await client.send(request);

      var offset = existing;
      if (response.statusCode == 200) {
        offset = 0; // Server ignored Range; restart.
      } else if (response.statusCode != 206) {
        throw DownloadException(
          DownloadFailure.httpError,
          'HTTP ${response.statusCode}',
        );
      }

      sink = part.openWrite(
        mode: offset == 0 ? FileMode.write : FileMode.append,
      );
      var received = offset;
      var lastReport = DateTime.fromMillisecondsSinceEpoch(0);
      final done = Completer<void>();
      late StreamSubscription<List<int>> sub;
      sub = response.stream.listen(
        (chunk) {
          sink!.add(chunk);
          received += chunk.length;
          if (received > expectedBytes) {
            sub.cancel();
            done.completeError(
              DownloadException(
                DownloadFailure.sizeMismatch,
                'server sent too much data',
              ),
            );
            return;
          }
          final now = DateTime.now();
          if (now.difference(lastReport).inMilliseconds > 250) {
            lastReport = now;
            onProgress(
              DownloadProgress(
                receivedBytes: received,
                totalBytes: expectedBytes,
              ),
            );
          }
        },
        onError: (Object e) {
          if (!done.isCompleted) {
            done.completeError(
              DownloadException(DownloadFailure.network, '$e'),
            );
          }
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
        cancelOnError: true,
      );
      unawaited(
        cancel.whenCancelled.then((_) async {
          await sub.cancel();
          if (!done.isCompleted) {
            done.completeError(DownloadException(DownloadFailure.cancelled));
          }
        }),
      );
      await done.future;
      onProgress(
        DownloadProgress(receivedBytes: received, totalBytes: expectedBytes),
      );
    } on SocketException catch (e) {
      throw DownloadException(DownloadFailure.network, e.message);
    } on http.ClientException catch (e) {
      throw DownloadException(DownloadFailure.network, e.message);
    } finally {
      await sink?.flush();
      await sink?.close();
      client.close();
    }
  }
}

/// Hashes a file in a background isolate.
Future<String> sha256OfFile(String path) => Isolate.run(() async {
  final digest = await sha256.bind(File(path).openRead()).first;
  return digest.toString();
});
