import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/app_header.dart';
import 'package:run4share/shared/widgets/buttons.dart';
import 'package:run4share/shared/widgets/icon_tile.dart';

/// My Creations tab. Phase 0 shows the empty state.
class CreationsScreen extends StatelessWidget {
  const CreationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

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
                  l10n.creationsCount(0),
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
            ),
          ),
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
