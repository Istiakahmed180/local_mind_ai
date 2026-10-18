import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';
import 'package:localmind_ai/services/inference/summary_planner.dart';

int words(String s) =>
    s.trim().isEmpty ? 0 : s.trim().split(RegExp(r'\s+')).length;

ChatTurn u(String t) => ChatTurn(ChatRole.user, t);
ChatTurn a(String t) => ChatTurn(ChatRole.assistant, t);

String n(int count) => List.filled(count, 'w').join(' ');

void main() {
  test('no plan when everything fits', () {
    expect(
      planSummary(
        systemText: 'sys',
        summary: null,
        history: [u('hi'), a('hello')],
        coveredCount: 0,
        newUserText: 'next',
        contextSize: 4000,
        reservedForOutput: 100,
        countTokens: words,
      ),
      isNull,
    );
  });

  test('summarizes the oldest messages that do not fit', () {
    // budget 1000-100=900; fixed: 1 + 1 + 256 reserve = 258 → 642 left
    final history = [for (var i = 0; i < 10; i++) u(n(100))];
    final plan = planSummary(
      systemText: 'sys',
      summary: null,
      history: history,
      coveredCount: 0,
      newUserText: 'next',
      contextSize: 1000,
      reservedForOutput: 100,
      countTokens: words,
    )!;
    expect(plan.toSummarize, hasLength(4)); // 6 newest (600) fit
    expect(plan.newCoveredCount, 4);
  });

  test('only uncovered messages are planned, and the count adds up', () {
    final history = [for (var i = 0; i < 10; i++) u(n(100))];
    final plan = planSummary(
      systemText: 'sys',
      summary: 'short summary',
      history: history,
      coveredCount: 3,
      newUserText: 'next',
      contextSize: 1000,
      reservedForOutput: 100,
      countTokens: words,
    )!;
    expect(plan.toSummarize, hasLength(1));
    expect(plan.newCoveredCount, 4);
  });

  test('a long existing summary takes its real size', () {
    final history = [for (var i = 0; i < 4; i++) u(n(100))];
    final small = planSummary(
      systemText: 'sys',
      summary: n(10),
      history: history,
      coveredCount: 0,
      newUserText: 'x',
      contextSize: 800,
      reservedForOutput: 100,
      countTokens: words,
    );
    final big = planSummary(
      systemText: 'sys',
      summary: n(400),
      history: history,
      coveredCount: 0,
      newUserText: 'x',
      contextSize: 800,
      reservedForOutput: 100,
      countTokens: words,
    );
    expect(small, isNull);
    expect(big!.toSummarize.length, greaterThan(0));
  });

  test('chunks keep order, respect the budget and never come back empty', () {
    final msgs = [for (var i = 0; i < 6; i++) u('m$i ${n(40)}')];
    final chunks = chunkForSummary(msgs, 100, countTokens: words);
    expect(chunks.expand((c) => c).map((t) => t.text), msgs.map((t) => t.text));
    expect(chunks.every((c) => c.isNotEmpty), isTrue);
    expect(chunks.length, greaterThan(1));
    final huge = chunkForSummary([u(n(5000))], 100, countTokens: words);
    expect(huge.single, hasLength(1));
  });

  test('prompt carries the previous summary, roles and a length limit', () {
    final p = buildSummaryPrompt('Rahim lives in Sylhet.', [
      u('I like tea'),
      a('Noted'),
      u('x' * 5000),
    ]);
    expect(p.first.role, ChatRole.system);
    expect(p.first.text, contains('same language'));
    final body = p.last.text;
    expect(body, contains('Summary so far:\nRahim lives in Sylhet.'));
    expect(body, contains('User: I like tea'));
    expect(body, contains('Assistant: Noted'));
    expect(body.length, lessThan(2500), reason: 'long message shortened');
  });

  test('summary block labels the text as possibly incomplete', () {
    expect(summaryBlock('abc'), contains('may be incomplete'));
    expect(summaryBlock('abc'), endsWith('abc'));
  });
}
