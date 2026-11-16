import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/l10n/app_localizations.dart';

import 'helpers/pump_app.dart';

void main() {
  test('supports en, pt, es, fr and de', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      {'en', 'pt', 'es', 'fr', 'de'},
    );
  });

  // Each screen is pumped at phone size in every language; any overflow
  // fails the test.
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('all phase-0 screens lay out in ${locale.languageCode}', (
      tester,
    ) async {
      await tester.pumpApp(locale: locale);
      final l10n = lookupAppLocalizations(locale);

      expect(find.text(l10n.homeTemplatesTitle), findsOneWidget);
      expect(find.text(l10n.navActivities), findsOneWidget);

      await tester.tap(find.text(l10n.navCreations).last);
      await tester.pumpAndSettle();
      expect(find.text(l10n.creationsEmptyTitle), findsOneWidget);

      await tester.tap(find.byTooltip(l10n.settingsTooltip));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.settingsLanguageSubtitle(l10n.languageName)),
        findsOneWidget,
      );
    });
  }
}
