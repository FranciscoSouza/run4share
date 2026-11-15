import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/app/theme/app_theme.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/creation_repository.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/create/cropped_photo.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/sticker_view.dart';
import 'package:run4share/features/editor/story_canvas.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/share/share_actions.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/coming_soon.dart';
import 'package:run4share/shared/widgets/logo.dart';

/// Width of exported images: Instagram's 1080 for every format.
const exportWidth = 1080;

/// Longest side of the photo loaded for export: enough for a 1080-wide
/// crop of most of the frame.
const exportPhotoMaxSide = 3072;

enum _Action { save, instagram, more }

/// Last step: preview, sticker-only and watermark options, then save to
/// Photos or share. Every export is kept in My Creations.
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final GlobalKey _boundary = GlobalKey();
  Future<Uint8List?>? _photo;
  bool _stickerOnly = false;
  _Action? _busy;

  /// The creation made for each variant, so saving then sharing the same
  /// image doesn't add it twice.
  final _creations = <bool, int>{};

  @override
  void initState() {
    super.initState();
    final draft = ref.read(creationDraftProvider);
    if (draft != null) {
      _photo = ref
          .read(photoLibraryProvider)
          .preview(draft.photoId, maxSide: exportPhotoMaxSide)
          .then((bytes) async {
        // Decoded before any export, so the image is never blank.
        if (bytes != null && mounted) {
          await precacheImage(MemoryImage(bytes), context);
        }
        return bytes;
      });
    }
  }

  Future<({Uint8List png, int width, int height})> _render() async {
    final boundary =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(
      pixelRatio: exportWidth / boundary.size.width,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final result = (
      png: data!.buffer.asUint8List(),
      width: image.width,
      height: image.height,
    );
    image.dispose();
    return result;
  }

  /// Renders the image and keeps it in My Creations (once per variant).
  Future<({Uint8List png, int creationId})> _export(
    CreationDraft draft,
    String activityName,
  ) async {
    final rendered = await _render();
    final existing = _creations[_stickerOnly];
    if (existing != null) return (png: rendered.png, creationId: existing);
    final id = await ref.read(creationRepositoryProvider).add(
          png: rendered.png,
          width: rendered.width,
          height: rendered.height,
          draft: draft,
          activityName: activityName,
          stickerOnly: _stickerOnly,
          now: ref.read(clockProvider)(),
        );
    _creations[_stickerOnly] = id;
    return (png: rendered.png, creationId: id);
  }

  Future<void> _run(
    _Action action,
    CreationDraft draft,
    String activityName,
  ) async {
    if (_busy != null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(shareActionsProvider);
    final repo = ref.read(creationRepositoryProvider);
    setState(() => _busy = action);
    try {
      final exported = await _export(draft, activityName);
      switch (action) {
        case _Action.save:
          await actions.saveToPhotos(
            exported.png,
            name: 'run4share-${exported.creationId}',
          );
          if (mounted) {
            unawaited(context.push(AppRoutes.saved(exported.creationId)));
          }
        case _Action.instagram || _Action.more:
          final creation = await repo.watchById(exported.creationId).first;
          if (creation == null) return;
          await actions.shareFile((await repo.file(creation)).path);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.shareKept)));
      }
    } on SaveException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e.failure == SaveFailure.noAccess
                  ? l10n.shareSaveNoAccess
                  : l10n.shareSaveFailed,
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = ref.watch(creationDraftProvider);
    final activity = draft == null
        ? null
        : ref.watch(activityByIdProvider(draft.activityId)).value;
    final data = activity == null
        ? null
        : stickerDataFor(
            activity,
            ActivityFormat(
              l10n: l10n,
              locale: Localizations.localeOf(context).toString(),
              units: ref.watch(unitsProvider),
            ),
          );
    final theme = draft == null ? null : themeById(draft.themeId);

    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(AppIcons.back, size: 30),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.pop(),
              ),
              title: Text(l10n.actionShare),
            ),
            body: draft == null || data == null || theme == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<Uint8List?>(
                    future: _photo,
                    builder: (context, snapshot) {
                      final bytes = snapshot.data;
                      final ready =
                          snapshot.connectionState == ConnectionState.done &&
                              bytes != null;
                      return SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xxl * 2,
                                  vertical: AppSpacing.lg,
                                ),
                                child: Center(
                                  child: !ready
                                      ? const CircularProgressIndicator()
                                      : _stickerOnly
                                          ? _StickerOnlyPreview(
                                              boundary: _boundary,
                                              theme: theme,
                                              data: data,
                                              style: draft.style,
                                            )
                                          : _ImagePreview(
                                              boundary: _boundary,
                                              draft: draft,
                                              bytes: bytes,
                                              theme: theme,
                                              data: data,
                                            ),
                                ),
                              ),
                            ),
                            _Options(
                              stickerOnly: _stickerOnly,
                              onStickerOnly: (value) =>
                                  setState(() => _stickerOnly = value),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                AppSpacing.lg,
                                AppSpacing.lg,
                                AppSpacing.lg,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _ActionButton(
                                    icon: AppIcons.download,
                                    label: l10n.shareSave,
                                    primary: true,
                                    busy: _busy == _Action.save,
                                    onTap: ready
                                        ? () => _run(
                                              _Action.save,
                                              draft,
                                              activity!.name,
                                            )
                                        : null,
                                  ),
                                  _ActionButton(
                                    icon: AppIcons.story,
                                    label: l10n.shareInstagram,
                                    busy: _busy == _Action.instagram,
                                    onTap: ready
                                        ? () => _run(
                                              _Action.instagram,
                                              draft,
                                              activity!.name,
                                            )
                                        : null,
                                  ),
                                  _ActionButton(
                                    icon: AppIcons.moreHorizontal,
                                    label: l10n.shareMore,
                                    busy: _busy == _Action.more,
                                    onTap: ready
                                        ? () => _run(
                                              _Action.more,
                                              draft,
                                              activity!.name,
                                            )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

/// The full image, inside the repaint boundary that is exported.
class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.boundary,
    required this.draft,
    required this.bytes,
    required this.theme,
    required this.data,
  });

  final GlobalKey boundary;
  final CreationDraft draft;
  final Uint8List bytes;
  final StickerTheme theme;
  final StickerData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.thumb),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 30),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.thumb),
        child: RepaintBoundary(
          key: boundary,
          child: StoryCanvas(
            format: draft.format,
            background: CroppedPhoto(
              bytes: bytes,
              crop: draft.crop,
              aspectRatio: draft.format.ratio,
            ),
            theme: theme,
            data: data,
            placement: draft.sticker,
            style: draft.style,
          ),
        ),
      ),
    );
  }
}

/// The sticker alone on a checkerboard (meaning transparent); only the
/// sticker and its small mark are inside the exported boundary.
class _StickerOnlyPreview extends StatelessWidget {
  const _StickerOnlyPreview({
    required this.boundary,
    required this.theme,
    required this.data,
    required this.style,
  });

  final GlobalKey boundary;
  final StickerTheme theme;
  final StickerData data;
  final StickerStyle style;

  @override
  Widget build(BuildContext context) {
    final colour = (style.colour ?? theme.colour).color;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.thumb),
      child: CustomPaint(
        painter: const _Checkerboard(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: RepaintBoundary(
            key: boundary,
            child: FittedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StickerView(theme: theme, data: data, style: style),
                  const SizedBox(height: 24),
                  AppLogo(fontSize: 40, color: colour, fourColor: colour),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Checkerboard extends CustomPainter {
  const _Checkerboard();

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 12.0;
    final a = Paint()..color = AppColors.neutral20;
    final b = Paint()..color = AppColors.neutral10;
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final odd = ((x / cell).floor() + (y / cell).floor()).isOdd;
        canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), odd ? a : b);
      }
    }
  }

  @override
  bool shouldRepaint(_Checkerboard oldDelegate) => false;
}

class _Options extends StatelessWidget {
  const _Options({required this.stickerOnly, required this.onStickerOnly});

  final bool stickerOnly;
  final ValueChanged<bool> onStickerOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SwitchListTile(
              value: stickerOnly,
              onChanged: onStickerOnly,
              title: Text(
                l10n.shareStickerOnly,
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(l10n.shareStickerOnlySubtitle, style: muted),
            ),
            const Divider(),
            ListTile(
              title: Text(
                l10n.shareRemoveWatermark,
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(l10n.shareIncludedInPro, style: muted),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _ProBadge(),
                  Icon(AppIcons.right, color: theme.colorScheme.outline),
                ],
              ),
              // Pro and its purchase come later.
              onTap: () => showComingSoon(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warning60,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.star, size: 15, color: AppColors.neutral0),
          const SizedBox(width: 4),
          Text(
            'PRO',
            style: AppText.label.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 108,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primary
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.thumb + 4),
                ),
                child: busy
                    ? const Padding(
                        padding: EdgeInsets.all(18),
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Icon(icon, size: 26),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
