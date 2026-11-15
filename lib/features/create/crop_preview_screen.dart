import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_theme.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/create/crop_screen.dart';
import 'package:run4share/features/create/cropped_photo.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/buttons.dart';

/// Temporary end of the flow until the editor (phase 4a): shows the framed
/// photo so the crop can be checked.
class CropPreviewScreen extends ConsumerStatefulWidget {
  const CropPreviewScreen({super.key});

  @override
  ConsumerState<CropPreviewScreen> createState() => _CropPreviewState();
}

class _CropPreviewState extends ConsumerState<CropPreviewScreen> {
  Future<Uint8List?>? _bytes;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(creationDraftProvider);
    if (draft != null) {
      _bytes = ref
          .read(photoLibraryProvider)
          .preview(draft.photoId, maxSide: cropPreviewMaxSide);
    }
  }

  void _done() {
    ref.read(creationDraftProvider.notifier).clear();
    context.go(AppRoutes.activities);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = ref.watch(creationDraftProvider);

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
              title: Text(l10n.previewTitle),
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: draft == null
                            ? const SizedBox.shrink()
                            : FutureBuilder<Uint8List?>(
                                future: _bytes,
                                builder: (context, snapshot) {
                                  final data = snapshot.data;
                                  if (data == null) {
                                    return const CircularProgressIndicator();
                                  }
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.thumb,
                                    ),
                                    child: CroppedPhoto(
                                      bytes: data,
                                      crop: draft.crop,
                                      aspectRatio: draft.format.ratio,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                  Text(
                    l10n.previewNote,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AppButton(label: l10n.actionDone, onPressed: _done),
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
