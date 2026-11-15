import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/l10n/app_localizations.dart';

Activity row({
  String sportType = 'Run',
  double? distance = 5020,
  int movingTime = 1994,
  double? calories,
  double? heartRate,
  ActivitySource source = ActivitySource.strava,
}) =>
    Activity(
      id: 1,
      source: source,
      name: 'Lunch Run',
      sportType: sportType,
      startLocal: DateTime.utc(2026, 11, 12, 12, 31),
      distance: distance,
      movingTime: movingTime,
      averageSpeed: distance == null ? null : distance / movingTime,
      calories: calories,
      averageHeartrate: heartRate,
      race: false,
    );

void main() {
  setUpAll(initializeDateFormatting);

  ActivityFormat format(String locale, [Units units = Units.km]) =>
      ActivityFormat(
        l10n: lookupAppLocalizations(Locale(locale)),
        locale: locale,
        units: units,
      );

  test('run shows distance, time and pace per km', () {
    final stats = format('en').stats(row());

    expect(stats.map((s) => s.label), ['Distance', 'Time', 'Pace']);
    expect(stats.map((s) => s.value), ['5.02', '33:14', '6:37']);
    expect(stats.map((s) => s.unit), ['km', null, '/km']);
  });

  test('comma decimals in Portuguese and German', () {
    expect(format('pt').distance(5020), '5,02');
    expect(format('de').distance(22500), '22,50');
  });

  test('miles', () {
    final f = format('en', Units.mi);
    expect(f.distance(1609.344 * 3.1), '3.10');
    expect(f.pace(1609.344 / 480), '8:00');
    expect(f.speedUnit, 'mph');
  });

  test('ride shows speed instead of pace', () {
    final stats = format(
      'en',
    ).stats(row(sportType: 'Ride', distance: 22500, movingTime: 3490));

    expect(stats.last.label, 'Speed');
    expect(stats.last.value, '23.2');
    expect(stats.last.unit, 'km/h');
  });

  test('durations past an hour', () {
    expect(format('en').duration(3725), '1:02:05');
    expect(format('en').duration(59), '0:59');
  });

  test('start keeps the wall-clock time', () {
    expect(
      format('en').when(DateTime.utc(2026, 11, 12, 12, 31)),
      'Thu 12 Nov · 12:31',
    );
  });

  test('without distance: time, then calories, else heart rate', () {
    final f = format('en');
    final workout = f.stats(
      row(sportType: 'WeightTraining', distance: null, calories: 189),
    );
    expect(workout.map((s) => s.label), ['Time', 'Calories']);
    expect(workout.last.value, '189');
    expect(workout.last.unit, 'kcal');

    final yoga = f.stats(
      row(sportType: 'Yoga', distance: null, heartRate: 98),
    );
    expect(yoga.map((s) => s.label), ['Time', 'Avg HR']);

    final bare = f.stats(row(sportType: 'Yoga', distance: null));
    expect(bare.map((s) => s.label), ['Time']);
  });

  test('manual activities are labelled as such', () {
    final card = format('en').card(row(source: ActivitySource.manual));
    expect(card.subtitle, 'Manual · Thu 12 Nov · 12:31');
  });
}
