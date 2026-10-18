import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localmind_ai/domain/model_definition.dart';
import 'package:localmind_ai/services/agent/agent_orchestrator.dart';
import 'package:localmind_ai/services/agent/agent_tool.dart';
import 'package:localmind_ai/services/agent/tools.dart';
import 'package:localmind_ai/services/downloads/model_downloader.dart';
import 'package:localmind_ai/services/inference/inference_runtime.dart';
import 'package:localmind_ai/services/inference/llamadart_runtime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Runs the agent loop against the real model with grammar-constrained
/// decoding. Everything the model produced is logged, so the result can be
/// judged by a human, not only by the assertions.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final runtime = LlamadartRuntime();
  tearDownAll(runtime.dispose);

  Future<String> ensureModel(String id) async {
    final catalog = ModelCatalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/models/catalog.json'))
          as Map<String, dynamic>,
    );
    final m = catalog.byId(id)!;
    final dir = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'models'),
    );
    await dir.create(recursive: true);
    final path = p.join(dir.path, m.fileName);
    if (File(path).existsSync()) return path;
    final pushed = File('/data/local/tmp/${m.fileName}');
    if (pushed.existsSync() && await sha256OfFile(pushed.path) == m.sha256) {
      await pushed.copy(path);
      return path;
    }
    await ModelDownloader(freeBytes: () async => 1 << 40).download(
      url: m.downloadUrl,
      targetPath: path,
      expectedBytes: m.sizeBytes,
      expectedSha256: m.sha256,
      onProgress: (_) {},
      cancel: CancelSignal(),
    );
    return path;
  }

  Future<AgentOrchestrator> runTask(String task) async {
    final o = AgentOrchestrator(
      registry: ToolRegistry([CalculatorTool(), DateTimeTool()]),
      generate: runtime.generate,
      cancelGeneration: runtime.cancel,
      approve: (_, _) async => false,
    );
    final watch = Stopwatch()..start();
    await o.run(task);
    log('[agent] "$task" -> ${o.state.name} in ${watch.elapsedMilliseconds} ms, '
        'replies=${o.modelReplies}, grammar=${o.useGrammar}');
    for (final s in o.steps) {
      log('  ${s.kind.name} ${s.tool ?? ''} ${s.args ?? ''} ${s.text}'.trimRight());
    }
    if (o.failure != null) log('  failure=${o.failure} ${o.failureDetail ?? ''}');
    return o;
  }

  testWidgets('Qwen2.5 0.5B completes a calculator task', semanticsEnabled: false, (
    tester,
  ) async {
    final path = await ensureModel('qwen2.5-0.5b-instruct-q4_k_m');
    await runtime.load(path, const RuntimeLoadConfig(contextSize: 2048));

    final o = await runTask('What is 23 * 47 + 12?');
    expect(o.state, AgentState.completed);
    final results = o.steps.where(
      (s) => s.kind == AgentStepKind.toolResult && s.tool == 'calculator',
    );
    expect(results.map((s) => s.text), contains('1093'));
    expect(o.answer, contains('1093'));

    // Logged for the record; not asserted, small models vary on these.
    await runTask('What is the square root of 144 multiplied by 3?');
    await runTask('What day of the week is it today?');

    // Cancellation against the real engine.
    final c = AgentOrchestrator(
      registry: ToolRegistry([CalculatorTool()]),
      generate: runtime.generate,
      cancelGeneration: runtime.cancel,
      approve: (_, _) async => false,
    );
    final run = c.run('Compute 1+1, then 2+2, then 3+3, then 4+4.');
    await Future<void>.delayed(const Duration(milliseconds: 300));
    c.cancel();
    await run;
    log('[cancel] state=${c.state.name} replies=${c.modelReplies}');
    expect(c.state, AgentState.cancelled);
    await runtime.unload();
  });
}

// ignore: avoid_print
void log(String s) => print(s);
