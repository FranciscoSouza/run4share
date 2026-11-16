# Template pictures

Each template ships with an original flat illustration (no people, no
licence to track; see `CREDITS.md`), one portrait JPG per template named
by its id, 1080 × 1920. They come from `tool/art/generate_art.py`.

Composition: the top third is sky or calm background, the main feature
(road, trail, track, skyline) is in the middle, the bottom is plain
ground. Each template's sticker position (`position` and extras'
`center` in `lib/features/editor/sticker_theme.dart`) is set to suit its
picture; check it again after changing one.

To replace one with a real photo: keep the same file name, at least
1080 × 1920 and at most 450 KB, and record the source URL, photographer
and licence (Unsplash or Pexels licence; no competitor or Strava
imagery) in `CREDITS.md`.

`templatePhotos` in `sticker_theme.dart` lists the files present; a test
fails if one is missing from the bundle.
