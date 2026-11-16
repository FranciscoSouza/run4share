import 'package:run4share/app/material.dart';
import 'package:run4share/features/activities/activity_format.dart'
    show SportKind;
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

/// An extra sticker a template places with its theme.
@immutable
class TemplateExtra {
  const TemplateExtra({
    required this.kind,
    required this.center,
    this.value = '',
    this.scale = 1,
    this.rotation = 0,
  });

  final ExtraKind kind;

  /// As in `ExtraSticker.value` (a route style, a label...).
  final String value;

  /// Fractions of the canvas.
  final Offset center;
  final double scale;

  /// Radians, clockwise.
  final double rotation;
}

/// Pictures under assets/templates/ that exist (see the README there):
/// the app's own illustrations since phase 18. A template not listed
/// keeps its gradient.
const templatePhotos = <String>{
  'sunrise-half',
  'summit-day',
  'mountain-climb',
  'final-score',
  'race-day',
  'run-receipt',
  'coast-walk',
  'story-hero',
  'top-line',
  'left-stack',
  'race-poster',
};

/// A Popular template: a theme in a format, with sample art, for one sport,
/// optionally with extra stickers (charts, route, labels).
@immutable
class StoryTemplate {
  const StoryTemplate({
    required this.id,
    required this.name,
    required this.themeId,
    required this.format,
    required this.colours,
    this.sport = SportKind.run,
    this.extras = const [],
    this.featured = false,
    this.proOnly = false,
    this.position,
    this.style = const StickerStyle(),
  });

  final String id;
  final String name;
  final String themeId;
  final ShareFormat format;

  /// Gradient standing in for a photo until there is one.
  final List<Color> colours;

  /// The sport the sample data and photo show.
  final SportKind sport;

  /// Extra stickers placed with the theme.
  final List<TemplateExtra> extras;

  /// Shown in the Home carousel (others only in See all).
  final bool featured;

  /// Pro even though its theme is free (Francisco, 16 Nov 2026: Summit
  /// Day and Mountain Climb; Sunrise Half and Coast Walk stay free, their
  /// extras then need Pro only to export).
  final bool proOnly;

  StickerTheme get theme => themeById(themeId)!;

  /// Where this template puts the theme sticker, to suit its picture;
  /// null uses the theme's own position (Francisco, 16 Nov 2026).
  final Offset? position;

  /// Colour and backing for the theme sticker, carried into the editor
  /// when the template is used (a soft backing where the sky is pale).
  final StickerStyle style;

  /// The theme sticker's centre: the template's, else the theme's.
  Offset get stickerCenter => position ?? theme.position;

  /// Pro when its theme is, or when marked so.
  bool get pro => theme.pro || proOnly;

  /// `assets/templates/<id>.jpg` when present; null → gradient [colours].
  String? get photo =>
      templatePhotos.contains(id) ? 'assets/templates/$id.jpg' : null;
}

/// The catalogue: the seven featured ones in carousel order, then the
/// four free ones (docs/home_templates.md). Positions suit each picture
/// (docs/illustrations.md): stickers on sky or plain ground, clear of
/// busy middles and banners.
const storyTemplates = <StoryTemplate>[
  StoryTemplate(
    id: 'sunrise-half',
    name: 'Sunrise Half',
    themeId: 'big-distance',
    format: ShareFormat.story,
    colours: [Color(0xFFF0A65A), Color(0xFFB8653A), Color(0xFF6E3B2A)],
    featured: true,
    extras: [
      TemplateExtra(
        kind: ExtraKind.pace,
        center: Offset(0.5, 0.86),
        scale: 0.9,
      ),
    ],
  ),
  StoryTemplate(
    id: 'summit-day',
    name: 'Summit Day',
    themeId: 'vertical-stack',
    format: ShareFormat.story,
    colours: [Color(0xFFC9DCE6), Color(0xFF7A9A86), Color(0xFF3E5A48)],
    sport: SportKind.hike,
    featured: true,
    proOnly: true,
    extras: [
      TemplateExtra(
        kind: ExtraKind.elevation,
        center: Offset(0.5, 0.84),
        scale: 0.95,
      ),
    ],
  ),
  StoryTemplate(
    id: 'mountain-climb',
    name: 'Mountain Climb',
    themeId: 'inline-top',
    format: ShareFormat.story,
    colours: [Color(0xFF8CC2E8), Color(0xFF5A7A8C), Color(0xFF3F7A66)],
    position: Offset(0.5, 0.07),
    sport: SportKind.ride,
    featured: true,
    proOnly: true,
    extras: [
      TemplateExtra(
        kind: ExtraKind.route,
        value: 'glow',
        center: Offset(0.5, 0.48),
        scale: 0.9,
      ),
    ],
  ),
  StoryTemplate(
    id: 'final-score',
    name: 'Night Run',
    themeId: 'scoreboard',
    format: ShareFormat.story,
    colours: [Color(0xFF1F2A44), Color(0xFF2B3560), Color(0xFF0E1220)],
    position: Offset(0.5, 0.86),
    featured: true,
    extras: [
      TemplateExtra(
        kind: ExtraKind.heartRate,
        // Below the corner where the PRO badge sits.
        center: Offset(0.5, 0.2),
        scale: 0.9,
      ),
    ],
  ),
  StoryTemplate(
    id: 'race-day',
    name: 'Race Day',
    themeId: 'race-bib',
    format: ShareFormat.story,
    colours: [Color(0xFF5FACDB), Color(0xFF7FB3C8), Color(0xFFC0533A)],
    featured: true,
    extras: [
      TemplateExtra(
        kind: ExtraKind.label,
        value: 'record',
        center: Offset(0.74, 0.56),
        scale: 1.2,
        rotation: 0.1,
      ),
    ],
  ),
  StoryTemplate(
    id: 'run-receipt',
    name: 'Run Receipt',
    themeId: 'receipt',
    format: ShareFormat.story,
    colours: [Color(0xFFF0A65A), Color(0xFFB8653A), Color(0xFF6E3B2A)],
    featured: true,
  ),
  StoryTemplate(
    id: 'coast-walk',
    name: 'Coast Walk',
    themeId: 'big-distance',
    format: ShareFormat.story,
    colours: [Color(0xFFBFD8E6), Color(0xFF2E92CE), Color(0xFFC9B48A)],
    sport: SportKind.walk,
    featured: true,
    extras: [
      TemplateExtra(
        kind: ExtraKind.route,
        value: 'glow',
        center: Offset(0.5, 0.56),
        scale: 0.9,
      ),
    ],
  ),
  StoryTemplate(
    id: 'story-hero',
    name: 'Story Hero',
    themeId: 'big-distance',
    format: ShareFormat.story,
    colours: [Color(0xFF4A9AD8), Color(0xFF8CC4EC), Color(0xFF3F7A6A)],
    // Pale sky: a soft dark backing keeps the white text readable.
    style: StickerStyle(background: 0.3),
  ),
  StoryTemplate(
    id: 'top-line',
    name: 'Top Line',
    themeId: 'inline-top',
    format: ShareFormat.story,
    colours: [Color(0xFF6A3F9A), Color(0xFF2A1F45), Color(0xFF1A1426)],
    // Pale sky: a soft dark backing keeps the white text readable.
    style: StickerStyle(background: 0.3),
    position: Offset(0.5, 0.07),
    sport: SportKind.ride,
  ),
  StoryTemplate(
    id: 'left-stack',
    name: 'Left Stack',
    themeId: 'vertical-stack',
    format: ShareFormat.story,
    colours: [Color(0xFF1E3F6E), Color(0xFF27406B), Color(0xFFB8492F)],
    position: Offset(0.3, 0.52),
  ),
  StoryTemplate(
    id: 'race-poster',
    name: 'Race Poster',
    themeId: 'poster',
    format: ShareFormat.story,
    colours: [Color(0xFF6B4E7A), Color(0xFFC07A5A), Color(0xFF2A2235)],
    position: Offset(0.6, 0.82),
  ),
];

/// The Home carousel's templates, in order.
final List<StoryTemplate> featuredTemplates = [
  for (final t in storyTemplates)
    if (t.featured) t,
];

StoryTemplate? templateById(String? id) {
  for (final template in storyTemplates) {
    if (template.id == id) return template;
  }
  return null;
}
