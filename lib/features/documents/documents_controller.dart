import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/database.dart';
import '../../services/documents/document_service.dart';
import '../../services/documents/grounding.dart';
import '../../services/documents/retrieval.dart';
import '../../services/documents/text_extraction.dart';
import '../../services/inference/context_budget.dart';
import '../../services/inference/inference_runtime.dart';
import '../../services/inference/model_runtime_service.dart';
import '../../services/model_service.dart';
import '../../services/settings_service.dart';

enum AskPhase { idle, searching, loadingModel, generating }

class DocumentsController extends GetxController {
  final service = Get.find<DocumentService>();
  final runtime = Get.find<ModelRuntimeService>();
  final models = Get.find<ModelService>();
  final settings = Get.find<SettingsService>();

  final documents = <Document>[].obs;
  final importing = false.obs;
  final rebuilding = false.obs;
  final phase = AskPhase.idle.obs;
  final question = TextEditingController();
  final streamingText = ''.obs;

  /// The last answer; null until a question was asked.
  final answer = Rxn<GroundedAnswer>();
  final askedQuestion = RxnString();
  final passages = <RetrievedPassage>[].obs;
  final error = RxnString();

  /// The model's unparsed reply to the last question, for diagnostics.
  String lastRawReply = '';

  StreamSubscription<List<Document>>? _sub;
  bool _cancelled = false;

  int get totalBytes => documents.fold(0, (n, d) => n + d.sizeBytes);
  int get totalChars => documents.fold(0, (n, d) => n + d.charCount);
  bool get busy => phase.value != AskPhase.idle;

  @override
  void onInit() {
    super.onInit();
    _sub = service.watchAll().listen((docs) {
      documents.assignAll(docs);
      service.semantic?.refreshCounts();
    });
  }

  /// Returns a translation key describing the outcome, or null if cancelled.
  Future<String?> pickAndImport() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt', 'md', 'markdown', 'pdf'],
    );
    final file = picked.isEmpty ? null : picked.first;
    if (file == null || file.path == null) return null;
    importing.value = true;
    try {
      await service.import(file.path!, file.name);
      return 'doc_imported';
    } on ExtractionException catch (e) {
      return e.reason;
    } on Object {
      return 'doc_error_import';
    } finally {
      importing.value = false;
    }
  }

  Future<void> remove(Document d) async {
    await service.remove(d.id);
    if (passages.any((p) => p.documentId == d.id)) _clearAnswer();
  }

  Future<int> rebuild() async {
    rebuilding.value = true;
    try {
      _clearAnswer();
      return await service.rebuildIndex();
    } finally {
      rebuilding.value = false;
    }
  }

  void _clearAnswer() {
    answer.value = null;
    askedQuestion.value = null;
    passages.clear();
  }

  Future<void> ask() async {
    final q = question.text.trim();
    if (q.isEmpty || busy) return;
    final mid = settings.activeModelId.value;
    if (mid == null || models.installedById(mid) == null) {
      error.value = 'error_no_model_selected';
      return;
    }
    error.value = null;
    _clearAnswer();
    askedQuestion.value = q;
    phase.value = AskPhase.searching;

    final terms = queryTerms(q);
    final found = await service.search(q, limit: 4);
    if (!hasEnoughEvidence(
      found,
      terms,
      minSimilarity: service.minSimilarity,
    )) {
      passages.assignAll(found);
      answer.value = const GroundedAnswer(
        text: '',
        cited: [],
        invalidCitations: [],
        notEnoughEvidence: true,
      );
      phase.value = AskPhase.idle;
      return;
    }

    phase.value = AskPhase.loadingModel;
    try {
      await runtime.ensureLoaded(mid);
    } on LoadFailure catch (e) {
      error.value = e.reason;
      phase.value = AskPhase.idle;
      return;
    }

    final bengali = settings.localeCode.value == 'bn';
    final overhead = estimateTokens(
      buildGroundedTurns(
        q,
        const [],
        bengali: bengali,
      ).map((t) => t.text).join('\n'),
    );
    final budget =
        runtime.loadedContextSize - settings.generation.maxTokens - overhead;
    final used = fitPassages(found, budget, estimateTokens);
    passages.assignAll(used);
    final turns = buildGroundedTurns(q, used, bengali: bengali);

    phase.value = AskPhase.generating;
    streamingText.value = '';
    _cancelled = false;
    try {
      final gen = settings.generation;
      await for (final event in runtime.generate(
        turns,
        // Low temperature: answers should stay close to the excerpts.
        settings: GenerationSettings(
          temperature: 0.1,
          topP: gen.topP,
          maxTokens: gen.maxTokens,
        ),
      )) {
        if (event case TokenEvent(:final text)) streamingText.value += text;
      }
    } on InferenceException catch (e) {
      error.value = e.outOfMemory
          ? 'error_out_of_memory'
          : 'error_generation_failed';
    } on LoadFailure catch (e) {
      error.value = e.reason;
    }
    lastRawReply = streamingText.value;
    if (error.value == null && streamingText.value.trim().isEmpty) {
      if (!_cancelled) error.value = 'doc_error_empty_reply';
    } else if (error.value == null) {
      final parsed = parseGroundedAnswer(streamingText.value, used);
      if (!parsed.notEnoughEvidence && parsed.isBlank) {
        error.value = 'doc_error_empty_reply';
      } else {
        answer.value = parsed;
      }
    }
    streamingText.value = '';
    phase.value = AskPhase.idle;
  }

  void stop() {
    if (phase.value != AskPhase.generating) return;
    _cancelled = true;
    runtime.cancel();
  }

  String label(RetrievedPassage p) => citationLabel(
    p,
    page: 'doc_page_abbr'.tr,
    lines: 'doc_lines'.tr,
    line: 'doc_line'.tr,
  );

  @override
  void onClose() {
    if (phase.value == AskPhase.generating) runtime.cancel();
    _sub?.cancel();
    question.dispose();
    super.onClose();
  }
}
