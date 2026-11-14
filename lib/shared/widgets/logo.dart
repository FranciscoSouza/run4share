import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_text.dart';

/// The "run4share" wordmark, with the 4 in brand blue.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.fontSize = 26, this.color});

  final double fontSize;

  /// Colour of "run" and "share". Defaults to the theme's text colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = AppText.logo.copyWith(
      fontSize: fontSize,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: const [
          TextSpan(text: 'run'),
          TextSpan(
            text: '4',
            style: TextStyle(color: AppColors.primary50),
          ),
          TextSpan(text: 'share'),
        ],
      ),
      semanticsLabel: 'run4share',
      maxLines: 1,
    );
  }
}
