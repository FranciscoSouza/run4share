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
`.github/workflows/ci.yml`). Confirmed on Francisco's phone (Galaxy S22,
Android 16) on 15 Nov 2026.

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

**Phase 1 status (Strava):** confirmed on Francisco's phone on 15 Nov 2026
with Laboratory demo data; never tried against real Strava (no API
credentials yet). Connect screen (`/connect/strava`), OAuth via flutter_web_auth_2
to `run4share://localhost`, session in flutter_secure_storage, refresh
5 min before expiry, disconnect revokes on Strava, Settings and Home show
the connection, Home lists the latest 30 activities (interim; phase 2
adds caching, paging, manual activities).
- Token exchange: Cloudflare Worker in `server/strava-token/` (deploy
  steps in its README). Client ID and secret are Worker secrets.
- App config: `--dart-define-from-file=config/strava.json` (gitignored;
  copy `config/strava.example.json`). VS Code launch.json passes it.
- Strava API app must have Authorization Callback Domain `localhost`.
- No Strava API credentials yet (Strava API access is now paid). Until
  then use Settings → Laboratory → "Strava demo data": the same connect
  flow, a demo athlete and sample activities, nothing sent anywhere.
  Saved on the phone; switching disconnects the current connection.
  Laboratory is hidden in release builds unless `--dart-define=LAB=true`.
- flutter_web_auth_2 5.1.0 (latest) still applies the Kotlin Gradle
  Plugin; Flutter warns future versions will refuse it. Watch for an
  update.
- The connect screen's Strava tile is a placeholder: use Strava's official
  brand assets and check their guidelines before release (phase 7).

**Phase 2 status (home/activities):** committed (`phase-2-activities`);
Francisco moved on to phase 3 on 15 Nov 2026 without reporting problems.
- Local database: drift (`lib/data/`), tables `activities` (every source)
  and `preferences` (units, sync state). Start times are wall-clock values
  stored as UTC text (`store_date_time_values_as_text` in build.yaml).
- Strava sync (`lib/features/activities/strava_sync.dart`): first sync
  takes the newest 30; later syncs page down until known activities (max
  5 pages); older pages load on scroll via Strava's `before`. Auto-sync on
  Home if older than 15 min, after connecting, and on pull-to-refresh.
  Sync depth was not answered by Francisco; this was the recommended
  option.
- Disconnect deletes Strava activities from the phone (Strava API terms);
  manual ones stay.
- Manual activities: Add form (`/activity/new`), Edit and Delete from the
  card's ⋮ menu (`/activity/:id/edit`). Types Run, Ride, Hike, Walk,
  Workout.
- Templates carousel tap still says "coming"; the guided flow comes with
  themes in phase 4a. Tapping an activity leads to phase 3 (photo).

**Phase 3 status (photo/crop):** committed (`phase-3-photo`); Francisco
moved on to phase 4a on 15 Nov 2026 without reporting problems.
- Flow: tap an activity → `/create/:activityId/photo` (explainer the first
  time, "Photo access is off" after a denial, else the picker) →
  `/create/:activityId/photo/:photoId` (format and crop, dark theme) →
  `/create/editor` (phase 4a).
- Android can't tell "never asked" from "denied", so the app stores
  `photos.asked` in preferences.
- Photos go through `PhotoLibrary` (`lib/features/photos/`); tests use a
  fake. The crop is non-destructive: `CreationDraft` keeps the photo ID,
  the format (`ShareFormat`: story 9:16, feed 4:5, square 1:1) and the crop
  as fractions of the photo, so export can use the full-resolution
  original. The cropper works on a preview no larger than 2048 px.
- The last format used is offered first (Story the first time).
- iOS photo-permission text is English only for now (needs InfoPlist
  .strings per language later).

**Phase 4a status (editor core):** code done, installed on Francisco's
phone, waiting for his check. Not committed yet.
- Themes are data (`lib/features/editor/sticker_theme.dart`): id, name,
  layout (inline, stack, hero, poster, ring, weekday), metric list and
  start position. One renderer (`sticker_view.dart`) draws them all in
  canvas units (1080 wide); `StoryCanvas` places photo, sticker and
  watermark and is used by the editor, theme thumbnails, template
  previews and (phase 5) export.
- `Metric.rate` is pace on foot and speed on rides. A theme is offered
  only if the activity has all its metrics; others are greyed with the
  reason. Strava calories come from the activity detail endpoint, fetched
  when the editor opens.
- Sticker: drag, pinch to resize and rotate (snaps straight within 3°);
  when selected, rotate/remove/resize handles. Removing it leaves the
  photo alone until a theme is picked again. Switching theme puts the
  sticker at the new theme's start position.
- Templates (`storyTemplates`): Story Hero (Big Distance), Top Line
  (Inline Top), Left Stack (Vertical Stack), Race Poster (Poster), all
  9:16. Flow: preview → choose activity (unusable greyed) → photo → crop
  (template format) → editor (template theme). "Race Poster" is a guess
  from the cut-off "Race P…" in the design.
- Last theme and format used are offered first. Share says "coming"
  until phase 5.

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

Answered 15 Nov 2026 for phase 4a:
- Theme names: Inline Top, Vertical Stack, Big Distance, Poster, Heart
  Ring, Weekday, Time & Calories.
- Watermark "run4share" drawn on images now; Pro will remove it later.
- Editor bottom bar shows only Theme; Calories, Quotes, Text and Stickers
  come after phase 4b.
- No undo/redo for now.

## Open questions (ask Francisco, don't assume)

Still open from design: free/Pro split and price, duplicate rule across
sources, edit-again from My Creations, when the rate sheet
appears, invite reward, native review of translations, Effort formula.

## How Francisco works

- VS Code, tests on his Android phone; iOS verified late on his Mac.
- Wants to be asked questions rather than have things assumed.
- Never claim something works on a device until he has confirmed it.
- Strava secrets never go into the repo.
- Repo: https://github.com/FranciscoSouza/run4share.git
- Conversations in English or Brazilian Portuguese.
