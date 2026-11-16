import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/extra_sticker_view.dart';
import 'package:run4share/features/strava/strava_demo.dart';
import 'package:run4share/features/strava/strava_models.dart';

/// The onboarding art's run: 10.02 km in 46:56, a Strava record, with a
/// route, splits and streams from the Laboratory demo generators. Shown
/// only as an illustration; never stored.
Activity onboardingSampleActivity({required String name}) {
  final run = StravaActivity(
    id: 7,
    name: name,
    sportType: 'Run',
    startDate: DateTime.utc(2026, 11, 15, 7, 42),
    startDateLocal: DateTime.utc(2026, 11, 15, 7, 42),
    distance: 10020,
    movingTime: 2816,
    elapsedTime: 2876,
    averageSpeed: 10020 / 2816,
    averageHeartrate: 152,
    prCount: 1,
    polyline: demoRoute(7, 10020),
  );
  return Activity(
    id: -1,
    source: ActivitySource.strava,
    name: run.name,
    sportType: run.sportType,
    startLocal: run.startDateLocal,
    startUtc: run.startDate,
    distance: run.distance,
    movingTime: run.movingTime,
    elapsedTime: run.elapsedTime,
    averageSpeed: run.averageSpeed,
    averageHeartrate: run.averageHeartrate,
    calories: 640,
    prCount: run.prCount,
    race: false,
    polyline: run.polyline,
    splitsJson: encodeSplits(
      metric: demoSplits(run, 1000),
      standard: demoSplits(run, 1609.344),
    ),
    streamsJson: demoStreams(run).toJson(),
  );
}

/// The data stickers' view of the sample, built like the editor's.
StickerFacts onboardingSampleFacts({
  required String name,
  required Units units,
}) =>
    StickerFacts(activity: onboardingSampleActivity(name: name), units: units);
