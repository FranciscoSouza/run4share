import 'package:flutter/widgets.dart';
import 'package:run4share/l10n/app_localizations.dart';

export 'package:run4share/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
