import 'package:intl/intl.dart';

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

/// "14:05" today, "12 Mar" this year, "12 Mar 2025" otherwise.
String formatWhen(DateTime t, {DateTime? now}) {
  final n = now ?? DateTime.now();
  if (t.year == n.year && t.month == n.month && t.day == n.day) {
    return DateFormat.Hm().format(t);
  }
  if (t.year == n.year) return DateFormat.MMMd().format(t);
  return DateFormat.yMMMd().format(t);
}
