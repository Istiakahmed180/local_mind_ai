import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Value;
import 'package:localmind_ai/app/theme.dart';
import 'package:localmind_ai/app/translations.dart';
import 'package:localmind_ai/data/local/database.dart';
import 'package:localmind_ai/data/repositories/benchmark_repository.dart';
import 'package:localmind_ai/data/repositories/model_repository.dart';
import 'package:localmind_ai/features/benchmark/benchmark_controller.dart';
import 'package:localmind_ai/features/benchmark/benchmark_view.dart';
import 'package:localmind_ai/services/device/device_info_service.dart';
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
  late FakeRuntime runtime;

  Future<void> setUpServices() async {
    dir = await Directory.systemTemp.createTemp('bench');
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({
      'contextSize': 1024,
      'activeModelId': 'm',
    });
    final settings = SettingsService(await SharedPreferences.getInstance());
    final modelRepo = ModelRepository(db);
    final models = ModelService(modelRepo, DeviceInfoService());
    final path = '${dir.path}/m.gguf';
    await writeFakeGguf(path);
    await modelRepo.upsert(
      InstalledModelsCompanion.insert(
        id: 'm',
        displayName: 'Test model',
        source: 'import',
        filePath: path,
        sizeBytes: await File(path).length(),
        sha256: const Value('x'),
        verified: false,
        installedAt: DateTime.now(),
      ),
    );
    models.installed.add((await modelRepo.byId('m'))!);
    runtime = FakeRuntime(tokens: List.filled(20, 'word '));
    Get
      ..put(settings)
      ..put(modelRepo)
      ..put(models)
      ..put<DeviceInfoService>(_NoNativeDevice())
      ..put(BenchmarkRepository(db))
      ..put(ModelRuntimeService(runtime, models, modelRepo, settings));
  }

  tearDown(() async {
    Get.reset();
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<BenchmarkController> pumpView(
    WidgetTester tester,
    Locale locale,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = Get.put(BenchmarkController());
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light(),
        translations: AppTranslations(),
        locale: locale,
        home: const BenchmarkView(),
      ),
    );
    return c;
  }

  for (final locale in const [Locale('en', 'US'), Locale('bn', 'BD')]) {
    testWidgets('runs, saves and shows a result (${locale.languageCode})', (
      tester,
    ) async {
      await tester.runAsync(setUpServices);
      final c = await pumpView(tester, locale);
      expect(find.text('benchmark_run'.tr), findsOneWidget);

      await tester.runAsync(() async {
        await c.start();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(c.error.value, isNull, reason: c.errorDetail.value);
      expect(runtime.unloads + runtime.loads.length, greaterThan(0));
      expect(runtime.loads, hasLength(1), reason: 'one cold load');
      // Warm-up plus three measured runs.
      expect(runtime.generateCalls, 4);
      expect(c.history, hasLength(1));
      final b = c.history.single;
      expect(b.modelName, 'Test model');
      expect(b.runs, 3);
      expect(b.contextSize, 1024);
      // FakeRuntime: 20 tokens, 100 ms first token, 1100 ms total.
      expect(b.generationTokensPerSecond, closeTo(19, 0.01));
      expect(find.text('Test model'), findsWidgets);
      expect(find.text('benchmark_results'.tr), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cancel saves nothing', (tester) async {
    await tester.runAsync(setUpServices);
    final c = await pumpView(tester, const Locale('en', 'US'));
    await tester.runAsync(() async {
      final f = c.start();
      c.cancel();
      await f;
    });
    await tester.pump();
    expect(c.cancelled.value, isTrue);
    expect(c.history, isEmpty);
    expect(find.text('benchmark_cancelled'.tr), findsOneWidget);
  });
}

/// Skips the native network listener, which has no plugin in unit tests.
class _NoNativeDevice extends DeviceInfoService {
  @override
  // ignore: must_call_super
  void onInit() {}
}
