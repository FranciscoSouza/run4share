import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/theme_messages.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/buttons.dart';

/// Template step 1 of 3: choose an activity. Activities the template's
/// theme can't draw are shown greyed with the reason.
class TemplateActivityScreen extends ConsumerWidget {
  const TemplateActivityScreen({required this.templateId, super.key});

  final String templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final template = templateById(templateId);
    final activities = ref.watch(activitiesProvider).value;
    final back = IconButton(
      icon: const Icon(AppIcons.back, size: 30),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => context.pop(),
    );
    if (template == null) return Scaffold(appBar: AppBar(leading: back));

    final format = ActivityFormat(
      l10n: l10n,
      locale: Localizations.localeOf(context).toString(),
      units: ref.watch(unitsProvider),
    );

    return Scaffold(
      appBar: AppBar(leading: back, title: Text(template.name)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text.rich(
            TextSpan(
              text: l10n.templateStepOf(1, 3),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: ' · ${template.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            child: Text(
              l10n.templateChooseActivity,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (activities == null)
            const Center(child: CircularProgressIndicator())
          else if (activities.isEmpty) ...[
            Text(
              l10n.homeNoActivitiesYet,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.homeAddManually,
              icon: AppIcons.plus,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push(AppRoutes.newActivity),
            ),
          ] else
            for (final activity in activities)
              Builder(
                builder: (context) {
                  final data = stickerDataFor(activity, format);
                  final missing = data.missingFor(template.theme);
                  final card = format.card(
                    activity,
                    onTap: missing != null
                        ? null
                        : () {
                            ref
                                .read(templateChoiceProvider.notifier)
                                .choose(template.id);
                            unawaited(
                              context.push(AppRoutes.choosePhoto(activity.id)),
                            );
                          },
                    footer: missing == null
                        ? null
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                AppIcons.info,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  l10n.templateCantUse(
                                    themeMissingMessage(l10n, missing),
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: missing == null
                        ? card
                        : Opacity(opacity: 0.55, child: card),
                  );
                },
              ),
        ],
      ),
    );
  }
}
