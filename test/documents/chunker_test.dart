import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/services/documents/chunker.dart';
import 'package:localmind_ai/services/documents/text_extraction.dart';

void main() {
  test('keeps short paragraphs together and records line ranges', () {
    const text = 'Title line\n\nFirst paragraph\ncontinues here.\n\nSecond.';
    final chunks = chunkSegments([const SourceSegment(text)]);
    expect(chunks, hasLength(1));
    expect(
      chunks.single.text,
      'Title line\nFirst paragraph continues here.\nSecond.',
    );
    expect(chunks.single.lineStart, 1);
    expect(chunks.single.lineEnd, 6);
    expect(chunks.single.page, isNull);
  });

  test('splits at paragraph boundaries and never exceeds maxChars', () {
    final paragraphs = List.generate(20, (i) => 'Paragraph $i ${'word ' * 30}');
    final chunks = chunkSegments(
      [SourceSegment(paragraphs.join('\n\n'))],
      maxChars: 400,
      overlapChars: 100,
    );
    expect(chunks.length, greaterThan(5));
    for (final c in chunks) {
      expect(c.text.length, lessThanOrEqualTo(400));
    }
    expect(
      chunks.map((c) => c.ordinal),
      List.generate(chunks.length, (i) => i),
    );
    final all = chunks.map((c) => c.text).join('\n');
    for (var i = 0; i < 20; i++) {
      expect(all, contains('Paragraph $i '));
    }
  });

  test('line ranges point at the paragraphs a chunk came from', () {
    final text = [for (var i = 0; i < 6; i++) 'Line ${i * 2 + 1} ${'x' * 150}']
        .join('\n\n');
    final chunks = chunkSegments([SourceSegment(text)], maxChars: 400);
    expect(chunks.first.lineStart, 1);
    expect(chunks.last.lineEnd, 11);
    for (final c in chunks) {
      expect(c.text, startsWith('Line ${c.lineStart} '));
    }
  });

  test('long paragraphs split at sentence ends, including the danda', () {
    final sentence = 'এটি একটি দীর্ঘ বাংলা বাক্য যা বারবার আসে। ';
    final chunks = chunkSegments(
      [SourceSegment(sentence * 40)],
      maxChars: 300,
      overlapChars: 50,
    );
    expect(chunks.length, greaterThan(1));
    for (final c in chunks) {
      expect(c.text.length, lessThanOrEqualTo(300));
      expect(c.text.trimRight(), endsWith('।'));
    }
  });

  test('a single unbroken token is hard split', () {
    final chunks = chunkSegments([SourceSegment('a' * 1000)], maxChars: 300);
    expect(chunks.map((c) => c.text.length), [300, 300, 300, 100]);
  });

  test('chunks never cross pages and keep their page number', () {
    final chunks = chunkSegments([
      const SourceSegment('Alpha page text.', page: 1),
      const SourceSegment('', page: 2),
      const SourceSegment('Gamma page text.', page: 3),
    ]);
    expect(chunks.map((c) => c.page), [1, 3]);
    expect(chunks.map((c) => c.lineStart), [null, null]);
  });

  test('short boundary paragraphs overlap into the next chunk', () {
    final text = ['A' * 250, 'B' * 250, 'short bridge', 'C' * 250].join('\n\n');
    final chunks = chunkSegments(
      [SourceSegment(text)],
      maxChars: 520,
      overlapChars: 100,
    );
    expect(chunks, hasLength(2));
    expect(chunks[0].text, endsWith('short bridge'));
    expect(chunks[1].text, startsWith('short bridge'));
  });

  test('empty input produces no chunks', () {
    expect(chunkSegments([const SourceSegment('  \n\n ')]), isEmpty);
  });
}
