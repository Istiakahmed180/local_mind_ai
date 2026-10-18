# Google Play Release Checklist

Verified sources (2026-10-17): Android target SDK requirements page (developer.android.com/google/play/requirements/target-sdk) and Play Console help "Understanding Google Play's AI-Generated Content policy" (support.google.com/googleplay/android-developer/answer/14094294). Re-check both before every submission — policies change.

## Build & SDK

- [ ] `targetSdk` ≥ 36 (required for new apps and updates from 2026-08-31; extension possible to 2026-11-01)
- [ ] `minSdk` 26
- [ ] Release built as Android App Bundle: `flutter build appbundle --release`
- [ ] Play App Signing enrolled; upload key stored outside the repo (`android/key.properties` is git-ignored)
- [x] 16 KB page size compatible native libraries — verified 2026-10-17 with `zipalign -c -P 16` and `llvm-readelf` (all LOAD ≥ 0x4000). Re-check after every llamadart upgrade
- [x] ABI: arm64-v8a + x86_64 only (`--target-platform android-arm64,android-x64`; `abiFilters` in Gradle)
- [ ] Version code incremented

## Policy

- [ ] **AI-Generated Content policy**: app is a text chatbot where AI interaction is central → in scope even though inference is offline.
  - [ ] In-app way to report/flag offensive output without leaving the app. **Implemented:** long-press message → Report → optional "Send to developer", which previews the exact text and opens the user's email app to support@tdevs.co. **Still to confirm:** that an email-based flow satisfies the policy (it briefly leaves the app to the email client)
  - [ ] System prompt includes safety instruction; document testing process (keep a record of red-team prompts run against each catalog model).
  - [ ] Store listing does not over-claim model quality or language support.
- [ ] **User Data / Data safety form** — answer from actual behavior:
  - Data collected: **none** (no analytics, no accounts). Model downloads send standard HTTP requests (IP address) to Hugging Face — disclose that model files are downloaded from a third-party host.
  - Data shared: none.
  - Encryption in transit: downloads use HTTPS.
  - Deletion: Settings → Clear all data; uninstall.
- [ ] Privacy policy URL hosted publicly, matching `docs/PRIVACY_POLICY.md`
- [ ] Permissions: `INTERNET`, `ACCESS_NETWORK_STATE`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_DATA_SYNC`, `POST_NOTIFICATIONS`, `RECORD_AUDIO` (optional voice input, runtime-requested on first mic tap; declare microphone use in the Data safety form as processed on-device and not collected). No storage, accessibility, package visibility or location permissions.
- [ ] Play Console foreground-service declaration for `dataSync` (user-initiated model downloads), with a short video if requested
- [ ] Content rating questionnaire (AI chatbot generating user-requested text → answer honestly; expect at least Teen)
- [ ] Target audience: not directed at children
- [ ] Large downloads: models are fetched at runtime by user action; not bundled in the AAB (keeps base size under limits)
- [ ] GPU (Vulkan): run the in-app GPU check on several real phones (at least one Adreno, one Mali, one Xclipse/PowerVR if possible) and record results; Vulkan adds ~8 MB compressed per ABI (AAB 119.3 MB incl. debug symbols). Do not declare `android.hardware.vulkan` as required — the app must install and run on CPU-only phones
- [x] OCR notices (Tesseract, Tesseract4Android, tessdata_fast, Leptonica, libjpeg, libpng) added to About → Licenses — compare against the full upstream LICENSE files before release
- [ ] Open-source notices: About → Licenses (Flutter `LicenseRegistry` + llama.cpp MIT notice + model licenses)

## Testing before production

- [ ] Internal testing track with ≥ 3 real devices (low/mid/high RAM)
- [ ] Pre-launch report clean (no crashes, no accessibility blockers)
- [ ] Airplane-mode chat verified on real device
- [ ] Closed testing requirement for new personal developer accounts (12 testers / 14 days, if applicable to the account type — verify in Play Console)
