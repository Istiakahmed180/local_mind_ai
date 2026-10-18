import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/document_repository.dart';
import 'package:localmind_ai/services/documents/document_service.dart';
import 'package:localmind_ai/services/documents/ocr_service.dart';
import 'package:localmind_ai/services/documents/text_extraction.dart';
import 'package:localmind_ai/services/downloads/model_downloader.dart';
import 'package:path/path.dart' as p;

class FakePdf implements PdfTextExtractor {
  FakePdf(this.pages);
  final List<String> pages;
  @override
  Future<List<String>> pageTexts(String path) async => pages;
}

class FakeRenderer implements PdfPageRenderer {
  final rendered = <int>[];
  @override
  Future<PageImage?> render(String path, int index) async {
    rendered.add(index);
    return PageImage(Uint8List(4), 2, 2);
  }
}

class FakeOcr implements PageOcr {
  FakeOcr(this.text, {this.ready = true});
  final String text;
  @override
  final bool ready;
  int calls = 0;
  @override
  Future<String> recognize(PageImage image) async {
    calls++;
    return text;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('image helpers', () {
    test('BGRA to grayscale uses luminance weights', () {
      final bgra = Uint8List.fromList([
        255, 255, 255, 255, // white
        0, 0, 0, 255, // black
        0, 0, 255, 255, // red (B,G,R,A)
      ]);
      expect(bgraToGray(bgra, 3, 1), [255, 0, 76]);
    });

    test('render size is about 200 DPI and capped at 2400 px', () {
      final a4 = ocrRenderSize(595, 842);
      expect(a4.width, closeTo(1653, 2));
      expect(a4.height, closeTo(2339, 2));
      final poster = ocrRenderSize(2000, 3000);
      expect(poster.height, 2400);
      expect(poster.width, 1600);
    });
  });

  group('extractor', () {
    test(
      'OCRs only pages without a text layer and keeps page numbers',
      () async {
        final renderer = FakeRenderer();
        final ocr = FakeOcr('Scanned invoice total 500 taka');
        final progress = <(int, int)>[];
        final x = TextExtractor(
          pdf: FakePdf(['', 'A real text layer with plenty of words.', ' ']),
          renderer: renderer,
          ocr: ocr,
        );
        final r = await x.extract(
          'f.pdf',
          DocumentKind.pdf,
          onOcrProgress: (d, t) => progress.add((d, t)),
        );
        expect(renderer.rendered, [0, 2]);
        expect(r.ocrPages, 2);
        expect(r.segments.map((s) => s.page), [1, 2, 3]);
        expect(r.segments[0].text, 'Scanned invoice total 500 taka');
        expect(r.segments[1].text, 'A real text layer with plenty of words.');
        expect(progress, [(0, 2), (1, 2), (2, 2)]);
      },
    );

    test('no OCR when no language is installed', () async {
      final ocr = FakeOcr('x', ready: false);
      final r = await TextExtractor(
        pdf: FakePdf(['']),
        renderer: FakeRenderer(),
        ocr: ocr,
      ).extract('f.pdf', DocumentKind.pdf);
      expect(ocr.calls, 0);
      expect(r.ocrPages, 0);
    });

    test('refuses too many scanned pages', () {
      final x = TextExtractor(
        pdf: FakePdf(List.filled(maxOcrPages + 1, '')),
        renderer: FakeRenderer(),
        ocr: FakeOcr('x'),
      );
      expect(
        () => x.extract('f.pdf', DocumentKind.pdf),
        throwsA(
          isA<ExtractionException>().having(
            (e) => e.reason,
            'reason',
            'doc_error_ocr_too_many_pages',
          ),
        ),
      );
    });

    test('cancel stops between pages', () async {
      final cancel = ExtractionCancel();
      final ocr = FakeOcr('text');
      final x = TextExtractor(
        pdf: FakePdf(['', '', '']),
        renderer: FakeRenderer(),
        ocr: ocr,
      );
      await expectLater(
        x.extract(
          'f.pdf',
          DocumentKind.pdf,
          cancel: cancel,
          onOcrProgress: (d, _) {
            if (d == 1) cancel.cancel();
          },
        ),
        throwsA(
          isA<ExtractionException>().having(
            (e) => e.reason,
            'reason',
            'doc_import_cancelled',
          ),
        ),
      );
      expect(ocr.calls, 1);
    });
  });

  group('document import', () {
    late Directory tmp;
    late AppDatabase db;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('ocr_doc');
      db = AppDatabase(NativeDatabase.memory());
    });
    tearDown(() async {
      await db.close();
      await tmp.delete(recursive: true);
    });

    DocumentService service(PageOcr? ocr, List<String> pages) =>
        DocumentService(
          DocumentRepository(db),
          extractor: TextExtractor(
            pdf: FakePdf(pages),
            renderer: FakeRenderer(),
            ocr: ocr,
          ),
          baseDir: () async => Directory(p.join(tmp.path, 's')),
        );

    Future<String> pdf() async {
      final f = File(p.join(tmp.path, 'scan.pdf'))..writeAsBytesSync([1]);
      return f.path;
    }

    test('scanned PDF without OCR points the user to OCR', () async {
      await expectLater(
        service(null, ['']).import(await pdf(), 'scan.pdf'),
        throwsA(
          isA<ExtractionException>().having(
            (e) => e.reason,
            'reason',
            'doc_error_no_text_pdf',
          ),
        ),
      );
    });

    test('scanned PDF with OCR is imported and marked', () async {
      final s = service(FakeOcr('The warranty lasts twelve months.'), ['', '']);
      final doc = await s.import(await pdf(), 'scan.pdf');
      expect(doc.ocrPages, 2);
      final found = await s.search('warranty months');
      expect(found.first.page, 1);
    });

    test('OCR that finds nothing gives a clear error', () async {
      await expectLater(
        service(FakeOcr('   '), ['']).import(await pdf(), 'scan.pdf'),
        throwsA(
          isA<ExtractionException>().having(
            (e) => e.reason,
            'reason',
            'doc_error_ocr_no_text',
          ),
        ),
      );
    });
  });

  group('OCR service', () {
    late Directory tmp;
    final eng = utf8.encode('eng-data');
    final ben = utf8.encode('ben-data!');
    const channel = MethodChannel('localmind/ocr');
    final calls = <MethodCall>[];

    Map<String, dynamic> catalog() => {
      'hosts': {'gh': 'https://raw.example'},
      'ocrLanguages': [
        {
          'id': 'ben',
          'name': 'Bengali',
          'host': 'gh',
          'path': 'org/repo/abc/ben.traineddata',
          'sizeBytes': ben.length,
          'sha256': sha256.convert(ben).toString(),
          'license': 'Apache-2.0',
        },
        {
          'id': 'eng',
          'name': 'English',
          'host': 'gh',
          'path': 'org/repo/abc/eng.traineddata',
          'sizeBytes': eng.length,
          'sha256': sha256.convert(eng).toString(),
          'license': 'Apache-2.0',
        },
      ],
    };

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('ocr_svc');
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (c) async {
            calls.add(c);
            return c.method == 'recognize'
                ? {'text': ' hello ', 'confidence': 90}
                : true;
          });
    });
    tearDown(() => tmp.delete(recursive: true));

    Future<OcrService> make({String? corruptBen}) => OcrService(
      freeBytes: () async => 1 << 40,
      baseDir: () async => tmp,
      downloader: ModelDownloader(
        freeBytes: () async => 1 << 40,
        clientFactory: () => MockClient(
          (r) async => http.Response.bytes(
            r.url.path.endsWith('eng.traineddata')
                ? eng
                : utf8.encode(corruptBen ?? 'ben-data!'),
            200,
          ),
        ),
      ),
    ).init(catalog: catalog());

    test('catalog parsing rejects unsafe entries', () {
      final bad = catalog();
      (bad['ocrLanguages'] as List)[0]['path'] = 'x/../evil.traineddata';
      expect(() => parseOcrLanguages(bad), throwsFormatException);
      final http = catalog()..['hosts'] = {'gh': 'http://raw.example'};
      expect(() => parseOcrLanguages(http), throwsFormatException);
    });

    test('language string puts English first', () {
      expect(ocrLanguageString(['ben', 'eng']), 'eng+ben');
      expect(ocrLanguageString(['ben']), 'ben');
      expect(ocrLanguageString([]), '');
    });

    test('downloads, verifies, recognizes and removes', () async {
      final s = await make();
      expect(s.ready, isFalse);
      for (final l in s.languages) {
        await s.download(l);
      }
      expect(s.installedIds, ['ben', 'eng']);
      expect(
        File(p.join(tmp.path, 'ocr', 'tessdata', 'eng.traineddata'))
            .existsSync(),
        isTrue,
      );
      final text = await s.recognize(PageImage(Uint8List(4), 2, 2));
      expect(text, ' hello ');
      final rec = calls.lastWhere((c) => c.method == 'recognize');
      expect((rec.arguments as Map)['langs'], 'eng+ben');
      expect((rec.arguments as Map)['dataPath'], p.join(tmp.path, 'ocr'));

      await s.remove(s.languages.firstWhere((l) => l.id == 'ben'));
      expect(s.installedIds, ['eng']);
    });

    test('a file that fails the checksum is not installed', () async {
      final s = await make(corruptBen: 'tampered');
      await s.download(s.languages.firstWhere((l) => l.id == 'ben'));
      expect(s.states['ben'], OcrLangState.failed);
      expect(s.ready, isFalse);
    });
  });
}
