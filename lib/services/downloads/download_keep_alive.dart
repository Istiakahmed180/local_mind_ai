import 'package:flutter/services.dart';

/// One active download as shown in the notification.
class ActiveDownload {
  const ActiveDownload(this.name, this.received, this.total);

  final String name;
  final int received;
  final int total;
}

/// What the foreground notification should show, or null to stop it.
({String text, int progress})? keepAliveContent(List<ActiveDownload> active) {
  if (active.isEmpty) return null;
  final received = active.fold<int>(0, (s, d) => s + d.received);
  final total = active.fold<int>(0, (s, d) => s + d.total);
  final progress = total == 0 ? -1 : (received * 100 ~/ total).clamp(0, 100);
  final names = active.map((d) => d.name).join(', ');
  return (text: names, progress: progress);
}

/// Starts, updates and stops the Android foreground service that keeps the
/// process alive while a model downloads.
class DownloadKeepAlive {
  DownloadKeepAlive({MethodChannel? channel, DateTime Function()? clock})
    : _channel = channel ?? const MethodChannel('localmind/downloads'),
      _clock = clock ?? DateTime.now;

  final MethodChannel _channel;
  final DateTime Function() _clock;
  bool _running = false;
  DateTime _lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  int _lastProgress = -2;

  bool get isRunning => _running;

  Future<void> sync(
    List<ActiveDownload> active, {
    required String title,
    required String channelName,
  }) async {
    final content = keepAliveContent(active);
    try {
      if (content == null) {
        if (_running) {
          _running = false;
          await _channel.invokeMethod<bool>('stop');
        }
        return;
      }
      final args = {
        'title': title,
        'text': content.text,
        'progress': content.progress,
        'channelName': channelName,
      };
      if (!_running) {
        _running = true;
        _lastUpdate = _clock();
        _lastProgress = content.progress;
        await _channel.invokeMethod<bool>('start', args);
        return;
      }
      final now = _clock();
      if (content.progress == _lastProgress ||
          now.difference(_lastUpdate) < const Duration(seconds: 1)) {
        return;
      }
      _lastUpdate = now;
      _lastProgress = content.progress;
      await _channel.invokeMethod<bool>('update', args);
    } on MissingPluginException {
      // Not on Android (unit tests).
    }
  }
}
