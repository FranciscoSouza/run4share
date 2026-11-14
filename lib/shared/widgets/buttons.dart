import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_text.dart';

enum AppButtonVariant {
  /// Brand blue, e.g. "Primary action".
  primary,

  /// Black, e.g. "Connect with Strava".
  dark,

  /// Outlined, e.g. "Add activity manually".
  secondary,

  /// Outlined in red, e.g. "Delete".
  destructive,
}

/// Full-width button from the Foundations components.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  static const height = 52.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    const minimumSize = Size.fromHeight(height);
    final child = _content();

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.dark:
        final dark = variant == AppButtonVariant.dark;
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: dark ? AppColors.neutral0 : scheme.primary,
            foregroundColor: dark ? AppColors.neutral100 : scheme.onPrimary,
            minimumSize: minimumSize,
            shape: shape,
            textStyle: AppText.button,
          ),
          child: child,
        );
      case AppButtonVariant.secondary:
      case AppButtonVariant.destructive:
        final colour = variant == AppButtonVariant.destructive
            ? scheme.error
            : scheme.onSurface;
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colour,
            side: BorderSide(
              color: variant == AppButtonVariant.destructive
                  ? scheme.error
                  : scheme.outline,
              width: 1.5,
            ),
            minimumSize: minimumSize,
            shape: shape,
            textStyle: AppText.button,
          ),
          child: child,
        );
    }
  }

  Widget _content() {
    final text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (icon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: text),
      ],
    );
  }
}
