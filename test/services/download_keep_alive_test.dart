import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/services/downloads/download_keep_alive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('localmind/downloads');
  final calls = <MethodCall>[];
  var now = DateTime(2026);

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (c) async {
          calls.add(c);
          return true;
        });
  });

  DownloadKeepAlive make() =>
      DownloadKeepAlive(channel: channel, clock: () => now);

  Future<void> sync(DownloadKeepAlive k, List<ActiveDownload> a) =>
      k.sync(a, title: 'Downloading', channelName: 'Downloads');

  test('content sums progress across downloads', () {
    final c = keepAliveContent(const [
      ActiveDownload('A', 50, 100),
      ActiveDownload('B', 0, 100),
    ]);
    expect(c!.progress, 25);
    expect(c.text, 'A, B');
    expect(keepAliveContent(const []), isNull);
  });

  test('starts once, throttles updates, stops when idle', () async {
    final k = make();
    await sync(k, const [ActiveDownload('A', 10, 100)]);
    await sync(k, const [ActiveDownload('A', 20, 100)]); // <1s later
    now = now.add(const Duration(seconds: 2));
    await sync(k, const [ActiveDownload('A', 30, 100)]);
    await sync(k, const []);
    await sync(k, const []);
    expect(calls.map((c) => c.method), ['start', 'update', 'stop']);
    expect((calls.first.arguments as Map)['progress'], 10);
    expect(k.isRunning, isFalse);
  });

  test('does nothing when no download ever starts', () async {
    await sync(make(), const []);
    expect(calls, isEmpty);
  });
}
