import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/document_repository.dart';
import 'package:localmind_ai/data/repositories/model_repository.dart';
import 'package:localmind_ai/domain/model_definition.dart';
import 'package:localmind_ai/services/device/device_info_service.dart';
import 'package:localmind_ai/services/documents/document_service.dart';
import 'package:localmind_ai/services/documents/embedding_service.dart';
import 'package:localmind_ai/services/documents/retrieval.dart';
import 'package:localmind_ai/services/inference/embedding_runtime.dart';
import 'package:localmind_ai/services/inference/llamadart_runtime.dart';
import 'package:localmind_ai/services/inference/model_runtime_service.dart';
import 'package:localmind_ai/services/model_service.dart';
import 'package:localmind_ai/services/settings_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real embedding models. Push them first:
///   `adb push nomic-embed-text-v1.5.Q8_0.gguf /data/local/tmp/`
///   `adb push Qwen3-Embedding-0.6B-Q8_0.gguf /data/local/tmp/`
/// Prints similarities used to calibrate `minSimilarity` in the catalog.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // One paragraph per file, so each is its own passage and the test checks
  // that the right one ranks first.
  const paragraphs = {
    'refunds.txt': 'Customers may obtain a full reimbursement within thirty days of purchase if the item is unused and in its original packaging.',
    'delivery.txt': 'Orders are dispatched within two working days. Parcels inside Dhaka normally reach the customer in three days.',
    'warranty.txt': 'Every appliance comes with a one-year guarantee covering manufacturing faults. Damage caused by misuse is not covered.',
    'support.txt':
        'Our support desk is open from 9 am to 6 pm, Sunday to Thursday.',
  };

  // (question, expected passage keyword or null for "should not match")
  const questions = [
    ('How long do I have to get my money back?', 'reimbursement'),
    ('When will my parcel arrive in Dhaka?', 'three days'),
    ('Is a broken washing machine covered?', 'guarantee'),
    ('What time can I call customer service?', '9 am'),
    ('আমি কত দিনের মধ্যে টাকা ফেরত পাব?', 'reimbursement'),
    ('What is the capital of France?', null),
    ('Write a poem about the ocean.', null),
  ];

  Future<void> evaluate(String id) async {
    final catalog = ModelCatalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/models/catalog.json'))
          as Map<String, dynamic>,
    );
    final def = catalog.byId(id)!;
    final path = '/data/local/tmp/${def.fileName}';
    if (!File(path).existsSync()) {
      markTestSkipped('push ${def.fileName}');
      return;
    }
    final db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({'embeddingModelId': id});
    final settings = SettingsService(await SharedPreferences.getInstance());
    final modelRepo = ModelRepository(db);
    final models = ModelService(modelRepo, DeviceInfoService());
    models.catalog.value = catalog;
    await modelRepo.upsert(
      InstalledModelsCompanion.insert(
        id: id,
        displayName: def.name,
        source: 'catalog',
        filePath: path,
        sizeBytes: def.sizeBytes,
        sha256: Value(def.sha256),
        verified: true,
        installedAt: DateTime.now(),
      ),
    );
    models.installed.add((await modelRepo.byId(id))!);
    final repo = DocumentRepository(db);
    final embeddings = EmbeddingService(
      repo,
      models,
      settings,
      ModelRuntimeService(LlamadartRuntime(), models, modelRepo, settings),
      LlamadartEmbeddingRuntime(),
    );
    final tmp = await getTemporaryDirectory();
    final docs = DocumentService(
      repo,
      baseDir: () async => Directory(p.join(tmp.path, 'sem-$id')),
    )..semantic = embeddings;

    for (final e in paragraphs.entries) {
      final file = File(p.join(tmp.path, e.key))..writeAsStringSync(e.value);
      await docs.import(file.path, e.key);
    }
    final watch = Stopwatch()..start();
    await embeddings.indexMissing();
    log(
      '[$id] indexed ${embeddings.embedded.value}/${embeddings.total.value} '
      'passages in ${watch.elapsedMilliseconds}ms',
    );
    expect(embeddings.embedded.value, embeddings.total.value);

    for (final (q, expected) in questions) {
      final w = Stopwatch()..start();
      final meaning = await embeddings.search(q, k: 2);
      final keyword = await repo.search(q, limit: 1);
      final top = meaning.first;
      final hit = expected != null && top.text.contains(expected);
      log(
        '[$id] top=${top.similarity!.toStringAsFixed(3)} '
        'second=${meaning[1].similarity!.toStringAsFixed(3)} '
        '${expected == null ? 'UNRELATED' : (hit ? 'HIT ' : 'MISS')} '
        'keywordHit=${keyword.isNotEmpty && expected != null && keyword.first.text.contains(expected)} '
        '${w.elapsedMilliseconds}ms  $q',
      );
    }

    final evidence = await docs.search(questions.first.$1, limit: 3);
    log(
      '[$id] paraphrase evidence at minSimilarity=${def.minSimilarity}: '
      '${hasEnoughEvidence(evidence, queryTerms(questions.first.$1), minSimilarity: def.minSimilarity)}',
    );
    embeddings.onClose();
    await db.close();
  }

  testWidgets(
    'nomic-embed-text v1.5',
    semanticsEnabled: false,
    (_) => evaluate('nomic-embed-text-v1.5-q8_0'),
  );
  testWidgets(
    'Qwen3-Embedding 0.6B',
    semanticsEnabled: false,
    (_) => evaluate('qwen3-embedding-0.6b-q8_0'),
  );
}

// ignore: avoid_print
void log(String s) => print(s);
