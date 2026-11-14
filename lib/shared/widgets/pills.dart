import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_text.dart';

enum AppPillVariant {
  /// Brand blue, e.g. "Next", "Unlock".
  filled,

  /// Light blue, e.g. "Connect" in Settings.
  tonal,

  /// Black, e.g. "Connect Strava" on Home.
  dark,

  /// Outlined, e.g. "Connect" for a second source on Home.
  outlined,

  /// Outlined with red text, e.g. "Disconnect".
  destructive,
}

/// Compact rounded button used inside rows and headers.
class AppPill extends StatelessWidget {
  const AppPill({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppPillVariant.filled,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppPillVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, border) = switch (variant) {
      AppPillVariant.filled => (scheme.primary, scheme.onPrimary, null),
      AppPillVariant.tonal => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          null,
        ),
      AppPillVariant.dark => (AppColors.neutral0, AppColors.neutral100, null),
      AppPillVariant.outlined => (
          Colors.transparent,
          scheme.onSurface,
          scheme.outline,
        ),
      AppPillVariant.destructive => (
          Colors.transparent,
          scheme.error,
          scheme.outline,
        ),
    };

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: StadiumBorder(
          side: border == null
              ? BorderSide.none
              : BorderSide(color: border, width: 1.5),
        ),
        textStyle: AppText.button.copyWith(fontSize: 15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
