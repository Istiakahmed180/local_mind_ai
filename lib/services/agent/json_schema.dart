/// Validates decoded JSON against the small JSON Schema subset the agent's
/// tools use: object (properties, required, additionalProperties: false),
/// string (minLength, maxLength, pattern, enum), integer, number, boolean.
///
/// Grammar-constrained decoding does not enforce lengths or patterns, and the
/// fallback parser accepts unconstrained text, so every tool call is checked
/// here before it can run.
List<String> validateJson(
  Object? value,
  Map<String, Object?> schema, [
  String path = r'$',
]) {
  final errors = <String>[];
  final type = schema['type'];
  switch (type) {
    case 'object':
      if (value is! Map) return ['$path must be an object'];
      final props =
          (schema['properties'] as Map?)?.cast<String, Object?>() ??
          const <String, Object?>{};
      for (final r in (schema['required'] as List?) ?? const []) {
        if (!value.containsKey(r)) errors.add('$path.$r is required');
      }
      for (final entry in value.entries) {
        final key = entry.key;
        final sub = props[key];
        if (sub == null) {
          if (schema['additionalProperties'] == false) {
            errors.add('$path.$key is not allowed');
          }
          continue;
        }
        errors.addAll(
          validateJson(entry.value, (sub as Map).cast(), '$path.$key'),
        );
      }
    case 'string':
      if (value is! String) return ['$path must be a string'];
      final min = schema['minLength'] as int?;
      final max = schema['maxLength'] as int?;
      if (min != null && value.length < min) {
        errors.add('$path must have at least $min characters');
      }
      if (max != null && value.length > max) {
        errors.add('$path must have at most $max characters');
      }
      final pattern = schema['pattern'] as String?;
      if (pattern != null && !RegExp(pattern).hasMatch(value)) {
        errors.add('$path has an invalid format');
      }
    case 'integer':
      if (value is! int) return ['$path must be an integer'];
    case 'number':
      if (value is! num) return ['$path must be a number'];
    case 'boolean':
      if (value is! bool) return ['$path must be a boolean'];
    default:
      return ['$path: unsupported schema type $type'];
  }
  final allowed = schema['enum'] as List?;
  if (allowed != null && !allowed.contains(value)) {
    errors.add('$path must be one of ${allowed.join(', ')}');
  }
  return errors;
}
