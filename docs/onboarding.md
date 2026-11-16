# Onboarding (first launch): instructions for Claude Code

_16 Nov 2026 · written against commit `a5089c1` (Phase 12) · design:
https://claude.ai/artifact/VsWWKkWyBC1Mp2cQSuXnRK ("run4share — Onboarding",
4 pages + where it ends)_

Read `CLAUDE.md` first; every rule there still holds (Material only through
`lib/app/material.dart`, Lucide icons via `AppIcons`, five languages, tests,
an Android build Francisco confirms before committing).

## What to build

A four-page introduction shown **once**, on first launch, before Home. It
explains what the app does and what Pro adds, then hands over to Home, where
the existing "no source connected" state does the connecting.

| Page | Title (en) | Body (en) | Art |
|---|---|---|---|
| 1 | Your run. Your story. | Turn every workout into an image worth sharing: your photo, your stats, your style. | Photo + **Big Distance** theme + **pace chart** sticker at the top |
| 2 | Ready the moment you finish | Connect once and your latest workouts are waiting, with their route, splits and charts. | Photo + **Inline Top** theme + **route** sticker; under the body, source chips |
| 3 | Full image or just the sticker | Save to Photos, post to Instagram, or export only the sticker on a clear background to paste anywhere. | Two halves: full image / sticker only on a checkerboard |
| 4 | Pay once. Keep it forever. | Charts, route styles, Pro themes and stickers, and no watermark. One payment, no subscription. | Photo + **Receipt** theme + **Record** label + **heart-rate** chart |

Controls:
- Top bar: "run4share" wordmark left; **Skip** right on pages 1–3, a **PRO** badge on page 4.
- Bottom, fixed: page dots (active one 24×8 in brand blue, others 8×8 neutral20), then a 56 px brand-blue button: **Next** on pages 1–3, **Get started** on page 4.
- Page 4 only, under the button: a text button **See what's in Pro · {price}** (price from the store offer; without an offer, just "See what's in Pro").
- Swipe between pages as well as Next.

## Decisions taken in this spec (change them here if Francisco disagrees)

1. **Who sees it:** only a true first launch. Mark it as done, without showing it, when the database already has any activity or creation, or a Strava session exists. That way people updating the app never see it.
2. **Where it ends:** Skip and Get started both go to Home (`AppRoutes.activities`) with `context.go`. "See what's in Pro" goes to Home, then pushes `AppRoutes.pro`, so Back from Pro lands on Home.
3. **Replay:** Settings › About › **Show introduction again** opens it with `replay: true`. Finishing then pops back to Settings instead of going Home.
4. **Art is live, not pictures of stickers:** each page's art is a `StoryCanvas` drawn with real themes and extra stickers from an onboarding sample activity. Numbers, units (km/mi) and labels therefore follow the user's settings and language. `watermark: false`.
5. **Photos:** Francisco supplies four of his own photos (portrait, at least 1080 px wide) as `assets/onboarding/page1.jpg` … `page4.jpg`. Until they exist, fall back to a flat neutral colour per page (no gradients), so the build never breaks. Don't use stock or competitor images.
6. **Sources on page 2:** chips "Strava", the phone's own health source (`healthSourceFor(platform)`: Apple Health on iPhone, Health Connect on Android) and "Or add it by hand". Text chips, no logos (Strava's brand rules).
7. **No analytics** (privacy promise in `docs/privacy-policy.md`).

## Avoid what goes wrong in Fitshot's onboarding

In Fitshot's screenshots the body text runs under the page dots and the Start button on a normal iPhone. That is the main layout rule here:

- The bottom bar (dots + button, plus the Pro text button on page 4) is fixed and sits inside `SafeArea`.
- Between the top bar and the bottom bar, use a `LayoutBuilder`. The art takes `clamp(height × 0.48, 240, 420)` and keeps the 4:5 feed ratio, centred. Title and body go in an `Expanded` → `SingleChildScrollView`, so with large text sizes or on a small phone the text scrolls and never overlaps.
- Check this at 0.85× and 2.0× text scale in widget tests (see Tests).

## Files

### New: `lib/features/onboarding/onboarding.dart`

- `const onboardingPreference = 'onboarding.done';`
- `final onboardingDoneAtLaunchProvider = Provider<bool>((ref) => false);`, overridden in `main()` like `proAtLaunchProvider`.
- `onboardingDoneProvider`: a `Notifier<bool>` built from the launch value, with `Future<void> complete()` that sets the state and writes `'true'` to the preference.
- `Future<bool> onboardingAlreadyDone(AppDatabase db, StravaSessionStore store)`: true when the preference is `'true'`, or any activity or creation exists, or a Strava session is stored. Use a count/limit-1 query, not a full list.

### New: `lib/features/onboarding/onboarding_sample.dart`

`onboardingSampleActivity`: an `Activity` that has everything the art needs: distance, time, pace, heart rate, a route polyline, splits, elevation and streams. Take these from the Laboratory demo data in `lib/features/strava/strava_demo.dart` (it already has routes, splits, elevation, a shoe), adding streams if the demo lacks them. Make it a **run of 10.02 km**, with `prCount: 1` so the Record label is earned. Build its `StickerFacts` the same way the editor does (see `lib/features/stickers/sticker_facts.dart`), not with a copy of that logic.

### New: `lib/features/onboarding/onboarding_art.dart`

One widget per page, all through `StoryCanvas(format: ShareFormat.feed, background: …, theme: …, data: …, placement: StickerPlacement(center: …), extras: [...], watermark: false)` and clipped with a 20 px radius. Use the same calls `TemplateCanvas` makes for `stickerDataFor`. Exclude the art from semantics and give the whole block one label (`onboardingArtLabelN`).

| Page | Theme id | Extras (`ExtraSticker` kind → value) | Placement hints |
|---|---|---|---|
| 1 | `big-distance` | `pace` chart near the top | sticker at (0.5, 0.78) |
| 2 | `inline-top` | `route`, the most visible style (neon or glow) | route at (0.5, 0.3), theme at (0.5, 0.62) |
| 3 | `vertical-stack`, twice | none | left: on the photo; right: sticker only on a checkerboard. Move the private `_Checkerboard` painter from `share_screen.dart` (~line 393) to `lib/shared/widgets/` and use it in both places |
| 4 | `receipt` | `label` → `record`, `heartRate` chart | receipt at (0.32, 0.55), label at (0.72, 0.42), chart at the top |

Pro themes and stickers are drawn here even without Pro: this is a preview, not use. Don't route anything through `themeLocked`.

### New: `lib/features/onboarding/onboarding_screen.dart`

- `OnboardingScreen({bool replay = false})`, a `ConsumerStatefulWidget` holding a `PageController`.
- Dark theme: wrap it in `Theme(data: AppTheme.dark, …)`, as `crop_screen.dart` does (~line 125). Background `AppColors.neutral0`.
- Title: `AppText` display style, Barlow Condensed 800 italic, upper case, 44 px, height 1. Body: Inter 17, `AppColors.neutral70`. Add a token to `app_text.dart` if none matches; don't inline a new style.
- Next: `animateToPage(+1, 300 ms, easeOutCubic)`; if `MediaQuery.disableAnimationsOf(context)`, use `jumpToPage`.
- Android back (`PopScope`): on page > 0 go to the previous page; on page 0 let the system handle it.
- Dots: `Semantics(label: l10n.onboardingPageOf(n, 4))` around the row; the dots themselves excluded.
- Finish (Skip / Get started / See Pro): `await ref.read(onboardingDoneProvider.notifier).complete()`. Then, if `replay`, pop; otherwise `context.go(AppRoutes.activities)`, and for See Pro also `context.push(AppRoutes.pro)`.
- The price for "See what's in Pro" comes from the same offer the Pro screen reads (`pro_store.dart`); if it isn't loaded, show the label without a price.

### Changed: `lib/main.dart`

Before `runApp`, read `onboardingAlreadyDone(db, SecureStravaSessionStore())` (its `read()` returns the stored session or null) and override `onboardingDoneAtLaunchProvider`. If the result was true only because of existing data, also write the preference so the check is a single read next time.

### Changed: `lib/app/router.dart`

- `AppRoutes.onboarding = '/welcome'`.
- A top-level `GoRoute(path: AppRoutes.onboarding, parentNavigatorKey: _rootKey, builder: … OnboardingScreen(replay: state.extra == true))`.
- `initialLocation`: `ref.read(onboardingDoneProvider) ? AppRoutes.activities : AppRoutes.onboarding`. Read it once; don't `watch` it, or the router is rebuilt when onboarding completes. No `redirect`, so replay from Settings works.

### Changed: `lib/features/settings/settings_screen.dart`

In the About section, before Privacy: a `GroupedListTile` with an icon from `AppIcons` (add a Lucide icon such as `sparkles` or `info` there), titled `settingsShowIntro`, that does `context.push(AppRoutes.onboarding, extra: true)`.

### Assets

Add `assets/onboarding/` to `pubspec.yaml`, plus a `README.md` in that folder: four portrait JPGs, own photos, ≥ 1080 px wide, ≤ 400 KB each, faces cropped away from where stickers sit (top 35 % and bottom 30 %). The code checks whether an asset exists through a small manifest list in `onboarding_art.dart` (const list of the files that are present), not by catching load errors at runtime.

## Texts (ARB, all five languages)

English values, with Brazilian Portuguese alongside. Write es/fr/de the same way, keep `{placeholders}`, then run `python3 tool/translations.py export` so the new rows reach `docs/translations-review.csv` for native review.

| Key | en | pt (BR) |
|---|---|---|
| `onboardingSkip` | Skip | Pular |
| `onboardingNext` | Next | Próximo |
| `onboardingStart` | Get started | Começar |
| `onboardingSeePro` | See what's in Pro | Ver o que vem no Pro |
| `onboardingSeeProPrice` | See what's in Pro · {price} | Ver o que vem no Pro · {price} |
| `onboardingPageOf` | Page {page} of {total} | Página {page} de {total} |
| `onboardingTitle1` | Your run. Your story. | Sua corrida. Sua história. |
| `onboardingBody1` | Turn every workout into an image worth sharing: your photo, your stats, your style. | Transforme cada treino numa imagem que vale compartilhar: sua foto, seus números, seu estilo. |
| `onboardingTitle2` | Ready the moment you finish | Pronto assim que você termina |
| `onboardingBody2` | Connect once and your latest workouts are waiting, with their route, splits and charts. | Conecte uma vez e seus treinos mais recentes já estarão aqui, com percurso, parciais e gráficos. |
| `onboardingByHand` | Or add it by hand | Ou adicione à mão |
| `onboardingTitle3` | Full image or just the sticker | Imagem completa ou só o sticker |
| `onboardingBody3` | Save to Photos, post to Instagram, or export only the sticker on a clear background to paste anywhere. | Salve na galeria, poste no Instagram ou exporte só o sticker com fundo transparente para colar onde quiser. |
| `onboardingFullImage` | Full image | Imagem completa |
| `onboardingStickerOnly` | Sticker only | Só o sticker |
| `onboardingTitle4` | Pay once. Keep it forever. | Pague uma vez. É seu para sempre. |
| `onboardingBody4` | Charts, route styles, Pro themes and stickers, and no watermark. One payment, no subscription. | Gráficos, estilos de percurso, temas e stickers Pro, e sem marca d'água. Um pagamento, sem assinatura. |
| `onboardingArtLabel1` | A running photo with the distance and a pace chart | Foto de corrida com a distância e um gráfico de ritmo |
| `onboardingArtLabel2` | A photo with the route, distance and pace | Foto com o percurso, a distância e o ritmo |
| `onboardingArtLabel3` | The same stats as a full image and as a sticker alone | Os mesmos números como imagem completa e como sticker sozinho |
| `onboardingArtLabel4` | Pro receipt theme, a Record label and a heart-rate chart | Tema Pro de recibo, etiqueta de Recorde e gráfico de frequência cardíaca |
| `settingsShowIntro` | Show introduction again | Ver a introdução de novo |

"Sticker" stays "sticker" in Portuguese, as in the rest of the app. The health source chip reuses the existing source names (Apple Health / Health Connect strings already in the ARB files).

## Tests (`test/onboarding/`)

| Test | Checks |
|---|---|
| `onboarding_state_test.dart` | fresh database → not done; preference `'true'` → done; an activity, a creation or a Strava session → done; `complete()` writes the preference |
| `onboarding_screen_test.dart` | Next moves through 4 pages and the dots' semantics label follows; Skip on page 2 → Home and the preference is set; Get started → Home; See Pro → Pro screen with Home under it; `replay: true` pops instead; Back on page 3 → page 2; with `disableAnimations` Next jumps |
| `onboarding_layout_test.dart` | on 360×640 and 390×844 surfaces, at text scale 0.85, 1.0 and 2.0: no overflow errors, and the button's top is below the body text's bottom or the text area scrolls |
| `onboarding_art_test.dart` | each page's art builds with the sample activity in km and in mi, and in all five locales, without exceptions; Pro art draws with `isPro == false` |
| router test | first launch opens `/welcome`; launch with done → `/activities`; Settings row opens onboarding with replay |
| `l10n_test.dart` | already fails if a language misses a key |

## Check-points on Francisco's phone

1. Fresh install (or clear app data): onboarding appears, the swipe and Next both work, Skip goes Home, and onboarding doesn't come back after closing the app.
2. Install over the current build that already has data: onboarding does **not** appear.
3. Settings › Show introduction again: it opens, and Get started returns to Settings.
4. Large font (Android Settings › Display › Font size, maximum): nothing overlaps.
5. Each language: titles fit in at most 3 lines at normal font size; report any that don't.
6. With Francisco's four photos added: stickers sit on calm parts of each photo.

When done, add a **Phase 14 status (onboarding)** block to `CLAUDE.md` in the same style as the others. Phase 13 (Pro templates) is still open, so use whatever number Francisco prefers.

## Ideas from Fitshot for later phases (not in this work)

- **Chart extremes labelled on the line:** best and slowest pace (or max heart rate) written at the chart's high and low points, as in Fitshot's marathon screenshot.
- **Photo effects (Pro):** black-and-white and high-contrast filters on the background photo. Fitshot leads its whole store story with them.
- **"Sticker mode" to the clipboard:** copy the sticker-only PNG so it can be pasted straight into an Instagram or TikTok story, next to the existing export.
