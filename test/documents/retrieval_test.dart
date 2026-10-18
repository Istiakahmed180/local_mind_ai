import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/document_repository.dart';
import 'package:localmind_ai/services/documents/chunker.dart';
import 'package:localmind_ai/services/documents/retrieval.dart';

RetrievedPassage passage(int id, String text) => RetrievedPassage(
  chunkId: id,
  documentId: 'd',
  documentName: 'doc.txt',
  text: text,
);

void main() {
  group('queryTerms', () {
    test('drops stopwords and punctuation, stems English plurals', () {
      expect(queryTerms('What is the REFUND period for batteries?'), [
        'refund',
        'period',
        'battery',
      ]);
    });

    test('keeps Bengali words with their vowel signs, minus case endings', () {
      expect(queryTerms('ফেরতের সময়সীমা কত?'), ['ফেরত', 'সময়সীমা']);
      expect(queryTerms('বইগুলো বাড়ির'), ['বই', 'বাড়ি']);
    });

    test('drops question words and reduces English inflections', () {
      expect(queryTerms('How many days to return a product?'), [
        'day',
        'return',
        'product',
      ]);
      expect(queryTerms('returned returning returns'), ['return']);
      expect(queryTerms('stopped charging batteries'), [
        'stop',
        'charg',
        'battery',
      ]);
    });

    test('keeps numbers and deduplicates', () {
      expect(queryTerms('error 42 and error 42'), ['error', '42']);
    });

    test('match expression quotes every term as a prefix', () {
      expect(
        ftsMatchExpression(['refund', 'period']),
        '"refund"* OR "period"*',
      );
      expect(ftsMatchExpression(['battery']), '"batter"*');
    });
  });

  group('rankPassages', () {
    test('passages covering more query terms rank first', () {
      final ranked = rankPassages(
        [
          passage(1, 'The battery is replaceable. Battery battery battery.'),
          passage(2, 'Refunds are possible within a 30 day period.'),
          passage(3, 'Refund requests for a battery: 30 day period applies.'),
          passage(4, 'Unrelated text about shipping.'),
        ],
        ['refund', 'period', 'battery'],
        totalChunks: 10,
      );
      expect(ranked.map((p) => p.chunkId), [3, 2, 1]);
      expect(ranked.first.matchedTerms, {'refund', 'period', 'battery'});
    });

    test('rare terms weigh more than common ones', () {
      final ranked = rankPassages(
        [
          passage(1, 'warranty warranty'),
          passage(2, 'warranty'),
          passage(3, 'warranty'),
          passage(4, 'firmware'),
        ],
        queryTerms('warranty firmware'),
        totalChunks: 4,
      );
      expect(ranked.first.chunkId, 4);
    });

    test('ties break by chunk order and limit applies', () {
      final ranked = rankPassages(
        [passage(9, 'alpha'), passage(2, 'alpha'), passage(5, 'alpha')],
        ['alpha'],
        totalChunks: 3,
        limit: 2,
      );
      expect(ranked.map((p) => p.chunkId), [2, 5]);
    });

    test('inflected words in the passage match the question', () {
      const q = 'How many days to return a product?';
      final terms = queryTerms(q);
      final ranked = rankPassages(
        [
          passage(
            1,
            'Unused products can be returned within 30 days of delivery.',
          ),
        ],
        terms,
        totalChunks: 1,
      );
      expect(ranked.single.matchedTerms, {'day', 'return', 'product'});
      expect(hasEnoughEvidence(ranked, terms), isTrue);
    });

    test('evidence needs at least half of the terms', () {
      final ranked = rankPassages(
        [passage(1, 'refund only')],
        ['refund', 'period', 'battery'],
        totalChunks: 1,
      );
      expect(
        hasEnoughEvidence(ranked, ['refund', 'period', 'battery']),
        isFalse,
      );
      expect(hasEnoughEvidence(ranked, ['refund', 'period']), isTrue);
      expect(hasEnoughEvidence(const [], ['refund']), isFalse);
      expect(hasEnoughEvidence(ranked, const []), isFalse);
    });
  });

  group('DocumentRepository.search', () {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    late AppDatabase db;
    late DocumentRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = DocumentRepository(db);
      await db.customSelect('SELECT 1').get(); // opens the database
      Future<void> add(String id, String name, List<TextChunk> chunks) async {
        await repo.insert(
          DocumentsCompanion.insert(
            id: id,
            name: name,
            kind: 'txt',
            filePath: '/x/$id',
            sizeBytes: 1,
            status: 'ready',
            importedAt: DateTime(2026),
          ),
        );
        await repo.replaceChunks(id, chunks);
      }

      await add('a', 'policy.txt', const [
        TextChunk(
          ordinal: 0,
          text: 'Refunds are accepted within 30 days.',
          lineStart: 1,
          lineEnd: 2,
        ),
        TextChunk(
          ordinal: 1,
          text: 'Shipping takes five business days.',
          lineStart: 3,
          lineEnd: 3,
        ),
      ]);
      await add('b', 'manual.pdf', const [
        TextChunk(
          ordinal: 0,
          text: 'The battery refund period is 14 days.',
          page: 4,
        ),
        TextChunk(ordinal: 1, text: 'ফেরতের সময়সীমা ৭ দিন।', page: 5),
      ]);
      await add('c', 'shop.txt', const [
        TextChunk(
          ordinal: 0,
          text: 'Unused products can be returned within 30 days of delivery.',
          lineStart: 1,
          lineEnd: 1,
        ),
        TextChunk(
          ordinal: 1,
          text: 'বইগুলো কেনার পর দশ দিনের মধ্যে ফেরত দেওয়া যায়।',
          lineStart: 2,
          lineEnd: 2,
        ),
      ]);
    });

    tearDown(() => db.close());

    test('the test SQLite build has FTS5', () {
      expect(repo.usesFts5, isTrue);
    });

    for (final like in [false, true]) {
      final mode = like ? 'LIKE' : 'FTS5';
      test('$mode: ranks the passage matching most terms first', () async {
        final r = await repo.search('battery refund period', forceLike: like);
        expect(r.first.documentName, 'manual.pdf');
        expect(r.first.page, 4);
        expect(r.map((p) => p.text), contains(startsWith('Refunds')));
        expect(r.map((p) => p.text), isNot(contains(startsWith('Shipping'))));
      });

      test('$mode: finds Bengali text', () async {
        final r = await repo.search('ফেরতের সময়সীমা', forceLike: like);
        expect(r.first.page, 5);
      });

      test('$mode: question words and word forms still match', () async {
        const q = 'How many days to return a product?';
        final r = await repo.search(q, forceLike: like);
        expect(r.first.documentName, 'shop.txt');
        expect(r.first.lineStart, 1);
        expect(hasEnoughEvidence(r, queryTerms(q)), isTrue);
      });

      test('$mode: Bengali case endings still match', () async {
        const q = 'বইগুলোর ফেরতের জন্য কত দিন পাওয়া যায়?';
        final r = await repo.search(q, forceLike: like);
        expect(r.first.documentName, 'shop.txt');
        expect(r.first.lineStart, 2);
        expect(hasEnoughEvidence(r, queryTerms(q)), isTrue);
      });

      test('$mode: finds plural forms of a -y word', () async {
        final r = await repo.search('batteries', forceLike: like);
        expect(r.single.page, 4);
      });

      test('$mode: filters by document and handles no match', () async {
        final r = await repo.search(
          'refund',
          documentIds: {'a'},
          forceLike: like,
        );
        expect(r.single.documentName, 'policy.txt');
        expect(await repo.search('zebra', forceLike: like), isEmpty);
      });
    }

    test('FTS syntax in the query cannot break the MATCH expression', () async {
      final r = await repo.search('refund" OR NEAR(* AND -shipping');
      expect(r, isNotEmpty);
    });

    test('deleting a document removes its chunks from the index', () async {
      await repo.delete('b');
      expect(await repo.search('battery'), isEmpty);
      final fts = await db
          .customSelect(
            "SELECT count(*) AS n FROM document_chunks_fts "
            "WHERE document_chunks_fts MATCH 'battery'",
          )
          .getSingle();
      expect(fts.read<int>('n'), 0);
      expect(await repo.chunkCount(), 4);
    });

    test('rebuilding the keyword index keeps results', () async {
      await repo.rebuildKeywordIndex();
      final r = await repo.search('shipping');
      expect(r.single.lineStart, 3);
    });
  });
}
