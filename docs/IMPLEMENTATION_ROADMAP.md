# Implementation Roadmap

Status legend: ✅ done and verified · 🟡 partially done · ⬜ not started

| # | Milestone | Status | Notes |
|---|-----------|--------|-------|
| 1 | Repo audit, research, requirements, runtime decision, license review, plan | ✅ | All six docs written |
| 2 | Flutter foundation, design system, navigation, persistence, functional UI | ✅ | Onboarding, home, chat, history, model library/details, settings, privacy, reports, about. Agent/Documents screens state plainly that they are not built yet |
| 3 | One working local model + streaming chat | ✅ | Verified on an arm64 emulator, offline (airplane mode) |
| 4 | Model manager, verified downloads, device recommendations, switching | 🟡 | Download/resume/cancel/SHA-256/storage check/import/delete/active model/recommendations done. Missing: background download (foreground service), benchmark screen, real-device measurements |
| 5 | Safe tool-using agent | 🟡 | Orchestrator, 6 tools, approvals, limits, grammar-constrained calls done; calculator/date tasks verified with Qwen2.5 0.5B on the emulator. Approval dialogs and file tools not yet exercised by hand on a device; no document-search tool yet |
| 6 | Local documents, retrieval, source-grounded answers | ⬜ | |
| 7 | Memory, Bengali/English polish, optional voice | 🟡 | Full bn/en UI done (needs native-speaker review). Memory and voice not started |
| 8 | Security review, performance, real-device testing, Play release prep | 🟡 | Release AAB builds, 16 KB alignment verified. No real-device testing yet |

## Environment (audited 2026-10-17)

- macOS (Apple M4, 16 GB)
- Flutter 3.47.7 stable / Dart 3.13.5, JDK 17
- Android SDK platforms 31–37, build-tools 34–36.1, NDK 27/28/29
- Test device: dedicated AVD `localmind_test` (Android 14 / API 34, arm64-v8a, 3 GB RAM, 4 GB data), run on port 5556
- **No physical Android device was available.** All on-device numbers below are from the emulator running on an Apple M4 host and are not representative of phones.

## Verification log (2026-10-17)

Only commands that were actually executed are listed.

| Check | Command / method | Result |
|-------|------------------|--------|
| Static analysis | `flutter analyze` | No issues |
| Unit tests | `flutter test` | 49 passed |
| On-device inference | `flutter test integration_test/inference_test.dart -d emulator-5556` | All passed (English answer contains "Paris", cancel stops early, unload works) |
| Manual offline chat | App UI on emulator with airplane mode on | Model loaded (4.4 s) and answered; multi-turn context kept; Stop saved partial reply as "Stopped"; history survived app restart |
| In-app download | Model library → Qwen2.5 0.5B → Download | 491,400,032 bytes, SHA-256 verified on device, moved into place |
| Release bundle | `flutter build appbundle --release --target-platform android-arm64,android-x64` | Built, 71.7 MB (includes debug-symbol metadata) |
| Release APK size | `flutter build apk --release --target-platform android-arm64` | 45.6 MB |
| 16 KB page size | `zipalign -c -P 16 -v 4` + `llvm-readelf -lW` on every `.so` | Pass; all LOAD segments aligned ≥ 0x4000 |

### Emulator measurements (Qwen2.5 0.5B Q4_K_M, context 1024, CPU)

Noisy: one run during a concurrent download measured 5 tok/s; repeated runs afterwards measured the figures below.

| Metric | Range observed |
|--------|----------------|
| Load time | 0.9 – 4.4 s |
| Time to first token | 150 – 800 ms |
| Decode speed | 41 – 70 tok/s |

### Bengali quality check

Prompt: "বাংলাদেশের রাজধানীর নাম কী? এক বাক্যে বাংলায় উত্তর দিন।" (temperature 0)

| Model | Output summary | Correct (ঢাকা)? |
|-------|----------------|-----------------|
| Qwen2.5 0.5B Q4_K_M | Bengali text that restates the question, no answer | No |
| Qwen3 0.6B Q8_0 | Grammatical Bengali, names a wrong city | No |

Conclusion: no catalog model is marked "Bengali: tested". Larger models (Gemma 3 1B, Qwen3 1.7B) have not been tested yet.

## Agent (M5) — verified 2026-10-18

Design (code in `lib/services/agent/`, UI in `lib/features/agent/`):

- `AgentOrchestrator` with explicit states `idle → planning → (awaitingApproval →) runningTool → processingResult → planning … → completed | failed | cancelled`. Illegal transitions throw; terminal states have no exits.
- Each model reply is decoded under a JSON-schema grammar (`oneOf` over `{"tool": <const>, "args": <tool schema>}` plus `final_answer`) via llamadart `responseFormat`. `InferenceRuntime.generate` gained an optional `jsonSchema`.
- Fallback for small models: if the backend rejects the schema, decoding continues unconstrained, and a tolerant parser accepts code fences, `<tool_call>` tags, `{"name","arguments"}` and `{"answer"}`. Invalid replies get 2 corrective retries, then the run fails and the UI shows the raw output marked "unverified". Plain text is never treated as an answer.
- Every call is re-validated against the tool's schema (types, required, no extra keys, lengths, patterns) before it runs. Limits: 6 model replies, 256 tokens / 2 KB per reply, 2 KB tool output, 4 KB answer, per-tool timeouts, cancellation during generation, approval or a tool run.
- Tools: calculator (own recursive-descent parser, no eval), current date/time, read a user-picked file (approval, system picker, .txt/.md/.csv/.json/.log, 256 KB cap, UTF-8 only), write .txt/.md (approval, new files only, directly inside app-private `agent_workspace/`, 64 KB cap), summarize text (runs the loaded model), search chat history (only when the user turns on "Allow searching chat history", off by default; parameterized LIKE query). A tool denied once is auto-denied for the rest of the run. There is no shell, eval, SQL, intent or network tool.

| Check | Command / method | Result |
|-------|------------------|--------|
| Static analysis | `flutter analyze` | No issues |
| Unit tests | `flutter test` | 133 passed (includes 37 new agent tests: expression parser, schema validation, unsafe file names, write/read limits, history opt-in, state transitions, approval allow/deny, cancel during approval/tool/generation, step limit, invalid-output retries, grammar fallback, output truncation). The count also includes M6 tests from a parallel session |
| Real model | `flutter test integration_test/agent_test.dart -d emulator-5556` (Qwen2.5 0.5B Q4_K_M, ctx 2048) | Passed. "What is 23 * 47 + 12?" → `calculator {"expression":"23 * 47 + 12"}` → 1093 → final answer "1093" (2 replies, 2.2 s). Also logged: √144×3 → `sqrt(144)*3` → 36 → "36"; "What day of the week is it today?" → `current_datetime` → "Sunday" (correct for the device clock). Grammar-constrained decoding worked; no fallback needed. Cancel against the real engine ended in `cancelled` |

Caveats: three tasks, temperature 0, one model, emulator only — this does not show the agent is reliable on harder or multi-step tasks. The approval dialogs, file picker, workspace list and the agent screen itself were not tested by hand on the emulator. The `localmind_test` AVD had been deleted and was recreated on 2026-10-18 (API 34 google_apis arm64-v8a, 3 GB RAM; `/data` reports 5.8 GB).

## Bugs found and fixed during verification

- Catalog asset was missing from `pubspec.yaml`, so the app hung on the splash screen. Fixed; a unit test now guards it.
- Fit/language labels overflowed on narrow screens in the model library. Changed to a wrapping layout.
- "Bengali: Bengali: …" duplicated label on model details. Renamed the row to "Language support".
- Vulkan backend (≈26 MB per ABI) was bundled though unused; now excluded. 32-bit Flutter code removed via `--target-platform`.

## Remaining work (next sessions)

1. **Agent (M5) follow-ups**: hand-test approval dialogs and file read/write on a device; add a document-search tool on top of M6 `DocumentService.search`; measure tool-call success rate across catalog models.
2. **Documents (M6)**: SAF picker, TXT/MD/PDF text extraction (PDFium-based, permissive license), chunking, embeddings (llamadart `embed`) + keyword fallback, cited answers.
3. **Memory (M7)**: opt-in memory entries table, review/edit/delete, injection into the system prompt.
4. **Real-device matrix**: at least one low (≤4 GB), mid (6–8 GB) and high (≥12 GB) phone; record load time, TTFT, tok/s, thermal behaviour.
5. **Downloads in background**: foreground service with notification so large downloads survive leaving the app.
6. **Bengali**: test Gemma 3 1B and Qwen3 1.7B; native-speaker review of UI strings.
7. **Play compliance**: decide how reports reach the developer (see checklist); host privacy policy; Data safety form.
8. **Vulkan GPU path**: re-enable behind a setting once tested on Adreno/Mali devices.
