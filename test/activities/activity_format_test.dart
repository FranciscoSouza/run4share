import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/strava/strava_models.dart';
import 'package:run4share/l10n/app_localizations.dart';

import '../strava/fakes.dart';

void main() {
  setUpAll(initializeDateFormatting);

  ActivityFormat format(String locale, [Units units = Units.km]) =>
      ActivityFormat(
        l10n: lookupAppLocalizations(Locale(locale)),
        locale: locale,
        units: units,
      );

  final run = StravaActivity.fromJson(activityJson());

  test('run shows distance, time and pace per km', () {
    final stats = format('en').stats(run);

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
    final ride = StravaActivity.fromJson(
      activityJson(sportType: 'Ride', distance: 22500, movingTime: 3490),
    );
    final stats = format('en').stats(ride);

    expect(stats.last.label, 'Speed');
    expect(stats.last.value, '23.2');
    expect(stats.last.unit, 'km/h');
  });

  test('durations past an hour', () {
    expect(format('en').duration(3725), '1:02:05');
    expect(format('en').duration(59), '0:59');
  });

  test('subtitle keeps the wall-clock start time', () {
    expect(
      format('en').subtitle('Strava', run.startDateLocal),
      'Strava · Thu 12 Nov · 12:31',
    );
  });

  test('workouts without distance show only time', () {
    final yoga = StravaActivity.fromJson(
      activityJson(sportType: 'Yoga', distance: 0, movingTime: 1800),
    );
    expect(format('en').stats(yoga).map((s) => s.label), ['Time']);
  });
}
