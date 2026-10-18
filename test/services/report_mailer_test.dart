import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/services/report_mailer.dart';

void main() {
  final report = ContentReport(
    id: 'r1',
    messageId: 'm1',
    modelId: 'qwen2.5-0.5b-instruct-q4_k_m',
    reason: 'report_harmful',
    excerpt: 'the reported reply',
    createdAt: DateTime.utc(2026, 10, 18, 9, 30),
  );

  test('email body contains only the report fields', () {
    final body = formatReportEmail(report);
    expect(body, contains('Reason: report_harmful'));
    expect(body, contains('Model: qwen2.5-0.5b-instruct-q4_k_m'));
    expect(body, contains('2026-10-18T09:30:00.000Z'));
    expect(body, contains('the reported reply'));
    expect(body, isNot(contains('m1')), reason: 'internal ids stay local');
  });

  test('subject names the reason', () {
    expect(reportEmailSubject(report), endsWith('report_harmful'));
  });
}
