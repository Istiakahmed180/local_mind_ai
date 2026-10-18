import 'dart:async';

import 'json_schema.dart';

/// Thrown by a tool for an expected failure. The message is shown to the
/// user and passed back to the model, so it must not contain secrets.
class ToolException implements Exception {
  const ToolException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Lets a long-running tool notice that the run was cancelled.
class ToolContext {
  ToolContext({required this.isCancelled});

  final bool Function() isCancelled;
}

abstract class AgentTool {
  /// Stable identifier the model uses, e.g. `calculator`.
  String get name;

  /// One line for the model's prompt (English; models follow it best).
  String get description;

  /// Translation key for the user-facing name.
  String get labelKey;

  /// JSON schema of the `args` object. Must be `type: object` with
  /// `additionalProperties: false`.
  Map<String, Object?> get parameters;

  /// Whether the user must approve each call before it runs.
  bool get requiresApproval;

  Duration get timeout;

  Future<String> run(Map<String, Object?> args, ToolContext context);
}

class ToolCall {
  const ToolCall(this.tool, this.args);

  final String tool;
  final Map<String, Object?> args;
}

/// Only registered tools can run. There is deliberately no way to register a
/// shell, eval, SQL, intent or network tool from model output.
class ToolRegistry {
  ToolRegistry(Iterable<AgentTool> tools)
    : _tools = {for (final t in tools) t.name: t} {
    for (final t in tools) {
      if (t.parameters['type'] != 'object' ||
          t.parameters['additionalProperties'] != false) {
        throw ArgumentError('${t.name}: parameters must be a closed object');
      }
    }
  }

  final Map<String, AgentTool> _tools;

  Iterable<AgentTool> get tools => _tools.values;

  AgentTool? operator [](String name) => _tools[name];

  /// Returns validation errors for [call]; empty means it may run.
  List<String> validate(ToolCall call) {
    final tool = _tools[call.tool];
    if (tool == null) return ['Unknown tool "${call.tool}"'];
    return validateJson(call.args, tool.parameters, 'args');
  }
}
