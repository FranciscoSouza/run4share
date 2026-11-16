import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/theme_messages.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/templates/template_canvas.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/buttons.dart';
import 'package:run4share/shared/widgets/pro_badge.dart';

/// What a Popular template looks like, and the three steps to use it.
class TemplatePreviewScreen extends ConsumerWidget {
  const TemplatePreviewScreen({required this.templateId, super.key});

  final String templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final template = templateById(templateId);
    final back = IconButton(
      icon: const Icon(AppIcons.back, size: 30),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => context.pop(),
    );
    if (template == null) return Scaffold(appBar: AppBar(leading: back));

    final steps = [l10n.templateStep1, l10n.templateStep2, l10n.templateStep3];
    // Anyone can look; using a Pro template needs Pro.
    final locked = themeLocked(
      template.theme,
      isPro: ref.watch(isProProvider),
    );
    return Scaffold(
      appBar: AppBar(
        leading: back,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(template.name)),
            if (locked) ...[
              const SizedBox(width: AppSpacing.sm),
              const ProBadge(),
            ],
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          child: TemplateCanvas(template: template),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.templateSample(
                      '${template.format.width}:${template.format.height}',
                      themeMetricNames(l10n, template.theme),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (var i = 0; i < steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs + 2,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.primary95,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${i + 1}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary30,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              steps[i],
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                label: l10n.templateUse,
                onPressed: () => context.push(
                  locked
                      ? AppRoutes.pro
                      : AppRoutes.templateActivity(template.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
