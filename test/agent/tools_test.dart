import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/services/agent/agent_tool.dart';
import 'package:localmind_ai/services/agent/tools.dart';
import 'package:path/path.dart' as p;

void main() {
  final ctx = ToolContext(isCancelled: () => false);
  late Directory tmp;
  late Directory workspace;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('agent_tools');
    workspace = Directory(p.join(tmp.path, 'agent_workspace'));
  });
  tearDown(() => tmp.delete(recursive: true));

  group('registry validation', () {
    final registry = ToolRegistry([
      CalculatorTool(),
      DateTimeTool(),
      WriteFileTool(() async => Directory.systemTemp),
    ]);

    test('accepts valid calls', () {
      expect(registry.validate(const ToolCall('calculator', {'expression': '1+1'})), isEmpty);
      expect(registry.validate(const ToolCall('current_datetime', {})), isEmpty);
      expect(
        registry.validate(const ToolCall('write_file', {'filename': 'notes.md', 'content': 'hi'})),
        isEmpty,
      );
    });

    test('rejects unknown tools, missing, extra and mistyped args', () {
      expect(registry.validate(const ToolCall('shell', {'cmd': 'ls'})), isNotEmpty);
      expect(registry.validate(const ToolCall('calculator', {})), isNotEmpty);
      expect(registry.validate(const ToolCall('calculator', {'expression': 5})), isNotEmpty);
      expect(
        registry.validate(const ToolCall('calculator', {'expression': '1', 'x': 1})),
        isNotEmpty,
      );
      expect(registry.validate(const ToolCall('calculator', {'expression': ''})), isNotEmpty);
      expect(
        registry.validate(ToolCall('calculator', {'expression': '1' * 201})),
        isNotEmpty,
      );
      expect(registry.validate(const ToolCall('current_datetime', {'tz': 'UTC'})), isNotEmpty);
    });

    test('rejects unsafe file names', () {
      for (final name in [
        '../x.txt',
        'a/b.txt',
        '/etc/passwd',
        'x.sh',
        'x.txt.sh',
        '.hidden.txt',
        'notes',
        r'a\b.md',
      ]) {
        expect(
          registry.validate(ToolCall('write_file', {'filename': name, 'content': ''})),
          isNotEmpty,
          reason: name,
        );
      }
    });

    test('refuses tools without closed schemas', () {
      expect(() => ToolRegistry([_OpenTool()]), throwsArgumentError);
    });
  });

  test('calculator returns exact results and tool errors', () async {
    final c = CalculatorTool();
    expect(await c.run({'expression': '23 * 47 + 12'}, ctx), '1093');
    expect(() => c.run({'expression': '1/0'}, ctx), throwsA(isA<ToolException>()));
  });

  test('datetime reports the injected clock', () async {
    final t = DateTimeTool(now: () => DateTime(2026, 10, 17, 9, 5, 3));
    expect(await t.run({}, ctx), startsWith('2026-10-17T09:05:03'));
    expect(await t.run({}, ctx), contains('Saturday'));
  });

  group('write_file', () {
    test('writes inside the workspace only and never overwrites', () async {
      final tool = WriteFileTool(() async => workspace);
      expect(tool.requiresApproval, isTrue);
      await tool.run({'filename': 'list.md', 'content': '# Hi'}, ctx);
      expect(File(p.join(workspace.path, 'list.md')).readAsStringSync(), '# Hi');
      expect(
        () => tool.run({'filename': 'list.md', 'content': 'other'}, ctx),
        throwsA(isA<ToolException>()),
      );
      expect(File(p.join(workspace.path, 'list.md')).readAsStringSync(), '# Hi');
    });

    test('re-checks names even without registry validation', () async {
      final tool = WriteFileTool(() async => workspace);
      for (final name in ['../escape.txt', 'x.dart', 'a/b.md']) {
        await expectLater(
          tool.run({'filename': name, 'content': 'x'}, ctx),
          throwsA(isA<ToolException>()),
          reason: name,
        );
      }
      expect(File(p.join(tmp.path, 'escape.txt')).existsSync(), isFalse);
    });

    test('enforces the byte limit', () async {
      final tool = WriteFileTool(() async => workspace, maxBytes: 10);
      await expectLater(
        tool.run({'filename': 'big.txt', 'content': 'x' * 11}, ctx),
        throwsA(isA<ToolException>()),
      );
    });
  });

  group('read_file', () {
    PickedFile picked(String name, List<int> bytes, {int? size}) => PickedFile(
      name: name,
      size: size ?? bytes.length,
      readBytes: () async => bytes,
    );

    test('requires approval and returns text', () async {
      final tool = ReadFileTool(() async => picked('a.txt', utf8.encode('hello')));
      expect(tool.requiresApproval, isTrue);
      expect(await tool.run({}, ctx), contains('hello'));
    });

    test('rejects cancel, wrong type, oversize and binary files', () async {
      Future<void> fails(ReadFileTool t) =>
          expectLater(t.run({}, ctx), throwsA(isA<ToolException>()));
      await fails(ReadFileTool(() async => null));
      await fails(ReadFileTool(() async => picked('a.pdf', [1])));
      await fails(ReadFileTool(() async => picked('a.txt', [1], size: 300 * 1024)));
      await fails(ReadFileTool(() async => picked('a.txt', [0xff, 0xfe, 0x00])));
      var read = false;
      await fails(
        ReadFileTool(
          () async => PickedFile(
            name: 'a.txt',
            size: 1 << 30,
            readBytes: () async {
              read = true;
              return const [];
            },
          ),
        ),
      );
      expect(read, isFalse, reason: 'size is checked before reading');
    });
  });

  test('history search refuses to run when the setting is off', () async {
    var enabled = false;
    var searched = 0;
    final tool = HistorySearchTool((q, n) async {
      searched++;
      return const [HistoryHit(title: 'T', snippet: 'match')];
    }, isEnabled: () => enabled);
    await expectLater(tool.run({'query': 'match'}, ctx), throwsA(isA<ToolException>()));
    expect(searched, 0);
    enabled = true;
    expect(await tool.run({'query': 'match'}, ctx), contains('[T] match'));
  });
}

class _OpenTool extends CalculatorTool {
  @override
  Map<String, Object?> get parameters => const {'type': 'object'};
}
