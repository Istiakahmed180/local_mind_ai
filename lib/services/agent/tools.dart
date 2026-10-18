import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'agent_tool.dart';
import 'expression.dart';

const _noArgs = <String, Object?>{
  'type': 'object',
  'properties': <String, Object?>{},
  'additionalProperties': false,
};

class CalculatorTool extends AgentTool {
  @override
  String get name => 'calculator';
  @override
  String get description =>
      'Evaluate arithmetic. Supports + - * / % ^, parentheses, sqrt, abs, '
      'round, floor, ceil, ln, log10, pi, e.';
  @override
  String get labelKey => 'tool_calculator';
  @override
  Map<String, Object?> get parameters => const {
    'type': 'object',
    'properties': {
      'expression': {'type': 'string', 'minLength': 1, 'maxLength': 200},
    },
    'required': ['expression'],
    'additionalProperties': false,
  };
  @override
  bool get requiresApproval => false;
  @override
  Duration get timeout => const Duration(seconds: 2);

  @override
  Future<String> run(Map<String, Object?> args, ToolContext context) async {
    final expr = args['expression']! as String;
    try {
      return formatNumber(evaluateExpression(expr));
    } on ExpressionException catch (e) {
      throw ToolException(e.message);
    }
  }
}

class DateTimeTool extends AgentTool {
  DateTimeTool({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  @override
  String get name => 'current_datetime';
  @override
  String get description => "Get the device's current local date and time.";
  @override
  String get labelKey => 'tool_datetime';
  @override
  Map<String, Object?> get parameters => _noArgs;
  @override
  bool get requiresApproval => false;
  @override
  Duration get timeout => const Duration(seconds: 1);

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
    'Sunday', //
  ];

  @override
  Future<String> run(Map<String, Object?> args, ToolContext context) async {
    final t = _now();
    final off = t.timeZoneOffset;
    final sign = off.isNegative ? '-' : '+';
    final h = off.inHours.abs().toString().padLeft(2, '0');
    final m = (off.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final iso = t.toIso8601String().split('.').first;
    return '$iso$sign$h:$m (${_days[t.weekday - 1]}, ${t.timeZoneName})';
  }
}

class PickedFile {
  const PickedFile({
    required this.name,
    required this.size,
    required this.readBytes,
  });

  final String name;
  final int size;
  final Future<List<int>> Function() readBytes;
}

/// Opens the system picker. Returns null when the user cancels.
typedef FilePickerPort = Future<PickedFile?> Function();

class ReadFileTool extends AgentTool {
  ReadFileTool(this._pick, {this.maxBytes = 256 * 1024});

  final FilePickerPort _pick;
  final int maxBytes;

  static const extensions = ['txt', 'md', 'csv', 'json', 'log'];

  @override
  String get name => 'read_file';
  @override
  String get description =>
      'Ask the user to pick one text file (.txt .md .csv .json .log) and '
      'return its contents. The user chooses the file, not you.';
  @override
  String get labelKey => 'tool_read_file';
  @override
  Map<String, Object?> get parameters => _noArgs;
  @override
  bool get requiresApproval => true;
  // Includes the time the user spends in the system picker.
  @override
  Duration get timeout => const Duration(minutes: 3);

  @override
  Future<String> run(Map<String, Object?> args, ToolContext context) async {
    final file = await _pick();
    if (file == null) {
      throw const ToolException('The user did not pick a file.');
    }
    final ext = p.extension(file.name).replaceFirst('.', '').toLowerCase();
    if (!extensions.contains(ext)) {
      throw ToolException('Only ${extensions.join(', ')} files can be read.');
    }
    if (file.size > maxBytes) {
      throw ToolException(
        'The file is ${file.size} bytes; the limit is $maxBytes bytes.',
      );
    }
    final bytes = await file.readBytes();
    if (bytes.length > maxBytes) {
      throw ToolException('The file is larger than $maxBytes bytes.');
    }
    try {
      return 'File "${file.name}" (${bytes.length} bytes):\n'
          '${utf8.decode(bytes)}';
    } on FormatException {
      throw const ToolException('The file is not UTF-8 text.');
    }
  }
}

/// Writes only .txt/.md files, only directly inside [workspace], and never
/// overwrites an existing file.
class WriteFileTool extends AgentTool {
  WriteFileTool(this._workspace, {this.maxBytes = 64 * 1024});

  final Future<Directory> Function() _workspace;
  final int maxBytes;

  static final _namePattern = r'^[A-Za-z0-9][A-Za-z0-9 _-]{0,59}\.(txt|md)$';

  @override
  String get name => 'write_file';
  @override
  String get description =>
      'Save text as a new .txt or .md file in the app workspace. '
      'filename: letters, digits, space, _ or - plus .txt or .md.';
  @override
  String get labelKey => 'tool_write_file';
  @override
  Map<String, Object?> get parameters => {
    'type': 'object',
    'properties': {
      'filename': {'type': 'string', 'maxLength': 63, 'pattern': _namePattern},
      'content': {'type': 'string', 'maxLength': 20000},
    },
    'required': ['filename', 'content'],
    'additionalProperties': false,
  };
  @override
  bool get requiresApproval => true;
  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  Future<String> run(Map<String, Object?> args, ToolContext context) async {
    final name = args['filename']! as String;
    final content = args['content']! as String;
    // Re-checked here so the tool is safe even if called without validation.
    if (!RegExp(_namePattern).hasMatch(name) || p.basename(name) != name) {
      throw const ToolException('Invalid file name.');
    }
    final bytes = utf8.encode(content);
    if (bytes.length > maxBytes) {
      throw ToolException('Content is larger than $maxBytes bytes.');
    }
    final dir = await _workspace();
    await dir.create(recursive: true);
    final root = p.canonicalize(dir.path);
    final target = p.canonicalize(p.join(root, name));
    if (p.dirname(target) != root) {
      throw const ToolException('Files can only be written to the workspace.');
    }
    final file = File(target);
    if (await file.exists()) {
      throw ToolException('"$name" already exists; choose another name.');
    }
    await file.writeAsBytes(bytes, flush: true);
    return 'Saved "$name" (${bytes.length} bytes) in the app workspace.';
  }
}

typedef Summarizer = Future<String> Function(String text);

class SummarizeTool extends AgentTool {
  SummarizeTool(this._summarize);

  final Summarizer _summarize;

  @override
  String get name => 'summarize';
  @override
  String get description => 'Summarize the given text in a few sentences.';
  @override
  String get labelKey => 'tool_summarize';
  @override
  Map<String, Object?> get parameters => const {
    'type': 'object',
    'properties': {
      'text': {'type': 'string', 'minLength': 1, 'maxLength': 6000},
    },
    'required': ['text'],
    'additionalProperties': false,
  };
  @override
  bool get requiresApproval => false;
  @override
  Duration get timeout => const Duration(seconds: 90);

  @override
  Future<String> run(Map<String, Object?> args, ToolContext context) async {
    final summary = (await _summarize(args['text']! as String)).trim();
    if (summary.isEmpty) {
      throw const ToolException('The model returned no summary.');
    }
    return summary;
  }
}

class HistoryHit {
  const HistoryHit({required this.title, required this.snippet});

  final String title;
  final String snippet;
}

typedef HistorySearch = Future<List<HistoryHit>> Function(
  String query,
  int limit,
);

/// Only registered when the user has turned on history search; [isEnabled]
/// is checked again on every call in case the setting changed mid-run.
class HistorySearchTool extends AgentTool {
  HistorySearchTool(this._search, {required this.isEnabled});

  final HistorySearch _search;
  final bool Function() isEnabled;

  @override
  String get name => 'search_history';
  @override
  String get description =>
      "Search the user's past chat messages on this device for a word or phrase.";
  @override
  String get labelKey => 'tool_history_search';
  @override
  Map<String, Object?> get parameters => const {
    'type': 'object',
    'properties': {
      'query': {'type': 'string', 'minLength': 2, 'maxLength': 100},
    },
    'required': ['query'],
    'additionalProperties': false,
  };
  @override
  bool get requiresApproval => false;
  @override
  Duration get timeout => const Duration(seconds: 5);

  @override
  Future<String> run(Map<String, Object?> args, ToolContext context) async {
    if (!isEnabled()) {
      throw const ToolException('History search is turned off in Settings.');
    }
    final hits = await _search(args['query']! as String, 5);
    if (hits.isEmpty) return 'No matching messages.';
    return [
      for (final (i, h) in hits.indexed) '${i + 1}. [${h.title}] ${h.snippet}',
    ].join('\n');
  }
}
