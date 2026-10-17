/// How confident we are that a model handles Bengali.
enum BengaliSupport {
  /// Verified on a device with representative prompts.
  tested,

  /// The publisher lists Bengali, but we have not verified quality.
  vendorClaimed,

  /// The publisher does not list Bengali.
  notListed,

  /// The publisher states the model is English-only.
  notSupported;

  static BengaliSupport parse(String value) => switch (value) {
    'tested' => tested,
    'vendor_claimed' => vendorClaimed,
    'not_listed' => notListed,
    'not_supported' => notSupported,
    _ => throw FormatException('Unknown bengali value: $value'),
  };
}

/// One downloadable model from `assets/models/catalog.json`.
class ModelDefinition {
  const ModelDefinition({
    required this.id,
    required this.name,
    required this.publisher,
    required this.parameters,
    required this.quantization,
    required this.format,
    required this.runtime,
    required this.downloadUrl,
    required this.sourcePage,
    required this.fileName,
    required this.sizeBytes,
    required this.sha256,
    required this.license,
    required this.licenseUrl,
    required this.requiresLicenseAcceptance,
    required this.maxContext,
    required this.defaultContext,
    required this.minRamGb,
    required this.languages,
    required this.bengali,
    required this.starter,
    required this.notes,
  });

  final String id;
  final String name;
  final String publisher;
  final String parameters;
  final String quantization;
  final String format;
  final String runtime;
  final Uri downloadUrl;
  final Uri sourcePage;
  final String fileName;
  final int sizeBytes;
  final String sha256;
  final String license;
  final Uri licenseUrl;
  final bool requiresLicenseAcceptance;
  final int maxContext;
  final int defaultContext;
  final int minRamGb;
  final List<String> languages;
  final BengaliSupport bengali;
  final bool starter;
  final String notes;

  /// Very rough peak-RAM range: weights + KV cache + runtime overhead.
  /// Shown to users only as an estimate.
  ({int low, int high}) estimatedRamBytes(int contextSize) {
    final kvGuess = contextSize * 24 * 1024;
    return (
      low: sizeBytes + kvGuess + 150 * 1024 * 1024,
      high: sizeBytes + kvGuess * 3 + 300 * 1024 * 1024,
    );
  }

  static final _sha256Pattern = RegExp(r'^[0-9a-f]{64}$');
  static final _fileNamePattern = RegExp(r'^[A-Za-z0-9._-]+\.gguf$');

  factory ModelDefinition.fromJson(
    Map<String, dynamic> json,
    Map<String, String> hosts,
  ) {
    String str(String key) {
      final value = json[key];
      if (value is! String || value.isEmpty) {
        throw FormatException('Model field "$key" must be a non-empty string');
      }
      return value;
    }

    int positiveInt(String key) {
      final value = json[key];
      if (value is! int || value <= 0) {
        throw FormatException('Model field "$key" must be a positive integer');
      }
      return value;
    }

    final id = str('id');
    final hostKey = str('host');
    final host = hosts[hostKey];
    if (host == null) {
      throw FormatException('Model $id references unknown host "$hostKey"');
    }
    final hostUri = Uri.parse(host);
    if (hostUri.scheme != 'https') {
      throw FormatException('Host "$hostKey" must use https');
    }
    final repo = str('repo');
    final file = str('file');
    if (!_fileNamePattern.hasMatch(file)) {
      throw FormatException('Model $id has an unsafe file name: $file');
    }
    final sha = str('sha256');
    if (!_sha256Pattern.hasMatch(sha)) {
      throw FormatException('Model $id has an invalid sha256');
    }
    final format = str('format');
    if (format != 'gguf') {
      throw FormatException('Model $id uses unsupported format $format');
    }
    final maxContext = positiveInt('maxContext');
    final defaultContext = positiveInt('defaultContext');
    if (defaultContext > maxContext) {
      throw FormatException('Model $id defaultContext exceeds maxContext');
    }

    return ModelDefinition(
      id: id,
      name: str('name'),
      publisher: str('publisher'),
      parameters: str('parameters'),
      quantization: str('quantization'),
      format: format,
      runtime: str('runtime'),
      downloadUrl: hostUri.resolve('$repo/resolve/main/$file'),
      sourcePage: hostUri.resolve(repo),
      fileName: file,
      sizeBytes: positiveInt('sizeBytes'),
      sha256: sha,
      license: str('license'),
      licenseUrl: Uri.parse(str('licenseUrl')),
      requiresLicenseAcceptance: json['requiresLicenseAcceptance'] == true,
      maxContext: maxContext,
      defaultContext: defaultContext,
      minRamGb: positiveInt('minRamGb'),
      languages: (json['languages'] as List).cast<String>(),
      bengali: BengaliSupport.parse(str('bengali')),
      starter: json['starter'] == true,
      notes: str('notes'),
    );
  }
}

class ModelCatalog {
  const ModelCatalog(this.models);

  final List<ModelDefinition> models;

  ModelDefinition? byId(String id) {
    for (final m in models) {
      if (m.id == id) return m;
    }
    return null;
  }

  factory ModelCatalog.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != 1) {
      throw const FormatException('Unsupported catalog schemaVersion');
    }
    final hosts = (json['hosts'] as Map).cast<String, String>();
    final models = (json['models'] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => ModelDefinition.fromJson(m, hosts))
        .toList();
    final ids = <String>{};
    for (final m in models) {
      if (!ids.add(m.id)) throw FormatException('Duplicate model id ${m.id}');
    }
    return ModelCatalog(models);
  }
}
