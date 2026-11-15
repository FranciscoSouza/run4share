import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/shared/widgets/icon_tile.dart';

/// One figure on an [ActivityCard], e.g. DISTANCE 5.02 km.
@immutable
class ActivityStat {
  const ActivityStat({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;
}

/// Activity summary card: sport icon, name, source and date, then up to
/// three figures. Values arrive already formatted for the user's locale.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.stats,
    super.key,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<ActivityStat> stats;
  final VoidCallback? onTap;

  /// Replaces the chevron, e.g. with a menu button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconTile(
                    icon: icon,
                    size: 40,
                    background: AppColors.primary95,
                    foreground: AppColors.primary40,
                  ),
                  const SizedBox(width: AppSpacing.md + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else if (onTap != null)
                    Icon(AppIcons.right, color: scheme.outline),
                ],
              ),
              if (stats.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md + 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final stat in stats.take(3))
                      Expanded(child: _Stat(stat: stat)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.stat});

  final ActivityStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.label.toUpperCase(),
          style: theme.textTheme.labelSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(
            TextSpan(
              text: stat.value,
              style: AppText.stickerValue.copyWith(color: colour),
              children: [
                if (stat.unit != null)
                  TextSpan(
                    text: ' ${stat.unit}',
                    style: AppText.stickerValue.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
