import 'dart:math' as math;

class ExpressionException implements Exception {
  const ExpressionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Evaluates arithmetic with a recursive-descent parser. It only knows
/// numbers, + - * / % ^, parentheses, a fixed list of functions and the
/// constants pi and e, so model output can never reach `eval` or code.
double evaluateExpression(String source, {int maxLength = 200}) {
  if (source.length > maxLength) {
    throw ExpressionException('Expression is longer than $maxLength characters');
  }
  final p = _Parser(source.replaceAll('×', '*').replaceAll('÷', '/'));
  final value = p.parse();
  if (!value.isFinite) throw const ExpressionException('Result is not a finite number');
  return value;
}

/// Integers print without a decimal point; others use up to 12 significant
/// digits with trailing zeros removed.
String formatNumber(double v) {
  if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
  var s = v.toStringAsPrecision(12);
  if (s.contains('.') && !s.contains('e')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}

const _functions = <String, double Function(double)>{
  'sqrt': math.sqrt,
  'abs': _abs,
  'round': _round,
  'floor': _floor,
  'ceil': _ceil,
  'ln': math.log,
  'log10': _log10,
};

const _constants = <String, double>{'pi': math.pi, 'e': math.e};
const _maxDepth = 32;

double _abs(double x) => x.abs();
double _round(double x) => x.roundToDouble();
double _floor(double x) => x.floorToDouble();
double _ceil(double x) => x.ceilToDouble();
double _log10(double x) => math.log(x) / math.ln10;

class _Parser {
  _Parser(this.src);

  final String src;
  int pos = 0;
  int depth = 0;

  double parse() {
    _skipSpace();
    if (pos >= src.length) throw const ExpressionException('Expression is empty');
    final v = _expr();
    _skipSpace();
    if (pos < src.length) {
      throw ExpressionException('Unexpected "${src[pos]}" at position ${pos + 1}');
    }
    return v;
  }

  double _expr() {
    var v = _term();
    while (true) {
      if (_eat('+')) {
        v += _term();
      } else if (_eat('-')) {
        v -= _term();
      } else {
        return v;
      }
    }
  }

  double _term() {
    var v = _unary();
    while (true) {
      if (_eat('*')) {
        v *= _unary();
      } else if (_eat('/')) {
        final d = _unary();
        if (d == 0) throw const ExpressionException('Division by zero');
        v /= d;
      } else if (_eat('%')) {
        final d = _unary();
        if (d == 0) throw const ExpressionException('Division by zero');
        v %= d;
      } else {
        return v;
      }
    }
  }

  // Unary minus binds looser than ^, so -2^2 is -4.
  double _unary() {
    if (_eat('-')) return _nested(() => -_unary());
    if (_eat('+')) return _nested(_unary);
    return _power();
  }

  double _power() {
    final base = _primary();
    if (_eat('^')) {
      final exp = _nested(_unary);
      return math.pow(base, exp).toDouble();
    }
    return base;
  }

  double _primary() {
    _skipSpace();
    if (pos >= src.length) throw const ExpressionException('Expression ended early');
    final c = src[pos];
    if (c == '(') {
      pos++;
      final v = _nested(_expr);
      if (!_eat(')')) throw const ExpressionException('Missing ")"');
      return v;
    }
    if (_isDigit(c) || c == '.') return _number();
    if (_isLetter(c)) {
      final start = pos;
      while (pos < src.length && (_isLetter(src[pos]) || _isDigit(src[pos]))) {
        pos++;
      }
      final name = src.substring(start, pos).toLowerCase();
      final constant = _constants[name];
      if (constant != null) return constant;
      final fn = _functions[name];
      if (fn == null) throw ExpressionException('Unknown name "$name"');
      if (!_eat('(')) throw ExpressionException('Expected "(" after $name');
      final arg = _nested(_expr);
      if (!_eat(')')) throw const ExpressionException('Missing ")"');
      return fn(arg);
    }
    throw ExpressionException('Unexpected "$c" at position ${pos + 1}');
  }

  double _number() {
    final start = pos;
    while (pos < src.length && (_isDigit(src[pos]) || src[pos] == '.')) {
      pos++;
    }
    if (pos < src.length && (src[pos] == 'e' || src[pos] == 'E')) {
      final save = pos;
      pos++;
      if (pos < src.length && (src[pos] == '+' || src[pos] == '-')) pos++;
      if (pos < src.length && _isDigit(src[pos])) {
        while (pos < src.length && _isDigit(src[pos])) {
          pos++;
        }
      } else {
        pos = save;
      }
    }
    final text = src.substring(start, pos);
    final v = double.tryParse(text);
    if (v == null) throw ExpressionException('Invalid number "$text"');
    return v;
  }

  T _nested<T>(T Function() f) {
    if (++depth > _maxDepth) {
      throw const ExpressionException('Expression is nested too deeply');
    }
    try {
      return f();
    } finally {
      depth--;
    }
  }

  bool _eat(String ch) {
    _skipSpace();
    if (pos < src.length && src[pos] == ch) {
      pos++;
      return true;
    }
    return false;
  }

  void _skipSpace() {
    while (pos < src.length && ' \t\n\r'.contains(src[pos])) {
      pos++;
    }
  }

  static final _digit = RegExp(r'[0-9]');
  static final _letter = RegExp(r'[A-Za-z]');

  static bool _isDigit(String c) => _digit.hasMatch(c);
  static bool _isLetter(String c) => _letter.hasMatch(c);
}
