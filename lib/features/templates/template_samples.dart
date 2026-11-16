import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/extra_sticker_view.dart';
import 'package:run4share/features/strava/strava_demo.dart';
import 'package:run4share/features/strava/strava_models.dart';

/// Sample activities for template and onboarding art, one per sport, with
/// a route, splits and streams from the Laboratory demo generators. Shown
/// only as illustrations; never stored. Figures (Francisco, 16 Nov 2026):
/// the run is onboarding's 10.02 km; hike, ride and walk follow the Home
/// artboards.
Activity sampleActivityFor(SportKind sport, {required String name}) {
  final (id, type, metres, seconds, heart, climb) = switch (sport) {
    SportKind.hike => (9, 'Hike', 14600.0, 16330, 128.0, 1240.0),
    SportKind.ride => (8, 'Ride', 64300.0, 8165, 141.0, 820.0),
    SportKind.walk => (11, 'Walk', 8400.0, 6048, 104.0, 60.0),
    _ => (7, 'Run', 10020.0, 2816, 152.0, 48.0),
  };
  final start = DateTime.utc(2026, 11, 15, 7, 42);
  final demo = StravaActivity(
    id: id,
    name: name,
    sportType: type,
    startDate: start,
    startDateLocal: start,
    distance: metres,
    movingTime: seconds,
    elapsedTime: seconds + 60,
    averageSpeed: metres / seconds,
    averageHeartrate: heart,
    // The run earned a record, for the Record label.
    prCount: type == 'Run' ? 1 : 0,
    polyline: demoRoute(id, metres),
  );
  return Activity(
    id: -id,
    source: ActivitySource.strava,
    name: demo.name,
    sportType: demo.sportType,
    startLocal: demo.startDateLocal,
    startUtc: demo.startDate,
    distance: demo.distance,
    movingTime: demo.movingTime,
    elapsedTime: demo.elapsedTime,
    averageSpeed: demo.averageSpeed,
    averageHeartrate: demo.averageHeartrate,
    calories: seconds / 4.4,
    elevationGain: climb,
    prCount: demo.prCount,
    race: false,
    polyline: demo.polyline,
    splitsJson: encodeSplits(
      metric: demoSplits(demo, 1000),
      standard: demoSplits(demo, 1609.344),
    ),
    streamsJson: demoStreams(demo).toJson(),
  );
}

/// The data stickers' view of a sample, built like the editor's.
StickerFacts sampleFactsFor(
  SportKind sport, {
  required String name,
  required Units units,
}) =>
    StickerFacts(activity: sampleActivityFor(sport, name: name), units: units);
