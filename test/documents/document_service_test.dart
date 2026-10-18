import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/document_repository.dart';
import 'package:localmind_ai/services/documents/document_service.dart';
import 'package:localmind_ai/services/documents/text_extraction.dart';
import 'package:path/path.dart' as p;

class FakePdf implements PdfTextExtractor {
  FakePdf(this.pages);

  final List<String> pages;

  @override
  Future<List<String>> pageTexts(String path) async => pages;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory tmp;
  late AppDatabase db;
  late FakePdf pdf;
  late DocumentService service;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('docs_test');
    db = AppDatabase(NativeDatabase.memory());
    pdf = FakePdf([]);
    service = DocumentService(
      DocumentRepository(db),
      extractor: TextExtractor(pdf: pdf),
      baseDir: () async => Directory(p.join(tmp.path, 'support')),
    );
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  Future<String> source(String name, String content) async {
    final f = File(p.join(tmp.path, name));
    await f.writeAsString(content);
    return f.path;
  }

  test('imports a text file into app storage and searches it', () async {
    final path = await source(
      'policy.txt',
      '﻿Returns\n\nItems can be returned within 30 days of delivery.\n',
    );
    final doc = await service.import(path, 'policy.txt');
    expect(doc.kind, 'txt');
    expect(doc.chunkCount, 1);
    expect(doc.filePath, startsWith(p.join(tmp.path, 'support', 'documents')));
    expect(File(doc.filePath).existsSync(), isTrue);

    final hits = await service.search('return within how many days');
    expect(hits.single.documentName, 'policy.txt');
    expect(hits.single.lineStart, 1);
    expect(hits.single.lineEnd, 3);
    expect(hits.single.text, isNot(contains('﻿')));
  });

  test('PDF pages keep their numbers; empty pages are skipped', () async {
    pdf.pages.addAll(['Intro text here.', '', 'Battery lasts 10 hours.']);
    final doc = await service.import(await source('m.pdf', '%PDF'), 'm.pdf');
    expect(doc.pageCount, 3);
    final hits = await service.search('battery hours');
    expect(hits.single.page, 3);
  });

  test('a PDF without a text layer is rejected and nothing is kept', () async {
    pdf.pages.addAll(['', '  ', '\n']);
    await expectLater(
      service.import(await source('scan.pdf', '%PDF'), 'scan.pdf'),
      throwsA(
        isA<ExtractionException>().having(
          (e) => e.reason,
          'reason',
          'doc_error_no_text_pdf',
        ),
      ),
    );
    expect(await db.select(db.documents).get(), isEmpty);
    final dir = Directory(p.join(tmp.path, 'support', 'documents'));
    expect(dir.listSync(), isEmpty);
  });

  test('unsupported types are rejected before copying', () async {
    await expectLater(
      service.import(await source('a.docx', 'x'), 'a.docx'),
      throwsA(isA<ExtractionException>()),
    );
    expect(Directory(p.join(tmp.path, 'support')).existsSync(), isFalse);
  });

  test('remove deletes the stored copy and its passages', () async {
    final doc = await service.import(
      await source('n.md', '# Notes\n\nThe secret word is pelican.'),
      'n.md',
    );
    await service.remove(doc.id);
    expect(File(doc.filePath).existsSync(), isFalse);
    expect(await service.search('pelican'), isEmpty);
  });

  test('rebuild re-indexes and flags documents whose copy is gone', () async {
    final good = await service.import(
      await source('a.txt', 'Alpha bravo charlie.'),
      'a.txt',
    );
    final bad = await service.import(
      await source('b.txt', 'Delta echo foxtrot.'),
      'b.txt',
    );
    await File(bad.filePath).delete();
    expect(await service.rebuildIndex(), 1);
    final rows = {for (final d in await db.select(db.documents).get()) d.id: d};
    expect(rows[good.id]!.status, 'ready');
    expect(rows[bad.id]!.status, 'error');
    expect(rows[bad.id]!.chunkCount, 0);
    expect(await service.search('alpha'), hasLength(1));
    expect(await service.search('delta'), isEmpty);
  });

  test('removeAll clears rows and files', () async {
    await service.import(await source('a.txt', 'Alpha bravo.'), 'a.txt');
    await service.removeAll();
    expect(await db.select(db.documents).get(), isEmpty);
    expect(
      Directory(p.join(tmp.path, 'support', 'documents')).existsSync(),
      isFalse,
    );
  });

  test('document Q&A code has no path to agent tools or the network', () {
    final files = [
      ...Directory('lib/services/documents').listSync(),
      ...Directory('lib/features/documents').listSync(),
      File('lib/data/repositories/document_repository.dart'),
    ].whereType<File>();
    for (final f in files) {
      final src = f.readAsStringSync();
      expect(src, isNot(contains('services/agent')), reason: f.path);
      expect(src, isNot(contains('openUri')), reason: f.path);
      expect(src, isNot(contains('package:http')), reason: f.path);
    }
  });
}
