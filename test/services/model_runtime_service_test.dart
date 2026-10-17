import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/model_repository.dart';
import 'package:localmind_ai/services/device/device_info_service.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';
import 'package:localmind_ai/services/inference/model_runtime_service.dart';
import 'package:localmind_ai/services/model_service.dart';
import 'package:localmind_ai/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory dir;
  late AppDatabase db;
  late ModelRepository repo;
  late ModelService models;
  late SettingsService settings;

  Future<InstalledModel> install(
    String id, {
    bool verified = true,
    bool writeFile = true,
  }) async {
    final path = '${dir.path}/$id.gguf';
    final size = 17 * 1024 * 1024;
    if (writeFile) await writeFakeGguf(path, size: size);
    await repo.upsert(
      InstalledModelsCompanion.insert(
        id: id,
        displayName: id,
        source: 'catalog',
        filePath: path,
        sizeBytes: size,
        sha256: const Value('x'),
        verified: verified,
        installedAt: DateTime.now(),
      ),
    );
    final row = (await repo.byId(id))!;
    models.installed.add(row);
    return row;
  }

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('rt');
    db = AppDatabase(NativeDatabase.memory());
    repo = ModelRepository(db);
    models = ModelService(repo, DeviceInfoService());
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(await SharedPreferences.getInstance());
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test('loads, streams tokens and records load time', () async {
    final rt = FakeRuntime();
    final svc = ModelRuntimeService(rt, models, repo, settings);
    await install('a');
    await svc.ensureLoaded('a');
    expect(svc.status.value, RuntimeStatus.ready);
    expect(svc.loadedModelId.value, 'a');

    final events = await svc.generate(const [
      ChatTurn(ChatRole.user, 'hi'),
    ]).toList();
    expect(
      events.whereType<TokenEvent>().map((e) => e.text).join(),
      'Hello world',
    );
    expect(events.last, isA<DoneEvent>());
    expect(svc.status.value, RuntimeStatus.ready);
    expect((await repo.byId('a'))!.lastLoadMs, isNotNull);
  });

  test('switching models unloads the previous one first', () async {
    final rt = FakeRuntime();
    final svc = ModelRuntimeService(rt, models, repo, settings);
    await install('a');
    await install('b');
    await svc.ensureLoaded('a');
    await svc.ensureLoaded('b');
    expect(rt.unloads, 1);
    expect(svc.loadedModelId.value, 'b');
  });

  test('does not reload when the same model is already loaded', () async {
    final rt = FakeRuntime();
    final svc = ModelRuntimeService(rt, models, repo, settings);
    await install('a');
    await svc.ensureLoaded('a');
    await svc.ensureLoaded('a');
    expect(rt.loads, hasLength(1));
  });

  test('refuses to load unverified or missing files', () async {
    final rt = FakeRuntime();
    final svc = ModelRuntimeService(rt, models, repo, settings);
    await install('unverified', verified: false);
    await install('missing', writeFile: false);
    await expectLater(
      svc.ensureLoaded('unverified'),
      throwsA(
        isA<LoadFailure>().having(
          (e) => e.reason,
          'reason',
          'error_model_notVerified',
        ),
      ),
    );
    await expectLater(
      svc.ensureLoaded('missing'),
      throwsA(
        isA<LoadFailure>().having(
          (e) => e.reason,
          'reason',
          'error_model_fileMissing',
        ),
      ),
    );
    expect(rt.loads, isEmpty);
  });

  test('reports out-of-memory load failures', () async {
    final rt = FakeRuntime(
      loadError: const InferenceException(
        'failed to allocate',
        outOfMemory: true,
      ),
    );
    final svc = ModelRuntimeService(rt, models, repo, settings);
    await install('a');
    await expectLater(
      svc.ensureLoaded('a'),
      throwsA(
        isA<LoadFailure>().having(
          (e) => e.reason,
          'reason',
          'error_out_of_memory',
        ),
      ),
    );
    expect(svc.status.value, RuntimeStatus.error);
    expect((await repo.byId('a'))!.lastError, 'failed to allocate');
  });

  test('cancel stops generation early', () async {
    final rt = FakeRuntime(tokens: List.filled(50, 'x'));
    final svc = ModelRuntimeService(rt, models, repo, settings);
    await install('a');
    await svc.ensureLoaded('a');
    var count = 0;
    await for (final e in svc.generate(const [ChatTurn(ChatRole.user, 'hi')])) {
      if (e is TokenEvent && ++count == 3) svc.cancel();
    }
    expect(count, lessThan(50));
  });

  test('generating without a loaded model fails clearly', () async {
    final svc = ModelRuntimeService(FakeRuntime(), models, repo, settings);
    expect(
      () => svc.generate(const [ChatTurn(ChatRole.user, 'hi')]).toList(),
      throwsA(isA<LoadFailure>()),
    );
  });
}
