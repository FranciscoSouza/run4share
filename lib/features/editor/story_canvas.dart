import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/photo_effect.dart';
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

/// ID of the theme sticker among the canvas items.
const themeItemId = 'theme';

/// The sticker's style tools, opened from its handles.
enum StickerTool { textColour, background }

/// One movable thing on the canvas: the theme sticker or an extra one.
/// [child] is drawn at canvas units.
@immutable
class CanvasItem {
  const CanvasItem({
    required this.id,
    required this.child,
    required this.placement,
    this.tools = const {StickerTool.textColour},
  });

  final Object id;
  final Widget child;
  final StickerPlacement placement;

  /// Style handles shown when selected (rotate, remove and resize always).
  final Set<StickerTool> tools;
}

/// Accessibility labels for the sticker handles.
@immutable
class HandleLabels {
  const HandleLabels({
    this.rotate = 'Rotate',
    this.resize = 'Resize',
    this.remove = 'Remove',
    this.textColour = 'Text colour',
    this.background = 'Background',
  });

  final String rotate;
  final String resize;
  final String remove;
  final String textColour;
  final String background;
}

/// The image being made: background, the theme sticker, extra stickers and
/// the watermark, laid out in canvas units ([canvasUnits] wide) and scaled
/// to whatever size it is given. The same widget draws the editor,
/// thumbnails and the export, so they cannot differ.
class StoryCanvas extends StatefulWidget {
  const StoryCanvas({
    required this.format,
    required this.background,
    this.theme,
    this.data,
    this.placement,
    this.style = const StickerStyle(),
    this.extras = const [],
    this.effect = PhotoEffect.none,
    this.watermark = true,
    this.editable = false,
    this.selected,
    this.onSelect,
    this.onPlacement,
    this.onRemove,
    this.onTool,
    this.activeTool,
    this.handleLabels = const HandleLabels(),
    super.key,
  });

  final ShareFormat format;
  final Widget background;

  /// Applied to [background] only; stickers keep their colours.
  final PhotoEffect effect;
  final StickerTheme? theme;
  final StickerData? data;

  /// The theme sticker's placement; null hides it.
  final StickerPlacement? placement;
  final StickerStyle style;

  /// Extra stickers, above the theme sticker.
  final List<CanvasItem> extras;
  final bool watermark;

  /// Gestures and handles (the editor); off for thumbnails and export.
  final bool editable;

  /// The selected item's ID ([themeItemId] or an extra's), or null.
  final Object? selected;
  final ValueChanged<Object?>? onSelect;
  final void Function(Object id, StickerPlacement placement)? onPlacement;
  final ValueChanged<Object>? onRemove;
  final void Function(Object id, StickerTool tool)? onTool;

  /// The open style panel, to highlight its handle.
  final StickerTool? activeTool;
  final HandleLabels handleLabels;

  @override
  State<StoryCanvas> createState() => _StoryCanvasState();
}

class _StoryCanvasState extends State<StoryCanvas> {
  final GlobalKey _canvasKey = GlobalKey();

  /// Each item's size in canvas units, measured after layout.
  final Map<Object, Size> _sizes = {};

  Object? _active;
  StickerPlacement? _start;
  Offset? _startFocal;
  double _startAngle = 0;
  double _startDistance = 1;

  List<CanvasItem> get _items {
    final theme = widget.theme;
    final data = widget.data;
    final placement = widget.placement;
    return [
      if (theme != null && data != null && placement != null)
        CanvasItem(
          id: themeItemId,
          child: StickerView(theme: theme, data: data, style: widget.style),
          placement: placement,
          tools: const {StickerTool.textColour, StickerTool.background},
        ),
      ...widget.extras,
    ];
  }

  Offset _toGlobal(Offset local) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.localToGlobal(local) ?? local;
  }

  void _emit(Object id, StickerPlacement placement) =>
      widget.onPlacement?.call(id, placement);

  // Dragging and pinching an item itself.
  void _onScaleStart(CanvasItem item, ScaleStartDetails details) {
    _active = item.id;
    _start = item.placement;
    _startFocal = details.focalPoint;
    widget.onSelect?.call(item.id);
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size canvas) {
    final id = _active;
    final start = _start;
    final focal = _startFocal;
    if (id == null || start == null || focal == null) return;
    final delta = details.focalPoint - focal;
    final center = start.center +
        Offset(delta.dx / canvas.width, delta.dy / canvas.height);
    _emit(
      id,
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
  void _onHandleStart(
    CanvasItem item,
    DragStartDetails details,
    Offset centerLocal,
  ) {
    _active = item.id;
    _start = item.placement;
    final v = details.globalPosition - _toGlobal(centerLocal);
    _startAngle = v.direction;
    _startDistance = math.max(v.distance, 1);
  }

  void _onRotate(DragUpdateDetails details, Offset centerLocal) {
    final id = _active;
    final start = _start;
    if (id == null || start == null) return;
    final v = details.globalPosition - _toGlobal(centerLocal);
    _emit(
      id,
      start.copyWith(
        rotation: snapRotation(start.rotation + v.direction - _startAngle),
      ),
    );
  }

  void _onResize(DragUpdateDetails details, Offset centerLocal) {
    final id = _active;
    final start = _start;
    if (id == null || start == null) return;
    final v = details.globalPosition - _toGlobal(centerLocal);
    _emit(
      id,
      start.copyWith(
        scale: (start.scale * v.distance / _startDistance).clamp(
          StickerPlacement.minScale,
          StickerPlacement.maxScale,
        ),
      ),
    );
  }

  Offset _centerOf(CanvasItem item, Size size) => Offset(
        item.placement.center.dx * size.width,
        item.placement.center.dy * size.height,
      );

  Widget _positioned(CanvasItem item, Size size, double k) {
    Widget child = _MeasureSize(
      onSize: (s) {
        if (_sizes[item.id] != s) setState(() => _sizes[item.id] = s);
      },
      child: item.child,
    );
    if (widget.editable) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelect?.call(item.id),
        onScaleStart: (d) => _onScaleStart(item, d),
        onScaleUpdate: (d) => _onScaleUpdate(d, size),
        child: child,
      );
    }
    final center = _centerOf(item, size);
    return Positioned(
      key: ValueKey(item.id),
      left: center.dx,
      top: center.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: item.placement.rotation,
          child: Transform.scale(
            scale: k * item.placement.scale,
            child: child,
          ),
        ),
      ),
    );
  }

  List<Widget> _handles(CanvasItem item, Size size, double k) {
    final measured = _sizes[item.id];
    if (measured == null) return const [];
    final placement = item.placement;
    final center = _centerOf(item, size);
    final half = Offset(
      measured.width * k * placement.scale / 2,
      measured.height * k * placement.scale / 2,
    );
    const pad = 10.0;
    Offset at(double x, double y) =>
        center + rotateVector(Offset(x, y), placement.rotation);
    final labels = widget.handleLabels;
    return [
      Positioned(
        left: center.dx,
        top: center.dy,
        child: IgnorePointer(
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: Transform.rotate(
              angle: placement.rotation,
              child: CustomPaint(
                size: Size(half.dx * 2 + pad * 2, half.dy * 2 + pad * 2),
                painter: const _DashedFrame(stem: 44),
              ),
            ),
          ),
        ),
      ),
      _Handle(
        at: at(0, -half.dy - pad - 44),
        icon: AppIcons.refresh,
        label: labels.rotate,
        onPanStart: (d) => _onHandleStart(item, d, center),
        onPanUpdate: (d) => _onRotate(d, center),
      ),
      _Handle(
        at: at(half.dx + pad, -half.dy - pad),
        icon: AppIcons.trash,
        label: labels.remove,
        onTap: () => widget.onRemove?.call(item.id),
      ),
      if (item.tools.contains(StickerTool.textColour))
        _Handle(
          at: at(-half.dx - pad, -half.dy - pad),
          icon: AppIcons.textColour,
          label: labels.textColour,
          active: widget.activeTool == StickerTool.textColour,
          onTap: () => widget.onTool?.call(item.id, StickerTool.textColour),
        ),
      if (item.tools.contains(StickerTool.background))
        _Handle(
          at: at(-half.dx - pad, half.dy + pad),
          icon: AppIcons.contrast,
          label: labels.background,
          active: widget.activeTool == StickerTool.background,
          onTap: () => widget.onTool?.call(item.id, StickerTool.background),
        ),
      _Handle(
        at: at(half.dx + pad, half.dy + pad),
        icon: AppIcons.resize,
        label: labels.resize,
        onPanStart: (d) => _onHandleStart(item, d, center),
        onPanUpdate: (d) => _onResize(d, center),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.format.ratio,
      child: LayoutBuilder(
        builder: (context, box) {
          final size = box.biggest;
          final k = size.width / canvasUnits;
          final items = _items;
          // Forget sizes of items that are gone.
          _sizes.removeWhere((id, _) => !items.any((i) => i.id == id));

          final picture = ClipRect(
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.editable
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onSelect?.call(null),
                          child: withPhotoEffect(
                            widget.effect,
                            widget.background,
                          ),
                        )
                      : withPhotoEffect(widget.effect, widget.background),
                ),
                for (final item in items) _positioned(item, size, k),
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

          final selected = widget.editable
              ? items.where((i) => i.id == widget.selected).firstOrNull
              : null;
          return Stack(
            key: _canvasKey,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: picture),
              if (selected != null) ..._handles(selected, size, k),
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
    this.active = false,
    this.onTap,
    this.onPanStart,
    this.onPanUpdate,
  });

  static const size = 40.0;

  final Offset at;
  final IconData icon;
  final String label;

  /// Its tool's panel is open: blue, like the design.
  final bool active;
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
        selected: active,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: active ? AppColors.primary50 : AppColors.neutral100,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Color(0x40000000), blurRadius: 6),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: active ? AppColors.neutral100 : AppColors.neutral0,
            ),
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
