import 'package:run4share/app/material.dart';
import 'package:run4share/features/create/creation_draft.dart';

/// What a sticker can show. [rate] is pace on foot and speed on wheels.
enum Metric { distance, time, rate, heartRate, calories }

/// How a sticker arranges its metrics. Each layout is drawn by
/// `StickerView`; new themes reuse layouts with other metrics or styles.
enum StickerLayout {
  /// Metrics side by side: label above value.
  inline,

  /// Metrics one below the other, left-aligned.
  stack,

  /// One huge value with "RUN · THURSDAY" under it.
  hero,

  /// Each metric in a coloured box.
  poster,

  /// One value inside a ring.
  ring,

  /// One small value above a huge weekday.
  weekday,

  /// A race-number card: name on top, the first metric as the number,
  /// the others underneath, pin holes in the corners.
  bib,

  /// A till receipt: name and date, the other metrics as line items, the
  /// first as the total, a barcode at the bottom.
  receipt,

  /// A stadium board: each metric lit in its own dark box.
  scoreboard,
}

/// One theme = one whole sticker: layout plus the metrics it shows. The
/// metric list is authoritative: a theme is only offered when the activity
/// has every metric it needs.
@immutable
class StickerTheme {
  const StickerTheme({
    required this.id,
    required this.name,
    required this.layout,
    required this.metrics,
    required this.position,
    this.colour = StickerColour.white,
    this.pro = false,
  });

  final String id;

  /// Shown under the thumbnail; a product name, not translated.
  final String name;
  final StickerLayout layout;
  final List<Metric> metrics;

  /// Where the sticker's centre starts, as fractions of the canvas.
  final Offset position;

  /// The theme's own colour, used until the user picks another.
  final StickerColour colour;

  /// Pro only. The seven launch themes are free; themes added later can
  /// be Pro (decided 15 Nov 2026).
  final bool pro;
}

/// The catalogue, in carousel order.
const stickerThemes = <StickerTheme>[
  StickerTheme(
    id: 'inline-top',
    name: 'Inline Top',
    layout: StickerLayout.inline,
    metrics: [Metric.distance, Metric.time, Metric.rate],
    position: Offset(0.5, 0.72),
  ),
  StickerTheme(
    id: 'vertical-stack',
    name: 'Vertical Stack',
    layout: StickerLayout.stack,
    metrics: [Metric.distance, Metric.time, Metric.rate],
    position: Offset(0.32, 0.36),
  ),
  StickerTheme(
    id: 'big-distance',
    name: 'Big Distance',
    layout: StickerLayout.hero,
    metrics: [Metric.distance],
    position: Offset(0.5, 0.2),
  ),
  StickerTheme(
    id: 'poster',
    name: 'Poster',
    layout: StickerLayout.poster,
    metrics: [Metric.distance, Metric.time, Metric.rate],
    position: Offset(0.62, 0.5),
    colour: StickerColour.amber,
  ),
  StickerTheme(
    id: 'heart-ring',
    name: 'Heart Ring',
    layout: StickerLayout.ring,
    metrics: [Metric.heartRate],
    position: Offset(0.5, 0.42),
  ),
  StickerTheme(
    id: 'weekday',
    name: 'Weekday',
    layout: StickerLayout.weekday,
    metrics: [Metric.distance],
    position: Offset(0.5, 0.62),
  ),
  StickerTheme(
    id: 'time-calories',
    name: 'Time & Calories',
    layout: StickerLayout.inline,
    metrics: [Metric.time, Metric.calories],
    position: Offset(0.5, 0.72),
  ),
  // Phase 12: the first Pro themes.
  StickerTheme(
    id: 'race-bib',
    name: 'Race Bib',
    layout: StickerLayout.bib,
    metrics: [Metric.distance, Metric.time, Metric.rate],
    position: Offset(0.5, 0.7),
    pro: true,
  ),
  StickerTheme(
    id: 'receipt',
    name: 'Receipt',
    layout: StickerLayout.receipt,
    metrics: [Metric.distance, Metric.time, Metric.rate],
    position: Offset(0.5, 0.6),
    pro: true,
  ),
  StickerTheme(
    id: 'scoreboard',
    name: 'Scoreboard',
    layout: StickerLayout.scoreboard,
    metrics: [Metric.distance, Metric.time, Metric.rate],
    position: Offset(0.5, 0.76),
    colour: StickerColour.amber,
    pro: true,
  ),
];

StickerTheme? themeById(String? id) {
  for (final theme in stickerThemes) {
    if (theme.id == id) return theme;
  }
  return null;
}

/// A Popular template: a theme in a format, with sample background art.
@immutable
class StoryTemplate {
  const StoryTemplate({
    required this.id,
    required this.name,
    required this.themeId,
    required this.format,
    required this.colours,
  });

  final String id;
  final String name;
  final String themeId;
  final ShareFormat format;

  /// Gradient standing in for a photo in previews.
  final List<Color> colours;

  StickerTheme get theme => themeById(themeId)!;
}

const storyTemplates = <StoryTemplate>[
  StoryTemplate(
    id: 'story-hero',
    name: 'Story Hero',
    themeId: 'big-distance',
    format: ShareFormat.story,
    colours: [Color(0xFF4A9AD8), Color(0xFF8CC4EC), Color(0xFF3F7A6A)],
  ),
  StoryTemplate(
    id: 'top-line',
    name: 'Top Line',
    themeId: 'inline-top',
    format: ShareFormat.story,
    colours: [Color(0xFF6A3F9A), Color(0xFF2A1F45), Color(0xFF1A1426)],
  ),
  StoryTemplate(
    id: 'left-stack',
    name: 'Left Stack',
    themeId: 'vertical-stack',
    format: ShareFormat.story,
    colours: [Color(0xFF1E3F6E), Color(0xFF27406B), Color(0xFFB8492F)],
  ),
  StoryTemplate(
    id: 'race-poster',
    name: 'Race Poster',
    themeId: 'poster',
    format: ShareFormat.story,
    colours: [Color(0xFF6B4E7A), Color(0xFFC07A5A), Color(0xFF2A2235)],
  ),
];

StoryTemplate? templateById(String? id) {
  for (final template in storyTemplates) {
    if (template.id == id) return template;
  }
  return null;
}
