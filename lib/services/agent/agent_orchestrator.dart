import 'dart:async';
import 'dart:convert';

import '../inference/inference_runtime.dart';
import 'agent_protocol.dart';
import 'agent_tool.dart';

enum AgentState {
  idle,
  planning,
  awaitingApproval,
  runningTool,
  processingResult,
  completed,
  failed,
  cancelled;

  bool get isTerminal => this == completed || this == failed || this == cancelled;
}

const agentTransitions = <AgentState, Set<AgentState>>{
  AgentState.idle: {AgentState.planning, AgentState.cancelled},
  AgentState.planning: {
    AgentState.awaitingApproval,
    AgentState.runningTool,
    AgentState.processingResult,
    AgentState.completed,
    AgentState.failed,
    AgentState.cancelled,
  },
  AgentState.awaitingApproval: {
    AgentState.runningTool,
    AgentState.processingResult,
    AgentState.cancelled,
  },
  AgentState.runningTool: {
    AgentState.processingResult,
    AgentState.failed,
    AgentState.cancelled,
  },
  AgentState.processingResult: {
    AgentState.planning,
    AgentState.failed,
    AgentState.cancelled,
  },
  AgentState.completed: {},
  AgentState.failed: {},
  AgentState.cancelled: {},
};

enum AgentFailure { stepLimit, invalidModelOutput, modelError, outOfMemory }

enum AgentStepKind {
  toolCall,
  toolResult,
  toolError,
  approvalDenied,
  invalidOutput,
  note,
  finalAnswer,
}

class AgentStep {
  const AgentStep(this.kind, {this.tool, this.args, this.text = '', this.elapsed});

  final AgentStepKind kind;
  final String? tool;
  final Map<String, Object?>? args;
  final String text;
  final Duration? elapsed;
}

class AgentLimits {
  const AgentLimits({
    this.maxSteps = 6,
    this.maxToolOutputBytes = 2048,
    this.maxAnswerBytes = 4096,
    this.maxModelOutputBytes = 2048,
    this.maxInvalidOutputs = 2,
    this.maxTokensPerStep = 256,
  });

  /// Model replies per run, including the final answer.
  final int maxSteps;
  final int maxToolOutputBytes;
  final int maxAnswerBytes;

  /// A reply longer than this is cut off and treated as invalid.
  final int maxModelOutputBytes;

  /// Unparseable or invalid replies tolerated before giving up.
  final int maxInvalidOutputs;
  final int maxTokensPerStep;
}

typedef GenerateFn =
    Stream<GenerationEvent> Function(
      List<ChatTurn> turns,
      GenerationSettings settings, {
      Map<String, Object?>? jsonSchema,
    });

typedef Approver = Future<bool> Function(AgentTool tool, ToolCall call);

class InvalidTransition extends StateError {
  InvalidTransition(AgentState from, AgentState to) : super('$from -> $to');
}

/// Runs one task as a bounded loop: the model proposes a step as JSON, the
/// orchestrator validates it, asks for approval where required, runs the
/// tool with a timeout, and feeds the (truncated) result back.
///
/// Tools are fixed Dart functions in [registry]; model output is only ever
/// parsed as data and never executed.
class AgentOrchestrator {
  AgentOrchestrator({
    required this.registry,
    required this._generate,
    required this._cancelGeneration,
    required this._approve,
    this.limits = const AgentLimits(),
    this.useGrammar = true,
    this.onChange,
  });

  final ToolRegistry registry;
  final GenerateFn _generate;
  final void Function() _cancelGeneration;
  final Approver _approve;
  final AgentLimits limits;
  final void Function()? onChange;

  /// Set to false after the backend rejects a schema; later steps then rely
  /// on the tolerant parser alone.
  bool useGrammar;

  AgentState _state = AgentState.idle;
  final _steps = <AgentStep>[];
  final _cancelSignal = Completer<void>();
  String? _answer;
  AgentFailure? _failure;
  String? _failureDetail;
  int _modelReplies = 0;
  final _denied = <String>{};

  AgentState get state => _state;
  List<AgentStep> get steps => List.unmodifiable(_steps);
  String? get answer => _answer;
  AgentFailure? get failure => _failure;
  String? get failureDetail => _failureDetail;
  int get modelReplies => _modelReplies;
  bool get isCancelled => _state == AgentState.cancelled;

  void _to(AgentState next) {
    if (!agentTransitions[_state]!.contains(next)) {
      throw InvalidTransition(_state, next);
    }
    _state = next;
    onChange?.call();
  }

  void _add(AgentStep step) {
    _steps.add(step);
    onChange?.call();
  }

  void cancel() {
    if (_state.isTerminal) return;
    _to(AgentState.cancelled);
    _cancelGeneration();
    if (!_cancelSignal.isCompleted) _cancelSignal.complete();
  }

  Future<void> run(String task) async {
    if (_state != AgentState.idle) throw StateError('An orchestrator runs once');
    final turns = [
      ChatTurn(ChatRole.system, systemPrompt(registry, maxSteps: limits.maxSteps)),
      ChatTurn(ChatRole.user, task),
    ];
    _to(AgentState.planning);
    var invalid = 0;
    while (true) {
      if (isCancelled) return;
      if (_modelReplies >= limits.maxSteps) {
        return _fail(AgentFailure.stepLimit);
      }
      String raw;
      var overflow = false;
      try {
        raw = await _reply(turns);
      } on _Overflow catch (e) {
        raw = truncateUtf8(e.partial, limits.maxModelOutputBytes);
        overflow = true;
      } on InferenceException catch (e) {
        if (isCancelled) return;
        return _fail(
          e.outOfMemory ? AgentFailure.outOfMemory : AgentFailure.modelError,
          e.message,
        );
      }
      if (isCancelled) return;
      _modelReplies++;
      turns.add(ChatTurn(ChatRole.assistant, raw));

      final step = overflow ? null : parseStep(raw);
      final errors = switch (step) {
        null when overflow => [
          'Reply was longer than ${limits.maxModelOutputBytes} bytes.',
        ],
        null => const ['Reply was not a JSON object with "tool" and "args".'],
        ToolStep(:final call) => registry.validate(call),
        FinalStep(:final answer) when answer.trim().isEmpty => const [
          'The answer is empty.',
        ],
        FinalStep() => const <String>[],
      };
      if (errors.isNotEmpty) {
        _add(
          AgentStep(
            AgentStepKind.invalidOutput,
            tool: step is ToolStep ? step.call.tool : null,
            text: '${errors.join('; ')}\n${truncateUtf8(raw, 300)}',
          ),
        );
        if (++invalid > limits.maxInvalidOutputs) {
          return _fail(AgentFailure.invalidModelOutput, raw);
        }
        turns.add(
          ChatTurn(
            ChatRole.user,
            'Error: ${errors.join('; ')} Reply with one valid JSON object.',
          ),
        );
        continue;
      }

      switch (step!) {
        case FinalStep(:final answer):
          _answer = truncateUtf8(answer.trim(), limits.maxAnswerBytes);
          _add(AgentStep(AgentStepKind.finalAnswer, text: _answer!));
          _to(AgentState.completed);
          return;
        case ToolStep(:final call):
          final result = await _runTool(call);
          if (result == null) return;
          if (isCancelled) return;
          _to(AgentState.processingResult);
          turns.add(ChatTurn(ChatRole.user, result));
          _to(AgentState.planning);
      }
    }
  }

  /// Returns the message for the model, or null if the run ended.
  Future<String?> _runTool(ToolCall call) async {
    final tool = registry[call.tool]!;
    _add(AgentStep(AgentStepKind.toolCall, tool: tool.name, args: call.args));
    if (tool.requiresApproval) {
      _to(AgentState.awaitingApproval);
      // A tool the user denied once in this run is not asked about again.
      final approved =
          !_denied.contains(tool.name) &&
          await Future.any([
            _approve(tool, call),
            _cancelSignal.future.then((_) => false),
          ]);
      if (isCancelled) return null;
      if (!approved) {
        _denied.add(tool.name);
        _add(AgentStep(AgentStepKind.approvalDenied, tool: tool.name));
        return 'The user denied ${tool.name}. Do not call it again; '
            'answer with what you have.';
      }
    }
    _to(AgentState.runningTool);
    final watch = Stopwatch()..start();
    try {
      final output = await Future.any([
        tool
            .run(call.args, ToolContext(isCancelled: () => isCancelled))
            .timeout(tool.timeout),
        _cancelSignal.future.then((_) => ''),
      ]);
      if (isCancelled) return null;
      final text = truncateUtf8(output, limits.maxToolOutputBytes);
      _add(
        AgentStep(
          AgentStepKind.toolResult,
          tool: tool.name,
          text: text,
          elapsed: watch.elapsed,
        ),
      );
      return 'Result of ${tool.name}: $text\n'
          'If this completes the task, reply with $finalAnswerTool.';
    } on TimeoutException {
      return _toolError(tool, 'Timed out after ${tool.timeout.inSeconds} s.', watch);
    } on ToolException catch (e) {
      return _toolError(tool, e.message, watch);
    } on InferenceException catch (e) {
      // A tool that uses the model (summarize) failed.
      return _toolError(tool, e.message, watch);
    }
  }

  String? _toolError(AgentTool tool, String message, Stopwatch watch) {
    if (isCancelled) return null;
    _add(
      AgentStep(
        AgentStepKind.toolError,
        tool: tool.name,
        text: message,
        elapsed: watch.elapsed,
      ),
    );
    return 'Error from ${tool.name}: $message';
  }

  Future<String> _reply(List<ChatTurn> turns) async {
    final settings = GenerationSettings(
      temperature: 0,
      topP: 1,
      maxTokens: limits.maxTokensPerStep,
    );
    if (useGrammar) {
      try {
        return await _collect(turns, settings, stepSchema(registry));
      } on InferenceException catch (e) {
        if (e.outOfMemory || isCancelled) rethrow;
        useGrammar = false;
        _add(AgentStep(AgentStepKind.note, text: 'grammar_unavailable: ${e.message}'));
      }
    }
    return _collect(turns, settings, null);
  }

  /// Throws [_Overflow] when the reply exceeds [AgentLimits.maxModelOutputBytes].
  Future<String> _collect(
    List<ChatTurn> turns,
    GenerationSettings settings,
    Map<String, Object?>? schema,
  ) async {
    final b = StringBuffer();
    var bytes = 0;
    await for (final e in _generate(turns, settings, jsonSchema: schema)) {
      if (e is TokenEvent) {
        b.write(e.text);
        bytes += utf8.encode(e.text).length;
        if (bytes > limits.maxModelOutputBytes) {
          _cancelGeneration();
          throw _Overflow(b.toString());
        }
      }
    }
    return b.toString();
  }

  void _fail(AgentFailure failure, [String? detail]) {
    _failure = failure;
    _failureDetail = detail == null ? null : truncateUtf8(detail, 500);
    _to(AgentState.failed);
  }
}

class _Overflow implements Exception {
  const _Overflow(this.partial);
  final String partial;
}
