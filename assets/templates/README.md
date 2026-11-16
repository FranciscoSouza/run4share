# Template photos

One portrait JPG per template, named by its id, at least 1080 × 1920 and
at most 450 KB. Francisco's own photos, or photos whose licence allows
use in an app (Unsplash or Pexels licence): record each one's source URL
and photographer in `CREDITS.md` here. No competitor or Strava imagery.
Each photo needs calm areas where that template's sticker and extras sit
(see `design/Home · template tiles.png`).

| File | Template | Shows |
|---|---|---|
| `sunrise-half.jpg` | Sunrise Half | a run at sunrise |
| `summit-day.jpg` | Summit Day | a hike, mountains |
| `mountain-climb.jpg` | Mountain Climb | a ride, mountain road |
| `final-score.jpg` | Night Run | a run at night, city |
| `race-day.jpg` | Race Day | a race, track or start line |
| `run-receipt.jpg` | Run Receipt | a run, warm light |
| `coast-walk.jpg` | Coast Walk | a walk by the sea |
| `story-hero.jpg` | Story Hero | a run |
| `top-line.jpg` | Top Line | a ride |
| `left-stack.jpg` | Left Stack | a run |
| `race-poster.jpg` | Race Poster | a run, evening |

After adding one, put its id in `templatePhotos` in
`lib/features/editor/sticker_theme.dart`. Until then the template keeps
its gradient.
