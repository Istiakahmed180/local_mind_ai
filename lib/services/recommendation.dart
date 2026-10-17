import '../domain/model_definition.dart';

enum Fit { recommended, possible, tooLarge, unknown }

class ModelFit {
  const ModelFit(this.model, this.fit);

  final ModelDefinition model;
  final Fit fit;
}

/// Ranks catalog models for a device, smallest suitable first.
///
/// Inputs are the device's total RAM and free storage. Total RAM is used
/// because available RAM on Android fluctuates; we leave half of total RAM for
/// the OS and other apps, which is deliberately conservative.
List<ModelFit> recommendModels({
  required List<ModelDefinition> catalog,
  required int? totalRamBytes,
  required int? freeStorageBytes,
  bool preferBengali = false,
}) {
  const gb = 1024 * 1024 * 1024;
  final sorted = [...catalog]
    ..sort((a, b) => a.sizeBytes.compareTo(b.sizeBytes));

  Fit fitFor(ModelDefinition m) {
    if (totalRamBytes == null || totalRamBytes <= 0) return Fit.unknown;
    if (freeStorageBytes != null && freeStorageBytes < m.sizeBytes) {
      return Fit.tooLarge;
    }
    final peak = m.estimatedRamBytes(m.defaultContext).high;
    if (totalRamBytes < m.minRamGb * gb * 0.9) return Fit.tooLarge;
    if (peak <= totalRamBytes * 0.5) return Fit.recommended;
    if (peak <= totalRamBytes * 0.7) return Fit.possible;
    return Fit.tooLarge;
  }

  final fits = [for (final m in sorted) ModelFit(m, fitFor(m))];
  if (preferBengali) {
    int rank(ModelFit f) =>
        f.model.bengali == BengaliSupport.tested ||
            f.model.bengali == BengaliSupport.vendorClaimed
        ? 0
        : 1;
    fits.sort((a, b) {
      final byFit = a.fit.index.compareTo(b.fit.index);
      if (byFit != 0) return byFit;
      final byLang = rank(a).compareTo(rank(b));
      if (byLang != 0) return byLang;
      return a.model.sizeBytes.compareTo(b.model.sizeBytes);
    });
  } else {
    fits.sort((a, b) {
      final byFit = a.fit.index.compareTo(b.fit.index);
      return byFit != 0
          ? byFit
          : a.model.sizeBytes.compareTo(b.model.sizeBytes);
    });
  }
  return fits;
}
