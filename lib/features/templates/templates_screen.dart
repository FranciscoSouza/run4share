import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/templates/template_canvas.dart';
import 'package:run4share/features/templates/template_info.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/pro_badge.dart';

/// Every template in two columns ("See all" on Home).
class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final isPro = ref.watch(isProProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back, size: 30),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.templatesTitle),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.xl,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.lg,
          // A 9:16 tile plus room for the name under it.
          childAspectRatio: 9 / 16 * 0.86,
        ),
        itemCount: storyTemplates.length,
        itemBuilder: (context, index) {
          final template = storyTemplates[index];
          return Semantics(
            button: true,
            label: '${template.name}, '
                '${templateWhat(l10n, template, isPro: isPro)}',
            excludeSemantics: true,
            child: InkWell(
              onTap: () => context.push(AppRoutes.template(template.id)),
              borderRadius: BorderRadius.circular(AppRadius.thumb),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.thumb),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: 180,
                              height: 320,
                              child: TemplateCanvas(
                                template: template,
                                watermark: false,
                              ),
                            ),
                          ),
                          if (templateLocked(template, isPro: isPro))
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: ProBadge(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    template.name,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
