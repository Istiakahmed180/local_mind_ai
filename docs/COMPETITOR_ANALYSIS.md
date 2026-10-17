# Competitor Analysis

Research date: 2026-10-17. Figures are copied from the public Google Play listings viewed on that date (Bangladesh storefront, English). Download counts are Play's bucketed ranges, not exact numbers. Anything not visible on the listing is marked "not verified".

## Apps reviewed

| App | Developer | Play downloads | Rating | Last updated | Data safety (as declared) |
|-----|-----------|----------------|--------|--------------|---------------------------|
| PocketPal AI (`com.pocketpalai`) | LLM Ventures | 1M+ | 3.4 (≈3.5K reviews) | 2026-10-05 | Declares it *may* collect personal and financial info and *may* share personal info (likely related to in-app purchases of "Pals") |
| Google AI Edge Gallery (`com.google.ai.edge.gallery`) | Research at Google | 1M+ | not shown | not captured | not captured |
| SmolChat (`io.shubham0204.smollmandroid`) | Shubham Panchal | 10K+ | not shown | 2026-06-21 | No data collected, no data shared |

Other apps found in search but **not verified on Play** during this research: MLC Chat (one guide says it is sideload-only), ChatterUI, Maid, Layla, Apollo AI.

## Observed features

**PocketPal AI** — open source; GGUF models from Hugging Face; offline; parameter control (temperature, context, system prompt); built-in benchmarking; "Pals" personas sold in-app. Listing states 6 GB+ RAM is needed for smaller models. No document Q&A or tool-using agent mentioned on the listing.

**Google AI Edge Gallery** — LiteRT `.task`/`.litertlm` models (Gemma family); Agent Skills (Wikipedia grounding, maps, skills loaded from URL); thinking mode; on-device media search; audio transcription; Prompt Lab; "Mobile Actions" via FunctionGemma 270M. Third-party coverage says it targets high-end devices and does not reliably support emulators (not independently verified). It is positioned as experimental/showcase.

**SmolChat** — GGUF via llama.cpp; per-chat model selection; temperature/min-p settings; saved system prompts; home-screen chat shortcuts. Small, privacy-clean, no documents or tools listed.

## Gaps we can address (with honest caveats)

| Gap | Evidence | Our response |
|-----|----------|--------------|
| Bengali-first interface | None of the three listings mention Bengali UI | Full Bengali + English UI; per-model Bengali support marked "vendor claims" vs "tested on device" |
| Grounded answers over the user's own documents with citations | Not listed by PocketPal or SmolChat; Edge Gallery offers media search, not document Q&A | Document workspace with page-level citations and "insufficient evidence" responses |
| Device guidance for mid-range phones | PocketPal states 6 GB+ RAM; no listing gives per-device recommendations before download | Device-aware recommendation that starts with sub-1 GB models, shows RAM estimate as a range |
| Approval-gated local agent | Edge Gallery has Agent Skills, some using network sources (Wikipedia, URLs) | Offline-only tools, explicit approval for file access/writes, visible step history. **Not unique** — Edge Gallery already ships agents |
| Clean data-safety story | PocketPal declares possible collection of personal/financial info | No analytics, no accounts, no purchases in v1 |

We do **not** claim to be better overall than any of these apps. Edge Gallery has Google's model optimisation and NPU access; PocketPal has a large model ecosystem and 1M+ users.
