import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/templates/template_canvas.dart';
import 'package:run4share/l10n/app_localizations.dart';

import '../helpers/pump_app.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('ids unique, every theme exists, Pro as decided', () {
    expect(storyTemplates.map((t) => t.id).toSet(), hasLength(11));
    for (final t in storyTemplates) {
      expect(themeById(t.themeId), isNotNull, reason: t.id);
    }
    // Francisco, 16 Nov 2026: Sunrise Half and Coast Walk free even with
    // their chart and route; the last four free.
    expect(
      [
        for (final t in storyTemplates)
          if (t.pro) t.id,
      ],
      [
        'summit-day',
        'mountain-climb',
        'final-score',
        'race-day',
        'run-receipt',
      ],
    );
    expect(
      featuredTemplates.map((t) => t.name),
      [
        'Sunrise Half',
        'Summit Day',
        'Mountain Climb',
        'Night Run',
        'Race Day',
        'Run Receipt',
        'Coast Walk',
      ],
    );
  });

  test('no photos yet: every template keeps its gradient', () {
    for (final t in storyTemplates) {
      expect(t.photo, isNull, reason: t.id);
    }
  });

  for (final locale in AppLocalizations.supportedLocales) {
    for (final units in Units.values) {
      testWidgets(
          'featured templates draw in ${locale.languageCode}, ${units.name}', (
        tester,
      ) async {
        for (final template in featuredTemplates) {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                ...baseOverrides(),
                unitsAtLaunchProvider.overrideWithValue(units),
              ],
              child: Localizations(
                locale: locale,
                delegates: AppLocalizations.localizationsDelegates,
                child: Center(
                  child: SizedBox(
                    width: 220,
                    height: 391,
                    child: TemplateCanvas(template: template),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: template.id);
        }
      });
    }
  }
}
