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
6 settings/languages → 7 hardening/release → 8a Pro stickers (labels,
time, phrases, stamps) → 8b Pro data stickers (shoe, route, charts) →
9 Health Connect source → 10 Apple Health + iOS → 11 real activity
charts → 12 Pro themes → 13 Pro templates → 14 onboarding → 15 chart extremes → 16 Home templates → 17 photo effects + copy sticker.
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

**Phase 4a status (editor core):** committed (`phase-4a-editor`);
Francisco moved on to phase 4b on 15 Nov 2026 without reporting problems.
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

**Phase 4b status (sticker controls):** committed (`phase-4b-controls`);
Francisco moved on to phase 5 on 15 Nov 2026 without reporting problems.
- Selected sticker's "A" handle opens Text colour (White, Black, Amber,
  Red, Blue, Green); the contrast handle opens Sticker background, one
  slider from white through transparent (snaps within 0.06) to black.
- `StickerStyle` (colour, background) lives in the draft and is kept when
  the theme changes. Null colour means the theme's own (Poster: amber).
  Poster fills its boxes with the colour and picks black or white text;
  Heart Ring colours the ring and gets a round backing. Text shadow only
  for light text without a backing.
- French "Time" is "Durée", as in the Editor · Français artboard.

**Phase 5 status (share / My Creations):** committed (`phase-5-share`);
Francisco moved on to phase 6 on 15 Nov 2026 without reporting problems.
- Share screen (`/create/share`): its preview is a RepaintBoundary
  exported at 1080 px wide (1080×1920 / ×1350 / ×1080) from a photo copy
  up to 3072 px. "Sticker only" exports the sticker alone on transparency
  with a small run4share mark under it, 1080 wide. PNG throughout.
- Save to Photos uses gal (album "run4share"), then the Saved screen.
  Instagram Stories and More both open the system share sheet (no Meta
  App ID yet). "Remove watermark · PRO" says "coming" until Pro exists.
- Every export is a creation (drift `creations` table, schema 2, PNG in
  the app's documents/creations folder) with its settings as JSON; one
  creation per variant per Share visit, so save + share don't duplicate.
- My Creations: two staggered columns; detail with Share again, Edit
  (reopens the editor if the activity and original photo still exist,
  else says which is missing) and Delete (Photos copies stay).

**Phase 6 status (settings / languages):** committed (`phase-6-settings`).
- Language: Android 13+ opens the system per-app language screen
  (`MainActivity` method channel `run4share/system`, `locales_config.xml`);
  iOS opens the app's Settings page (`CFBundleLocalizations`); Android 12
  and older get an in-app list saved as preference `language`.
- Rate: Settings opens the store listing (in_app_review). The rating sheet
  shows on the Saved screen from the 3rd image saved to Photos, at most
  every 90 days, never after Rate/feedback or a second "Not now".
  "Send feedback instead" opens a new GitHub issue.
- Invite: screen from the design; link is the Play Store URL
  (`lib/app/links.dart`), copy confirms inline, share uses the sheet.
- Privacy policy: draft in `docs/privacy-policy.md` (needs Francisco's
  review, contact details and hosting); Settings links to it on GitHub's
  main branch, so it only resolves once merged to main.
- Translation review: `python3 tool/translations.py export` writes
  `docs/translations-review.csv`; `import` applies reviewers' fixes and
  refuses rows that drop a placeholder.
- Pro and Restore purchase stay "coming" until phase 7.

**Phase 7 status (hardening / release):** committed (`phase-7-release`).
What's left needs Francisco's accounts: see `docs/release-checklist.md`.
- Release signing: upload key `~/.run4share/run4share-upload.jks`,
  `android/key.properties` (gitignored) read by `build.gradle.kts`;
  falls back to the debug key when absent. Signed AAB verified.
- Icon and splash: r4s tile rendered by `tool/icon/render_icons_test.dart`
  into `assets/icon/`, then flutter_launcher_icons / flutter_native_splash
  (config in pubspec.yaml). Adaptive + monochrome icons on Android.
- Strava brand: official, unmodified assets in `assets/strava/` (Connect
  with Strava button, Compatible with Strava, Powered by Strava under
  lists with Strava data). Strava's guidelines make them optional ("if
  you choose to"); used per Francisco's decision.
- Pro: one-off product `run4share_pro` via in_app_purchase
  (`lib/features/pro/`). Entitlement saved as preference `pro.unlocked`;
  Restore asks the store again. Pro removes the watermark (editor,
  share, sticker-only) and unlocks themes with `pro: true` (none of the
  seven launch themes). Without a Play Console product the Pro screen
  says Pro isn't available yet. Laboratory "Pretend Pro" for testing.
- Errors: release builds show a neutral box instead of a broken widget;
  uncaught errors are logged; no reporting service (privacy promise).
- Workout sources show only the phone's own health source: Apple Health
  on iPhone, Health Connect on Android (`lib/app/platform.dart`).
- A test keeps `AppInfo.version` equal to pubspec's version.

**Phase 8a status (Pro sticker pack, part 1):** committed
(`phase-8a-stickers`).
- Editor "Stickers" tool (Pro): extra stickers as canvas layers above the
  theme sticker (`CanvasItem`s in `StoryCanvas`), each movable, sizable,
  rotatable, recolourable and removable; saved in the draft/creation
  JSON (`extras`), exported with the image. Without Pro, tapping one
  opens the Pro screen.
- Kinds (`lib/features/stickers/`): automatic labels (Record, Long run,
  Race day, Sub-X), start time with time-of-day icon, 15 mood phrases (5
  moods x 3) in all languages, 6 stamps/seals (4 round with ring text, 2
  rectangular). All need native review via the translation sheet.
- Schema 3: activities gain `pr_count` (Strava) and `race` (Strava
  workout type 1/11, or the manual form's "This was a race" switch).
- Demo data has "City 10K" (race, PR) to show the labels.
- Sticker-only export still contains only the theme sticker.

Label rules (Francisco, 15 Nov 2026):
- Record: Strava PR (pr_count > 0); otherwise run4share history of the
  same sport: the longest, or the fastest among activities at least as
  long.
- Long run (Longão): a run of 15 km or more.
- Race day: Strava "Race" or the manual switch.
- Sub-X: runs within 4.95-5.4 km, 9.9-10.6 km, 21.0-21.7 km or
  42.1-43.1 km, under the best round mark beaten: 5K 20/25/30, 10K
  40/45/50/60, half 1:30/1:45/2:00, marathon 3/3:30/4.
- Shoe sticker (8b) asks Strava's profile:read_all permission; manual
  activities type a shoe name and km.

**Phase 8b status (Pro data stickers):** committed
(`phase-8b-data-stickers`); Francisco moved on to phase 9.
- New extra-sticker kinds: shoe (name + lifetime distance), route (neon,
  glow, dotted; drawn from the polyline, no map), elevation profile with
  total climb, and splits bars (fastest highlighted, best pace).
- Strava: scope now includes `profile:read_all` (gear); the session
  stores granted scopes. Summary gives `map.summary_polyline` and
  `gear_id`; the editor fetches detail splits (km and mi), the altitude
  stream (downsampled to 120 points) and the gear, each best effort. A
  Strava shoe without the permission shows "Reconnect Strava".
- Schema 4: activities `polyline`, `gear_id`, `splits_json`,
  `elevation_json`; new `gear` table. Manual activities can type a shoe
  (stored as gear `manual:<name>`).
- Demo data has routes, splits, elevation, a shoe and a bike.

**Phase 9 status (Health Connect):** committed (`phase-9-health-connect`).
- `health` plugin 13 (Health Connect now; Apple Health later with the
  same code). Read-only: workouts, distance, calories, heart rate,
  routes, history. `MainActivity` is a `FlutterFragmentActivity`; Health
  Connect's privacy link opens the policy. minSdk 26.
- `lib/features/health/`: `HealthHub` interface (fake in tests),
  `HealthConnectSync` (connect, sync every 15 min / on refresh,
  disconnect revokes and deletes its workouts, revoked access detected).
  First sync reads 365 days with past-data access, else 30; later syncs
  re-read from 2 days before the last sync.
- Workouts are activities with source `healthConnect`, named like Strava
  ("Morning Run"); route, elevation and splits are computed from the
  route's timestamped points, so data stickers work for them too.
- Duplicates (Francisco, 16 Nov 2026): a Health Connect workout is not
  listed when a Strava activity of the same sport starts within 2 min
  and its distance is within 5%; it is not deleted and shows again if
  Strava is disconnected (`hideDuplicates`).

**Phase 10 status (Apple Health + iOS):** code done, runs on the iPhone
16 Pro simulator (no paid Apple Developer membership yet, so no device
build). Not committed yet.
- Same `health` plugin and `HealthConnectSync` (now "the phone's health
  hub"); on iOS workouts are stored as source `appleHealth`. iOS can't
  report a read refusal or revoke access: `hasAccess` is assumed, history
  is always available, disconnect only removes local copies, and an
  empty result shows a hint (Health app › Profile › Apps › run4share).
- iOS project: HealthKit entitlement (`Runner/Runner.entitlements`),
  deployment target 15.0, NSHealthShare/Update texts, and
  `InfoPlist.strings` in en, pt-BR, es, fr, de for photo and health texts
  (closes "English only" from phase 3). Project edited with the
  `xcodeproj` gem, not by hand.
- No "coming soon" actions remain; the helper and string were removed.
- Device signing (Team ID, HealthKit capability on the App ID) waits for
  Francisco's Apple Developer membership.

**Phase 11 status (real activity charts):** committed
(`phase-11-charts`); Francisco approved it on his phone, 16 Nov 2026.
- New Pro extra stickers: heart rate (over time; avg on top, max and
  duration under) and pace (over time, min/km or min/mi, faster drawn
  higher, avg and best). Elevation (over distance) now shows m or ft.
- Data path: `StravaApi.streams` (one request: time, distance,
  altitude, heartrate, velocity_smooth, moving) → `ActivityStreams`
  (`lib/features/stickers/activity_streams.dart`, 200 time slices,
  bucket means) → cached as `activities.streams_json` (schema 5; an
  empty answer is cached so it isn't re-asked; failures retry) →
  `chart_data.dart` (pace = metres per unit / speed; paused slices,
  speeds under 0.5 m/s and spikes beyond 2.5x the median are gaps;
  heart rate outside 30-240 bpm dropped; fewer than 10 readings → chart
  not offered) → `ActivityCharts` built in `StickerFacts` → one line
  painter. `editor_screen.dart` unchanged.
- Holes up to 30 s between real readings are bridged (sparse sources);
  longer ones and pauses stay gaps.
- Health Connect / Apple Health: `hubStreams` builds the same streams
  from heart-rate samples and the timestamped route at sync time.
- Older activities keep their elevation sticker from `elevation_json`;
  `StravaApi.elevation` was replaced by `streams`.
- Editor toolbar (Francisco, 16 Nov 2026): Theme, Stickers and Your
  data (chart icon, Pro). Your data (shoe, route, charts, splits) moved
  out of the Stickers panel into its own tool (`StickersPanel(data:
  true)`); `editor_screen.dart` changed only for that tool.
- Laboratory demo streams (test builds only): a pause in longer runs,
  every 5th activity without heart rate, no GPS streams without a route.

**Phase 12 status (Pro themes):** committed (`phase-12-pro-themes`);
Francisco moved on 16 Nov 2026 without reporting problems.
- Three Pro themes (Francisco chose them from proposals; no design
  artboards): Race Bib (card with pin holes: name, distance as the
  number, time and pace), Receipt (name, date and start time, line
  items, TOTAL = distance, barcode, torn edge) and Scoreboard (dark
  board, digits lit in the text colour, default amber). All need
  distance, time and rate. Bib and Receipt fill with the chosen colour
  and pick black/white text, like Poster.
- New layouts `bib`, `receipt`, `scoreboard` in `sticker_view.dart`;
  `StickerData` gains `name` and `date`. String `receiptTotal`.
- Carousel shows a PRO badge on Pro themes without Pro (shared
  `ProBadge` in `lib/shared/widgets/`); tapping one opens the Pro screen.
  `editor_screen.dart` changed only for that badge.
- Templates for them came in phase 13.
- A test draws every theme for a 4-hour marathon with a long name in
  every language; `tool/preview/theme_preview_test.dart` renders the Pro
  themes to PNGs with the real fonts for a visual check.

**Phase 13 status (Pro templates):** committed
(`phase-13-pro-templates`) 16 Nov 2026.
- Three Popular templates, 9:16, after the four free ones: Race Day
  (Race Bib), Run Receipt (Receipt), Final Score (Scoreboard). A
  template is Pro when its theme is (`StoryTemplate.pro`).
- Without Pro: PRO badge on the Home tile and in the preview title; the
  preview is open to everyone, "Use this template" opens the Pro screen.

**Phase 14 status (onboarding):** committed (`phase-14-onboarding`),
built from `docs/onboarding.md` (the spec, with the decisions it took);
Francisco approved it 16 Nov 2026. His four photos are still to come.
- `lib/features/onboarding/`: four pages at `/welcome` (dark), shown
  only on a true first launch; an update with any activity, creation or
  Strava session marks it done unseen (preference `onboarding.done`).
  Skip / Get started go Home; "See what's in Pro · price" goes Home then
  Pro. Settings › About › Show introduction again replays it (`extra:
  true`) and returns to Settings.
- Art is live `StoryCanvas`es (Big Distance + pace; Inline Top + neon
  route; Vertical Stack full and sticker-only on the shared
  `Checkerboard`; Receipt + Record + heart rate) from
  `onboardingSampleActivity` (10.02 km, demo route/splits/streams via the
  now top-level `demoStreams` and `encodeSplits`). Name is the localised
  sport word.
- Photos: none yet; `assets/onboarding/README.md` says what to add and
  `onboardingPhotos` lists the ones present. Flat colours meanwhile.
- Fix found here: stickers (`StickerView`, `ExtraStickerView`) now ignore
  the phone's font size, so large-font phones no longer get enlarged,
  overflowing sticker text in the editor or the exported PNG.
- `tool/preview/onboarding_preview_test.dart` renders the pages
  (PREVIEW_LANGS, PREVIEW_TEXT_SCALE).

**Phase 15 status (chart extremes):** committed
(`phase-15-chart-extremes`) 16 Nov 2026, before Francisco's phone check
(he asked to move on to Home templates). First idea from
`docs/onboarding.md`'s later list (Francisco didn't pick; Claude took
the first). Home templates followed as phase 16 (`docs/home_templates.md`).
- Heart rate: "Max" at the peak, "Min" at the lowest reading. Pace:
  "Best" at the fastest point, "Slowest" at the slowest. Painted on the
  line with a dot, in bands above and below it; the footer keeps only
  the duration (max/best moved onto the line).
- Fix found here: speed readings while stopped (Strava `moving` false;
  health hubs under 0.5 m/s) are left out before averaging, so slices
  around a pause no longer show a fake slow spike.

**Phase 16 status (Home templates):** code done on
`phase-16-home-templates` from `docs/home_templates.md` (the doc calls it
phase 15; extremes took that number). Committed 16 Nov 2026 after
Francisco ran it on his phone.
- Home: "Make posts like these" + See all, then `FeaturedTemplates`
  (`lib/features/home/featured_templates.dart`): looping `PageView`,
  centre card 9:16 at clamp(width x 0.565, 200, 280), neighbours at 0.82
  scale / 0.85 opacity following the finger, name + "what" line + dots,
  "Use this template". Auto-advance every 5 s; a touch stops it and it
  restarts 10 s later; off with animations disabled, a screen reader,
  Home not on screen or the app in the background.
- See all: `/templates`, `TemplatesScreen`, two-column grid.
- `StoryTemplate` gains sport, extras (`TemplateExtra`), featured,
  `proOnly`, photo (`templatePhotos` lists those present). 11 templates:
  7 featured (Sunrise Half, Summit Day, Mountain Climb, Night Run =
  `final-score` renamed, Race Day, Run Receipt, Coast Walk) + 4 free.
- Decisions (Francisco, 16 Nov 2026, against the doc's table):
  Sunrise Half and Coast Walk are free, as in the artboards; Summit Day
  and Mountain Climb are `proOnly`. Free templates' extras (pace chart,
  route) show in the editor, but Share asks for Pro while any extra
  (or a Pro theme) is on the image (`draftNeedsPro`, dialog in
  `editor_screen.dart`'s Share; the only editor change). Samples: run
  10.02 km (onboarding's), hike 14.6 km 4:32:10 +1,240 m, ride 64.3 km
  2:16:05, walk 8.40 km (1:40:48, Claude's figure; the artboard has no
  time). The route's name in the "what" line is a new string, "Route".
- `lib/features/templates/template_samples.dart` (per-sport samples;
  onboarding uses it), `template_info.dart` (what line, `useTemplate`
  shared by Home and the preview, `templateExtrasFor`, `draftNeedsPro`).
- Using a template: the crop step's Next fetches Strava details first
  (heart rate, pace, elevation come from streams), keeps the extras the
  activity can draw, and shows one "left out" snackbar for the rest.
- Photos: none yet; `assets/templates/README.md` lists what to add.
- Tests: `test/home/template_carousel_test.dart`,
  `test/templates/{templates_screen,template_catalogue,template_extras}_test.dart`,
  Share gate in `editor_test.dart`. Home content now starts below the
  carousel: tests use `tester.showOnHome(...)` / `homeToTop()`.
- `tool/preview/home_preview_test.dart` renders Home and See all.

**Phase 17 status (photo effects + copy sticker):** code done on
`phase-17-effects-clipboard`, the onboarding spec's two remaining ideas
(Francisco, 16 Nov 2026). Committed after it ran on his phone; the
paste into Instagram/TikTok wasn't reported.
- Effects (`PhotoEffect` none / blackWhite / highContrast in the draft
  and its JSON; old creations read as none): colour matrices in
  `lib/features/editor/photo_effect.dart`, applied by `StoryCanvas` to
  the background only, so editor, thumbnails and export match. Editor
  toolbar gains a fourth tool, Photo (`PhotoEffectsPanel`: the photo in
  each effect); the four tools now share the width.
- Pro: anyone can try an effect; Share asks for Pro while one is on
  (`draftNeedsPro`; dialog now "Pro on this image").
- Copy sticker: Share screen, sticker-only mode, a Copy button
  (`ShareActions.copyImage`). Flutter's clipboard is text only, so the
  PNG goes to cache/clipboard/ and the `run4share/system` channel puts
  it on the clipboard: Android via a FileProvider (`${applicationId}.clipboard`,
  cache/clipboard/ only) and `ClipData.newUri`; iOS via
  `UIPasteboard` (AppDelegate now registers the channel). Copying is an
  export, so it's kept in My Creations like Save/Share.
- The Share buttons now share the row width (four didn't fit).

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

Answered 15 Nov 2026 for phase 5:
- Instagram Stories: system share sheet until a Meta App ID exists.
- Sticker-only exports carry a small watermark; Pro removes it later.
- Share screen shows the Pro row as "coming soon".
- Edit-again from My Creations: yes, reopens the editor.

Answered 15 Nov 2026 for phase 6:
- Language row opens the phone's per-app language setting.
- Rating sheet after the 3rd saved image (rules above).
- Pro screen and purchases move to phase 7, with Play Console setup.
- Translations: review sheet for native speakers.
- Privacy policy: Claude drafts, Francisco reviews and hosts.
- Feedback goes to a GitHub issue; invite link is the Play Store URL.

Answered 15 Nov 2026 for phase 7:
- Pro = no watermark + themes added from now on; launch themes free.
  Price: US$ 2.99 tier.
- No Play Console account yet; Francisco will create it (checklist).
- App icon: the design's r4s tile.
- Claude generated the upload key; Francisco backs it up.
- Official Strava brand assets; no crash-reporting service.
- Health sources by platform (Francisco, 15 Nov): Apple Health only on
  iOS, Health Connect only on Android.

## Open questions (ask Francisco, don't assume)

Still open from design: invite reward, Effort formula.

## How Francisco works

- VS Code, tests on his Android phone; iOS verified late on his Mac.
- Wants to be asked questions rather than have things assumed.
- Never claim something works on a device until he has confirmed it.
- Strava secrets never go into the repo.
- Repo: https://github.com/FranciscoSouza/run4share.git
- Conversations in English or Brazilian Portuguese.
