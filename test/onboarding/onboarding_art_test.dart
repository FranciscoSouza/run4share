import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/sticker_view.dart';
import 'package:run4share/features/onboarding/onboarding_art.dart';
import 'package:run4share/features/onboarding/onboarding_sample.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/activity_labels.dart';
import 'package:run4share/features/stickers/extra_sticker_view.dart';
import 'package:run4share/l10n/app_localizations.dart';

import '../helpers/pump_app.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('the sample run has everything the art draws', () {
    final facts = onboardingSampleFacts(name: 'Run', units: Units.km);
    final run = facts.activity;
    expect(run.distance, 10020);
    expect(facts.charts.pace, isNotNull);
    expect(facts.charts.heartRate, isNotNull);
    expect(facts.charts.elevation, isNotNull);
    expect(run.polyline, isNotNull);
    expect(run.splitsJson, contains('"km"'));
    expect(
      labelsFor(run, const []).map((l) => l.kind),
      contains(LabelKind.record),
    );
  });

  for (final locale in AppLocalizations.supportedLocales) {
    for (final units in Units.values) {
      testWidgets('every page draws in ${locale.languageCode}, ${units.name}', (
        tester,
      ) async {
        for (var page = 1; page <= 4; page++) {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                ...baseOverrides(),
                unitsAtLaunchProvider.overrideWithValue(units),
                proAtLaunchProvider.overrideWithValue(false),
              ],
              child: Localizations(
                locale: locale,
                delegates: AppLocalizations.localizationsDelegates,
                child: Center(
                  child: SizedBox(
                    width: 320,
                    height: 400,
                    child: OnboardingArt(page: page),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: 'page $page');
        }
        // Pro art draws without Pro: the receipt is there.
        expect(find.byType(StickerView), findsOneWidget);
        expect(find.byType(ExtraStickerView), findsNWidgets(2));
      });
    }
  }

  testWidgets("stickers ignore the phone's font size", (tester) async {
    const data = StickerData(
      stats: {
        Metric.distance:
            StickerStat(label: 'Distance', value: '10.02', unit: 'km'),
      },
      sport: 'RUN',
      weekday: 'SUNDAY',
    );
    Future<Size> sizeAt(double scale) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: UnconstrainedBox(
                child: StickerView(theme: stickerThemes[2], data: data),
              ),
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(StickerView));
    }

    expect(await sizeAt(2), await sizeAt(1));
  });
}
