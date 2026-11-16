# Home: featured templates carousel, instructions for Claude Code

_16 Nov 2026 · written against commit `a326d77` (Phase 14) · design chosen by
Francisco: **Option A · Featured carousel**_

Read `CLAUDE.md` first; every rule there still holds (Material only through
`lib/app/material.dart`, Lucide icons via `AppIcons`, five languages, tests,
an Android build Francisco confirms before committing).

## Design files (source of truth for look)

| File | What it shows |
|---|---|
| `design/Home · templates carousel.png` | Home with the carousel, first template centred |
| `design/Home · templates carousel 2.png` | Same after one swipe (a Pro template centred, Pro badge) |
| `design/Home · template tiles.png` | The 7 new or updated template looks: photo + theme + extra stickers |

Interactive version (owner's account): https://claude.ai/artifact/UYK9kUs3877p8gQw6TSJD2, artboard "Option A · Featured carousel".

The PNGs show intent. In the app every tile is drawn live by `StoryCanvas` with sample data, so exact text and positions follow the real themes and stickers. Don't hand-draw stickers to match the PNGs. The illustrated people and landscapes are placeholders for real photos (see Photos).

## What changes

Today Home shows `_TemplateCarousel` in `lib/features/home/home_screen.dart`: tiles of 100×178 with a gradient and only the theme sticker. Replace it with:

1. **Header row:** "Make posts like these" (heading style as today) and a **See all** text button on the right, which opens a new **Templates** screen.
2. **Featured carousel**, one template at a time:
   - The centre card is 9:16, its width `clamp(screenWidth × 0.565, 200, 280)` (220 on a 390-wide phone), corner radius 18, soft shadow.
   - The previous and next cards peek at both sides at 0.82 scale and 0.85 opacity, vertically centred.
   - Build it with a `PageView.builder` (`viewportFraction` = centre width ÷ screen width, plus a gap of 12). Scale and opacity are interpolated from `controller.page` in an `AnimatedBuilder`, so cards grow and shrink with the finger rather than jumping.
   - It loops: `itemCount` large, index `% featured.length`, starting in the middle.
   - Tapping a side card animates it to the centre. Tapping the centre card opens the existing template preview (`AppRoutes.template(id)`).
   - **Auto-advance** every 5 s. It stops for 10 s after any touch, while Home isn't the visible route or the app isn't resumed, and entirely when `MediaQuery.disableAnimationsOf(context)` or `MediaQuery.accessibleNavigationOf(context)` is true.
3. **Under the carousel**, following the centred template:
   - Its **name** (Barlow Condensed 700, 24).
   - A **"what" line** in neutral40, 14: sport · main extra · Pro, for example "Hike · Elevation · Pro".
   - **Page dots** on the right: active 18×6 in brand blue, others 6×6 in neutral80, at most one dot per featured template.
4. **Use this template:** a full-width 52 px primary button. It does exactly what the preview screen's button does: Pro template without Pro → `AppRoutes.pro`, otherwise → `AppRoutes.templateActivity(id)`. Copy that rule from `template_preview_screen.dart` (~line 135) into one shared helper; don't duplicate it.
5. "Your activities" and the list follow unchanged.

Remove the old tile constants and widget. `TemplateCanvas` stays and grows (below).

### Templates screen (See all)

`/templates` (`AppRoutes.templates`), title "Templates". A 2-column grid of every template: the same live tile at column width, the name under it, a Pro badge when locked. Tap → template preview. Keep it simple: no sport filter in this work.

## Templates gain a sport, a photo and extra stickers

`StoryTemplate` in `lib/features/editor/sticker_theme.dart` gets:

```dart
  /// The sport the sample data and photo show.
  final SportKind sport;

  /// assets/templates/<id>.jpg when present; null → gradient [colours].
  final String? photo;

  /// Extra stickers placed with the theme (charts, route, labels).
  final List<TemplateExtra> extras;

  /// Shown in the Home carousel (others only in See all).
  final bool featured;

  /// Pro when the theme is Pro or any extra is (extras are Pro stickers).
  bool get pro => theme.pro || extras.isNotEmpty;
```

`TemplateExtra` (same file): `kind` (`ExtraKind`), `value` (as in `ExtraSticker.value`), `center` (fractions of the canvas), `scale`, `rotation`.

### The catalogue

Keep every existing id (other code and tests use them). The first seven are featured, in this order:

| id | Name | Sport | Theme | Extras | Pro |
|---|---|---|---|---|---|
| `sunrise-half` (new) | Sunrise Half | run | `big-distance` | `pace` chart near the bottom | yes |
| `summit-day` (new) | Summit Day | hike | `vertical-stack` | `elevation` along the bottom | yes |
| `mountain-climb` (new) | Mountain Climb | ride | `inline-top` | `route` in the middle | yes |
| `final-score` | Night Run (rename) | run | `scoreboard` | `heartRate` chart at the top | yes |
| `race-day` | Race Day | run | `race-bib` | `label` → `record` | yes |
| `run-receipt` | Run Receipt | run | `receipt` | none | yes |
| `coast-walk` (new) | Coast Walk | walk | `big-distance` | `route` in the middle | yes |
| `story-hero` | Story Hero | run | `big-distance` | none | no |
| `top-line` | Top Line | ride | `inline-top` | none | no |
| `left-stack` | Left Stack | run | `vertical-stack` | none | no |
| `race-poster` | Race Poster | run | `poster` | none | no |

Free users still have four templates (the last four), now with photos. Tune the extras' `center`/`scale` on the phone until they sit like `design/Home · template tiles.png`.

**"What" line text:** the sport's existing name (`typeRun`, `typeRide`, `typeHike`, `typeWalk`), then the first extra's name if any (reuse the names the "Your data" / Stickers panels already show), then "Pro" when locked. Joined with " · ".

### Sample data per sport

`TemplateCanvas` uses one `sampleActivity` (a run, no charts). Templates now need a run, a ride, a hike and a walk, each with a route, splits, elevation and streams.

- Generalise `lib/features/onboarding/onboarding_sample.dart` into `lib/features/templates/template_samples.dart`, with `Activity sampleActivityFor(SportKind sport)` and `StickerFacts sampleFactsFor(SportKind sport, …)`.
- Build them from the Laboratory demo data in `strava_demo.dart`, which already has a ride ("Evening Ride") and routes.
- Make onboarding use the new file, so there's one source.
- Keep `sampleActivity` working for anything else that uses it.

`TemplateCanvas` then passes `extras:` (built from `template.extras` with stable ids) and the photo as `background` (`Image.asset(fit: BoxFit.cover)`), falling back to today's gradient.

### Using a template carries its extras into the editor

Where the crop/editor steps read `templateChoiceProvider` (`crop_screen.dart` ~lines 58 and 101) and create the draft with the template's theme, also add the template's extras as `ExtraSticker`s at their placements.

If the chosen activity lacks the data for an extra (no heart rate, no route, no elevation), leave that extra out. Show a single snackbar in the editor, for example "Heart rate isn't in this activity, so its chart was left out." The theme's own metrics still decide which activities can be picked (`missingFor`, unchanged).

## Photos

- Put them in `assets/templates/<id>.jpg`: portrait, at least 1080×1920, ≤ 450 KB, and add the folder to `pubspec.yaml`.
- Francisco supplies them: his own photos, or photos under a licence that allows use in an app (Unsplash or Pexels licence; keep the source URL and photographer's name in `assets/templates/CREDITS.md`). No competitor or Strava imagery.
- Each photo needs calm areas where that template's sticker and extras sit.
- Until a photo exists, the template keeps its gradient. List the expected files in `assets/templates/README.md`.
- Precache the first three featured photos when Home builds, so the carousel doesn't flash.

## Texts (ARB, all five languages)

| Key | en | pt (BR) |
|---|---|---|
| `homeTemplatesTitle` | Make posts like these | Crie posts como estes |
| `homeSeeAll` | See all | Ver todos |
| `homeTemplateOf` | Template {index} of {total} | Modelo {index} de {total} |
| `templatesTitle` | Templates | Modelos |
| `templateExtraMissing` | {thing} isn't in this activity, so it was left out. | {thing} não está nesta atividade, então ficou de fora. |
| `templateNameSunriseHalf` … | Template names stay English product names (like today's theme names); no keys needed. | |

`templateUse` ("Use this template" / "Usar este modelo") already exists; reuse it. Remove `homePopularTemplates` if nothing else uses it. Write es/fr/de, then `python3 tool/translations.py export` for review.

## Accessibility

- Each card is a button whose semantics label is "name, what line" (for example "Summit Day, Hike · Elevation · Pro"). The canvas inside is `ExcludeSemantics`, as today.
- The carousel announces "Template {index} of {total}" on page change (`SemanticsService.announce`), but not on auto-advance.
- With TalkBack, auto-advance is off and side cards stay reachable as buttons.
- Large text: name and "what" line wrap to 2 lines at most (ellipsis); the button keeps 52 px minimum.

## Tests

| Test | Checks |
|---|---|
| `test/home/template_carousel_test.dart` | shows the featured templates in order; swipe changes name, "what" line and dots; tapping a side card centres it; tapping the centre opens the preview; Use this template → template activity (free or with Pro) or Pro screen (locked Pro); auto-advance after 5 s; no auto-advance with `disableAnimations` or `accessibleNavigation`; pauses after a touch |
| `test/templates/templates_screen_test.dart` | See all lists every template in 2 columns; Pro badge only when locked; tap → preview |
| `test/templates/template_catalogue_test.dart` | ids unique; every `themeId` exists; `pro` true when any extra; every featured template draws in km and mi, in all five locales, without exceptions; missing photo → gradient |
| `test/templates/template_extras_test.dart` | choosing a template adds its extras to the draft; an activity without heart rate drops the HR extra and shows the note once |
| existing Home and template flow tests | updated for the new widget and names |

## Check-points on Francisco's phone

1. Home: the carousel is the first thing seen; swiping feels smooth (no stutter on the Galaxy S22) and cards grow and shrink with the finger.
2. Auto-advance runs, stops when touched, and doesn't run with Remove animations (Android › Accessibility) on.
3. Use this template on a free template goes to choosing an activity; on a Pro one without Pro (Laboratory › Pretend Pro off) goes to Pro.
4. A template with a chart, used on a run with heart rate, shows the chart in the editor. Used on a manual activity, it shows the "left out" note.
5. See all opens the grid; every tile draws.
6. With Francisco's photos added: stickers and charts sit on calm parts of each photo.

When done, add a **Phase 15 status (Home templates)** block to `CLAUDE.md` in the same style as the others.
