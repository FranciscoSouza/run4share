import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_text.dart';

/// The "run4share" wordmark, with the 4 in brand blue.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.fontSize = 26,
    this.color,
    this.fourColor = AppColors.primary50,
    this.shadows,
  });

  final double fontSize;

  /// Colour of "run" and "share". Defaults to the theme's text colour.
  final Color? color;

  /// Colour of the "4": brand blue, or white for the watermark.
  final Color fourColor;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final base = AppText.logo.copyWith(
      fontSize: fontSize,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      shadows: shadows,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'run'),
          TextSpan(
            text: '4',
            style: TextStyle(color: fourColor),
          ),
          const TextSpan(text: 'share'),
        ],
      ),
      semanticsLabel: 'run4share',
      maxLines: 1,
    );
  }
}
