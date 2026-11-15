import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/app_info.dart';
import 'package:run4share/app/links.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/system.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/features/rate/rate_prompt.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/buttons.dart';

/// "Enjoying run4share?": rate, send feedback instead, or not now.
Future<void> showRateSheet(BuildContext context, WidgetRef ref) async {
  final prompt = ref.read(ratePromptProvider);
  final system = ref.read(systemActionsProvider);
  final choice = await showModalBottomSheet<_Choice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const _RateSheet(),
  );
  switch (choice) {
    case _Choice.rate:
      await prompt.answered();
      await system.requestReview();
    case _Choice.feedback:
      await prompt.answered();
      await system.openLink(AppLinks.feedback(version: AppInfo.version));
    case _Choice.notNow || null:
      await prompt.notNow();
  }
}

enum _Choice { rate, feedback, notNow }

class _RateSheet extends StatelessWidget {
  const _RateSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 5; i++)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.star_rounded,
                        size: 38,
                        color: AppColors.warning60,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.rateTitle,
              style: theme.textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.rateBody,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.settingsRate,
              icon: AppIcons.star,
              onPressed: () => Navigator.pop(context, _Choice.rate),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.rateFeedback,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.pop(context, _Choice.feedback),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.pop(context, _Choice.notNow),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.actionNotNow),
            ),
          ],
        ),
      ),
    );
  }
}
