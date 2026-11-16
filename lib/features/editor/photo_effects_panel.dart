import 'dart:typed_data';

import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/create/cropped_photo.dart';
import 'package:run4share/features/editor/photo_effect.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/pro_badge.dart';

/// The editor's Photo tool: the photo itself in each effect. Effects are
/// Pro, but anyone may try one; Share asks for Pro while it's on.
class PhotoEffectsPanel extends StatelessWidget {
  const PhotoEffectsPanel({
    required this.bytes,
    required this.crop,
    required this.selected,
    required this.isPro,
    required this.onChoose,
    required this.onClose,
    super.key,
  });

  final Uint8List bytes;
  final Rect crop;
  final PhotoEffect selected;
  final bool isPro;
  final ValueChanged<PhotoEffect> onChoose;
  final VoidCallback onClose;

  static const _tile = 92.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    // The middle square of the crop, like the theme thumbnails.
    final side = crop.width < crop.height ? crop.width : crop.height;
    final square = Rect.fromCenter(
      center: crop.center,
      width: side,
      height: side,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Text(l10n.editorPhoto, style: theme.textTheme.headlineSmall),
              if (!isPro) ...[
                const SizedBox(width: AppSpacing.sm),
                const ProBadge(),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(AppIcons.down),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: onClose,
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final effect in PhotoEffect.values)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Semantics(
                    button: true,
                    selected: effect == selected,
                    label: photoEffectName(l10n, effect),
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () => onChoose(effect),
                      child: SizedBox(
                        width: _tile + 6,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.thumb + 3,
                                ),
                                border: Border.all(
                                  color: effect == selected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.thumb - 2),
                                child: SizedBox.square(
                                  dimension: _tile - 6,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      withPhotoEffect(
                                        effect,
                                        CroppedPhoto(
                                          bytes: bytes,
                                          crop: square,
                                          aspectRatio: 1,
                                        ),
                                      ),
                                      if (!isPro && effect != PhotoEffect.none)
                                        const Positioned(
                                          top: 4,
                                          right: 4,
                                          child: ProBadge(),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              photoEffectName(l10n, effect),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                fontWeight: effect == selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
