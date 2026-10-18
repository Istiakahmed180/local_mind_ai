import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/model_repository.dart';
import 'package:localmind_ai/services/device/device_info_service.dart';
import 'package:localmind_ai/services/inference/gpu_check.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';
import 'package:localmind_ai/services/inference/model_runtime_service.dart';
import 'package:localmind_ai/services/model_service.dart';
import 'package:localmind_ai/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

const _story =
    'The lighthouse keeper woke before dawn, as he always did, and climbed '
    'the spiral stairs to check the lamp.';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('comparison', () {
    test('same start agrees, ignoring case and punctuation', () {
      expect(
        outputsAgree(_story, '${_story.toUpperCase()} Then more.'),
        isTrue,
      );
      expect(outputsAgree(_story, _story.replaceAll(',', ' ,  ')), isTrue);
    });

    test('a different word, garbage or too little text disagrees', () {
      expect(
        outputsAgree(_story, _story.replaceFirst('dawn', 'noon')),
        isFalse,
      );
      expect(outputsAgree(_story, '!!!! ???? <unk><unk>'), isFalse);
      expect(outputsAgree('Hi', 'Hi'), isFalse, reason: 'too short to tell');
    });

    test('a later difference is tolerated', () {
      final words = _story.split(' ');
      final changed = [...words.take(13), 'different', 'ending'].join(' ');
      expect(outputsAgree(_story, changed), isTrue);
    });

    test('verdict: mismatch beats speed, slower is not used', () {
      expect(
        judgeGpu(cpuText: _story, gpuText: 'x y z', cpuTps: 5, gpuTps: 50),
        GpuCheckOutcome.mismatch,
      );
      expect(
        judgeGpu(cpuText: _story, gpuText: _story, cpuTps: 10, gpuTps: 8),
        GpuCheckOutcome.slower,
      );
      expect(
        judgeGpu(cpuText: _story, gpuText: _story, cpuTps: 10, gpuTps: 14),
        GpuCheckOutcome.passed,
      );
    });
  });

  group('runtime service and checker', () {
    late Directory dir;
    late AppDatabase db;
    late ModelRepository repo;
    late ModelService models;
    late SettingsService settings;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('gpu');
      db = AppDatabase(NativeDatabase.memory());
      repo = ModelRepository(db);
      models = ModelService(repo, DeviceInfoService());
      SharedPreferences.setMockInitialValues({});
      settings = SettingsService(await SharedPreferences.getInstance());
      final path = '${dir.path}/m.gguf';
      await writeFakeGguf(path);
      await repo.upsert(
        InstalledModelsCompanion.insert(
          id: 'm',
          displayName: 'm',
          source: 'catalog',
          filePath: path,
          sizeBytes: await File(path).length(),
          sha256: const Value('x'),
          verified: true,
          installedAt: DateTime.now(),
        ),
      );
      models.installed.add((await repo.byId('m'))!);
    });

    tearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    test('CPU unless the model passed the check', () async {
      final rt = FakeRuntime();
      final svc = ModelRuntimeService(rt, models, repo, settings);
      await svc.ensureLoaded('m');
      expect(rt.configs.single.gpu, isFalse);
      expect(svc.backend.value, 'CPU');

      await settings.setGpu('m', true);
      await svc.ensureLoaded('m');
      expect(rt.configs.last.gpu, isTrue, reason: 'reloads when it changes');
      expect(svc.backend.value, 'Vulkan');
      await svc.ensureLoaded('m');
      expect(rt.configs, hasLength(2), reason: 'no reload when unchanged');
    });

    test('a failing GPU load falls back to the CPU and says so', () async {
      final rt = FakeRuntime(
        gpuError: const InferenceException('Vulkan 1.1 < 1.2 required'),
      );
      final svc = ModelRuntimeService(rt, models, repo, settings);
      await settings.setGpu('m', true);
      await svc.ensureLoaded('m');
      expect(rt.isLoaded, isTrue);
      expect(svc.backend.value, 'CPU');
      expect(svc.gpuFallback.value, contains('Vulkan 1.1'));
    });

    test('checker: matching and faster passes', () async {
      final rt = FakeRuntime(respond: (_) => _story);
      final svc = ModelRuntimeService(rt, models, repo, settings);
      final stages = <bool>[];
      final r = await GpuChecker(svc).check('m', onStage: stages.add);
      // FakeRuntime gives both the same speed, which counts as not slower.
      expect(r.outcome, GpuCheckOutcome.passed);
      expect(r.backend, 'Vulkan');
      expect(stages, [false, true]);
      expect(rt.configs.map((c) => c.gpu), [false, true]);
      expect(rt.isLoaded, isFalse, reason: 'unloaded after the check');
    });

    test('checker: different GPU text is a mismatch', () async {
      final rt = FakeRuntime(
        respond: (_) => _story,
        gpuRespond: (_) => 'ssss ssss ssss ssss ssss ssss ssss ssss',
      );
      final svc = ModelRuntimeService(rt, models, repo, settings);
      final r = await GpuChecker(svc).check('m');
      expect(r.outcome, GpuCheckOutcome.mismatch);
      expect(settings.usesGpu('m'), isFalse);
    });

    test('checker: no GPU is unsupported, never a silent CPU run', () async {
      final rt = FakeRuntime(
        respond: (_) => _story,
        gpuError: const InferenceException('no Vulkan device'),
      );
      final svc = ModelRuntimeService(rt, models, repo, settings);
      final r = await GpuChecker(svc).check('m');
      expect(r.outcome, GpuCheckOutcome.unsupported);
      expect(r.detail, contains('no Vulkan device'));
      expect(svc.gpuFallback.value, isNull);
    });

    test('clear all data forgets GPU choices', () async {
      await settings.setGpu('m', true);
      await settings.clear();
      expect(settings.usesGpu('m'), isFalse);
    });
  });
}
