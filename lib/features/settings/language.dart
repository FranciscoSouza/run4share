import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/l10n/app_localizations.dart';

const languagePreference = 'language';

/// The in-app language choice (older Android only), read in main().
/// Null follows the phone.
final languageAtLaunchProvider = Provider<Locale?>((ref) => null);

/// The language the user picked inside run4share; null follows the phone.
/// Android 13+ and iOS set it in the phone's per-app settings instead.
final languageProvider = NotifierProvider<LanguageNotifier, Locale?>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => ref.read(languageAtLaunchProvider);

  Future<void> select(Locale? locale) async {
    state = locale;
    await ref
        .read(appDatabaseProvider)
        .writePreference(languagePreference, locale?.languageCode);
  }
}

/// A saved language code back to a supported locale, or null.
Locale? savedLanguage(String? code) {
  for (final locale in AppLocalizations.supportedLocales) {
    if (locale.languageCode == code) return locale;
  }
  return null;
}
