# Offline Voice — Evaluation

Researched 2026-10-18. The recommended option (Android platform APIs) **is now implemented** — see "Implementation" below. Other options were not built.

## Requirements (from the brief)

- Optional; the app must work fully without voice assets.
- On-device only; no recording in the background; visible microphone indicator.
- Bengali support may not be claimed until tested on real devices.

## Options

| Option | STT | TTS | Bengali | Size | License | Notes |
|--------|-----|-----|---------|------|---------|-------|
| **Android platform APIs** (`SpeechRecognizer.createOnDeviceSpeechRecognizer`, API 31+; `TextToSpeech`) | Yes | Yes | Depends on the phone's installed language packs/voices; not confirmed for bn-BD on-device | 0 MB in our APK | System component | On-device recognizer throws if unavailable; must check first. Older `EXTRA_PREFER_OFFLINE` is only a preference and may use the network — **do not use it**, because it could upload audio |
| **llamadart Qwen3-ASR / Qwen3-TTS** (already our runtime) | Yes | Yes | **Not listed** by either model (ASR: 30 languages + Chinese dialects; TTS: 10 languages) | Several hundred MB + projector | Apache-2.0 (verify per file) | Zero new native code, but no Bengali |
| **whisper.cpp** with a Bengali fine-tune | Yes | No | Published Bengali fine-tunes report roughly 30–60% WER on their own test sets (not comparable across papers) | 75–500 MB | MIT runtime; model licenses vary | New native dependency; accuracy for Bengali is weak at mobile sizes |
| sherpa-onnx (Bengali TTS/ASR models) | Yes | Yes | Not verified in this research | Varies | Apache-2.0 runtime; models vary | Needs separate research |

## Recommendation

1. **First version: Android platform APIs only**, behind a setting that is off by default.
   - STT through `createOnDeviceSpeechRecognizer` only (never the cloud recognizer). If the phone has no on-device recognizer for the chosen language, show "Offline voice input isn't available for this language on your phone" and do nothing else.
   - TTS through `TextToSpeech`, using only voices that report `isNetworkConnectionRequired() == false`.
   - Adds `RECORD_AUDIO` (runtime permission, asked on the first mic tap). Push-to-talk only; recording stops when the button is released or after 30 s.
   - No model download, no APK size increase.
2. **Test on real phones** (at least one Samsung and one Pixel) for bn-BD and en-US before claiming any Bengali voice support.
3. Revisit model-based voice (Qwen3-ASR for English; a Bengali Whisper or sherpa-onnx model) only if platform support turns out to be missing on target phones.

## Sources

- Qwen3-ASR language list: https://gitee.com/ahsh14/Qwen3-ASR and the technical report https://arxiv.org/abs/2601.21337v2
- Qwen3-TTS languages (third-party docs host): https://www.mintlify.com/QwenLM/Qwen3-TTS/concepts/languages
- Whisper vs Wav2Vec-BERT on Bangla: https://arxiv.org/abs/2507.01931
- On-device recognizer notes: https://hackernoon.com/testing-androids-on-device-speech-recognition-with-hindi-english-code-switching
- llamadart 0.14.0 source: `Qwen3AsrAdapter`, `Qwen3TtsAdapter`, `LiteRtLmAsrAdapter`

## Implementation (2026-10-18)

- Native: `android/app/src/main/kotlin/co/tdevs/localmind_ai/VoiceBridge.kt`. Speech input uses **only** `SpeechRecognizer.createOnDeviceSpeechRecognizer` (API 31+); on API 33+ the language is checked with `checkRecognitionSupport`. Read-aloud uses `TextToSpeech` and skips any voice with `isNetworkConnectionRequired()` or `KEY_FEATURE_NOT_INSTALLED`. Long replies are split at sentence ends (including `।`).
- Dart: `lib/services/voice/voice_service.dart` (status, 30 s cap, stop on app background, Markdown-to-speech cleanup), mic button + listening bar + "Read aloud" in chat, Voice section in Settings with per-language status and a user-confirmed "Download" for Android's own speech pack.
- Off by default. New permission: `RECORD_AUDIO`, requested only on the first mic tap.

### Verified on the `localmind_test` emulator (API 34, audio input disabled)

| Check | Result |
|-------|--------|
| Voice off | No mic button; native side not queried (unit test) |
| English status | Speech input: "downloadable" (on-device recognizer present, pack not installed). Read aloud: first "no offline voice" — correct, Google TTS only had a *server* voice — then "Ready, works offline" after Google TTS installed `en-us-x-tpf-local` |
| Bengali status | Speech input: not available for this language; read aloud: no offline Bengali voice. Shown in Bengali |
| Mic tap with no pack | Shows the reason; microphone not opened |
| Read aloud | Engine log: `Synthesis request … name en-us-x-tpf-local`, `TTS dispatch: en-us-x-tpf-seanet-embedded` (on-device). "Reading aloud… Stop" bar shown and cleared when done |
| Speech pack download | Request accepted, but this emulator image queued nothing; **live speech recognition was not tested** |

Real phones (with Google speech packs and a microphone) are needed to test speech input in English and Bengali.
