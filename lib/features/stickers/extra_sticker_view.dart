import 'dart:math' as math;

import 'package:intl/intl.dart' show DateFormat;
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/story_canvas.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/chart_data.dart';
import 'package:run4share/features/stickers/data_sticker_views.dart';
import 'package:run4share/features/stickers/sticker_catalogue.dart';
import 'package:run4share/l10n/l10n.dart';

const _shadow = [
  Shadow(color: Color(0x59000000), blurRadius: 14, offset: Offset(0, 3)),
];

/// What the data stickers draw from: the activity, its shoe, the units.
@immutable
class StickerFacts {
  StickerFacts({
    required this.activity,
    this.units = Units.km,
    this.gear,
  }) : charts = ActivityCharts.of(
          streamsJson: activity.streamsJson,
          elevationJson: activity.elevationJson,
          units: units,
        );

  final Activity activity;
  final Units units;
  final Gear? gear;

  /// Heart rate, pace and elevation, worked out once from the cached
  /// streams; widgets only draw them.
  final ActivityCharts charts;

  StickerFacts withUnits(Units units) =>
      StickerFacts(activity: activity, units: units, gear: gear);
}

/// Draws one extra sticker at canvas units (1080-wide canvas), like the
/// theme stickers, so it scales the same in the editor and the export.
class ExtraStickerView extends StatelessWidget {
  const ExtraStickerView({
    required this.kind,
    required this.value,
    required this.facts,
    this.colour,
    super.key,
  });

  final ExtraKind kind;
  final String value;
  final StickerFacts facts;

  /// Null: the kind's own colour.
  final StickerColour? colour;

  @override
  Widget build(BuildContext context) =>
      // Part of an image: the phone's font size never changes it.
      MediaQuery.withNoTextScaling(child: Builder(builder: _sticker));

  Widget _sticker(BuildContext context) {
    final l10n = context.l10n;
    final c = colour ?? defaultColour(kind, value);
    final activity = facts.activity;
    return DefaultTextStyle(
      style: const TextStyle(),
      child: switch (kind) {
        ExtraKind.label => _Badge(
            text: labelFromValue(value) == null
                ? value
                : labelText(l10n, labelFromValue(value)!),
            icon: labelFromValue(value) == null
                ? AppIcons.trophy
                : labelIcon(labelFromValue(value)!.kind),
            fill: c,
          ),
        ExtraKind.time => _Time(start: activity.startLocal, colour: c),
        ExtraKind.shoe => switch (facts.gear) {
            final gear? => ShoeSticker(
                gear: gear,
                units: facts.units,
                colour: c.color,
              ),
            null => const SizedBox.shrink(),
          },
        ExtraKind.route => switch (activity.polyline) {
            final line? => RouteSticker(
                polyline: line,
                style: RouteStyle.values.asNameMap()[value] ?? RouteStyle.neon,
                colour: c.color,
              ),
            null => const SizedBox.shrink(),
          },
        ExtraKind.elevation => switch (facts.charts.elevation) {
            final chart? => ElevationSticker(
                chart: chart,
                colour: c.color,
                climb: elevationGainShown(chart, activity.elevationGain),
              ),
            null => const SizedBox.shrink(),
          },
        ExtraKind.heartRate => switch (facts.charts.heartRate) {
            final chart? => HeartRateSticker(chart: chart, colour: c.color),
            null => const SizedBox.shrink(),
          },
        ExtraKind.pace => switch (facts.charts.pace) {
            final chart? => PaceSticker(chart: chart, colour: c.color),
            null => const SizedBox.shrink(),
          },
        ExtraKind.splits => switch (activity.splitsJson) {
            final json? => SplitsSticker(
                json: json,
                units: facts.units,
                colour: c.color,
              ),
            null => const SizedBox.shrink(),
          },
        ExtraKind.phrase => _Phrase(
            text: phraseText(l10n, value) ?? value,
            colour: c,
          ),
        ExtraKind.stamp => switch (StampKind.values.asNameMap()[value]) {
            final stamp? when stamp.seal => _Seal(
                text: stampText(l10n, stamp),
                icon: stampIcon(stamp),
                colour: c,
              ),
            final stamp? => _Stamp(
                text: stampText(l10n, stamp),
                icon: stampIcon(stamp),
                colour: c,
              ),
            null => const SizedBox.shrink(),
          },
      },
    );
  }
}

TextStyle _bold(double size, Color colour, {bool shadow = true}) =>
    AppText.stickerValue.copyWith(
      fontSize: size,
      height: 1,
      fontWeight: FontWeight.w800,
      fontStyle: FontStyle.italic,
      color: colour,
      shadows: shadow ? _shadow : null,
    );

/// RECORD, LONG RUN, RACE DAY, SUB-25: a filled pill with an icon.
class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.icon, required this.fill});

  final String text;
  final IconData icon;
  final StickerColour fill;

  @override
  Widget build(BuildContext context) {
    final ink = fill.isLight ? AppColors.neutral0 : AppColors.neutral100;
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 22, 48, 22),
      decoration: BoxDecoration(
        color: fill.color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: ink),
          const SizedBox(width: 22),
          Text(
            text.toUpperCase(),
            style: _bold(76, ink, shadow: false),
          ),
        ],
      ),
    );
  }
}

/// The start time with the moment of the day.
class _Time extends StatelessWidget {
  const _Time({required this.start, required this.colour});

  final DateTime start;
  final StickerColour colour;

  IconData get _icon => switch (start.hour) {
        >= 5 && < 8 => AppIcons.sunrise,
        >= 8 && < 18 => AppIcons.sun,
        >= 18 && < 21 => AppIcons.sunset,
        _ => AppIcons.moon,
      };

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final c = colour.color;
    final shadow = colour.isLight;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 110, color: c, shadows: shadow ? _shadow : null),
        const SizedBox(width: 28),
        Text(
          DateFormat.Hm(locale).format(start),
          style: _bold(170, c, shadow: shadow).copyWith(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
          ),
        ),
      ],
    );
  }
}

class _Phrase extends StatelessWidget {
  const _Phrase({required this.text, required this.colour});

  final String text;
  final StickerColour colour;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 860),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: _bold(
          96,
          colour.color,
          shadow: colour.isLight,
        ).copyWith(height: 1.05),
      ),
    );
  }
}

/// A rubber stamp: double border, slightly rough letters.
class _Stamp extends StatelessWidget {
  const _Stamp({required this.text, required this.icon, required this.colour});

  final String text;
  final IconData icon;
  final StickerColour colour;

  @override
  Widget build(BuildContext context) {
    final c = colour.color;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: c, width: 10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(34, 18, 40, 18),
        decoration: BoxDecoration(
          border: Border.all(color: c, width: 4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: c),
            const SizedBox(width: 20),
            Text(text.toUpperCase(), style: _bold(96, c, shadow: false)),
          ],
        ),
      ),
    );
  }
}

/// A round seal: two rings, the text around them, an icon in the middle.
class _Seal extends StatelessWidget {
  const _Seal({required this.text, required this.icon, required this.colour});

  final String text;
  final IconData icon;
  final StickerColour colour;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 440,
      child: CustomPaint(
        painter: _SealPainter(text: text.toUpperCase(), colour: colour.color),
        child: Center(child: Icon(icon, size: 130, color: colour.color)),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  const _SealPainter({required this.text, required this.colour});

  final String text;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.width / 2 - 8;
    final ring = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke;
    canvas
      ..drawCircle(center, outer, ring..strokeWidth = 12)
      ..drawCircle(center, outer - 84, ring..strokeWidth = 5);

    // The text, repeated with separators to go once around the ring.
    final radius = outer - 44;
    final circumference = 2 * math.pi * radius;
    var fontSize = 44.0;
    List<TextPainter> lay(String s) => [
          for (final ch in s.characters)
            TextPainter(
              text: TextSpan(
                text: ch,
                style: _bold(fontSize, colour, shadow: false).copyWith(
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0,
                ),
              ),
              textDirection: TextDirection.ltr,
            )..layout(),
        ];
    double width(List<TextPainter> ps) => ps.fold(0, (sum, p) => sum + p.width);

    final unit = '$text  •  ';
    var glyphs = lay(unit);
    if (width(glyphs) > circumference * 0.95) {
      // Long text (some languages): shrink to fit once around.
      fontSize *= circumference * 0.95 / width(glyphs);
      glyphs = lay(unit);
    }
    final repeats = math.max(1, (circumference / width(glyphs)).floor());
    glyphs = lay(List.filled(repeats, unit).join());
    final gap = (circumference - width(glyphs)) / glyphs.length;

    var angle = -math.pi / 2;
    for (final glyph in glyphs) {
      angle += glyph.width / 2 / radius;
      canvas
        ..save()
        ..translate(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        )
        ..rotate(angle + math.pi / 2);
      glyph.paint(canvas, Offset(-glyph.width / 2, -glyph.height / 2));
      canvas.restore();
      angle += (glyph.width / 2 + gap) / radius;
    }
  }

  @override
  bool shouldRepaint(_SealPainter oldDelegate) =>
      oldDelegate.text != text || oldDelegate.colour != colour;
}

/// The draft's extra stickers as canvas items, for the editor and the
/// export alike.
List<CanvasItem> extraItems(CreationDraft draft, StickerFacts facts) => [
      for (final extra in draft.extras)
        CanvasItem(
          id: extra.id,
          placement: extra.placement,
          child: ExtraStickerView(
            kind: extra.kind,
            value: extra.value,
            facts: facts,
            colour: extra.colour,
          ),
        ),
    ];
