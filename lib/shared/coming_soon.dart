import 'package:run4share/app/material.dart';
import 'package:run4share/l10n/l10n.dart';

/// Placeholder action for buttons whose feature lands in a later phase.
void showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)));
}
