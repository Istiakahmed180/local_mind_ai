import '../benchmark/benchmark.dart';
import 'inference_runtime.dart';
import 'model_runtime_service.dart';

enum GpuCheckOutcome {
  /// Same answer as the CPU and at least as fast: safe to use.
  passed,

  /// No usable GPU, driver excluded, Vulkan too old, or the load failed.
  unsupported,

  /// The GPU wrote something different from the CPU: known llama.cpp Vulkan
  /// failure on some Android GPUs.
  mismatch,

  /// Correct but not faster than the CPU, so there is no reason to use it.
  slower,
}

class GpuCheckResult {
  const GpuCheckResult(
    this.outcome, {
    this.cpuTokensPerSecond,
    this.gpuTokensPerSecond,
    this.backend,
    this.detail,
    this.cpuText,
    this.gpuText,
  });

  final GpuCheckOutcome outcome;
  final double? cpuTokensPerSecond;
  final double? gpuTokensPerSecond;
  final String? backend;
  final String? detail;
  final String? cpuText;
  final String? gpuText;
}

/// Words compared between the CPU and GPU answers. Greedy decoding gives the
/// same text on both unless the GPU computes wrongly; tiny float differences
/// can still change a later word, so only the start must match.
const gpuCheckWords = 12;

/// The GPU must reach this share of the CPU speed to count as not slower.
const gpuMinSpeedRatio = 1.0;

bool outputsAgree(String cpu, String gpu, {int words = gpuCheckWords}) {
  List<String> norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(words)
      .toList();
  final a = norm(cpu);
  final b = norm(gpu);
  if (a.length < words ~/ 2 || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

GpuCheckOutcome judgeGpu({
  required String cpuText,
  required String gpuText,
  required double? cpuTps,
  required double? gpuTps,
}) {
  if (!outputsAgree(cpuText, gpuText)) return GpuCheckOutcome.mismatch;
  if (cpuTps != null &&
      (gpuTps == null || gpuTps < cpuTps * gpuMinSpeedRatio)) {
    return GpuCheckOutcome.slower;
  }
  return GpuCheckOutcome.passed;
}

/// Runs the same greedy prompt on the CPU and on the GPU and compares them.
class GpuChecker {
  GpuChecker(this._runtime);

  final ModelRuntimeService _runtime;

  static const _tokens = 48;
  static const _config = BenchmarkConfig();

  Future<GpuCheckResult> check(
    String modelId, {
    void Function(bool onGpu)? onStage,
  }) async {
    onStage?.call(false);
    await _runtime.ensureLoaded(modelId, gpu: false);
    final cpu = await _measure();

    onStage?.call(true);
    try {
      await _runtime.ensureLoaded(modelId, gpu: true);
    } on LoadFailure catch (e) {
      return GpuCheckResult(
        GpuCheckOutcome.unsupported,
        cpuTokensPerSecond: cpu.$2,
        detail: e.detail ?? e.reason,
      );
    }
    final backend = _runtime.backend.value;
    final GpuRun gpu;
    try {
      gpu = await _measure();
    } on Object catch (e) {
      await _runtime.unload();
      return GpuCheckResult(
        GpuCheckOutcome.unsupported,
        cpuTokensPerSecond: cpu.$2,
        backend: backend,
        detail: e.toString(),
      );
    }
    // The next normal use loads the model the way the setting says.
    await _runtime.unload();
    return GpuCheckResult(
      judgeGpu(
        cpuText: cpu.$1,
        gpuText: gpu.$1,
        cpuTps: cpu.$2,
        gpuTps: gpu.$2,
      ),
      cpuTokensPerSecond: cpu.$2,
      gpuTokensPerSecond: gpu.$2,
      backend: backend,
      cpuText: cpu.$1,
      gpuText: gpu.$1,
    );
  }

  /// One short warm-up (Vulkan compiles its shaders on first use), then the
  /// measured greedy run.
  Future<GpuRun> _measure() async {
    await _drain(_config.settings(4));
    return _drain(_config.settings(_tokens));
  }

  Future<GpuRun> _drain(GenerationSettings s) async {
    final b = StringBuffer();
    GenerationStats? stats;
    await for (final e in _runtime.generate(_config.turns(1), settings: s)) {
      switch (e) {
        case TokenEvent(:final text):
          b.write(text);
        case DoneEvent(stats: final st):
          stats = st;
      }
    }
    return (b.toString(), stats?.tokensPerSecond);
  }
}

typedef GpuRun = (String text, double? tokensPerSecond);
