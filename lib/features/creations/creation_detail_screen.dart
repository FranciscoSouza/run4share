import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/creation_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/creations/creation_image.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/share/share_actions.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/buttons.dart';

/// One creation: share it again, edit it, or delete it.
class CreationDetailScreen extends ConsumerWidget {
  const CreationDetailScreen({required this.creationId, super.key});

  final int creationId;

  Future<void> _share(WidgetRef ref, Creation creation) async {
    final file = await ref.read(creationRepositoryProvider).file(creation);
    await ref.read(shareActionsProvider).shareFile(file.path);
  }

  /// Reopens the editor with the saved settings, if the activity and the
  /// original photo are still there.
  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Creation creation,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    void say(String text) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));

    final draft = ref.read(creationRepositoryProvider).settingsOf(creation);
    if (draft == null) return say(l10n.creationEditUnavailable);
    final activity =
        await ref.read(activityRepositoryProvider).byId(draft.activityId);
    if (activity == null) return say(l10n.creationActivityGone);
    final photo =
        await ref.read(photoLibraryProvider).thumbnail(draft.photoId, size: 64);
    if (photo == null) return say(l10n.creationPhotoGone);

    ref.read(templateChoiceProvider.notifier).choose(null);
    ref.read(creationDraftProvider.notifier).set(draft);
    if (context.mounted) unawaited(context.push(AppRoutes.editor));
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Creation creation,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.creationDeleteTitle),
        content: Text(l10n.creationDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(creationRepositoryProvider).delete(creation);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final creation = ref.watch(creationByIdProvider(creationId)).value;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back, size: 30),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
        title: creation == null
            ? null
            : Column(
                children: [
                  Text(creation.activityName),
                  Text(
                    DateFormat(
                      'd MMM · HH:mm',
                      locale,
                    ).format(creation.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
        actions: [
          if (creation != null)
            IconButton(
              icon: Icon(AppIcons.trash, color: theme.colorScheme.error),
              tooltip: l10n.actionDelete,
              onPressed: () => _delete(context, ref, creation),
            ),
        ],
      ),
      body: creation == null
          ? const SizedBox.shrink()
          : SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl + 8,
                        AppSpacing.lg,
                        AppSpacing.xxl + 8,
                        AppSpacing.lg,
                      ),
                      child: Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppRadius.card + 8,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 30,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppRadius.card + 8,
                            ),
                            child: CreationImage(creation: creation),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: l10n.creationShareAgain,
                            icon: AppIcons.share,
                            onPressed: () => _share(ref, creation),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: l10n.actionEdit,
                            variant: AppButtonVariant.secondary,
                            onPressed: () => _edit(context, ref, creation),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
