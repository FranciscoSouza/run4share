import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/l10n/app_localizations.dart';

ActivityFormat format(String locale) => ActivityFormat(
      l10n: lookupAppLocalizations(Locale(locale)),
      locale: locale,
      units: Units.km,
    );

Activity activity({
  String sportType = 'Run',
  double? distance = 5020,
  double? heartRate,
  double? calories,
}) =>
    Activity(
      id: 1,
      source: ActivitySource.manual,
      name: 'Test',
      sportType: sportType,
      startLocal: DateTime.utc(2026, 11, 12, 12, 31),
      distance: distance,
      movingTime: 1994,
      averageHeartrate: heartRate,
      calories: calories,
      race: false,
    );

void main() {
  setUpAll(initializeDateFormatting);

  test('the seven design themes, then the Pro ones; ids unique', () {
    expect(stickerThemes.map((t) => t.name), [
      'Inline Top',
      'Vertical Stack',
      'Big Distance',
      'Poster',
      'Heart Ring',
      'Weekday',
      'Time & Calories',
      'Race Bib',
      'Receipt',
      'Scoreboard',
    ]);
    expect(stickerThemes.map((t) => t.id).toSet(), hasLength(10));
    for (final template in storyTemplates) {
      expect(themeById(template.themeId), isNotNull, reason: template.id);
    }
  });

  test('name and start date for the Bib and the Receipt', () {
    final data = stickerDataFor(activity(), format('en'));
    expect(data.name, activity().name);
    expect(data.date, matches(RegExp(r'^[A-Z]{3} \d+, 2026 · \d\d:\d\d$')));
    final pt = stickerDataFor(activity(), format('pt'));
    expect(pt.date, contains('2026 · '));
  });

  test('sample run: everything but what is missing', () {
    final data = stickerDataFor(activity(), format('en'));
    expect(data.stats[Metric.distance]?.value, '5.02');
    expect(data.stats[Metric.rate]?.label, 'Pace');
    expect(data.stats[Metric.rate]?.value, '6:37');
    expect(data.sport, 'RUN');
    expect(data.weekday, 'THURSDAY');
    expect(data.supports(themeById('inline-top')!), isTrue);
    expect(data.missingFor(themeById('heart-ring')!), Metric.heartRate);
    expect(data.missingFor(themeById('time-calories')!), Metric.calories);
  });

  test('rides show speed in the rate slot', () {
    final data = stickerDataFor(
      activity(sportType: 'Ride', distance: 22500),
      format('en'),
    );
    expect(data.stats[Metric.rate]?.label, 'Speed');
    expect(data.stats[Metric.rate]?.unit, 'km/h');
    expect(data.sport, 'RIDE');
  });

  test('workouts without distance only fit time-based themes', () {
    final data = stickerDataFor(
      activity(sportType: 'WeightTraining', distance: null, calories: 189),
      format('en'),
    );
    final usable = stickerThemes.where(data.supports).map((t) => t.id);
    expect(usable, ['time-calories']);
  });

  test('heart rate unlocks the ring', () {
    final data = stickerDataFor(activity(heartRate: 152), format('en'));
    expect(data.stats[Metric.heartRate]?.value, '152');
    expect(data.supports(themeById('heart-ring')!), isTrue);
  });

  test('labels and weekday follow the language', () {
    final data = stickerDataFor(activity(), format('pt'));
    expect(data.stats[Metric.distance]?.value, '5,02');
    expect(data.weekday, 'QUINTA-FEIRA');
    expect(data.sport, 'CORRIDA');
  });
}
