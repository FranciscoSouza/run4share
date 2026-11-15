import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/data/creation_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/creations/creation_image.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/app_header.dart';
import 'package:run4share/shared/widgets/buttons.dart';
import 'package:run4share/shared/widgets/icon_tile.dart';

/// My Creations tab: every saved or shared image, newest first.
class CreationsScreen extends ConsumerWidget {
  const CreationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final creations = ref.watch(creationsProvider).value;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.creationsTitle,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ),
                Text(
                  l10n.creationsCount(creations?.length ?? 0),
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          if (creations != null && creations.isNotEmpty)
            Expanded(child: _CreationsGrid(creations: creations))
          else
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    children: [
                      const IconTile(
                        icon: AppIcons.image,
                        size: 72,
                        background: AppColors.primary95,
                        foreground: AppColors.primary40,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.creationsEmptyTitle,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.creationsEmptyBody,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: muted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: l10n.creationsEmptyAction,
                        onPressed: () => context.go(AppRoutes.activities),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Two columns, each image at its own height, like the design.
class _CreationsGrid extends ConsumerWidget {
  const _CreationsGrid({required this.creations});

  final List<Creation> creations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Each image goes to whichever column is shorter so far.
    final columns = [<Creation>[], <Creation>[]];
    final heights = [0.0, 0.0];
    for (final creation in creations) {
      final column = heights[0] <= heights[1] ? 0 : 1;
      columns[column].add(creation);
      heights[column] += creation.height / creation.width + 0.25;
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.xl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var c = 0; c < 2; c++) ...[
            if (c > 0) const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                children: [
                  for (final creation in columns[c])
                    _CreationTile(creation: creation),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CreationTile extends ConsumerWidget {
  const _CreationTile({required this.creation});

  final Creation creation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final day = creationDay(
      creation.createdAt,
      ref.watch(clockProvider)(),
      today: l10n.creationsToday,
      yesterday: l10n.creationsYesterday,
      date: (d) => DateFormat('d MMM', locale).format(d),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Semantics(
        button: true,
        label: '${creation.activityName}, $day',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => context.push(AppRoutes.creation(creation.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: CreationImage(creation: creation, cacheWidth: 500),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text.rich(
                TextSpan(
                  text: creation.activityName,
                  style: theme.textTheme.titleMedium,
                  children: [
                    TextSpan(
                      text: ' · $day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
