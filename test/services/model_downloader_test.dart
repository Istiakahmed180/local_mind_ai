import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:localmind_ai/services/downloads/model_downloader.dart';

void main() {
  late Directory dir;
  late List<int> payload;
  late String sha;
  final requests = <http.BaseRequest>[];

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('dl_test');
    payload = List<int>.generate(100000, (i) => i % 251);
    sha = sha256.convert(payload).toString();
    requests.clear();
  });

  tearDown(() => dir.delete(recursive: true));

  MockClient server({bool honorRange = true, List<int>? body}) {
    final data = body ?? payload;
    return MockClient.streaming((request, _) async {
      requests.add(request);
      final range = request.headers['Range'];
      if (range != null && honorRange) {
        final start = int.parse(range.substring(6, range.length - 1));
        return http.StreamedResponse(Stream.value(data.sublist(start)), 206);
      }
      return http.StreamedResponse(Stream.value(data), 200);
    });
  }

  ModelDownloader downloader(http.Client client, {int free = 1 << 40}) =>
      ModelDownloader(clientFactory: () => client, freeBytes: () async => free);

  Future<void> run(
    ModelDownloader d,
    String target, {
    CancelSignal? cancel,
    String? expectedSha,
  }) => d.download(
    url: Uri.parse('https://host.example/m.gguf'),
    targetPath: target,
    expectedBytes: payload.length,
    expectedSha256: expectedSha ?? sha,
    onProgress: (_) {},
    cancel: cancel ?? CancelSignal(),
  );

  test('downloads, verifies and moves the file into place', () async {
    final target = '${dir.path}/m.gguf';
    await run(downloader(server()), target);
    expect(File(target).readAsBytesSync(), payload);
    expect(File(ModelDownloader.partPath(target)).existsSync(), isFalse);
  });

  test('resumes from a partial file using a Range request', () async {
    final target = '${dir.path}/m.gguf';
    File(ModelDownloader.partPath(target))
        .writeAsBytesSync(payload.sublist(0, 40000));
    await run(downloader(server()), target);
    expect(requests.single.headers['Range'], 'bytes=40000-');
    expect(File(target).readAsBytesSync(), payload);
  });

  test('restarts when the server ignores Range', () async {
    final target = '${dir.path}/m.gguf';
    File(ModelDownloader.partPath(target))
        .writeAsBytesSync(payload.sublist(0, 40000));
    await run(downloader(server(honorRange: false)), target);
    expect(File(target).readAsBytesSync(), payload);
  });

  test('deletes the file when the checksum does not match', () async {
    final target = '${dir.path}/m.gguf';
    await expectLater(
      run(downloader(server()), target, expectedSha: 'b' * 64),
      throwsA(
        isA<DownloadException>().having(
          (e) => e.failure,
          'failure',
          DownloadFailure.checksumMismatch,
        ),
      ),
    );
    expect(File(target).existsSync(), isFalse);
    expect(File(ModelDownloader.partPath(target)).existsSync(), isFalse);
  });

  test('refuses to start without enough free storage', () async {
    final target = '${dir.path}/m.gguf';
    await expectLater(
      run(downloader(server(), free: 1000), target),
      throwsA(
        isA<DownloadException>().having(
          (e) => e.failure,
          'failure',
          DownloadFailure.insufficientStorage,
        ),
      ),
    );
    expect(requests, isEmpty);
  });

  test('rejects truncated downloads', () async {
    final target = '${dir.path}/m.gguf';
    await expectLater(
      run(downloader(server(body: payload.sublist(0, 500))), target),
      throwsA(
        isA<DownloadException>().having(
          (e) => e.failure,
          'failure',
          DownloadFailure.sizeMismatch,
        ),
      ),
    );
    expect(File(target).existsSync(), isFalse);
  });

  test('cancel keeps the partial file for resuming', () async {
    final target = '${dir.path}/m.gguf';
    final controller = StreamController<List<int>>();
    final client = MockClient.streaming(
      (request, _) async => http.StreamedResponse(controller.stream, 200),
    );
    final cancel = CancelSignal();
    final future = run(downloader(client), target, cancel: cancel);
    controller.add(payload.sublist(0, 30000));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    cancel.cancel();
    await expectLater(
      future,
      throwsA(
        isA<DownloadException>().having(
          (e) => e.failure,
          'failure',
          DownloadFailure.cancelled,
        ),
      ),
    );
    expect(File(ModelDownloader.partPath(target)).lengthSync(), 30000);
    expect(File(target).existsSync(), isFalse);
    await controller.close();
  });

  test('reports HTTP errors', () async {
    final target = '${dir.path}/m.gguf';
    final client = MockClient((_) async => http.Response('nope', 404));
    await expectLater(
      run(downloader(client), target),
      throwsA(
        isA<DownloadException>().having(
          (e) => e.failure,
          'failure',
          DownloadFailure.httpError,
        ),
      ),
    );
  });
}
