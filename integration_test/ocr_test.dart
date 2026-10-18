import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/document_repository.dart';
import 'package:localmind_ai/services/documents/document_service.dart';
import 'package:localmind_ai/services/documents/ocr_service.dart';
import 'package:localmind_ai/services/documents/text_extraction.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Real Tesseract on image-only PDFs. Push first:
///   `adb push eng.traineddata ben.traineddata en-scan.pdf bn-scan.pdf /data/local/tmp/`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const tmp = '/data/local/tmp';

  late OcrService ocr;
  late DocumentService docs;
  late AppDatabase db;

  setUpAll(() async {
    final base = Directory(
      p.join((await getTemporaryDirectory()).path, 'ocr-it'),
    );
    ocr = await OcrService(
      freeBytes: () async => 1 << 40,
      baseDir: () async => base,
    ).init();
    for (final l in ocr.languages) {
      final src = File('$tmp/${l.fileName}');
      if (src.existsSync()) {
        await src.copy(p.join(ocr.dataPath, 'tessdata', l.fileName));
      }
    }
    await ocr.refresh();
    db = AppDatabase(NativeDatabase.memory());
    docs = DocumentService(
      DocumentRepository(db),
      extractor: TextExtractor(ocr: ocr),
      baseDir: () async => base,
    );
  });

  tearDownAll(() => db.close());

  Future<void> run(
    String file,
    List<String> expectedWords,
    String query,
  ) async {
    if (!File('$tmp/$file').existsSync() || !ocr.ready) {
      markTestSkipped('push $file and tessdata');
      return;
    }
    final watch = Stopwatch()..start();
    final doc = await docs.import('$tmp/$file', file);
    final ms = watch.elapsedMilliseconds;
    final chunks = await DocumentRepository(db).search(query, limit: 1);
    final text = (await db.select(db.documentChunks).get())
        .where((c) => c.documentId == doc.id)
        .map((c) => c.body)
        .join(' ');
    final found = [
      for (final w in expectedWords)
        if (text.toLowerCase().contains(w.toLowerCase())) w,
    ];
    // ignore: avoid_print
    print(
      '[$file] langs=${ocrLanguageString(ocr.installedIds)} ${ms}ms '
      'ocrPages=${doc.ocrPages} words ${found.length}/${expectedWords.length} '
      'search("$query")=${chunks.isNotEmpty}\n  text: ${text.replaceAll('\n', ' ')}',
    );
    expect(doc.ocrPages, 1);
    expect(text.trim(), isNotEmpty);
  }

  testWidgets(
    'English scan',
    semanticsEnabled: false,
    (_) => run('en-scan.pdf', [
      'Warranty',
      'appliance',
      'guarantee',
      'manufacturing',
      'Refunds',
      'thirty',
      'purchase',
      'unused',
    ], 'guarantee'),
  );

  testWidgets(
    'Bengali scan',
    semanticsEnabled: false,
    (_) => run('bn-scan.pdf', [
      'ফেরত',
      'নীতি',
      'পণ্য',
      'ত্রিশ',
      'দিনের',
      'টাকা',
      'ঢাকার',
      'ডেলিভারি',
    ], 'ঢাকার'),
  );
}
