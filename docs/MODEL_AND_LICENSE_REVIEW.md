# Model and License Review

Reviewed 2026-10-17. Sizes and SHA-256 values are taken from the Hugging Face API (`/api/models/<repo>/tree/main`, `lfs.oid`). The app **never redistributes weights**: it downloads directly from the publisher's Hugging Face repository the user sees before downloading. Hosts are configured in `assets/models/catalog.json` and can be changed without code changes.

## Runtime

| Component | Version | License | Notes |
|-----------|---------|---------|-------|
| llamadart (Dart/Flutter bindings) | 0.14.0 | MIT (© 2024 Jhin Lee) | Pinned prebuilt llama.cpp natives; the build hook verifies archive SHA-256 before use |
| llama.cpp native runtime (via `leehack/llamadart-native` `v0.7.0`) | pinned by llamadart | MIT (llama.cpp / ggml) | Bundled as shared libraries in the APK; attribution in About → Licenses |
| GetX | 4.7.3 | MIT | |
| Drift / sqlite3 | 2.35.2 / 3.x | MIT / public domain (SQLite) | |
| pdfrx (PDF text extraction, M6) | 2.6.5 (with pdfrx_engine 0.6.1, pdfium_flutter / pdfium_dart 0.3.1) | MIT (© 2018 Takashi Kawasaki) | Only `PdfDocument.openFile` + `PdfPage.loadText()` are used. pdfrx_engine also contains an `openUri` HTTP loader; the app never calls it (a unit test checks the documents code does not reference it) |
| PDFium native library | `chromium/7811` build from `bblanchon/pdfium-binaries` | BSD-3-Clause (© 2014 The PDFium Authors); the binaries project is MIT | Downloaded by the `pdfium_dart` build hook **at build time** and bundled as `libpdfium.so`; no download at runtime. Notice added to About → Licenses. PDFium statically includes third-party code (FreeType, libjpeg-turbo, OpenJPEG, lcms2, zlib, Abseil, …); the full notice set from the binary release must be collected before Play release |
| pdfrx transitive deps | rxdart 0.28, synchronized 3.4, image 4.8, archive 4.0, vector_math 2.x, url_launcher 6.3 | Apache-2.0 / MIT / MIT / MIT / BSD-3 / BSD-3 | Dart package licenses appear in About → Licenses automatically |

LiteRT-LM and stable-diffusion runtimes are **excluded** (`llamadart_native_runtimes: [llama_cpp]`), and on Android only the CPU backend is bundled (`llamadart_native_backends.platforms.android: [cpu]`); the Vulkan module is left out until it is tested on real GPUs.

## Model catalog

| Model | File | Size (bytes) | License | Bengali | Status |
|-------|------|--------------|---------|---------|--------|
| Qwen2.5 0.5B Instruct Q4_K_M | `qwen2.5-0.5b-instruct-q4_k_m.gguf` | 491,400,032 | Apache-2.0 | Not listed by vendor (29+ languages "and more"); emulator test: did not answer a simple Bengali question | **Starter.** Download, load and chat verified on arm64 emulator (offline) |
| Qwen3 0.6B Q8_0 | `Qwen3-0.6B-Q8_0.gguf` | 639,446,688 | Apache-2.0 | Vendor claims Bengali among 119 languages; emulator test: grammatical but factually wrong | Catalog; loads and generates on emulator |
| SmolLM2 360M Instruct Q8_0 | `smollm2-360m-instruct-q8_0.gguf` | 386,404,992 | Apache-2.0 | English-focused | Catalog; low-resource option |
| Qwen2.5 1.5B Instruct Q4_K_M | `qwen2.5-1.5b-instruct-q4_k_m.gguf` | 1,117,320,736 | Apache-2.0 | Not listed by vendor | Catalog |
| Gemma 3 1B IT Q4_K_M (ggml-org) | `gemma-3-1b-it-Q4_K_M.gguf` | 806,058,240 | Gemma Terms of Use | Vendor claims 140+ languages | Catalog; user must accept Gemma Terms in-app before download |
| Qwen3 1.7B Q8_0 | `Qwen3-1.7B-Q8_0.gguf` | 1,834,426,016 | Apache-2.0 | Vendor claims Bengali | Catalog; high-memory devices |

### License notes

- **Apache-2.0 models**: downloading from the publisher's repo is permitted; we display the license and link. We do not modify or re-host weights.
- **Gemma**: Gemma Terms of Use and the Gemma Prohibited Use Policy apply to the user. The app shows the terms link and requires an explicit acceptance tap before the download. We do not redistribute the file. If we ever host Gemma weights ourselves, the redistribution clauses (passing on use restrictions, notice file) must be reviewed by counsel first.
- Llama-family models are deliberately excluded from v1 because the Llama community license has attribution/naming and acceptable-use requirements we have not reviewed.

### RAM guidance

File size is **not** peak RAM. Rough estimate used in the app: `weights + KV cache (context-dependent) + ~150–300 MB runtime overhead`, shown as a range, and labelled "estimate". Only empirical measurements on a device are shown as measured values.

### Untrusted assets

GGUF files are treated as untrusted input. The app checks: catalog SHA-256 (downloads), `GGUF` magic bytes, minimum size, and free storage. Parsing is done by llama.cpp; historic GGUF parser CVEs exist in llama.cpp, so the runtime version must be kept current and imported files are labelled "unverified source".

### Document Q&A (M6)

- No OCR: PDFium reads the PDF text layer only. Scanned or image-only PDFs are rejected with an explicit message; the app does not claim to support them.
- Semantic (embedding) retrieval is **not implemented**. llamadart can embed, but it would need a second engine instance holding an embedding model next to the chat model, or swapping models per question; neither was built or measured. No embedding model is in the catalog.
- Keyword search uses SQLite FTS5 (`unicode61` tokenizer) from the sqlite3 build drift already ships, with a LIKE fallback if FTS5 is missing.

## Test record

See `docs/IMPLEMENTATION_ROADMAP.md` → "Verification log" for exactly what was executed and on which device.
