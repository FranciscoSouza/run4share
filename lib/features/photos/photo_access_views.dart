import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/shared/widgets/buttons.dart';
import 'package:run4share/shared/widgets/icon_tile.dart';

/// Centred icon, title and text with a main action and a text action:
/// the "Add a photo" and "Photo access is off" screens.
class PhotoAccessView extends StatelessWidget {
  const PhotoAccessView({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.onAction,
    required this.secondary,
    required this.onSecondary,
    this.highlight = true,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String action;
  final VoidCallback onAction;
  final String secondary;
  final VoidCallback onSecondary;

  /// Blue icon tile (asking) or neutral (access off).
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    IconTile(
                      icon: icon,
                      size: 88,
                      background: highlight
                          ? AppColors.primary95
                          : theme.colorScheme.surfaceContainer,
                      foreground: highlight
                          ? AppColors.primary30
                          : theme.colorScheme.onSurface,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      body,
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                AppButton(label: action, onPressed: onAction),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: onSecondary,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon for the "access off" screen.
const IconData photoAccessOffIcon = AppIcons.imageOff;
