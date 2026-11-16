import 'dart:math' as math;

import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/l10n/l10n.dart';

/// Canvas width every sticker is designed for. Sizes below are in these
/// units; the canvas scales them to the screen or the exported image.
const canvasUnits = 1080.0;

const _shadow = [
  Shadow(color: Color(0x59000000), blurRadius: 14, offset: Offset(0, 3)),
];

/// The colour a layout draws its text in, and whether it gets a shadow.
@immutable
class _Ink {
  const _Ink(this.colour, {required this.shadow});

  final Color colour;
  final bool shadow;

  List<Shadow>? get shadows => shadow ? _shadow : null;

  TextStyle label(double size) => AppText.label.copyWith(
        fontSize: size,
        letterSpacing: size * 0.12,
        color: colour,
        shadows: shadows,
      );

  TextStyle value(double size) => AppText.stickerValue.copyWith(
        fontSize: size,
        height: 1,
        color: colour,
        shadows: shadows,
      );

  TextStyle unit(double size) =>
      value(size).copyWith(fontWeight: FontWeight.w600);
}

/// Draws one sticker theme for one activity, at canvas units. The single
/// renderer behind the editor, the theme thumbnails, the template
/// previews and the exported image.
class StickerView extends StatelessWidget {
  const StickerView({
    required this.theme,
    required this.data,
    this.style = const StickerStyle(),
    super.key,
  });

  final StickerTheme theme;
  final StickerData data;
  final StickerStyle style;

  List<StickerStat> get _stats => [
        for (final metric in theme.metrics)
          if (data.stats[metric] case final stat?) stat,
      ];

  @override
  Widget build(BuildContext context) {
    final colour = style.colour ?? theme.colour;
    final background = style.background;
    // A shadow helps light text on a busy photo; not on a backing panel.
    final ink = _Ink(
      colour.color,
      shadow: colour.isLight && background.abs() < 0.35,
    );

    Widget sticker = switch (theme.layout) {
      StickerLayout.inline => _Inline(stats: _stats, ink: ink),
      StickerLayout.stack => _Stack(stats: _stats, ink: ink),
      StickerLayout.hero => _Hero(stat: _stats.first, data: data, ink: ink),
      StickerLayout.poster => _Poster(stats: _stats, fill: colour),
      StickerLayout.ring => _Ring(stat: _stats.first, ink: ink),
      StickerLayout.weekday => _Weekday(
          stat: _stats.first,
          data: data,
          ink: ink,
        ),
      StickerLayout.bib => _Bib(stats: _stats, data: data, fill: colour),
      StickerLayout.receipt => _Receipt(
          stats: _stats,
          data: data,
          fill: colour,
        ),
      StickerLayout.scoreboard => _Scoreboard(
          stats: _stats,
          data: data,
          lit: colour.color,
        ),
    };

    if (background != 0) {
      final round = theme.layout == StickerLayout.ring;
      sticker = DecoratedBox(
        decoration: BoxDecoration(
          color: (background < 0 ? AppColors.neutral100 : AppColors.neutral0)
              .withValues(alpha: background.abs()),
          shape: round ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: round ? null : BorderRadius.circular(28),
        ),
        child: Padding(
          padding: round
              ? const EdgeInsets.all(28)
              : const EdgeInsets.symmetric(horizontal: 44, vertical: 34),
          child: sticker,
        ),
      );
    }

    return DefaultTextStyle(style: const TextStyle(), child: sticker);
  }
}

/// "5.02 km" with the unit smaller, on a shared baseline.
class _ValueText extends StatelessWidget {
  const _ValueText(this.stat, {required this.size, required this.ink});

  final StickerStat stat;
  final double size;
  final _Ink ink;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: stat.value,
        style: ink.value(size),
        children: [
          if (stat.unit != null)
            TextSpan(text: ' ${stat.unit}', style: ink.unit(size * 0.42)),
        ],
      ),
      maxLines: 1,
      softWrap: false,
    );
  }
}

class _Inline extends StatelessWidget {
  const _Inline({required this.stats, required this.ink});

  final List<StickerStat> stats;
  final _Ink ink;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 64),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(stats[i].label.toUpperCase(), style: ink.label(32)),
              const SizedBox(height: 10),
              _ValueText(stats[i], size: 100, ink: ink),
            ],
          ),
        ],
      ],
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack({required this.stats, required this.ink});

  final List<StickerStat> stats;
  final _Ink ink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(height: 34),
          Text(stats[i].label.toUpperCase(), style: ink.label(30)),
          const SizedBox(height: 8),
          _ValueText(stats[i], size: 116, ink: ink),
        ],
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.stat, required this.data, required this.ink});

  final StickerStat stat;
  final StickerData data;
  final _Ink ink;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ValueText(stat, size: 300, ink: ink),
        const SizedBox(height: 22),
        Text(
          '${data.sport} · ${data.weekday}',
          style: ink.label(36).copyWith(letterSpacing: 7),
        ),
      ],
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.stats, required this.fill});

  final List<StickerStat> stats;

  /// Box colour; the text inside picks black or white to stay readable.
  final StickerColour fill;

  @override
  Widget build(BuildContext context) {
    final ink = _Ink(
      fill.isLight ? AppColors.neutral0 : AppColors.neutral100,
      shadow: false,
    );
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Container(
              color: fill.color,
              padding: const EdgeInsets.fromLTRB(28, 18, 32, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 56),
                    child: Text(
                      stats[i].label.toUpperCase(),
                      style: ink.label(26),
                    ),
                  ),
                  const Spacer(),
                  _ValueText(stats[i], size: 76, ink: ink),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.stat, required this.ink});

  final StickerStat stat;
  final _Ink ink;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 460,
      child: CustomPaint(
        painter: _RingPainter(colour: ink.colour, shadow: ink.shadow),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(stat.value, style: ink.value(170)),
              const SizedBox(height: 4),
              Text(stat.unit ?? stat.label.toUpperCase(), style: ink.label(34)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.colour, required this.shadow});

  final Color colour;
  final bool shadow;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 22.0;
    final rect = (Offset.zero & size).deflate(stroke / 2 + 6);
    // A ring open at the bottom-left, like a gauge.
    const sweep = math.pi * 2 * 0.86;
    const start = math.pi / 2 + math.pi * 2 * 0.07;
    if (shadow) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = const Color(0x40000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke + 6
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = colour
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.colour != colour || oldDelegate.shadow != shadow;
}

class _Weekday extends StatelessWidget {
  const _Weekday({required this.stat, required this.data, required this.ink});

  final StickerStat stat;
  final StickerData data;
  final _Ink ink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ValueText(stat, size: 78, ink: ink),
        const SizedBox(height: 6),
        Text(data.sport, style: ink.label(26)),
        const SizedBox(height: 12),
        Text(
          data.weekday,
          style: ink.value(168).copyWith(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }
}

/// Black or white text, whichever reads on [fill].
_Ink _inkOn(StickerColour fill) => _Ink(
      fill.isLight ? AppColors.neutral0 : AppColors.neutral100,
      shadow: false,
    );

class _Bib extends StatelessWidget {
  const _Bib({required this.stats, required this.data, required this.fill});

  final List<StickerStat> stats;
  final StickerData data;
  final StickerColour fill;

  @override
  Widget build(BuildContext context) {
    final ink = _inkOn(fill);
    final number = stats.first;
    final rest = stats.skip(1).toList();
    Widget pin() => Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ink.colour.withValues(alpha: 0.18),
            border: Border.all(
              color: ink.colour.withValues(alpha: 0.45),
              width: 3,
            ),
          ),
        );
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 640, maxWidth: 940),
      child: IntrinsicWidth(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(76, 34, 76, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ink.label(32).copyWith(letterSpacing: 6),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 5, color: ink.colour),
                    const SizedBox(height: 10),
                    _ValueText(number, size: 230, ink: ink),
                    const SizedBox(height: 14),
                    Container(height: 5, color: ink.colour),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final stat in rest)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Text(
                                  stat.label.toUpperCase(),
                                  style: ink.label(24),
                                ),
                                const SizedBox(height: 6),
                                _ValueText(stat, size: 68, ink: ink),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(left: 24, top: 24, child: pin()),
              Positioned(right: 24, top: 24, child: pin()),
              Positioned(left: 24, bottom: 24, child: pin()),
              Positioned(right: 24, bottom: 24, child: pin()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Receipt extends StatelessWidget {
  const _Receipt({
    required this.stats,
    required this.data,
    required this.fill,
  });

  final List<StickerStat> stats;
  final StickerData data;
  final StickerColour fill;

  static const _width = 640.0;

  @override
  Widget build(BuildContext context) {
    final ink = _inkOn(fill);
    final total = stats.first;
    Widget rule() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: CustomPaint(
            size: const Size(double.infinity, 4),
            painter: _DashPainter(ink.colour.withValues(alpha: 0.7)),
          ),
        );
    return SizedBox(
      width: _width,
      child: ClipPath(
        clipper: const _TornEdge(),
        child: ColoredBox(
          color: fill.color,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 44, 48, 64),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  data.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ink.label(34).copyWith(letterSpacing: 5),
                ),
                const SizedBox(height: 10),
                Text(
                  data.date,
                  textAlign: TextAlign.center,
                  style: ink.label(24).copyWith(
                        color: ink.colour.withValues(alpha: 0.7),
                      ),
                ),
                rule(),
                for (final stat in stats.skip(1)) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(stat.label.toUpperCase(), style: ink.label(26)),
                      const Spacer(),
                      _ValueText(stat, size: 58, ink: ink),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                rule(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        context.l10n.receiptTotal.toUpperCase(),
                        style: ink.label(34).copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const Spacer(),
                    _ValueText(total, size: 104, ink: ink),
                  ],
                ),
                rule(),
                SizedBox(
                  height: 70,
                  child: CustomPaint(
                    painter: _BarcodePainter(
                      ink.colour,
                      seed: '${data.name}${total.value}'.hashCode,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A dashed horizontal line across the width.
class _DashPainter extends CustomPainter {
  const _DashPainter(this.colour);

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = size.height;
    const dash = 14.0;
    const gap = 10.0;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(math.min(x + dash, size.width), size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => oldDelegate.colour != colour;
}

/// Decorative barcode: the same bars for the same activity.
class _BarcodePainter extends CustomPainter {
  const _BarcodePainter(this.colour, {required this.seed});

  final Color colour;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()..color = colour;
    var x = 0.0;
    while (x < size.width) {
      final bar = 3.0 + random.nextInt(3) * 3;
      if (x + bar > size.width) break;
      canvas.drawRect(Rect.fromLTWH(x, 0, bar, size.height), paint);
      x += bar + 3 + random.nextInt(3) * 3;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter oldDelegate) =>
      oldDelegate.colour != colour || oldDelegate.seed != seed;
}

/// The receipt's torn bottom edge: a zigzag.
class _TornEdge extends CustomClipper<Path> {
  const _TornEdge();

  @override
  Path getClip(Size size) {
    const tooth = 24.0;
    const depth = 16.0;
    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - depth);
    var x = size.width;
    var down = true;
    while (x > 0) {
      x = math.max(0, x - tooth / 2);
      path.lineTo(x, down ? size.height : size.height - depth);
      down = !down;
    }
    return path..close();
  }

  @override
  bool shouldReclip(_TornEdge oldClipper) => false;
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({
    required this.stats,
    required this.data,
    required this.lit,
  });

  final List<StickerStat> stats;
  final StickerData data;

  /// The digits' colour.
  final Color lit;

  @override
  Widget build(BuildContext context) {
    const board = Color(0xF20E0F12);
    const box = Color(0xFF000000);
    final digits = AppText.stickerValue.copyWith(
      fontSize: 100,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final caption = AppText.label.copyWith(
      fontSize: 22,
      letterSpacing: 3,
      color: const Color(0xCCFFFFFF),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: BoxDecoration(
        color: board,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33FFFFFF), width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${data.sport} · ${data.weekday}', style: caption),
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  decoration: BoxDecoration(
                    color: box,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        stats[i].value,
                        style: digits.copyWith(
                          color: lit,
                          shadows: [
                            Shadow(
                              color: lit.withValues(alpha: 0.6),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        [
                          stats[i].label.toUpperCase(),
                          if (stats[i].unit case final unit?) unit,
                        ].join(' · '),
                        style: caption,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
