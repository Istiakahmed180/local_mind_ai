import 'dart:convert';

import 'agent_tool.dart';

const finalAnswerTool = 'final_answer';

/// One parsed model step: either a tool call or the final answer.
sealed class ModelStep {
  const ModelStep();
}

class ToolStep extends ModelStep {
  const ToolStep(this.call);
  final ToolCall call;
}

class FinalStep extends ModelStep {
  const FinalStep(this.answer);
  final String answer;
}

/// JSON schema for one step, used for grammar-constrained decoding. Length
/// limits are left out because llama.cpp grammars with large repetition
/// counts are slow or rejected; [ToolRegistry.validate] enforces them.
Map<String, Object?> stepSchema(ToolRegistry registry) => {
  'oneOf': [
    for (final t in registry.tools)
      _call(t.name, _withoutLengths(t.parameters)),
    _call(finalAnswerTool, const {
      'type': 'object',
      'properties': {
        'answer': {'type': 'string'},
      },
      'required': ['answer'],
      'additionalProperties': false,
    }),
  ],
};

Map<String, Object?> _call(String name, Map<String, Object?> args) => {
  'type': 'object',
  'properties': {
    'tool': {'const': name},
    'args': args,
  },
  'required': ['tool', 'args'],
  'additionalProperties': false,
};

Map<String, Object?> _withoutLengths(Map<String, Object?> schema) => {
  for (final e in schema.entries)
    if (e.key != 'minLength' && e.key != 'maxLength')
      e.key: switch (e.value) {
        final Map<String, Object?> m when e.key == 'properties' => {
          for (final p in m.entries)
            p.key: _withoutLengths((p.value as Map).cast()),
        },
        final v => v,
      },
};

String systemPrompt(ToolRegistry registry, {required int maxSteps}) {
  final b = StringBuffer()
    ..writeln(
      "You are a careful assistant running offline on the user's phone. "
      'Solve the task using the tools below.',
    )
    ..writeln('Reply with exactly one JSON object and nothing else.')
    ..writeln('To call a tool: {"tool": "<name>", "args": {...}}')
    ..writeln(
      'When finished: {"tool": "$finalAnswerTool", "args": {"answer": "<answer>"}}',
    )
    ..writeln('Tools:');
  for (final t in registry.tools) {
    b.writeln('- ${t.name}: ${t.description} args: ${_describeArgs(t)}');
  }
  b
    ..writeln('Rules:')
    ..writeln(
      '- Use the calculator for every arithmetic step; do not compute in your head.',
    )
    ..writeln('- Never invent tool results. Use only results you were given.')
    ..writeln(
      '- At most $maxSteps replies. Answer in the language of the task.',
    );
  return b.toString().trim();
}

String _describeArgs(AgentTool t) {
  final props = (t.parameters['properties'] as Map).cast<String, Object?>();
  if (props.isEmpty) return '{}';
  return '{${props.entries.map((e) => '"${e.key}": ${(e.value as Map)['type']}').join(', ')}}';
}

/// Turns raw model output into a step. Grammar-constrained output is plain
/// JSON; the fallback also accepts code fences, `<tool_call>` tags, text
/// around the object, and `{"name", "arguments"}` / `{"answer"}` shapes,
/// because small models often ignore the requested format.
/// Returns null when no usable JSON object is found.
ModelStep? parseStep(String raw) {
  final obj = _firstJsonObject(raw);
  if (obj == null) return null;
  final name = obj['tool'] ?? obj['name'];
  final args = obj['args'] ?? obj['arguments'] ?? obj['parameters'];
  if (name == finalAnswerTool) {
    final answer = args is Map ? args['answer'] : obj['answer'];
    return answer is String ? FinalStep(answer) : null;
  }
  if (name is String) {
    final decoded = args is String ? _tryDecode(args) : args;
    if (decoded is Map) {
      return ToolStep(ToolCall(name, decoded.cast<String, Object?>()));
    }
    if (decoded == null) return ToolStep(ToolCall(name, const {}));
    return null;
  }
  final answer = obj['answer'];
  if (answer is String) return FinalStep(answer);
  return null;
}

Map<String, Object?>? _firstJsonObject(String raw) {
  var start = raw.indexOf('{');
  while (start >= 0) {
    final end = _matchingBrace(raw, start);
    if (end < 0) return null;
    final decoded = _tryDecode(raw.substring(start, end + 1));
    if (decoded is Map) return decoded.cast<String, Object?>();
    start = raw.indexOf('{', start + 1);
  }
  return null;
}

int _matchingBrace(String s, int start) {
  var depth = 0;
  var inString = false;
  for (var i = start; i < s.length; i++) {
    final c = s[i];
    if (inString) {
      if (c == r'\') {
        i++;
      } else if (c == '"') {
        inString = false;
      }
    } else if (c == '"') {
      inString = true;
    } else if (c == '{') {
      depth++;
    } else if (c == '}' && --depth == 0) {
      return i;
    }
  }
  return -1;
}

Object? _tryDecode(String s) {
  try {
    return jsonDecode(s);
  } on FormatException {
    return null;
  }
}

/// Cuts [text] to at most [maxBytes] UTF-8 bytes without splitting a
/// character, and says so when it did.
String truncateUtf8(String text, int maxBytes) {
  final bytes = utf8.encode(text);
  if (bytes.length <= maxBytes) return text;
  var end = maxBytes;
  // Step back to a UTF-8 lead byte.
  while (end > 0 && (bytes[end] & 0xC0) == 0x80) {
    end--;
  }
  return '${utf8.decode(bytes.sublist(0, end))}\n[truncated: ${bytes.length} bytes total]';
}
