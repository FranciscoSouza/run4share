import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/data/creation_repository.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/creations/creation_image.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/buttons.dart';

/// After Save to Photos: the image, and where to go next.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({required this.creationId, super.key});

  final int creationId;

  void _finish(BuildContext context, WidgetRef ref, String route) {
    ref.read(creationDraftProvider.notifier).clear();
    ref.read(templateChoiceProvider.notifier).choose(null);
    context.go(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final creation = ref.watch(creationByIdProvider(creationId)).value;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      if (creation != null)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 240),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.thumb,
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
                                    AppRadius.thumb,
                                  ),
                                  child: CreationImage(
                                    creation: creation,
                                    cacheWidth: 600,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -18,
                                bottom: -18,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.success40,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 4,
                                    ),
                                  ),
                                  child: const Icon(
                                    AppIcons.check,
                                    color: AppColors.neutral100,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xxl),
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.savedTitle,
                          style: theme.textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.savedBody,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  AppButton(
                    label: l10n.savedCreateAnother,
                    onPressed: () =>
                        _finish(context, ref, AppRoutes.activities),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.savedViewCreations,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => _finish(context, ref, AppRoutes.creations),
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
