import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/services/inference/context_budget.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';

int countWords(String s) => s.split(' ').length;

void main() {
  final turns = [
    const ChatTurn(ChatRole.system, 'sys prompt'),
    const ChatTurn(ChatRole.user, 'one two three four'),
    const ChatTurn(ChatRole.assistant, 'five six seven eight'),
    const ChatTurn(ChatRole.user, 'nine ten'),
  ];

  test('keeps everything when it fits', () {
    final r = fitToContext(
      turns: turns,
      contextSize: 100,
      reservedForOutput: 10,
      countTokens: countWords,
    );
    expect(r.turns, hasLength(4));
    expect(r.droppedCount, 0);
  });

  test('drops oldest dialog turns but keeps system and latest user turn', () {
    final r = fitToContext(
      turns: turns,
      contextSize: 10,
      reservedForOutput: 4,
      countTokens: countWords,
    );
    expect(r.turns.first.role, ChatRole.system);
    expect(r.turns.last.text, 'nine ten');
    expect(r.droppedCount, 2);
  });

  test('truncates the latest turn when nothing else fits', () {
    final long = [ChatTurn(ChatRole.user, 'x' * 1000)];
    final r = fitToContext(turns: long, contextSize: 60, reservedForOutput: 10);
    expect(r.turns.single.text.length, lessThan(1000));
    expect(r.turns.single.text, isNotEmpty);
  });

  test('rejects reserve larger than context', () {
    expect(
      () => fitToContext(turns: turns, contextSize: 10, reservedForOutput: 10),
      throwsArgumentError,
    );
  });

  test(
    'Bengali text is estimated as more tokens per character than English',
    () {
      final en = estimateTokens('a' * 30);
      final bn = estimateTokens('আমি' * 10);
      expect(bn, greaterThan(en));
    },
  );
}
