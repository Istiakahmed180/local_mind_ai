import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:get/get.dart' hide Value;

import '../../core/format.dart';
import '../../data/local/database.dart';
import '../../data/repositories/benchmark_repository.dart';
import '../../services/benchmark/benchmark.dart';
import '../../services/device/device_info_service.dart';
import '../../services/inference/model_runtime_service.dart';
import '../../services/model_service.dart';
import '../../services/settings_service.dart';

class BenchmarkController extends GetxController {
  final runtime = Get.find<ModelRuntimeService>();
  final models = Get.find<ModelService>();
  final settings = Get.find<SettingsService>();
  final device = Get.find<DeviceInfoService>();
  final _repo = Get.find<BenchmarkRepository>();

  final modelId = RxnString();
  final running = false.obs;
  final phase = Rxn<BenchmarkPhase>();
  final run = 0.obs;
  final error = RxnString();
  final errorDetail = RxnString();
  final cancelled = false.obs;
  final latestId = RxnString();
  final history = <BenchmarkRecord>[].obs;

  BenchmarkRunner? _runner;
  StreamSubscription<List<BenchmarkRecord>>? _sub;

  static const config = BenchmarkConfig();

  @override
  void onInit() {
    super.onInit();
    final initial = Get.arguments as String? ?? settings.activeModelId.value;
    final chat = models.installedChat;
    modelId.value = chat.any((m) => m.id == initial)
        ? initial
        : chat.firstOrNull?.id;
    _sub = _repo.watchAll().listen(history.assignAll);
  }

  @override
  void onClose() {
    _runner?.cancel();
    _sub?.cancel();
    super.onClose();
  }

  Future<void> start() async {
    final id = modelId.value;
    if (id == null || running.value) return;
    if (runtime.status.value == RuntimeStatus.generating) {
      error.value = 'benchmark_busy';
      return;
    }
    error.value = null;
    errorDetail.value = null;
    cancelled.value = false;
    latestId.value = null;
    running.value = true;
    final runner = _runner = BenchmarkRunner(
      coldLoad: () async {
        await runtime.unload();
        await runtime.ensureLoaded(id);
        return runtime.lastLoadDuration.value ?? Duration.zero;
      },
      generate: (turns, s) => runtime.generate(turns, settings: s),
      cancelGeneration: runtime.cancel,
      rss: () => ProcessInfo.currentRss,
      config: config,
    );
    try {
      final result = await runner.run(
        onProgress: (p, i) {
          phase.value = p;
          run.value = i;
        },
      );
      final saved = await _repo.add(
        _record(id, result, runtime.loadedContextSize),
      );
      latestId.value = saved.id;
    } on BenchmarkCancelled {
      cancelled.value = true;
    } on LoadFailure catch (e) {
      error.value = e.reason;
      errorDetail.value = e.detail;
    } on Object catch (e) {
      error.value = 'benchmark_failed';
      errorDetail.value = e.toString();
    } finally {
      _runner = null;
      running.value = false;
      phase.value = null;
    }
  }

  void cancel() => _runner?.cancel();

  Future<void> delete(String id) => _repo.delete(id);

  Future<void> deleteAll() => _repo.deleteAll();

  BenchmarkResultsCompanion _record(
    String id,
    BenchmarkResult r,
    int contextSize,
  ) => BenchmarkResultsCompanion.insert(
    id: '',
    modelId: id,
    modelName: models.displayName(id),
    createdAt: DateTime.now(),
    contextSize: contextSize,
    runs: r.runs.length,
    loadMs: r.loadTime.inMilliseconds,
    timeToFirstTokenMs: Value(r.timeToFirstToken?.inMilliseconds),
    promptTokens: r.promptTokens,
    completionTokens: r.completionTokens,
    promptTokensPerSecond: Value(r.promptTokensPerSecond),
    generationTokensPerSecond: Value(r.generationTokensPerSecond),
    generationMin: Value(r.generationMin),
    generationMax: Value(r.generationMax),
    rssAfterLoadBytes: Value(r.rssAfterLoadBytes),
    rssPeakBytes: Value(r.rssPeakBytes),
    device: deviceSummary(),
    backend: Value(runtime.backend.value),
  );

  String deviceSummary() {
    final i = device.info.value;
    if (i == null) return Platform.operatingSystem;
    return [
      '${i.manufacturer} ${i.model}'.trim(),
      'Android API ${i.sdkInt}',
      if (i.socModel != null) i.socModel!,
      '${i.cpuCores} cores',
      '${formatBytes(i.totalRamBytes)} RAM',
      if (i.isEmulator) 'emulator',
    ].join(' · ');
  }
}

/// Plain-text summary for copying or sharing. English only, so results can
/// be compared regardless of the UI language.
String benchmarkAsText(BenchmarkRecord b) {
  String tps(double? v) => v == null ? 'n/a' : '${v.toStringAsFixed(1)} tok/s';
  return [
    'LocalMind AI benchmark — ${b.modelName}',
    'Date: ${b.createdAt.toIso8601String()}',
    'Device: ${b.device}',
    if (b.backend != null) 'Backend: ${b.backend}',
    'Context: ${b.contextSize}, ${b.runs} runs, '
        '${b.promptTokens} prompt tokens, ${b.completionTokens} generated',
    'Load: ${b.loadMs} ms',
    'Prompt processing: ${tps(b.promptTokensPerSecond)}',
    'Generation: ${tps(b.generationTokensPerSecond)} (median; '
        'min ${tps(b.generationMin)}, max ${tps(b.generationMax)})',
    'Time to first token: '
        '${b.timeToFirstTokenMs == null ? 'n/a' : '${b.timeToFirstTokenMs} ms'}',
    if (b.rssAfterLoadBytes != null)
      'App memory after load: ${formatBytes(b.rssAfterLoadBytes!)}',
    if (b.rssPeakBytes != null)
      'App memory peak: ${formatBytes(b.rssPeakBytes!)}',
  ].join('\n');
}
