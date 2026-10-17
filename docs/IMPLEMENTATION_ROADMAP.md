# Implementation Roadmap

Status legend: ✅ done and verified · 🟡 partially done · ⬜ not started

| # | Milestone | Status | Notes |
|---|-----------|--------|-------|
| 1 | Repo audit, research, requirements, runtime decision, license review, plan | ✅ | All six docs written |
| 2 | Flutter foundation, design system, navigation, persistence, functional UI | ✅ | Onboarding, home, chat, history, model library/details, settings, privacy, reports, about. Agent/Documents screens state plainly that they are not built yet |
| 3 | One working local model + streaming chat | ✅ | Verified on an arm64 emulator, offline (airplane mode) |
| 4 | Model manager, verified downloads, device recommendations, switching | 🟡 | Download/resume/cancel/SHA-256/storage check/import/delete/active model/recommendations done. Missing: background download (foreground service), benchmark screen, real-device measurements |
| 5 | Safe tool-using agent | ⬜ | |
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

## Bugs found and fixed during verification

- Catalog asset was missing from `pubspec.yaml`, so the app hung on the splash screen. Fixed; a unit test now guards it.
- Fit/language labels overflowed on narrow screens in the model library. Changed to a wrapping layout.
- "Bengali: Bengali: …" duplicated label on model details. Renamed the row to "Language support".
- Vulkan backend (≈26 MB per ABI) was bundled though unused; now excluded. 32-bit Flutter code removed via `--target-platform`.

## Remaining work (next sessions)

1. **Agent engine (M5)**: tool registry with schemas, validation, approval UI, step/time limits, grammar-constrained JSON tool calls.
2. **Documents (M6)**: SAF picker, TXT/MD/PDF text extraction (PDFium-based, permissive license), chunking, embeddings (llamadart `embed`) + keyword fallback, cited answers.
3. **Memory (M7)**: opt-in memory entries table, review/edit/delete, injection into the system prompt.
4. **Real-device matrix**: at least one low (≤4 GB), mid (6–8 GB) and high (≥12 GB) phone; record load time, TTFT, tok/s, thermal behaviour.
5. **Downloads in background**: foreground service with notification so large downloads survive leaving the app.
6. **Bengali**: test Gemma 3 1B and Qwen3 1.7B; native-speaker review of UI strings.
7. **Play compliance**: decide how reports reach the developer (see checklist); host privacy policy; Data safety form.
8. **Vulkan GPU path**: re-enable behind a setting once tested on Adreno/Mali devices.
