import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/l10n/l10n.dart';

String colourName(AppLocalizations l10n, StickerColour colour) =>
    switch (colour) {
      StickerColour.white => l10n.colourWhite,
      StickerColour.black => l10n.colourBlack,
      StickerColour.amber => l10n.colourAmber,
      StickerColour.red => l10n.colourRed,
      StickerColour.blue => l10n.colourBlue,
      StickerColour.green => l10n.colourGreen,
    };

/// "Black 60%", "White 40%" or "Transparent".
String backgroundName(AppLocalizations l10n, double value) {
  final percent = (value.abs() * 100).round();
  if (percent == 0) return l10n.backgroundTransparent;
  return value < 0
      ? l10n.backgroundWhite(percent)
      : l10n.backgroundBlack(percent);
}

/// Title row shared by the style panels: name left, current value right.
class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xl,
        AppSpacing.page,
        AppSpacing.xl,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.headlineSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(value, style: theme.textTheme.bodySmall?.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(AppIcons.down),
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        onPressed: onClose,
      );
}

/// The design's six swatches.
class TextColourPanel extends StatelessWidget {
  const TextColourPanel({
    required this.selected,
    required this.onChoose,
    required this.onClose,
    super.key,
  });

  final StickerColour selected;
  final ValueChanged<StickerColour> onChoose;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ring = Theme.of(context).colorScheme.onSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PanelHeader(
          title: l10n.editorTextColour,
          value: colourName(l10n, selected),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final colour in StickerColour.values)
                Semantics(
                  button: true,
                  selected: colour == selected,
                  label: colourName(l10n, colour),
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () => onChoose(colour),
                    child: Container(
                      width: 54,
                      height: 54,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colour == selected ? ring : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colour.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neutral20,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CloseButton(onClose: onClose),
      ],
    );
  }
}

/// White ← transparent → black, as one slider.
class BackgroundPanel extends StatelessWidget {
  const BackgroundPanel({
    required this.value,
    required this.onChanged,
    required this.onClose,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PanelHeader(
          title: l10n.editorBackground,
          value: backgroundName(l10n, value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: BackgroundSlider(
            value: value,
            onChanged: onChanged,
            semanticLabel: l10n.editorBackground,
            semanticValue: backgroundName(l10n, value),
            describe: (v) => backgroundName(l10n, v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            0,
          ),
          child: Row(
            children: [
              Text(l10n.colourWhite, style: muted),
              Expanded(
                child: Text(
                  l10n.backgroundTransparent,
                  style: muted,
                  textAlign: TextAlign.center,
                ),
              ),
              Text(l10n.colourBlack, style: muted),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _CloseButton(onClose: onClose),
      ],
    );
  }
}

class BackgroundSlider extends StatelessWidget {
  const BackgroundSlider({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    required this.semanticValue,
    required this.describe,
    super.key,
  });

  /// -1 (white) to 1 (black).
  final double value;
  final ValueChanged<double> onChanged;
  final String semanticLabel;
  final String semanticValue;

  /// Names a value for screen readers, e.g. "Black 60%".
  final String Function(double value) describe;

  static const _thumb = 40.0;
  static const _step = 0.1;

  double get _up => (value + _step).clamp(-1.0, 1.0);
  double get _down => (value - _step).clamp(-1.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        final usable = width - _thumb;
        double valueAt(double dx) =>
            (((dx - _thumb / 2) / usable) * 2 - 1).clamp(-1.0, 1.0);
        final x = (value + 1) / 2 * usable;
        return Semantics(
          slider: true,
          label: semanticLabel,
          value: semanticValue,
          increasedValue: describe(_up),
          decreasedValue: describe(_down),
          onIncrease: () => onChanged(_up),
          onDecrease: () => onChanged(_down),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => onChanged(valueAt(d.localPosition.dx)),
            onHorizontalDragUpdate: (d) =>
                onChanged(valueAt(d.localPosition.dx)),
            child: SizedBox(
              height: _thumb + 8,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    left: _thumb / 2 - 14,
                    right: _thumb / 2 - 14,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: const SizedBox(
                        height: 26,
                        child: CustomPaint(painter: _TrackPainter()),
                      ),
                    ),
                  ),
                  Positioned(
                    left: width / 2 - 1,
                    child: Container(
                      width: 2,
                      height: 36,
                      color: AppColors.neutral70,
                    ),
                  ),
                  Positioned(
                    left: x,
                    child: Container(
                      width: _thumb,
                      height: _thumb,
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.neutral100, width: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Checkerboard (transparency) under a white → clear → black gradient.
class _TrackPainter extends CustomPainter {
  const _TrackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 6.0;
    final light = Paint()..color = const Color(0xFF6B6762);
    final dark = Paint()..color = const Color(0xFF3D3A36);
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final odd = ((x / cell).floor() + (y / cell).floor()).isOdd;
        canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), odd ? dark : light);
      }
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0x00FFFFFF),
            Color(0x00000000),
            Color(0xFF000000),
          ],
          stops: [0, 0.5, 0.5, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_TrackPainter oldDelegate) => false;
}
