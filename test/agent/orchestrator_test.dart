import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/services/agent/agent_orchestrator.dart';
import 'package:localmind_ai/services/agent/agent_protocol.dart';
import 'package:localmind_ai/services/agent/agent_tool.dart';
import 'package:localmind_ai/services/agent/tools.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';
import 'package:path/path.dart' as p;

import '../fakes.dart';

const _calc = '{"tool": "calculator", "args": {"expression": "23 * 47 + 12"}}';
const _final =
    '{"tool": "final_answer", "args": {"answer": "The result is 1093."}}';

class _Harness {
  _Harness(
    List<String> replies, {
    List<AgentTool>? tools,
    Approver? approve,
    AgentLimits limits = const AgentLimits(),
    GenerateFn? generate,
  }) : runtime = FakeRuntime(responses: replies) {
    orchestrator = AgentOrchestrator(
      registry: ToolRegistry(tools ?? [CalculatorTool(), DateTimeTool()]),
      generate: generate ?? runtime.generate,
      cancelGeneration: runtime.cancel,
      approve: approve ?? (_, _) async => fail('approval not expected'),
      limits: limits,
      onChange: () {
        if (states.lastOrNull != orchestrator.state) {
          states.add(orchestrator.state);
        }
      },
    );
  }

  final FakeRuntime runtime;
  late final AgentOrchestrator orchestrator;
  final states = <AgentState>[];

  List<AgentStepKind> get kinds => [for (final s in orchestrator.steps) s.kind];
}

void main() {
  test('completes a calculator task with grammar-constrained steps', () async {
    final h = _Harness([_calc, _final]);
    await h.orchestrator.run('What is 23 * 47 + 12?');

    expect(h.orchestrator.state, AgentState.completed);
    expect(h.orchestrator.answer, 'The result is 1093.');
    expect(h.kinds, [
      AgentStepKind.toolCall,
      AgentStepKind.toolResult,
      AgentStepKind.finalAnswer,
    ]);
    expect(h.orchestrator.steps[1].text, '1093');
    expect(h.states, [
      AgentState.planning,
      AgentState.runningTool,
      AgentState.processingResult,
      AgentState.planning,
      AgentState.completed,
    ]);
    // Every model call was constrained by the step schema.
    expect(h.runtime.schemas, hasLength(2));
    expect(h.runtime.schemas, everyElement(isNotNull));
    // The turn list is shared and also holds the final reply.
    final turns = h.runtime.lastTurns!;
    expect(
      turns[turns.length - 2].text,
      contains('Result of calculator: 1093'),
    );
  });

  test(
    'tolerates prose, fences and other call shapes when unconstrained',
    () async {
      final h = _Harness([
        'Sure! ```json\n{"name": "calculator", "arguments": {"expression": "2+2"}}\n```',
        '<tool_call>{"answer": "4"}</tool_call>',
      ]);
      await h.orchestrator.run('2+2?');
      expect(h.orchestrator.state, AgentState.completed);
      expect(h.orchestrator.answer, '4');
      expect(h.orchestrator.steps[1].text, '4');
    },
  );

  test(
    'falls back to unconstrained decoding when the backend rejects the schema',
    () async {
      final rt = FakeRuntime(responses: [_calc, _final]);
      Stream<GenerationEvent> generate(
        List<ChatTurn> t,
        GenerationSettings s, {
        Map<String, Object?>? jsonSchema,
      }) {
        if (jsonSchema != null) {
          return Stream.error(const InferenceException('grammar unsupported'));
        }
        return rt.generate(t, s);
      }

      final h = _Harness(const [], generate: generate);
      await h.orchestrator.run('task');
      expect(h.orchestrator.state, AgentState.completed);
      expect(h.orchestrator.useGrammar, isFalse);
      expect(h.kinds.first, AgentStepKind.note);
    },
  );

  test('invalid replies are retried, then the run fails honestly', () async {
    final h = _Harness([
      'I think the answer is 1093',
      '{"tool": "shell", "args": {"cmd": "rm"}}',
      'still no json',
    ], limits: const AgentLimits(maxInvalidOutputs: 2));
    await h.orchestrator.run('task');
    expect(h.orchestrator.state, AgentState.failed);
    expect(h.orchestrator.failure, AgentFailure.invalidModelOutput);
    expect(h.orchestrator.failureDetail, 'still no json');
    expect(h.orchestrator.answer, isNull);
    expect(h.kinds, everyElement(AgentStepKind.invalidOutput));
    final turns = h.runtime.lastTurns!;
    expect(turns[turns.length - 2].text, startsWith('Error:'));
  });

  test('invalid arguments never reach the tool', () async {
    final tool = _CountingTool();
    final h = _Harness(
      [
        '{"tool": "counter", "args": {"n": "not a number"}}',
        '{"tool": "counter", "args": {"n": 1, "extra": true}}',
        _final,
      ],
      tools: [tool],
    );
    await h.orchestrator.run('task');
    expect(tool.runs, 0);
    expect(h.orchestrator.state, AgentState.completed);
  });

  test('stops at the step limit', () async {
    final h = _Harness(
      List.of(List.filled(10, _calc)),
      limits: const AgentLimits(maxSteps: 3),
    );
    await h.orchestrator.run('loop forever');
    expect(h.orchestrator.state, AgentState.failed);
    expect(h.orchestrator.failure, AgentFailure.stepLimit);
    expect(h.orchestrator.modelReplies, 3);
    expect(h.runtime.generateCalls, 3);
  });

  test('cuts off oversized model output and tool output', () async {
    final h = _Harness(
      [
        '{"tool": "final_answer", "args": {"answer": "${'x' * 500}"}}',
        '{"tool": "big", "args": {}}',
        '{"tool": "final_answer", "args": {"answer": "ok"}}',
      ],
      tools: [_BigOutputTool()],
      limits: const AgentLimits(
        maxModelOutputBytes: 100,
        maxToolOutputBytes: 64,
      ),
    );
    await h.orchestrator.run('task');
    expect(h.kinds.first, AgentStepKind.invalidOutput);
    final result = h.orchestrator.steps.firstWhere(
      (s) => s.kind == AgentStepKind.toolResult,
    );
    expect(result.text, contains('[truncated'));
    expect(result.text.length, lessThan(200));
    expect(h.orchestrator.state, AgentState.completed);
  });

  group('approval', () {
    late Directory dir;
    setUp(() async => dir = await Directory.systemTemp.createTemp('agent_ws'));
    tearDown(() => dir.delete(recursive: true));

    const write =
        '{"tool": "write_file", "args": {"filename": "a.md", "content": "hi"}}';

    test('approved write runs after awaitingApproval', () async {
      final asked = <String>[];
      final h = _Harness(
        [write, _final],
        tools: [WriteFileTool(() async => dir)],
        approve: (tool, call) async {
          asked.add('${tool.name}:${call.args['filename']}');
          return true;
        },
      );
      await h.orchestrator.run('save');
      expect(asked, ['write_file:a.md']);
      expect(File(p.join(dir.path, 'a.md')).existsSync(), isTrue);
      expect(h.states.sublist(0, 4), [
        AgentState.planning,
        AgentState.awaitingApproval,
        AgentState.runningTool,
        AgentState.processingResult,
      ]);
    });

    test('denied write never touches disk and is not asked again', () async {
      var asked = 0;
      final h = _Harness(
        [write, write, _final],
        tools: [WriteFileTool(() async => dir)],
        approve: (_, _) async {
          asked++;
          return false;
        },
      );
      await h.orchestrator.run('save');
      expect(asked, 1);
      expect(dir.listSync(), isEmpty);
      expect(
        h.kinds.where((k) => k == AgentStepKind.approvalDenied),
        hasLength(2),
      );
      expect(h.kinds, isNot(contains(AgentStepKind.toolResult)));
      expect(h.orchestrator.state, AgentState.completed);
    });

    test('tools without requiresApproval are not asked about', () async {
      final h = _Harness([_calc, _final]);
      await h.orchestrator.run('calc');
      expect(h.states, isNot(contains(AgentState.awaitingApproval)));
    });
  });

  group('cancellation', () {
    test('while awaiting approval: no tool runs', () async {
      final tool = _CountingTool(approval: true);
      final pending = Completer<bool>();
      final h = _Harness(
        ['{"tool": "counter", "args": {"n": 1}}', _final],
        tools: [tool],
        approve: (_, _) => pending.future,
      );
      final run = h.orchestrator.run('task');
      while (h.orchestrator.state != AgentState.awaitingApproval) {
        await Future<void>.delayed(Duration.zero);
      }
      h.orchestrator.cancel();
      await run;
      pending.complete(true);
      await Future<void>.delayed(Duration.zero);
      expect(h.orchestrator.state, AgentState.cancelled);
      expect(tool.runs, 0);
    });

    test('while a tool is running: run ends at once', () async {
      final tool = _SlowTool();
      final h = _Harness(
        ['{"tool": "slow", "args": {}}', _final],
        tools: [tool],
      );
      final run = h.orchestrator.run('task');
      while (h.orchestrator.state != AgentState.runningTool) {
        await Future<void>.delayed(Duration.zero);
      }
      h.orchestrator.cancel();
      await run;
      expect(h.orchestrator.state, AgentState.cancelled);
      expect(h.runtime.generateCalls, 1);
      tool.release.complete();
    });

    test('while the model is generating: generation is cancelled', () async {
      final runtime = FakeRuntime(tokens: List.filled(50, 'x'));
      final o = AgentOrchestrator(
        registry: ToolRegistry([CalculatorTool()]),
        generate: runtime.generate,
        cancelGeneration: runtime.cancel,
        approve: (_, _) async => false,
      );
      final run = o.run('task');
      await Future<void>.delayed(Duration.zero);
      o.cancel();
      await run;
      expect(o.state, AgentState.cancelled);
      expect(o.steps, isEmpty);
    });
  });

  test('tool timeouts are reported to the model, not fatal', () async {
    final h = _Harness(
      ['{"tool": "slow", "args": {}}', _final],
      tools: [_SlowTool(timeout: const Duration(milliseconds: 10))],
    );
    await h.orchestrator.run('task');
    expect(h.kinds, contains(AgentStepKind.toolError));
    expect(h.orchestrator.state, AgentState.completed);
  });

  test('model errors fail the run', () async {
    Stream<GenerationEvent> generate(
      List<ChatTurn> t,
      GenerationSettings s, {
      Map<String, Object?>? jsonSchema,
    }) => Stream.error(const InferenceException('oom', outOfMemory: true));
    final h = _Harness(const [], generate: generate);
    await h.orchestrator.run('task');
    expect(h.orchestrator.failure, AgentFailure.outOfMemory);
  });

  test(
    'transition table: terminal states are final, idle cannot skip ahead',
    () {
      for (final s in AgentState.values.where((s) => s.isTerminal)) {
        expect(agentTransitions[s], isEmpty);
      }
      expect(
        agentTransitions[AgentState.idle],
        isNot(contains(AgentState.runningTool)),
      );
      expect(
        agentTransitions[AgentState.planning],
        isNot(contains(AgentState.idle)),
      );
      // A tool can only run after planning or approval.
      for (final e in agentTransitions.entries) {
        if (e.value.contains(AgentState.runningTool)) {
          expect(
            e.key,
            anyOf(AgentState.planning, AgentState.awaitingApproval),
          );
        }
      }
    },
  );

  test('an orchestrator runs only once', () async {
    final h = _Harness([_final]);
    await h.orchestrator.run('a');
    expect(() => h.orchestrator.run('b'), throwsStateError);
  });

  test('step schema lists every tool plus final_answer', () {
    final schema = stepSchema(ToolRegistry([CalculatorTool(), DateTimeTool()]));
    final names = [
      for (final alt in schema['oneOf']! as List)
        ((alt as Map)['properties'] as Map)['tool']['const'],
    ];
    expect(names, ['calculator', 'current_datetime', finalAnswerTool]);
    expect(schema.toString(), isNot(contains('maxLength')));
  });

  test('truncateUtf8 never splits a character', () {
    final s = truncateUtf8('আমি' * 10, 10);
    expect(s, startsWith('আমি'));
    expect(s, contains('[truncated'));
  });
}

class _CountingTool extends AgentTool {
  _CountingTool({this.approval = false});

  final bool approval;
  int runs = 0;

  @override
  String get name => 'counter';
  @override
  String get description => 'count';
  @override
  String get labelKey => 'tool_calculator';
  @override
  Map<String, Object?> get parameters => const {
    'type': 'object',
    'properties': {
      'n': {'type': 'integer'},
    },
    'required': ['n'],
    'additionalProperties': false,
  };
  @override
  bool get requiresApproval => approval;
  @override
  Duration get timeout => const Duration(seconds: 1);
  @override
  Future<String> run(Map<String, Object?> args, ToolContext context) async {
    runs++;
    return 'ok';
  }
}

class _SlowTool extends _CountingTool {
  _SlowTool({this.timeout = const Duration(minutes: 1)});

  final release = Completer<void>();
  @override
  final Duration timeout;
  @override
  String get name => 'slow';
  @override
  Map<String, Object?> get parameters => const {
    'type': 'object',
    'properties': <String, Object?>{},
    'additionalProperties': false,
  };
  @override
  Future<String> run(Map<String, Object?> args, ToolContext context) async {
    await release.future;
    return 'done';
  }
}

class _BigOutputTool extends _SlowTool {
  @override
  String get name => 'big';
  @override
  Future<String> run(Map<String, Object?> args, ToolContext context) async =>
      'y' * 1000;
}
