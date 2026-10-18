import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/services/agent/expression.dart';

void main() {
  double ev(String s) => evaluateExpression(s);

  test('arithmetic with precedence and parentheses', () {
    expect(ev('23 * 47 + 12'), 1093);
    expect(ev('2 + 3 * 4'), 14);
    expect(ev('(2 + 3) * 4'), 20);
    expect(ev('10 / 4'), 2.5);
    expect(ev('10 % 4'), 2);
    expect(ev('2 ^ 3 ^ 2'), 512);
    expect(ev('-2 ^ 2'), -4);
    expect(ev('--3'), 3);
    expect(ev('1.5e3 + .5'), 1500.5);
    expect(ev('6 × 7 ÷ 2'), 21);
  });

  test('functions and constants', () {
    expect(ev('sqrt(16) + abs(-2)'), 6);
    expect(ev('round(2.5) + floor(1.9) + ceil(1.1)'), 3 + 1 + 2);
    expect(ev('log10(1000)'), closeTo(3, 1e-12));
    expect(ev('pi'), closeTo(3.14159265, 1e-8));
  });

  test('rejects anything that is not arithmetic', () {
    for (final bad in [
      '',
      '1 +',
      '2 * (3',
      'print(1)',
      'x + 1',
      '1; 2',
      'import("dart:io")',
      '"a"',
      '1 / 0',
      '5 % 0',
      'sqrt 4',
      '1..2',
    ]) {
      expect(() => ev(bad), throwsA(isA<ExpressionException>()), reason: bad);
    }
  });

  test('limits length, nesting and non-finite results', () {
    expect(() => ev('1+' * 150 + '1'), throwsA(isA<ExpressionException>()));
    expect(
      () => ev('${'(' * 40}1${')' * 40}'),
      throwsA(isA<ExpressionException>()),
    );
    expect(() => ev('10 ^ 400'), throwsA(isA<ExpressionException>()));
    expect(() => ev('sqrt(-1)'), throwsA(isA<ExpressionException>()));
  });

  test('formats results', () {
    expect(formatNumber(1093), '1093');
    expect(formatNumber(2.5), '2.5');
    expect(formatNumber(1 / 3), '0.333333333333');
    expect(formatNumber(-4), '-4');
  });
}
