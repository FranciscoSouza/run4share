import 'dart:math' as math;

import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';

/// Canvas width every sticker is designed for. Sizes below are in these
/// units; the canvas scales them to the screen or the exported image.
const canvasUnits = 1080.0;

const _shadow = [
  Shadow(color: Color(0x59000000), blurRadius: 14, offset: Offset(0, 3)),
];

TextStyle _label(double size, {Color colour = AppColors.neutral100}) =>
    AppText.label.copyWith(
      fontSize: size,
      letterSpacing: size * 0.12,
      color: colour,
      shadows: colour == AppColors.neutral100 ? _shadow : null,
    );

TextStyle _value(double size, {Color colour = AppColors.neutral100}) =>
    AppText.stickerValue.copyWith(
      fontSize: size,
      height: 1,
      color: colour,
      shadows: colour == AppColors.neutral100 ? _shadow : null,
    );

TextStyle _unit(double size, {Color colour = AppColors.neutral100}) =>
    _value(size, colour: colour).copyWith(fontWeight: FontWeight.w600);

/// Draws one sticker theme for one activity, at canvas units. The single
/// renderer behind the editor, the theme thumbnails, the template
/// previews and the exported image.
class StickerView extends StatelessWidget {
  const StickerView({required this.theme, required this.data, super.key});

  final StickerTheme theme;
  final StickerData data;

  List<StickerStat> get _stats => [
        for (final metric in theme.metrics)
          if (data.stats[metric] case final stat?) stat,
      ];

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(),
      child: switch (theme.layout) {
        StickerLayout.inline => _Inline(stats: _stats),
        StickerLayout.stack => _Stack(stats: _stats),
        StickerLayout.hero => _Hero(stat: _stats.first, data: data),
        StickerLayout.poster => _Poster(stats: _stats),
        StickerLayout.ring => _Ring(stat: _stats.first),
        StickerLayout.weekday => _Weekday(stat: _stats.first, data: data),
      },
    );
  }
}

/// "5.02 km" with the unit smaller, on a shared baseline.
class _ValueText extends StatelessWidget {
  const _ValueText(
    this.stat, {
    required this.size,
    this.colour = AppColors.neutral100,
  });

  final StickerStat stat;
  final double size;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: stat.value,
        style: _value(size, colour: colour),
        children: [
          if (stat.unit != null)
            TextSpan(
              text: ' ${stat.unit}',
              style: _unit(size * 0.42, colour: colour),
            ),
        ],
      ),
      maxLines: 1,
      softWrap: false,
    );
  }
}

class _Inline extends StatelessWidget {
  const _Inline({required this.stats});

  final List<StickerStat> stats;

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
              Text(stats[i].label.toUpperCase(), style: _label(32)),
              const SizedBox(height: 10),
              _ValueText(stats[i], size: 100),
            ],
          ),
        ],
      ],
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack({required this.stats});

  final List<StickerStat> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(height: 34),
          Text(stats[i].label.toUpperCase(), style: _label(30)),
          const SizedBox(height: 8),
          _ValueText(stats[i], size: 116),
        ],
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.stat, required this.data});

  final StickerStat stat;
  final StickerData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ValueText(stat, size: 300),
        const SizedBox(height: 22),
        Text(
          '${data.sport} · ${data.weekday}',
          style: _label(36).copyWith(letterSpacing: 7),
        ),
      ],
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.stats});

  final List<StickerStat> stats;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Container(
              color: AppColors.warning70,
              padding: const EdgeInsets.fromLTRB(28, 18, 32, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 56),
                    child: Text(
                      stats[i].label.toUpperCase(),
                      style: _label(26, colour: AppColors.neutral0),
                    ),
                  ),
                  const Spacer(),
                  _ValueText(stats[i], size: 76, colour: AppColors.neutral0),
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
  const _Ring({required this.stat});

  final StickerStat stat;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 460,
      child: CustomPaint(
        painter: const _RingPainter(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(stat.value, style: _value(170)),
              const SizedBox(height: 4),
              Text(stat.unit ?? stat.label.toUpperCase(), style: _label(34)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 22.0;
    final rect = (Offset.zero & size).deflate(stroke / 2 + 6);
    // A ring open at the bottom-left, like a gauge.
    const sweep = math.pi * 2 * 0.86;
    const start = math.pi / 2 + math.pi * 2 * 0.07;
    canvas
      ..drawArc(
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
      )
      ..drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = AppColors.neutral100
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => false;
}

class _Weekday extends StatelessWidget {
  const _Weekday({required this.stat, required this.data});

  final StickerStat stat;
  final StickerData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ValueText(stat, size: 78),
        const SizedBox(height: 6),
        Text(data.sport, style: _label(26)),
        const SizedBox(height: 12),
        Text(
          data.weekday,
          style: _value(
            168,
          ).copyWith(fontWeight: FontWeight.w800, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
