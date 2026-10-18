# LocalMind AI — design system

Direction chosen with the owner (2026-10-18): **calm and premium** — a privacy app should feel quiet and trustworthy, not flashy.

## Foundations (`lib/app/theme.dart`)

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| primary (teal) | `#0E6E66` | `#4FD1BF` | Actions, selection, links |
| secondary (indigo) | `#4652B3` | `#A9B2FF` | Accent, gradient end |
| surface (page) | `#F7F8FA` | `#0B0F15` | Scaffold background |
| surfaceContainerLow (cards) | `#FFFFFF` | `#121821` | Cards, sheets, dialogs, nav bar |
| hairline | `#E3E7EE` | `#242C38` | 1-px card borders and dividers (no shadows) |
| onSurfaceVariant | `#5B6575` | `#98A2B3` | Captions, metadata |
| brand gradient | `#0E6E66 → #3B4FA8` | same | Logo, "New chat" tile, icon background |
| success / warning | `#15803D` / `#B45309` | `#6EE7A0` / `#F7B867` | Status pills, notices (`AppColors` extension) |

- **Type:** system Roboto with a tighter scale (headlines w600, negative tracking; body 1.5 line height). Bengali falls back to Noto Sans Bengali, which ships with Android — no font files are downloaded or bundled.
- **Spacing:** 4-pt scale (`AppSpacing.xs…xxl`), page gutter 20.
- **Radius:** 10 / 14 / 20 / 28 (`AppRadius`): chips, buttons/inputs, cards, sheets/dialogs.
- **Elevation:** none. Depth comes from surface tone + hairline borders.
- **Buttons:** 48 px min height, 14 radius. Dark mode uses `primaryContainer` for the FAB so large areas stay calm.

## Components (`lib/core/widgets/`)

- `BrandLogo` / `LogoPainter` (`brand.dart`) — the mark: a ring (the phone) around a core dot (the model on the device) with a spark where the ring opens. Drawn in code; the same painter renders the launcher icon and splash.
- `IconBadge` — tinted rounded square around an icon.
- `SectionCard` (optional title + icon), `SectionLabel` (group heading), `InfoRow` (label/value).
- `StatusPill` (neutral / primary / success / warning / error) and `NoticeText` (inline notice with icon).
- `MessageState` — empty/error states (safe inside lists too).
- `SheetHeader`, `StatRow`, `ComposerBar` / `composerDecoration`, `dangerButtonStyle`.

## Screens redesigned

Onboarding (concentric hero, pill page dots, full-width CTA), Home (brand header, connectivity pill, active-model gradient card with status pill, gradient "New chat" tile, equal-height feature tiles, recent chats with relative times), Chats (search + card rows), Model library (device stats card, model cards with status pills; active model outlined in primary), Model details (hero with key numbers and pills, action first, then measurements/benchmark/GPU, then full info), Chat (teal user bubbles with a tail corner, assistant replies in hairline cards with the logo avatar, animated typing dots, starter prompts on an empty chat, pill composer), Settings (grouped cards, compact sliders with value pills), Agent (warning notice, per-tool icons, "asks first" pills). Second pass (same day): Documents (stats card, file cards, answer card with numbered source chips that open the passage, shared composer), meaning-search and OCR cards and their sheets (`SheetHeader`), Memory (switch card with explainer, memory cards with dates), Benchmark (workload pills, tinted progress panel, result card led by a large tok/s number), About (logo hero, licence list with pills), Privacy (headline banner, icon sections), Reports (reason pills, send action), agent run view (step badges, code blocks, outlined answer/failure cards), approval dialog, chat model picker and message menu. Destructive confirm buttons are red (`dangerButtonStyle`). Chat, documents and agent share one input bar (`core/widgets/composer.dart`).

## App icon and splash

`flutter test tool/brand_assets_test.dart` renders, from `LogoPainter`:
- legacy `mipmap-*/ic_launcher.png` (48 dp), adaptive icon foreground + **monochrome** (themed icons) `mipmap-*/ic_launcher_foreground.png` with a gradient `drawable/ic_launcher_background.xml` (`mipmap-anydpi-v26/ic_launcher.xml`);
- Android 12+ splash `drawable-*/splash_icon.png` (`values-v31`, `values-night-v31` styles) and the pre-12 splash `drawable-*/splash_logo.png` in `launch_background.xml`, on the app's own background colour (light `#F7F8FA`, dark `#0B0F15`);
- the 512 px Play Store icon `assets/brand/play_store_icon_512.png` (not bundled).

## Verified

On the `localmind_test` emulator (1080×2400): onboarding, home, chats, models, model details, chat (with a real SmolLM2 reply), agent, documents and settings in light; home and chat in dark; home and settings in Bengali; splash and launcher (themed icon). Screenshots: `docs/design/screens/` (`00_before_home.png` is the old design). `test/core/brand_test.dart` renders the logo and shared widgets in light and dark at 360 px without layout errors; `flutter test` → 235 passed.

Second pass checked on the emulator in Bengali: Documents (empty, OCR sheet, with a file, an answer), Benchmark (running and a real result), Memory, Privacy, Reports, About. Not checked by hand: the agent run view, the approval dialog and the meaning-search sheet (covered only by `flutter analyze` and existing tests).

Not verified: real phones, very small (≤ 320 dp) or large screens/tablets, font scaling above 1.3×, TalkBack with the new layouts, and the screens listed above as theme-only.
