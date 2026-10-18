# Offline Voice — Evaluation

Researched 2026-10-18. Voice is **not implemented**. This note records the options and a recommendation; nothing below has been tested on a device.

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
