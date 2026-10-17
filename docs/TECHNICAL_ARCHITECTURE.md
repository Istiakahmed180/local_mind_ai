# Technical Architecture

## Runtime decision

| Option | Verdict | Reason |
|--------|---------|--------|
| **llamadart 0.14.0** (llama.cpp via FFI) | **Chosen** | MIT; actively maintained (released 2026-10); prebuilt, SHA-256-pinned Android arm64/x64 natives (no local NDK build needed); streaming `create()` API; `cancelGeneration()`; `ModelParams.contextSize`, threads, GPU layers; usage stats incl. time-to-first-token; embeddings API for later RAG; inference runs in a worker isolate |
| llama_flutter_android 0.2.6 | Runner-up | MIT, Android-only, EventChannel streaming, Vulkan; fewer releases, filename-based template detection |
| flutter_llama / llamafu / llm_llamacpp | Rejected | Older or 0.1.x releases with limited maintenance signals |
| Custom JNI wrapper around llama.cpp | Deferred | Full control but large build/maintenance cost; only ~13 GB free disk on the dev machine |
| MediaPipe / LiteRT-LM | Deferred | Good NPU/GPU paths but models limited to `.task`/`.litertlm` bundles; GGUF is the broader open ecosystem. llamadart can add LiteRT-LM later without app-level changes |

The runtime is wrapped behind `InferenceRuntime` (`lib/services/inference/inference_runtime.dart`) so it can be swapped, and so unit tests use a fake. **The fake is used only in tests.**

## Layers

```
lib/
  app/            routes, bindings, theme, translations, AppConfig
  core/           utils (formatting, GGUF header check), widgets (empty/error states)
  data/local/     Drift database (conversations, messages, models, documents, memory)
  domain/         plain entities + enums (no Flutter imports)
  services/
    inference/    InferenceRuntime interface, LlamadartRuntime, prompt builder, context budgeting
    downloads/    ModelDownloader (HTTP Range resume, SHA-256, storage check)
    device/       DeviceInfoService (Android MethodChannel: RAM, memoryClass, storage, ABIs)
    connectivity/ network status (lightweight, no plugin)
  features/
    onboarding/ home/ chat/ models/ agent/ documents/ history/ settings/ memory/ about/
      each: controller (GetX) + view (+ widgets)
```

Data flow for chat:

```
ChatView → ChatController ─┬─ ConversationRepository (Drift)
                           └─ ModelRuntimeService ── InferenceRuntime (llamadart, worker isolate)
                                     │                 └─ llama.cpp natives (libllama, ggml)
                                     └─ ModelRepository (installed models, active model)
```

## Key decisions

- **One loaded model.** `ModelRuntimeService` owns the only `InferenceRuntime` instance; loading a new model unloads the previous one first.
- **Model files** live in `getApplicationSupportDirectory()/models/` (app-private, excluded from backups via `android:allowBackup="false"` + data extraction rules). Partial downloads use `<file>.part` and resume with `Range` headers.
- **Load gate.** A model is loadable only if: file exists, size matches manifest (or is an imported file that passed header check), `GGUF` magic is present, and (for catalog downloads) SHA-256 was verified at download completion and recorded in the DB.
- **Prompt building** uses the chat template embedded in the GGUF (llama.cpp Jinja engine in llamadart). The app sends structured messages, never hand-formats special tokens.
- **Context budgeting.** `ContextBudget` keeps the system prompt + latest user message and drops oldest turns until the estimated token count fits `contextSize - maxTokens`. Token estimation uses the runtime tokenizer when a model is loaded; a conservative char-based heuristic otherwise.
- **Agent safety.** Tool calls are parsed from strict JSON (grammar-constrained output where the runtime supports it); tool names are matched against a registry; arguments are schema-validated; tools that read user files or write files require approval; max steps, max output bytes and per-tool timeouts are enforced. No shell, eval, SQL or intent-launching tools exist.
- **Documents** are untrusted data: retrieved passages are inserted inside a clearly delimited block and the system prompt instructs the model to treat them as reference text only. Document content can never trigger a tool call directly; only the user's request can start an agent run.
- **Network.** Only `ModelDownloader` uses the network. The `INTERNET` permission exists for model downloads. No other HTTP client is constructed in the app.

## Adding a new model

1. Find the GGUF on the publisher's Hugging Face repo; confirm license.
2. Get size and SHA-256: `curl -s https://huggingface.co/api/models/<repo>/tree/main` (`size`, `lfs.oid`).
3. Add an entry to `assets/models/catalog.json` (see existing entries for required fields).
4. Add a row to `docs/MODEL_AND_LICENSE_REVIEW.md`.
5. Run `flutter test test/models/catalog_test.dart` — it validates every entry.
6. Test on a real device before marking `"tested": true`.
