import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/document_repository.dart';
import 'package:localmind_ai/data/repositories/model_repository.dart';
import 'package:localmind_ai/domain/model_definition.dart';
import 'package:localmind_ai/services/device/device_info_service.dart';
import 'package:localmind_ai/services/documents/document_service.dart';
import 'package:localmind_ai/services/documents/embedding_service.dart';
import 'package:localmind_ai/services/documents/retrieval.dart';
import 'package:localmind_ai/services/documents/text_extraction.dart';
import 'package:localmind_ai/services/documents/vectors.dart';
import 'package:localmind_ai/services/inference/embedding_runtime.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';
import 'package:localmind_ai/services/inference/model_runtime_service.dart';
import 'package:localmind_ai/services/model_service.dart';
import 'package:localmind_ai/services/settings_service.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

/// Maps words to fixed "meaning" axes so paraphrases share a direction.
class FakeEmbedder implements EmbeddingRuntime {
  static const axes = [
    {'refund', 'money', 'back', 'reimburse', 'return'},
    {'shipping', 'delivery', 'courier', 'arrive'},
    {'warranty', 'guarantee', 'repair'},
  ];

  bool loaded = false;
  int loads = 0;
  final inputs = <String>[];
  bool fail = false;

  @override
  bool get isLoaded => loaded;

  @override
  Future<void> load(String path) async {
    loaded = true;
    loads++;
  }

  @override
  Future<void> unload() async => loaded = false;

  @override
  Future<List<List<double>>> embed(List<String> texts) async {
    if (fail) throw const InferenceException('boom');
    inputs.addAll(texts);
    return [
      for (final t in texts)
        [
          for (final axis in axes)
            axis.where((w) => t.toLowerCase().contains(w)).length.toDouble(),
          0.1,
        ],
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('vectors', () {
    test('float32 round trip', () {
      final v = [0.25, -1.5, 3.0];
      expect(decodeVector(encodeVector(v)), v);
    });

    test('normalize and dot give cosine similarity', () {
      final a = normalize([3, 4]);
      expect(dot(a, a), closeTo(1, 1e-9));
      expect(dot(normalize([1, 0]), normalize([0, 1])), 0);
      expect(dot([1, 2], [1]), 0, reason: 'length mismatch');
    });

    test('topSimilar ranks by similarity', () {
      final q = normalize([1, 0]);
      final stored = [
        (1, Float32List.fromList(normalize([0, 1]).cast<double>())),
        (2, Float32List.fromList(normalize([1, 0.1]).cast<double>())),
        (3, Float32List.fromList(normalize([1, 1]).cast<double>())),
      ];
      expect(topSimilar(q, stored, 2).map((e) => e.$1), [2, 3]);
    });

    test('fusion keeps both signals and favours passages found twice', () {
      RetrievedPassage p(int id, {double? sim, Set<String> t = const {}}) =>
          RetrievedPassage(
            chunkId: id,
            documentId: 'd',
            documentName: 'n',
            text: 't',
            matchedTerms: t,
            similarity: sim,
          );
      final fused = fuseRankings(
        [
          p(1, t: {'a'}),
          p(2, t: {'b'}),
        ],
        [p(2, sim: 0.9), p(3, sim: 0.8)],
        limit: 3,
      );
      expect(fused.map((x) => x.chunkId), [2, 1, 3]);
      expect(fused.first.matchedTerms, {'b'});
      expect(fused.first.similarity, 0.9);
    });
  });

  test('evidence: similarity counts when a threshold is given', () {
    const passage = RetrievedPassage(
      chunkId: 1,
      documentId: 'd',
      documentName: 'n',
      text: 't',
      similarity: 0.7,
    );
    expect(hasEnoughEvidence([passage], const []), isFalse);
    expect(hasEnoughEvidence([passage], const [], minSimilarity: 0.6), isTrue);
    expect(hasEnoughEvidence([passage], const [], minSimilarity: 0.8), isFalse);
  });

  test('catalog: embedding models parse and stay out of chat lists', () {
    final catalog = ModelCatalog.fromJson(
      jsonDecode(File('assets/models/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    expect(catalog.embeddingModels, isNotEmpty);
    expect(catalog.chatModels.any((m) => m.isEmbedding), isFalse);
    final nomic = catalog.byId('nomic-embed-text-v1.5-q8_0')!;
    expect(nomic.queryPrefix, 'search_query: ');
    expect(nomic.documentPrefix, 'search_document: ');
    expect(nomic.minSimilarity, isNotNull);
    expect(
      () => ModelCatalog.fromJson({
        'schemaVersion': 1,
        'hosts': {'h': 'https://x.y'},
        'models': [
          {
            ...?jsonDecode(jsonEncode(_entry())) as Map<String, dynamic>?,
            'kind': 'rerank',
          },
        ],
      }),
      throwsFormatException,
    );
  });

  group('semantic search', () {
    late Directory tmp;
    late AppDatabase db;
    late DocumentRepository repo;
    late DocumentService docs;
    late EmbeddingService embeddings;
    late FakeEmbedder embedder;
    late FakeRuntime chat;
    late ModelRuntimeService chatService;
    late SettingsService settings;
    late ModelService models;

    Future<void> installEmbedding(String id) async {
      final modelRepo = ModelRepository(db);
      await modelRepo.upsert(
        InstalledModelsCompanion.insert(
          id: id,
          displayName: id,
          source: 'catalog',
          filePath: '/fake/$id.gguf',
          sizeBytes: 1,
          sha256: const Value('x'),
          verified: true,
          installedAt: DateTime.now(),
        ),
      );
      models.installed.add((await modelRepo.byId(id))!);
    }

    ModelDefinition def(String id, {int size = 100 << 20}) =>
        ModelDefinition.fromJson(
          {
            ..._entry(),
            'id': id,
            'kind': 'embedding',
            'sizeBytes': size,
            'queryPrefix': 'q: ',
            'documentPrefix': 'd: ',
            'minSimilarity': 0.6,
          },
          {'h': 'https://x.y'},
        );

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('sem');
      db = AppDatabase(NativeDatabase.memory());
      repo = DocumentRepository(db);
      SharedPreferences.setMockInitialValues({});
      settings = SettingsService(await SharedPreferences.getInstance());
      final modelRepo = ModelRepository(db);
      models = ModelService(modelRepo, DeviceInfoService());
      models.catalog.value = ModelCatalog([
        def('small'),
        def('large', size: 600 << 20),
      ]);
      chat = FakeRuntime();
      chatService = ModelRuntimeService(chat, models, modelRepo, settings);
      embedder = FakeEmbedder();
      embeddings = EmbeddingService(
        repo,
        models,
        settings,
        chatService,
        embedder,
      );
      docs = DocumentService(
        repo,
        extractor: TextExtractor(),
        baseDir: () async => Directory(p.join(tmp.path, 's')),
      )..semantic = embeddings;
    });

    tearDown(() async {
      embeddings.onClose();
      await db.close();
      await tmp.delete(recursive: true);
    });

    Future<void> importText(String name, String text) async {
      final f = File(p.join(tmp.path, name))..writeAsStringSync(text);
      await docs.import(f.path, name);
    }

    test('keyword only until a model is chosen', () async {
      await importText('a.txt', 'You can get your money back within 30 days.');
      expect(embeddings.ready, isFalse);
      final found = await docs.search('refund policy');
      expect(found, isEmpty, reason: 'no shared keyword');
      expect(docs.minSimilarity, isNull);
    });

    test(
      'indexes passages with the document prefix and finds paraphrases',
      () async {
        await importText(
          'a.txt',
          'You can get your money back within 30 days.',
        );
        await importText('b.txt', 'Our courier will arrive in two days.');
        await installEmbedding('small');
        await embeddings.selectModel('small');
        await embeddings.indexMissing();
        expect(embeddings.embedded.value, embeddings.total.value);
        expect(embedder.inputs.where((t) => t.startsWith('d: ')), hasLength(2));

        final found = await docs.search('What is the refund policy?', limit: 2);
        expect(found.first.documentName, 'a.txt');
        expect(found.first.similarity, greaterThan(0.6));
        expect(embedder.inputs.last, startsWith('q: '));
        expect(
          hasEnoughEvidence(
            found,
            queryTerms('What is the refund policy?'),
            minSimilarity: docs.minSimilarity,
          ),
          isTrue,
        );
      },
    );

    test('meaning-search failure falls back to keyword results', () async {
      await importText('a.txt', 'Refund requests take 30 days.');
      await installEmbedding('small');
      await embeddings.selectModel('small');
      await embeddings.indexMissing();
      embedder.fail = true;
      final found = await docs.search('refund');
      expect(found.single.documentName, 'a.txt');
      expect(found.single.similarity, isNull);
    });

    test('a large embedding model unloads the chat model first', () async {
      final dir = await Directory.systemTemp.createTemp('m');
      final chatFile = await writeFakeGguf('${dir.path}/c.gguf');
      final modelRepo = ModelRepository(db);
      await modelRepo.upsert(
        InstalledModelsCompanion.insert(
          id: 'chat',
          displayName: 'chat',
          source: 'import',
          filePath: chatFile.path,
          sizeBytes: chatFile.lengthSync(),
          verified: false,
          installedAt: DateTime.now(),
        ),
      );
      models.installed.add((await modelRepo.byId('chat'))!);
      await chatService.ensureLoaded('chat');
      expect(chat.isLoaded, isTrue);

      await importText('a.txt', 'money back');
      await installEmbedding('large');
      await embeddings.selectModel('large');
      await embeddings.indexMissing();
      expect(chat.isLoaded, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(embedder.isLoaded, isFalse, reason: 'released after use');

      // The agent keeps its chat model: keyword search only.
      await chatService.ensureLoaded('chat');
      final found = await docs.search('money', keepChatModel: true);
      expect(chat.isLoaded, isTrue);
      expect(found.single.similarity, isNull);
      await dir.delete(recursive: true);
    });

    test('switching models drops old vectors; removing a document drops its vectors', () async {
      await importText('a.txt', 'money back');
      await installEmbedding('small');
      await installEmbedding('large');
      await embeddings.selectModel('small');
      await embeddings.indexMissing();
      expect(await repo.embeddedCount('small'), 1);
      await embeddings.selectModel('large');
      await embeddings.indexMissing();
      expect(await repo.embeddedCount('small'), 0);
      expect(await repo.embeddedCount('large'), 1);

      final doc = (await repo.all()).single;
      await docs.remove(doc.id);
      expect(await repo.embeddedCount('large'), 0);
    });
  });
}

Map<String, dynamic> _entry() => {
  'id': 'x',
  'name': 'X',
  'publisher': 'P',
  'parameters': '1',
  'quantization': 'Q8_0',
  'format': 'gguf',
  'runtime': 'llama.cpp',
  'host': 'h',
  'repo': 'o/r',
  'file': 'x.gguf',
  'sizeBytes': 1,
  'sha256': 'a' * 64,
  'license': 'MIT',
  'licenseUrl': 'https://x.y/l',
  'maxContext': 2048,
  'defaultContext': 512,
  'minRamGb': 1,
  'languages': ['en'],
  'bengali': 'not_listed',
  'notes': 'n',
};
