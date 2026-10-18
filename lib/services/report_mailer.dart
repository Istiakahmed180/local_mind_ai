import 'package:flutter/services.dart';

import '../app/app_config.dart';
import '../data/local/database.dart';

/// Exactly what leaves the device when the user chooses to send a report.
/// Only the reported response, its reason and model are included; no other
/// conversation content.
String formatReportEmail(ContentReport r) =>
    '${AppConfig.appName} content report\n'
    'Reason: ${r.reason}\n'
    'Model: ${r.modelId ?? '-'}\n'
    'App version: ${AppConfig.version}\n'
    'Reported at: ${r.createdAt.toUtc().toIso8601String()}\n'
    '\n'
    'Reported AI response:\n'
    '${r.excerpt}\n';

String reportEmailSubject(ContentReport r) =>
    '${AppConfig.appName} report: ${r.reason}';

/// Opens the user's email app with a prefilled draft. The user reviews and
/// sends it themselves; the app never sends anything on its own.
class ReportMailer {
  static const _channel = MethodChannel('localmind/device');

  Future<bool> compose(ContentReport r) async {
    try {
      return await _channel.invokeMethod<bool>('composeEmail', {
            'to': AppConfig.privacyContact,
            'subject': reportEmailSubject(r),
            'body': formatReportEmail(r),
          }) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }
}
