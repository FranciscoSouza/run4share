import 'dart:async';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_theme.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/pills.dart';

/// Longest side of the photo loaded for cropping. The crop is stored as
/// fractions, so later steps can use the full-resolution original.
const cropPreviewMaxSide = 2048;

/// Step 2: choose the format and frame the photo by dragging and pinching.
class CropScreen extends ConsumerStatefulWidget {
  const CropScreen({
    required this.activityId,
    required this.photoId,
    super.key,
  });

  final int activityId;
  final String photoId;

  @override
  ConsumerState<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends ConsumerState<CropScreen> {
  final _controller = CropController();
  Uint8List? _bytes;
  Size? _photoSize;
  ShareFormat? _format;
  bool _failed = false;

  /// Latest crop frame and photo rectangle on screen, from the cropper.
  Rect? _frame;
  Rect? _photoOnScreen;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final format = await lastFormat(db);
    final bytes = await ref
        .read(photoLibraryProvider)
        .preview(widget.photoId, maxSide: cropPreviewMaxSide);
    Size? size;
    if (bytes != null) {
      try {
        final image = await decodeImageFromList(bytes);
        size = Size(image.width.toDouble(), image.height.toDouble());
        image.dispose();
      } on Object {
        size = null;
      }
    }
    if (!mounted) return;
    setState(() {
      _format = format;
      _bytes = size == null ? null : bytes;
      _photoSize = size;
      _failed = size == null;
    });
  }

  void _setFormat(ShareFormat format) {
    if (format == _format) return;
    setState(() {
      _format = format;
      _frame = null;
    });
    _controller.aspectRatio = format.ratio;
  }

  Future<void> _next() async {
    final format = _format;
    final size = _photoSize;
    if (format == null || size == null) return;
    final frame = _frame;
    final photo = _photoOnScreen;
    final crop = frame != null && photo != null
        ? fractionalCrop(frame: frame, photo: photo)
        : centreCrop(size, format);
    ref.read(creationDraftProvider.notifier).set(
          CreationDraft(
            activityId: widget.activityId,
            photoId: widget.photoId,
            format: format,
            crop: crop,
          ),
        );
    await ref
        .read(appDatabaseProvider)
        .writePreference(formatPreference, format.name);
    if (mounted) await context.push(AppRoutes.createPreview);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bytes = _bytes;
    final format = _format;

    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(AppIcons.back, size: 30),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.pop(),
              ),
              title: Text(l10n.cropTitle),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: AppPill(
                    label: l10n.actionNext,
                    onPressed: bytes == null ? null : _next,
                  ),
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.sm,
                      ),
                      child: switch ((bytes, format)) {
                        (final Uint8List data, final ShareFormat f) => Crop(
                            image: data,
                            controller: _controller,
                            onCropped: (_) {},
                            aspectRatio: f.ratio,
                            initialRectBuilder:
                                InitialRectBuilder.withSizeAndRatio(
                              size: 1,
                              aspectRatio: f.ratio,
                            ),
                            interactive: true,
                            fixCropRect: true,
                            baseColor: AppColors.neutral0,
                            maskColor:
                                AppColors.neutral0.withValues(alpha: 0.6),
                            cornerDotBuilder: (size, edge) =>
                                const SizedBox.shrink(),
                            overlayBuilder: (context, rect) =>
                                const _CropFrame(),
                            progressIndicator: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            onMoved: (frame, imageRect) =>
                                _frame = Rect.fromLTRB(
                              frame.left,
                              frame.top,
                              frame.right,
                              frame.bottom,
                            ),
                            onImageMoved: (photo) => _photoOnScreen = photo,
                          ),
                        _ when _failed => Center(
                            child: Text(
                              l10n.photoLoadFailed,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        _ => const Center(child: CircularProgressIndicator()),
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      l10n.cropHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        for (final f in ShareFormat.values) ...[
                          if (f != ShareFormat.values.first)
                            const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _FormatCard(
                              format: f,
                              selected: f == format,
                              onTap: () => _setFormat(f),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Rule-of-thirds grid and corner brackets over the crop frame.
class _CropFrame extends StatelessWidget {
  const _CropFrame();

  @override
  Widget build(BuildContext context) =>
      const IgnorePointer(child: CustomPaint(painter: _CropFramePainter()));
}

class _CropFramePainter extends CustomPainter {
  const _CropFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = AppColors.neutral100.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      final y = size.height * i / 3;
      canvas
        ..drawLine(Offset(x, 0), Offset(x, size.height), thin)
        ..drawLine(Offset(0, y), Offset(size.width, y), thin);
    }
    canvas.drawRect(Offset.zero & size, thin..style = PaintingStyle.stroke);

    final thick = Paint()
      ..color = AppColors.neutral100
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const arm = 20.0;
    final w = size.width;
    final h = size.height;
    for (final (corner, dx, dy) in [
      (Offset.zero, 1.0, 1.0),
      (Offset(w, 0), -1.0, 1.0),
      (Offset(0, h), 1.0, -1.0),
      (Offset(w, h), -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx + dx * arm, corner.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx, corner.dy + dy * arm),
        thick,
      );
    }
  }

  @override
  bool shouldRepaint(_CropFramePainter oldDelegate) => false;
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.format,
    required this.selected,
    required this.onTap,
  });

  final ShareFormat format;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final name = switch (format) {
      ShareFormat.story => l10n.formatStory,
      ShareFormat.feed => l10n.formatFeed,
      ShareFormat.square => l10n.formatSquare,
    };
    final colour = selected
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? AppColors.primary30.withValues(alpha: 0.35)
            : theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.thumb),
          side: BorderSide(
            color: selected
                ? AppColors.primary60
                : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.thumb),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              children: [
                SizedBox(
                  height: 28,
                  child: Center(
                    child: Container(
                      width: 22 * format.ratio.clamp(0.5, 1),
                      height: 26 * (format.ratio < 1 ? 1 : 0.85),
                      decoration: BoxDecoration(
                        border: Border.all(color: colour, width: 2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FittedBox(
                  child: Text.rich(
                    TextSpan(
                      text: name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colour,
                      ),
                      children: [
                        TextSpan(
                          text: ' ${format.width}:${format.height}',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
