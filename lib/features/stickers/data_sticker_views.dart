import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:intl/intl.dart' show NumberFormat;
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/polyline.dart';
import 'package:run4share/l10n/l10n.dart';

const _shadow = [
  Shadow(color: Color(0x59000000), blurRadius: 14, offset: Offset(0, 3)),
];

TextStyle _label(double size, Color c) => AppText.label.copyWith(
      fontSize: size,
      letterSpacing: size * 0.12,
      color: c,
      shadows: _shadow,
    );

TextStyle _value(double size, Color c) => AppText.stickerValue.copyWith(
      fontSize: size,
      height: 1,
      color: c,
      shadows: _shadow,
    );

double _metresPerUnit(Units units) => units == Units.km ? 1000 : 1609.344;

/// The shoe and its lifetime distance.
class ShoeSticker extends StatelessWidget {
  const ShoeSticker({
    required this.gear,
    required this.units,
    required this.colour,
    super.key,
  });

  final Gear gear;
  final Units units;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final distance = NumberFormat(
      '#,##0',
      l10n.localeName,
    ).format(gear.distance / _metresPerUnit(units));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(AppIcons.run, size: 120, color: colour, shadows: _shadow),
        const SizedBox(width: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Text(
                gear.name,
                style: _value(58, colour).copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: distance,
                style: _value(124, colour).copyWith(
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
                children: [
                  TextSpan(
                    text: ' ${units == Units.km ? 'km' : 'mi'}',
                    style: _value(52, colour),
                  ),
                ],
              ),
            ),
            Text(
              l10n.stickerShoeTotal.toUpperCase(),
              style: _label(26, colour),
            ),
          ],
        ),
      ],
    );
  }
}

enum RouteStyle { neon, glow, dotted }

/// The route's shape, without a map, in one of three line styles.
class RouteSticker extends StatelessWidget {
  const RouteSticker({
    required this.polyline,
    required this.style,
    required this.colour,
    super.key,
  });

  final String polyline;
  final RouteStyle style;
  final Color colour;

  static const _box = 720.0;

  @override
  Widget build(BuildContext context) {
    final points = decodePolyline(polyline);
    if (points.length < 2) return const SizedBox.shrink();
    // Equirectangular projection, longitude scaled by latitude.
    final midLat =
        points.map((p) => p.$1).reduce((a, b) => a + b) / points.length;
    final scaleX = math.cos(midLat * math.pi / 180);
    final xs = [for (final p in points) p.$2 * scaleX];
    final ys = [for (final p in points) -p.$1];
    final minX = xs.reduce(math.min);
    final maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);
    final w = math.max(maxX - minX, 1e-9);
    final h = math.max(maxY - minY, 1e-9);
    final scale = _box / math.max(w, h);
    const margin = 40.0;
    final size = Size(w * scale + margin * 2, h * scale + margin * 2);
    final offsets = [
      for (var i = 0; i < points.length; i++)
        Offset(
          margin + (xs[i] - minX) * scale,
          margin + (ys[i] - minY) * scale,
        ),
    ];
    return CustomPaint(
      size: size,
      painter: _RoutePainter(offsets, style, colour),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter(this.points, this.style, this.colour);

  final List<Offset> points;
  final RouteStyle style;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addPolygon(points, false);
    Paint stroke(double width, Color c, {double blur = 0}) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = blur > 0 ? MaskFilter.blur(BlurStyle.normal, blur) : null;

    switch (style) {
      case RouteStyle.neon:
        canvas
          ..drawPath(path, stroke(34, colour.withValues(alpha: 0.55), blur: 22))
          ..drawPath(path, stroke(16, colour))
          ..drawPath(
            path,
            stroke(5, Color.lerp(colour, const Color(0xFFFFFFFF), 0.7)!),
          );
      case RouteStyle.glow:
        canvas
          ..drawPath(path, stroke(40, colour.withValues(alpha: 0.3), blur: 28))
          ..drawPath(path, stroke(12, colour));
      case RouteStyle.dotted:
        final dot = Paint()..color = colour;
        for (final metric in path.computeMetrics()) {
          for (var d = 0.0; d < metric.length; d += 26) {
            final at = metric.getTangentForOffset(d)?.position;
            if (at != null) canvas.drawCircle(at, 7, dot);
          }
        }
    }
    // Start: filled dot; finish: ring.
    canvas
      ..drawCircle(points.first, 18, Paint()..color = colour)
      ..drawCircle(
        points.last,
        16,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8,
      );
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.style != style ||
      oldDelegate.colour != colour;
}

/// Elevation profile with the total climb.
class ElevationSticker extends StatelessWidget {
  const ElevationSticker({
    required this.json,
    required this.colour,
    this.climb,
    super.key,
  });

  /// [[metres, altitude], ...] as stored.
  final String json;
  final Color colour;

  /// Metres climbed (Strava's total_elevation_gain), if known.
  final double? climb;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final points = [
      for (final p in jsonDecode(json) as List)
        Offset(
          ((p as List)[0] as num).toDouble(),
          (p[1] as num).toDouble(),
        ),
    ];
    if (points.length < 2) return const SizedBox.shrink();
    var gain = 0.0;
    for (var i = 1; i < points.length; i++) {
      gain += math.max(0, points[i].dy - points[i - 1].dy);
    }
    final shown = (climb ?? gain).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.chartElevation.toUpperCase(), style: _label(30, colour)),
            const SizedBox(width: 24),
            Text('+$shown m', style: _value(64, colour)),
          ],
        ),
        const SizedBox(height: 16),
        CustomPaint(
          size: const Size(860, 260),
          painter: _ElevationPainter(points, colour),
        ),
      ],
    );
  }
}

class _ElevationPainter extends CustomPainter {
  const _ElevationPainter(this.points, this.colour);

  final List<Offset> points;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final minX = points.first.dx;
    final maxX = points.last.dx;
    final ys = points.map((p) => p.dy);
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);
    final spanX = math.max(maxX - minX, 1);
    // Flat routes stay flat-looking: at least 30 m of vertical range.
    final spanY = math.max(maxY - minY, 30);
    Offset at(Offset p) => Offset(
          (p.dx - minX) / spanX * size.width,
          size.height - (p.dy - minY) / spanY * size.height * 0.9,
        );
    final line = Path()..addPolygon([for (final p in points) at(p)], false);
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawPath(
        area,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(0, size.height),
            [colour.withValues(alpha: 0.5), colour.withValues(alpha: 0.05)],
          ),
      )
      ..drawPath(
        line,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_ElevationPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.colour != colour;
}

/// One bar per km (or mile): taller is faster, the fastest is highlighted.
class SplitsSticker extends StatelessWidget {
  const SplitsSticker({
    required this.json,
    required this.units,
    required this.colour,
    super.key,
  });

  /// {"km": [[metres, seconds, climb], ...], "mi": [...]} as stored.
  final String json;
  final Units units;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final all = jsonDecode(json) as Map<String, dynamic>;
    final unit = _metresPerUnit(units);
    final rows = [
      for (final r in (all[units == Units.km ? 'km' : 'mi'] as List? ?? []))
        (
          ((r as List)[0] as num).toDouble(),
          (r[1] as num).toInt(),
        ),
    ]
        // A short last split would skew the bars; leave it out.
        .where((r) => r.$1 >= unit * 0.5 && r.$2 > 0)
        .toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    final paces = [for (final r in rows) r.$2 / (r.$1 / unit)];
    final best = paces.reduce(math.min);
    final bestIndex = paces.indexOf(best);
    final seconds = best.round();
    final pace =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.chartSplits.toUpperCase(), style: _label(30, colour)),
            const SizedBox(width: 24),
            Text(
              l10n.chartBest(pace, units == Units.km ? '/km' : '/mi'),
              style: _value(56, colour),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomPaint(
          size: const Size(860, 280),
          painter: _SplitsPainter(paces, bestIndex, colour),
        ),
      ],
    );
  }
}

class _SplitsPainter extends CustomPainter {
  const _SplitsPainter(this.paces, this.best, this.colour);

  /// Seconds per unit; lower is faster.
  final List<double> paces;
  final int best;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final slowest = paces.reduce(math.max);
    final fastest = paces.reduce(math.min);
    final gap = paces.length > 20 ? 4.0 : 10.0;
    final width = (size.width - gap * (paces.length - 1)) / paces.length;
    for (var i = 0; i < paces.length; i++) {
      // Speed relative to the range, never shorter than a stub.
      final t =
          slowest == fastest ? 1.0 : (slowest - paces[i]) / (slowest - fastest);
      final height = size.height * (0.35 + 0.65 * t);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * (width + gap),
          size.height - height,
          width,
          height,
        ),
        Radius.circular(math.min(10, width / 2)),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = i == best ? colour : colour.withValues(alpha: 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(_SplitsPainter oldDelegate) =>
      oldDelegate.paces != paces ||
      oldDelegate.best != best ||
      oldDelegate.colour != colour;
}
