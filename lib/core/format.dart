String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final digits = unit == 0 || value >= 100 ? 0 : 1;
  return '${value.toStringAsFixed(digits)} ${units[unit]}';
}

String formatDuration(Duration d) {
  if (d.inMilliseconds < 1000) return '${d.inMilliseconds} ms';
  return '${(d.inMilliseconds / 1000).toStringAsFixed(1)} s';
}
