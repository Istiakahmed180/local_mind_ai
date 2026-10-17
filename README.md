# LocalMind AI

Privacy-first, offline AI workspace for Android. Chat with language models that run entirely on the phone through llama.cpp. No account, no API keys, no cloud inference.

> Working name — change `AppConfig.appName` in `lib/app/app_config.dart` and `android:label` in the Android manifest.

## Status

See [docs/IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md) for exactly what is done, what was verified and how.

Working today: streaming offline chat, stop generation, conversation history (search/rename/delete), model catalog with verified downloads (resume, SHA-256, storage check), GGUF import, device-aware recommendations, load/speed measurements, Bengali + English UI, light/dark theme, local content reports, clear-all-data.

Not built yet: tool-using agent, document Q&A, memory, voice.

## Requirements

- Flutter 3.47+ / Dart 3.13+ (tested with 3.47.7)
- JDK 17, Android SDK 36, NDK 29
- An arm64 Android device or emulator (Android 8.0+). 32-bit devices are not supported.

The llama.cpp native libraries are downloaded by the `llamadart` build hook on first build (SHA-256 pinned by the package). No local C++ toolchain is needed.

## Build and run

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter run
```

Release bundle (64-bit only):

```bash
flutter build appbundle --release --target-platform android-arm64,android-x64
```

Release signing currently uses the debug key; configure an upload key before publishing.

## Tests

```bash
flutter analyze
```

```bash
flutter test
```

Real on-device inference (downloads ~1.1 GB of models on first run unless pushed to `/data/local/tmp` first):

```bash
flutter test integration_test/inference_test.dart -d <device-id>
```

## Architecture

See [docs/TECHNICAL_ARCHITECTURE.md](docs/TECHNICAL_ARCHITECTURE.md). In short: GetX services own the inference runtime (`lib/services/inference/`), model downloads (`lib/services/downloads/`) and device info; Drift stores conversations and installed models; features live under `lib/features/`.

## Adding a model

1. Confirm the license permits the use; add it to `docs/MODEL_AND_LICENSE_REVIEW.md`.
2. Get size and SHA-256 from `https://huggingface.co/api/models/<repo>/tree/main` (`size`, `lfs.oid`).
3. Add an entry to `assets/models/catalog.json`.
4. Run `flutter test test/models/catalog_test.dart`.
5. Test on a real device before changing any "tested" claims.

## Docs

- [Product requirements](docs/PRODUCT_REQUIREMENTS.md)
- [Technical architecture](docs/TECHNICAL_ARCHITECTURE.md)
- [Competitor analysis](docs/COMPETITOR_ANALYSIS.md)
- [Model and license review](docs/MODEL_AND_LICENSE_REVIEW.md)
- [Roadmap and verification log](docs/IMPLEMENTATION_ROADMAP.md)
- [Google Play release checklist](docs/GOOGLE_PLAY_RELEASE_CHECKLIST.md)
- [Privacy policy draft](docs/PRIVACY_POLICY.md)
