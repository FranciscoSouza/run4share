# run4share: notes for Claude Code

run4share is a Flutter app (iOS and Android) that turns workout stats into
shareable images: connect Strava, pick an activity, pick a gallery photo,
crop to 9:16 / 4:5 / 1:1, place and style stat stickers by theme, then save
or share to Instagram.

## Where things are

- `design/`: the final design, 34 PNG artboards. `Foundations.png` holds the
  colour, type, icon and component tokens. Treat the PNGs as the source of
  truth for layout and look.
- `lib/app/theme/`: colour, type, spacing tokens and the light/dark
  `ThemeData`, already written from `Foundations.png`.
- `tool/setup.sh`: one-off setup. It downloads the fonts, runs
  `flutter create` for android/ios, adds the packages with `flutter pub add`,
  then runs gen-l10n, analyze and test.
- `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`: written. Third-party
  packages are added by `tool/setup.sh`, not pinned by hand.

## Phase plan

0 foundations → 1 Strava → 2 home/activities → 3 photo/crop →
4a editor core → 4b sticker controls → 5 share/My Creations →
6 settings/languages → 7 hardening/release.
Each phase ends with an Android build that Francisco confirms on his phone.

**Phase 0 status:** code done (router with two-tab shell + Settings, ARB
files for en/pt/es/fr/de, shared widgets in `lib/shared/widgets/`, static
Home · no source, My Creations empty state, Settings, tests, CI in
`.github/workflows/ci.yml`). analyze and test pass; debug APK builds.
Waiting for Francisco to confirm on his phone.

Notes from phase 0:
- Material is imported only through `lib/app/material.dart`. Flutter 3.47+
  deprecates `flutter/material.dart` for the `material_ui` package, but
  go_router 17 still uses the old library, so switching now would split
  Theme/localisations. Switch that one file when the stack has moved.
- Icons: Lucide (`lucide_icons_flutter`, regular weight), all named in
  `lib/app/app_icons.dart`.
- Popular-template tiles on Home are gradient placeholders until themes
  exist (phase 4a). The My Creations empty state has no artboard; it was
  built from the same tokens.
- `android/` Gradle files were brought up to the Flutter 3.50 template
  (Gradle 9.5, AGP 9.3.1); `applicationId` kept as `com.run4share.app`.
- The design's Portuguese Home artboard is European Portuguese ("As tuas
  atividades"); the ARB follows the decision below (Brazilian).

## Decisions already taken (do not reopen without asking)

- Clean start: nothing from `~/development/src/run_sharing` (older
  ChatGPT-era code) is reused.
- Home is the activity list with a "Popular templates" carousel on top;
  tapping a template starts a guided flow.
- One theme = one whole sticker (metrics + layout); the theme's metric list
  is authoritative. Themes are data drawn by one renderer, so preview and
  canvas cannot differ, and the catalogue must be able to grow.
- Format chosen and cropped before editing: 9:16, 4:5 or 1:1.
- Manual activities allowed; My Creations, full Settings, sticker rotation
  and sticker-only transparent export are in scope.
- Monetisation: free app plus one cheap one-off purchase, no subscription.
- Sources: Strava first; Apple Health and Health Connect later.
- Light mode for browsing, dark for creation; brand blue #0077BD;
  Barlow Condensed + Inter, bundled (not google_fonts).
- Languages at launch: en, pt (Brazilian), es, fr, de, following the device.
- Stack: Riverpod, go_router, freezed, dio, flutter_web_auth_2,
  flutter_secure_storage, drift, photo_manager, crop_your_image, gal,
  share_plus, very_good_analysis.

## Application ID

`com.run4share.app` on both platforms (Android `applicationId`, iOS
`PRODUCT_BUNDLE_IDENTIFIER`; the RunnerTests target is
`com.run4share.app.RunnerTests`). The Kotlin namespace stays
`com.run4share.run4share`, which is only the code package and is never seen
by users.

## Answered by Francisco (14 Nov 2026)

1. Strava client secret: a small token-exchange function holds it; the app
   never contains it.
2. Strava scope: `activity:read_all` (private activities included).
3. First themes: the seven in the design's theme carousel.
4. Icons: `lucide_icons_flutter`.

## Open questions (ask Francisco, don't assume)

Still open from design: free/Pro split and price, duplicate rule across
sources, undo/redo, edit-again from My Creations, when the rate sheet
appears, invite reward, native review of translations, Effort formula.

## How Francisco works

- VS Code, tests on his Android phone; iOS verified late on his Mac.
- Wants to be asked questions rather than have things assumed.
- Never claim something works on a device until he has confirmed it.
- Strava secrets never go into the repo.
- Repo: https://github.com/FranciscoSouza/run4share.git
- Conversations in English or Brazilian Portuguese.
