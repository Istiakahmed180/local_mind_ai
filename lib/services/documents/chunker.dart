import 'text_extraction.dart';

class TextChunk {
  const TextChunk({
    required this.ordinal,
    required this.text,
    this.page,
    this.lineStart,
    this.lineEnd,
  });

  final int ordinal;
  final String text;
  final int? page;
  final int? lineStart;
  final int? lineEnd;
}

class _Unit {
  _Unit(this.text, this.lineStart, this.lineEnd);

  final String text;
  final int lineStart;
  final int lineEnd;
}

/// Splits extracted text into passages of at most [maxChars] characters.
///
/// Paragraphs (blank-line separated) are kept whole when they fit; longer ones
/// are split at sentence ends (including the Bengali danda) and, failing that,
/// at whitespace. Chunks never cross a PDF page, so every chunk has exactly one
/// page to cite. Consecutive chunks share their boundary unit when it is no
/// longer than [overlapChars], so an answer spanning a boundary is still found.
List<TextChunk> chunkSegments(
  List<SourceSegment> segments, {
  int maxChars = 900,
  int overlapChars = 200,
}) {
  assert(maxChars > 0 && overlapChars < maxChars);
  final chunks = <TextChunk>[];
  for (final segment in segments) {
    final units = <_Unit>[
      for (final p in _paragraphs(segment.text)) ..._split(p, maxChars),
    ];
    var current = <_Unit>[];
    var length = 0;

    void emit() {
      if (current.isEmpty) return;
      chunks.add(
        TextChunk(
          ordinal: chunks.length,
          text: current.map((u) => u.text).join('\n'),
          page: segment.page,
          lineStart: segment.page == null ? current.first.lineStart : null,
          lineEnd: segment.page == null ? current.last.lineEnd : null,
        ),
      );
    }

    for (final unit in units) {
      final added = unit.text.length + (current.isEmpty ? 0 : 1);
      if (current.isNotEmpty && length + added > maxChars) {
        emit();
        final last = current.last;
        final carry =
            current.length > 1 &&
            last.text.length <= overlapChars &&
            last.text.length + 1 + unit.text.length <= maxChars;
        current = carry ? [last] : [];
        length = carry ? last.text.length : 0;
      }
      length += unit.text.length + (current.isEmpty ? 0 : 1);
      current.add(unit);
    }
    emit();
  }
  return chunks;
}

Iterable<_Unit> _paragraphs(String text) sync* {
  final lines = text.split('\n');
  final buffer = <String>[];
  var start = 0;
  for (var i = 0; i <= lines.length; i++) {
    final line = i < lines.length ? lines[i].trim() : '';
    if (line.isEmpty) {
      if (buffer.isNotEmpty) {
        yield _Unit(_collapse(buffer.join(' ')), start + 1, i);
        buffer.clear();
      }
    } else {
      if (buffer.isEmpty) start = i;
      buffer.add(line);
    }
  }
}

final _space = RegExp(r'\s+');
final _sentenceEnd = RegExp(r'(?<=[.!?।॥])\s+');

String _collapse(String s) => s.replaceAll(_space, ' ').trim();

Iterable<_Unit> _split(_Unit unit, int maxChars) sync* {
  if (unit.text.length <= maxChars) {
    yield unit;
    return;
  }
  final pieces = <String>[];
  var buffer = '';
  for (final sentence in unit.text.split(_sentenceEnd)) {
    for (final part in _hardSplit(sentence, maxChars)) {
      if (buffer.isEmpty) {
        buffer = part;
      } else if (buffer.length + 1 + part.length <= maxChars) {
        buffer = '$buffer $part';
      } else {
        pieces.add(buffer);
        buffer = part;
      }
    }
  }
  if (buffer.isNotEmpty) pieces.add(buffer);
  for (final piece in pieces) {
    yield _Unit(piece, unit.lineStart, unit.lineEnd);
  }
}

Iterable<String> _hardSplit(String text, int maxChars) sync* {
  var rest = text;
  while (rest.length > maxChars) {
    var cut = rest.lastIndexOf(' ', maxChars);
    if (cut <= 0) cut = maxChars;
    yield rest.substring(0, cut).trim();
    rest = rest.substring(cut).trim();
  }
  if (rest.isNotEmpty) yield rest;
}
