import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_spacing.dart';

/// Rounded square holding an icon, at the start of list rows and cards.
class IconTile extends StatelessWidget {
  const IconTile({
    required this.icon,
    super.key,
    this.size = 36,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: Icon(
        icon,
        size: size * 0.56,
        color: foreground ?? scheme.onSurface,
      ),
    );
  }
}
