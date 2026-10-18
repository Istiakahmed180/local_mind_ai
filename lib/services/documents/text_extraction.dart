import 'dart:convert';
import 'dart:io';

import 'package:pdfrx/pdfrx.dart';

enum DocumentKind { txt, md, pdf }

DocumentKind? kindForFileName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.txt')) return DocumentKind.txt;
  if (lower.endsWith('.md') || lower.endsWith('.markdown')) {
    return DocumentKind.md;
  }
  if (lower.endsWith('.pdf')) return DocumentKind.pdf;
  return null;
}

/// Text from one PDF page, or the whole file for TXT/Markdown ([page] null).
class SourceSegment {
  const SourceSegment(this.text, {this.page});

  final String text;
  final int? page;
}

class ExtractionResult {
  const ExtractionResult(this.segments, {this.pageCount});

  final List<SourceSegment> segments;
  final int? pageCount;

  int get charCount => segments.fold(0, (n, s) => n + s.text.trim().length);
}

/// Reason keys are translation keys shown to the user.
class ExtractionException implements Exception {
  const ExtractionException(this.reason, [this.detail]);

  final String reason;
  final String? detail;

  @override
  String toString() => detail == null ? reason : '$reason: $detail';
}

abstract interface class PdfTextExtractor {
  /// One entry per page, in order. Pages without a text layer return ''.
  Future<List<String>> pageTexts(String path);
}

/// PDFium (via pdfrx) reads the text layer only; there is no OCR, so scanned
/// PDFs produce empty pages.
class PdfiumTextExtractor implements PdfTextExtractor {
  @override
  Future<List<String>> pageTexts(String path) async {
    await pdfrxFlutterInitialize();
    final PdfDocument doc;
    try {
      doc = await PdfDocument.openFile(path);
    } on PdfPasswordException {
      throw const ExtractionException('doc_error_pdf_password');
    } on PdfException catch (e) {
      throw ExtractionException('doc_error_pdf_unreadable', e.message);
    }
    try {
      final texts = <String>[];
      for (final page in doc.pages) {
        final raw = await page.loadText();
        texts.add(raw?.fullText ?? '');
      }
      return texts;
    } finally {
      await doc.dispose();
    }
  }
}

class TextExtractor {
  TextExtractor({PdfTextExtractor? pdf}) : _pdf = pdf ?? PdfiumTextExtractor();

  final PdfTextExtractor _pdf;

  Future<ExtractionResult> extract(String path, DocumentKind kind) async {
    switch (kind) {
      case DocumentKind.txt:
      case DocumentKind.md:
        final bytes = await File(path).readAsBytes();
        return ExtractionResult([SourceSegment(decodeText(bytes))]);
      case DocumentKind.pdf:
        final pages = await _pdf.pageTexts(path);
        return ExtractionResult([
          for (var i = 0; i < pages.length; i++)
            SourceSegment(cleanPdfText(pages[i]), page: i + 1),
        ], pageCount: pages.length);
    }
  }
}

/// UTF-8 (BOM stripped). Invalid sequences become U+FFFD instead of failing.
String decodeText(List<int> bytes) {
  var start = 0;
  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    start = 3;
  }
  return utf8
      .decode(bytes.sublist(start), allowMalformed: true)
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
}

/// PDFium reports line breaks as CRLF and keeps soft hyphens.
String cleanPdfText(String text) => text
    .replaceAll('\r\n', '\n')
    .replaceAll('\r', '\n')
    .replaceAll('­', '')
    .replaceAll('\u0000', '');
