# LocalMind AI — Product Requirements

> Working name. The display name lives in `lib/app/app_config.dart` (`AppConfig.appName`) and `android/app/src/main/AndroidManifest.xml` (`android:label`).

## 1. Vision

A privacy-first, local-first AI workspace for Android. All AI inference runs on the device. No account, no API keys, no paid inference, no backend. The network is used only to download model files the user explicitly chooses, from a host shown before the download starts.

## 2. Target users

- Privacy-conscious users who do not want prompts or documents to leave the phone.
- Students and professionals in Bangladesh and the Bengali-speaking diaspora who want a Bengali + English interface.
- Users with intermittent or expensive connectivity who need AI features offline.
- Owners of mid-range Android phones (roughly 4–8 GB RAM) who need honest guidance about what their device can run.

## 3. Principles

1. **Local by default** — inference, chat history, documents, indexes and memory stay in app-private storage.
2. **Honest** — no fabricated benchmarks, no claims that a model works on a device until measured there, no "AI remembers you" unless a memory entry was actually stored.
3. **Bounded** — the agent can only call registered tools with validated arguments, within step limits, and asks before anything that writes or reads user-selected files.
4. **Transparent network use** — the UI always shows whether the app is offline and labels every network operation.
5. **Device-aware** — recommend the smallest suitable model first; the user can always override.

## 4. Functional requirements

| ID | Requirement | Priority | Milestone |
|----|-------------|----------|-----------|
| F1 | Chat with a locally loaded GGUF model, streamed token by token | P0 | 3 |
| F2 | Stop generation at any time | P0 | 3 |
| F3 | Persistent conversation history: list, rename, delete, search | P0 | 2–3 |
| F4 | Manifest-based model catalog with size, license, languages, RAM guidance | P0 | 3–4 |
| F5 | Download with progress, cancel, resume (HTTP Range), SHA-256 verification, storage check | P0 | 3–4 |
| F6 | Import a local `.gguf` file (validated: magic header, size, extension) | P1 | 4 |
| F7 | Delete model with confirmation; active and last-used model tracking | P0 | 4 |
| F8 | Device info + recommendation (RAM total, Android memory class, free storage) | P1 | 4 |
| F9 | Performance metrics: load time, time-to-first-token, tokens/sec | P1 | 3–4 |
| F10 | Generation settings: temperature, top-p, max tokens, context length | P0 | 3 |
| F11 | Bounded agent with tool registry, approval flow, step limits, cancel | P1 | 5 |
| F12 | Document library (TXT, MD, text PDF): import, chunk, index, retrieve with citations | P1 | 6 |
| F13 | User-controlled memory entries: add, edit, delete, opt-in use in prompts | P2 | 7 |
| F14 | Bengali and English UI, language switch | P0 | 2 |
| F15 | Clear-all-data | P0 | 2 |
| F16 | Report a problematic AI response (local log + optional user-initiated email) | P0 (Play policy) | 2–3 |
| F17 | Optional on-device voice | P3 | 7 (evaluate only) |

## 5. Non-functional requirements

- UI stays responsive during inference (inference runs in a worker isolate inside the runtime library).
- At most one LLM loaded at a time.
- App works fully in airplane mode once a model is downloaded.
- No analytics SDKs, crash reporters or ad SDKs.
- Minimum permissions: `INTERNET` (model downloads only). Files are accessed through the system picker; no broad storage permission.
- Min SDK 26 (Android 8.0). Target the Play-required API level (36 as of 2026-08-31).
- arm64-v8a is the supported ABI for inference.

## 6. Out of scope for v1

- Cloud inference of any kind, accounts, sync.
- OCR / scanned PDFs.
- Image generation, vision models.
- Arbitrary code, shell or SQL execution by the agent.
- Background or continuous recording.

## 7. Success criteria for v1

- A user on a supported device can download the starter model, go offline, and complete a multi-turn conversation.
- Every claim in the UI about model size, license and language support matches `docs/MODEL_AND_LICENSE_REVIEW.md`.
- All automated tests pass; release AAB builds.
