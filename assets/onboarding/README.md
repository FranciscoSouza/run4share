# Onboarding pictures

Pages 1-4 of the introduction ship with original flat illustrations
(`page1.jpg` lake at blue hour, `page2.jpg` forest clearing, `page3.jpg`
city street at dusk, `page4.jpg` mountain trail at night), 1080 × 1920,
from `tool/art/generate_art.py`. The art shows them in a 4:5 crop, so
their middle is what's seen. No licence to track (see `CREDITS.md`).

To replace one with a real photo: keep the same name, portrait, at least
1080 px wide and at most 400 KB, with calm areas at the top and bottom
where the stickers sit, and record its source in `CREDITS.md`.

`onboardingPhotos` in `lib/features/onboarding/onboarding_art.dart`
lists the files present; a test fails if one is missing from the bundle.
