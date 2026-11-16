# Template and onboarding illustrations: instructions for Claude Code

_16 Nov 2026 · written against commit `e15562c` (Phase 17)_

Read `CLAUDE.md` first; its rules still hold.

## What's new in the repo

15 original flat landscape illustrations in one style, with no people in them (mountains, mountain and country roads, coast, city by day and night, running track, park, forest, lake), 1080×1920 JPG, 34–124 KB each. All are the app's own artwork: no licence to track.

| Folder | Files |
|---|---|
| `assets/templates/` | `sunrise-half.jpg`, `summit-day.jpg`, `mountain-climb.jpg`, `final-score.jpg`, `race-day.jpg`, `run-receipt.jpg`, `coast-walk.jpg`, `story-hero.jpg`, `top-line.jpg`, `left-stack.jpg`, `race-poster.jpg`, `CREDITS.md` |
| `assets/onboarding/` | `page1.jpg` (lake at blue hour), `page2.jpg` (forest clearing), `page3.jpg` (city street, dusk), `page4.jpg` (mountain trail at night), `CREDITS.md` (copy of the templates one) |
| `design/Illustrations sheet.png` | all 15 side by side, for reference |
| `tool/art/generate_art.py` | the generator, to tweak or add scenes later |

Composition rule used in every image: the top third is sky or calm background for stickers and charts, the main feature (road, trail, track, skyline) sits in the middle, and the bottom is plain ground. There are deliberately no people: Francisco decided against figures (16 Nov 2026).

## Steps

1. **Turn the images on.**
   - `lib/features/editor/sticker_theme.dart`: set `templatePhotos` to all eleven template ids above.
   - `lib/features/onboarding/onboarding_art.dart`: set `onboardingPhotos` to `['page1.jpg', 'page2.jpg', 'page3.jpg', 'page4.jpg']`.

   Nothing else in the loading code should need to change; it already reads `assets/templates/<id>.jpg` and `assets/onboarding/pageN.jpg`.
2. **Check that every template's stickers sit well on its picture** (Home carousel, See all, template preview), and adjust only `position` / extras `center` and `scale` in the template entries:
   - Text and charts must stay readable over the picture (sky and ground are the calm areas).
   - `final-score` (night city) is busy behind the middle. Keep the scoreboard low, as designed.
   - `race-day` and `race-poster` have a banner across the upper middle. Keep the bib or poster sticker clear of it, or over it on purpose; just not half on it.
   - `mountain-climb` and `top-line` have the road in the lower half. The `inline-top` stats belong at the top.
3. **Onboarding** uses the 4:5 crop of each picture (`BoxFit.cover`), so the middle of each picture stays in view. Check page 4 (dark): white sticker text must stay readable, and the heart-rate chart in red must stand out. Raise the sticker background only if it doesn't.
4. **Readme files:** update `assets/templates/README.md` and `assets/onboarding/README.md`. They now ship with illustrations; to replace one with a real photo, keep the same name and record it in `CREDITS.md`.
5. **Precache:** Home should already precache the first three featured template images (Phase 16). Confirm it does, and add precaching for onboarding page 1 in `OnboardingScreen`.
6. **App size:** about 0.9 MB in total. Note it in the Phase 18 status in `CLAUDE.md`.

## Tests

- A test that every id in `templatePhotos` and every name in `onboardingPhotos` has its file in the asset bundle (`rootBundle.load` in a widget test), so a renamed file fails CI instead of showing a blank.
- The existing template catalogue and onboarding art tests still pass, now drawing with the images.
- If golden tests exist for template tiles, regenerate them and look at the diffs before accepting.

## Check-points on Francisco's phone

1. Home carousel: every card shows its picture. Swiping stays smooth, and no image flashes in late.
2. See all: all 11 tiles have pictures.
3. Onboarding (Settings › Show introduction again): all 4 pages have pictures, and the text stays readable on page 4.
4. Create a post from a template: the template picture is only the sample in the preview. The editor still uses the user's own photo.

When done, add a **Phase 18 status (illustrations)** block to `CLAUDE.md`.
