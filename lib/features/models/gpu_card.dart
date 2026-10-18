import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';
import '../../services/inference/gpu_check.dart';
import '../../services/inference/model_runtime_service.dart';
import '../../services/settings_service.dart';

/// Experimental GPU (Vulkan) use for one installed chat model. It can only be
/// switched on after this phone's GPU gave the same answer as the CPU and was
/// not slower.
class GpuCard extends StatefulWidget {
  const GpuCard({super.key, required this.modelId});

  final String modelId;

  @override
  State<GpuCard> createState() => _GpuCardState();
}

class _GpuCardState extends State<GpuCard> {
  final _settings = Get.find<SettingsService>();
  final _runtime = Get.find<ModelRuntimeService>();
  bool _checking = false;
  bool _onGpuStage = false;
  GpuCheckResult? _result;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final on = _settings.usesGpu(widget.modelId);
      final loaded = _runtime.loadedModelId.value == widget.modelId;
      final backend = _runtime.backend.value;
      final fallback = _runtime.gpuFallback.value;
      final busy =
          _checking || _runtime.status.value == RuntimeStatus.generating;
      return SectionCard(
        title: 'gpu_title'.tr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('gpu_explainer'.tr, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('gpu_use'.tr),
              subtitle: Text(on ? 'gpu_on_hint'.tr : 'gpu_off_hint'.tr),
              value: on,
              onChanged: busy ? null : (v) => v ? _check() : _turnOff(),
            ),
            if (loaded && backend != null)
              InfoRow('gpu_running_on'.tr, backend),
            if (loaded && on && fallback != null)
              _Warning('gpu_fell_back'.trParams({'detail': fallback})),
            if (_checking) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_onGpuStage ? 'gpu_checking_gpu'.tr : 'gpu_checking_cpu'.tr),
              const SizedBox(height: AppSpacing.xs),
              const LinearProgressIndicator(),
            ],
            if (_error != null) _Warning(_error!),
            if (_result case final r?) _ResultView(r),
          ],
        ),
      );
    });
  }

  Future<void> _turnOff() async {
    await _settings.setGpu(widget.modelId, false);
    if (_runtime.loadedModelId.value == widget.modelId) {
      await _runtime.unload();
    }
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _onGpuStage = false;
      _result = null;
      _error = null;
    });
    try {
      final r = await GpuChecker(_runtime).check(
        widget.modelId,
        onStage: (gpu) {
          if (mounted) setState(() => _onGpuStage = gpu);
        },
      );
      if (r.outcome == GpuCheckOutcome.passed) {
        await _settings.setGpu(widget.modelId, true);
      }
      if (mounted) setState(() => _result = r);
    } on LoadFailure catch (e) {
      if (mounted) {
        setState(() => _error = [e.reason.tr, ?e.detail].join('\n'));
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView(this.r);

  final GpuCheckResult r;

  @override
  Widget build(BuildContext context) {
    String tps(double? v) =>
        v == null ? '—' : '${v.toStringAsFixed(1)} ${'tok_per_s'.tr}';
    final passed = r.outcome == GpuCheckOutcome.passed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        passed
            ? Text('gpu_result_passed'.tr)
            : _Warning('gpu_result_${r.outcome.name}'.tr),
        InfoRow('gpu_speed_cpu'.tr, tps(r.cpuTokensPerSecond)),
        if (r.outcome != GpuCheckOutcome.unsupported)
          InfoRow('gpu_speed_gpu'.tr, tps(r.gpuTokensPerSecond)),
        if (r.backend != null) InfoRow('gpu_backend'.tr, r.backend!),
        if (r.detail != null)
          Text(r.detail!, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
