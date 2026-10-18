import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

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
  const ExtractionResult(this.segments, {this.pageCount, this.ocrPages = 0});

  final List<SourceSegment> segments;
  final int? pageCount;

  /// Pages whose text came from OCR rather than the PDF's text layer.
  final int ocrPages;

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

/// A rendered page as 8-bit grayscale pixels, row by row.
class PageImage {
  const PageImage(this.gray, this.width, this.height);

  final Uint8List gray;
  final int width;
  final int height;
}

abstract interface class PdfPageRenderer {
  /// Renders page [index] (0-based) for OCR, or null if it cannot.
  Future<PageImage?> render(String path, int index);
}

/// Recognizes text in a page image. Implemented by the OCR service.
abstract interface class PageOcr {
  /// True when at least one OCR language is installed.
  bool get ready;

  Future<String> recognize(PageImage image);
}

/// Below this many characters a PDF page is treated as having no text layer.
const minPageTextChars = 20;

/// Most pages OCR will process in one document.
const maxOcrPages = 150;

/// Resolution used for OCR: about 200 DPI, long side at most 2400 px.
({int width, int height}) ocrRenderSize(double widthPt, double heightPt) {
  final scale = math.min(200 / 72, 2400 / math.max(widthPt, heightPt));
  return (
    width: (widthPt * scale).round().clamp(1, 2400),
    height: (heightPt * scale).round().clamp(1, 2400),
  );
}

/// BGRA8888 → 8-bit luminance (ITU-R BT.601 weights).
Uint8List bgraToGray(Uint8List bgra, int width, int height) {
  final out = Uint8List(width * height);
  for (var i = 0, j = 0; i < out.length; i++, j += 4) {
    out[i] = (bgra[j + 2] * 299 + bgra[j + 1] * 587 + bgra[j] * 114) ~/ 1000;
  }
  return out;
}

/// Renders pages with PDFium on a white background for OCR.
class PdfiumPageRenderer implements PdfPageRenderer {
  @override
  Future<PageImage?> render(String path, int index) async {
    await pdfrxFlutterInitialize();
    final doc = await PdfDocument.openFile(path);
    try {
      final page = doc.pages[index];
      final size = ocrRenderSize(page.width, page.height);
      final image = await page.render(
        fullWidth: size.width.toDouble(),
        fullHeight: size.height.toDouble(),
        width: size.width,
        height: size.height,
        backgroundColor: 0xFFFFFFFF,
        annotationRenderingMode: PdfAnnotationRenderingMode.none,
      );
      if (image == null) return null;
      try {
        final pixels = image.pixels;
        final w = image.width, h = image.height;
        final gray = await Isolate.run(() => bgraToGray(pixels, w, h));
        return PageImage(gray, w, h);
      } finally {
        image.dispose();
      }
    } finally {
      await doc.dispose();
    }
  }
}

/// Lets a running import be stopped between pages.
class ExtractionCancel {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class TextExtractor {
  TextExtractor({PdfTextExtractor? pdf, PdfPageRenderer? renderer, this.ocr})
    : _pdf = pdf ?? PdfiumTextExtractor(),
      _renderer = renderer ?? PdfiumPageRenderer();

  final PdfTextExtractor _pdf;
  final PdfPageRenderer _renderer;

  /// OCR for pages without a text layer; null or not ready means none.
  PageOcr? ocr;

  Future<ExtractionResult> extract(
    String path,
    DocumentKind kind, {
    void Function(int done, int total)? onOcrProgress,
    ExtractionCancel? cancel,
  }) async {
    switch (kind) {
      case DocumentKind.txt:
      case DocumentKind.md:
        final bytes = await File(path).readAsBytes();
        return ExtractionResult([SourceSegment(decodeText(bytes))]);
      case DocumentKind.pdf:
        final pages = [
          for (final t in await _pdf.pageTexts(path)) cleanPdfText(t),
        ];
        final o = ocr;
        var ocrPages = 0;
        if (o != null && o.ready) {
          final empty = [
            for (var i = 0; i < pages.length; i++)
              if (pages[i].trim().length < minPageTextChars) i,
          ];
          if (empty.length > maxOcrPages) {
            throw const ExtractionException('doc_error_ocr_too_many_pages');
          }
          for (var n = 0; n < empty.length; n++) {
            onOcrProgress?.call(n, empty.length);
            if (cancel?.isCancelled ?? false) {
              throw const ExtractionException('doc_import_cancelled');
            }
            final image = await _renderer.render(path, empty[n]);
            if (image == null) continue;
            final text = (await o.recognize(image)).trim();
            if (text.isNotEmpty) {
              pages[empty[n]] = text;
              ocrPages++;
            }
          }
          if (empty.isNotEmpty) onOcrProgress?.call(empty.length, empty.length);
        }
        return ExtractionResult(
          [
            for (var i = 0; i < pages.length; i++)
              SourceSegment(pages[i], page: i + 1),
          ],
          pageCount: pages.length,
          ocrPages: ocrPages,
        );
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
