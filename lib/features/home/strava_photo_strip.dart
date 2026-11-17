import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/photos/strava_photos.dart';
import 'package:run4share/features/strava/strava_models.dart';
import 'package:run4share/l10n/l10n.dart';

/// The photos a Strava activity has, as a scrolling row of thumbnails on
/// its card. Tapping one takes that photo, at full size, to the crop
/// step for this activity, skipping the gallery.
class StravaPhotoStrip extends ConsumerWidget {
  const StravaPhotoStrip({required this.activity, super.key});

  final Activity activity;

  static const _size = 64.0;

  Future<void> _use(
    BuildContext context,
    WidgetRef ref,
    StravaPhoto photo,
  ) async {
    final l10n = context.l10n;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    // The full-size image is one Strava request and a download away.
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: Text(l10n.stravaPhotoLoading)),
              ],
            ),
          ),
        ),
      ),
    );
    try {
      final photoId =
          await ref.read(stravaPhotoStoreProvider).download(activity, photo.id);
      navigator.pop();
      ref.read(templateChoiceProvider.notifier).choose(null);
      unawaited(router.push(AppRoutes.cropPicked(activity.id, photoId)));
    } on Object catch (error) {
      debugPrint('Strava photo failed: $error');
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.stravaPhotoFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = photosOf(activity);
    if (photos.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final pixels = (_size * MediaQuery.devicePixelRatioOf(context)).round();
    return SizedBox(
      height: _size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) => Semantics(
          button: true,
          label: l10n.stravaPhotoLabel(index + 1),
          excludeSemantics: true,
          child: GestureDetector(
            onTap: () => _use(context, ref, photos[index]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.thumb),
              child: Image.network(
                photos[index].url,
                width: _size,
                height: _size,
                fit: BoxFit.cover,
                cacheWidth: pixels,
                errorBuilder: (context, error, stack) => const ColoredBox(
                  color: AppColors.neutral90,
                  child: SizedBox.square(dimension: _size),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
