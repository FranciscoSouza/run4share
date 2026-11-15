import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/sticker_view.dart';
import 'package:run4share/shared/widgets/logo.dart';

/// Rotations this close to straight snap to straight.
const double _snapAngle = 3 * math.pi / 180;

double snapRotation(double radians) {
  const quarter = math.pi / 2;
  final nearest = (radians / quarter).round() * quarter;
  return (radians - nearest).abs() < _snapAngle ? nearest : radians;
}

Offset rotateVector(Offset v, double radians) {
  final c = math.cos(radians);
  final s = math.sin(radians);
  return Offset(v.dx * c - v.dy * s, v.dx * s + v.dy * c);
}

/// The image being made: background, one sticker and the watermark, laid
/// out in canvas units ([canvasUnits] wide) and scaled to whatever size it
/// is given. The same widget draws the editor, thumbnails and the export,
/// so they cannot differ.
class StoryCanvas extends StatefulWidget {
  const StoryCanvas({
    required this.format,
    required this.background,
    this.theme,
    this.data,
    this.placement,
    this.watermark = true,
    this.editable = false,
    this.selected = false,
    this.onSelect,
    this.onPlacement,
    this.onRemove,
    this.handleLabels = const HandleLabels(),
    super.key,
  });

  final ShareFormat format;
  final Widget background;
  final StickerTheme? theme;
  final StickerData? data;

  /// Null hides the sticker.
  final StickerPlacement? placement;
  final bool watermark;

  /// Gestures and handles (the editor); off for thumbnails and export.
  final bool editable;
  final bool selected;
  final ValueChanged<bool>? onSelect;
  final ValueChanged<StickerPlacement>? onPlacement;
  final VoidCallback? onRemove;
  final HandleLabels handleLabels;

  @override
  State<StoryCanvas> createState() => _StoryCanvasState();
}

/// Accessibility labels for the sticker handles.
@immutable
class HandleLabels {
  const HandleLabels({
    this.rotate = 'Rotate',
    this.resize = 'Resize',
    this.remove = 'Remove',
  });

  final String rotate;
  final String resize;
  final String remove;
}

class _StoryCanvasState extends State<StoryCanvas> {
  final GlobalKey _canvasKey = GlobalKey();

  /// The sticker's size in canvas units, measured after layout.
  Size? _stickerSize;

  StickerPlacement? _start;
  Offset? _startFocal;
  double _startAngle = 0;
  double _startDistance = 1;

  Offset _toGlobal(Offset local) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.localToGlobal(local) ?? local;
  }

  void _emit(StickerPlacement placement) => widget.onPlacement?.call(placement);

  // Dragging and pinching the sticker itself.
  void _onScaleStart(ScaleStartDetails details) {
    _start = widget.placement;
    _startFocal = details.focalPoint;
    widget.onSelect?.call(true);
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size canvas) {
    final start = _start;
    final focal = _startFocal;
    if (start == null || focal == null) return;
    final delta = details.focalPoint - focal;
    final center = start.center +
        Offset(delta.dx / canvas.width, delta.dy / canvas.height);
    _emit(
      start.copyWith(
        center: Offset(center.dx.clamp(0, 1), center.dy.clamp(0, 1)),
        scale: (start.scale * details.scale).clamp(
          StickerPlacement.minScale,
          StickerPlacement.maxScale,
        ),
        rotation: details.pointerCount > 1
            ? snapRotation(start.rotation + details.rotation)
            : start.rotation,
      ),
    );
  }

  // The rotate and resize handles turn and size around the centre.
  void _onHandleStart(DragStartDetails details, Offset centerLocal) {
    _start = widget.placement;
    final v = details.globalPosition - _toGlobal(centerLocal);
    _startAngle = v.direction;
    _startDistance = math.max(v.distance, 1);
  }

  void _onRotate(DragUpdateDetails details, Offset centerLocal) {
    final start = _start;
    if (start == null) return;
    final v = details.globalPosition - _toGlobal(centerLocal);
    _emit(
      start.copyWith(
        rotation: snapRotation(start.rotation + v.direction - _startAngle),
      ),
    );
  }

  void _onResize(DragUpdateDetails details, Offset centerLocal) {
    final start = _start;
    if (start == null) return;
    final v = details.globalPosition - _toGlobal(centerLocal);
    _emit(
      start.copyWith(
        scale: (start.scale * v.distance / _startDistance).clamp(
          StickerPlacement.minScale,
          StickerPlacement.maxScale,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.format.ratio,
      child: LayoutBuilder(
        builder: (context, box) {
          final size = box.biggest;
          final k = size.width / canvasUnits;
          final theme = widget.theme;
          final data = widget.data;
          final placement = widget.placement;
          final showSticker =
              theme != null && data != null && placement != null;
          final center = showSticker
              ? Offset(
                  placement.center.dx * size.width,
                  placement.center.dy * size.height,
                )
              : Offset.zero;

          Widget sticker = const SizedBox.shrink();
          if (showSticker) {
            sticker = _MeasureSize(
              onSize: (s) {
                if (s != _stickerSize) setState(() => _stickerSize = s);
              },
              child: StickerView(theme: theme, data: data),
            );
            if (widget.editable) {
              sticker = GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.onSelect?.call(true),
                onScaleStart: _onScaleStart,
                onScaleUpdate: (d) => _onScaleUpdate(d, size),
                child: sticker,
              );
            }
            sticker = Positioned(
              left: center.dx,
              top: center.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Transform.rotate(
                  angle: placement.rotation,
                  child: Transform.scale(
                    scale: k * placement.scale,
                    child: sticker,
                  ),
                ),
              ),
            );
          }

          final picture = ClipRect(
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.editable
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onSelect?.call(false),
                          child: widget.background,
                        )
                      : widget.background,
                ),
                sticker,
                if (widget.watermark)
                  Positioned(
                    right: 30 * k,
                    bottom: 26 * k,
                    child: AppLogo(
                      fontSize: 44 * k,
                      color: AppColors.neutral100,
                      fourColor: AppColors.neutral100,
                      shadows: const [
                        Shadow(color: Color(0x66000000), blurRadius: 8),
                      ],
                    ),
                  ),
              ],
            ),
          );

          final measured = _stickerSize;
          if (!widget.editable ||
              !widget.selected ||
              !showSticker ||
              measured == null) {
            return Stack(
              key: _canvasKey,
              children: [Positioned.fill(child: picture)],
            );
          }

          // Handles, in screen units around the turned sticker.
          final half = Offset(
            measured.width * k * placement.scale / 2,
            measured.height * k * placement.scale / 2,
          );
          const pad = 10.0;
          Offset at(double x, double y) =>
              center + rotateVector(Offset(x, y), placement.rotation);
          final topRight = at(half.dx + pad, -half.dy - pad);
          final bottomRight = at(half.dx + pad, half.dy + pad);
          final top = at(0, -half.dy - pad - 44);

          return Stack(
            key: _canvasKey,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: picture),
              Positioned(
                left: center.dx,
                top: center.dy,
                child: IgnorePointer(
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Transform.rotate(
                      angle: placement.rotation,
                      child: CustomPaint(
                        size: Size(
                          half.dx * 2 + pad * 2,
                          half.dy * 2 + pad * 2,
                        ),
                        painter: const _DashedFrame(stem: 44),
                      ),
                    ),
                  ),
                ),
              ),
              _Handle(
                at: top,
                icon: AppIcons.refresh,
                label: widget.handleLabels.rotate,
                onPanStart: (d) => _onHandleStart(d, center),
                onPanUpdate: (d) => _onRotate(d, center),
              ),
              _Handle(
                at: topRight,
                icon: AppIcons.trash,
                label: widget.handleLabels.remove,
                onTap: widget.onRemove,
              ),
              _Handle(
                at: bottomRight,
                icon: AppIcons.resize,
                label: widget.handleLabels.resize,
                onPanStart: (d) => _onHandleStart(d, center),
                onPanUpdate: (d) => _onResize(d, center),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({
    required this.at,
    required this.icon,
    required this.label,
    this.onTap,
    this.onPanStart,
    this.onPanUpdate,
  });

  static const size = 40.0;

  final Offset at;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: at.dx - size / 2,
      top: at.dy - size / 2,
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 6)],
            ),
            child: Icon(icon, size: 20, color: AppColors.neutral0),
          ),
        ),
      ),
    );
  }
}

class _DashedFrame extends CustomPainter {
  const _DashedFrame({required this.stem});

  final double stem;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neutral100
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 5.0;
    const gap = 4.0;
    void dashed(Offset a, Offset b) {
      final total = (b - a).distance;
      final dir = (b - a) / total;
      for (var d = 0.0; d < total; d += dash + gap) {
        canvas.drawLine(
          a + dir * d,
          a + dir * math.min(d + dash, total),
          paint,
        );
      }
    }

    final r = Offset.zero & size;
    dashed(r.topLeft, r.topRight);
    dashed(r.topRight, r.bottomRight);
    dashed(r.bottomRight, r.bottomLeft);
    dashed(r.bottomLeft, r.topLeft);
    // Stem up to the rotate handle.
    final top = Offset(size.width / 2, 0);
    canvas.drawLine(top, top - Offset(0, stem - 20), paint);
  }

  @override
  bool shouldRepaint(_DashedFrame oldDelegate) => oldDelegate.stem != stem;
}

/// Reports its child's size after layout.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onSize, super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onSize);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasureSize renderObject,
  ) =>
      renderObject.onSize = onSize;
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onSize);

  ValueChanged<Size> onSize;
  Size? _last;

  @override
  void performLayout() {
    super.performLayout();
    if (size != _last) {
      _last = size;
      final reported = size;
      WidgetsBinding.instance.addPostFrameCallback((_) => onSize(reported));
    }
  }
}
