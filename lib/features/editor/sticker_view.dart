import 'dart:math' as math;

import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';

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
