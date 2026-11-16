import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/features/stickers/polyline.dart';
import 'package:run4share/features/strava/strava_api.dart';
import 'package:run4share/features/strava/strava_auth.dart';
import 'package:run4share/features/strava/strava_config.dart';
import 'package:run4share/features/strava/strava_models.dart';

/// Demo stand-ins for Strava, used when Laboratory → Strava demo data is
/// on (see lib/features/lab/lab.dart). Same screens and flow as real
/// Strava, but nothing leaves the phone.

class DemoStravaAuth extends StravaAuth {
  DemoStravaAuth({required super.clock})
      : _now = clock,
        super(
          config: const StravaConfig(clientId: 'demo', tokenUrl: 'demo'),
          dio: Dio(),
          authenticate: _noBrowser,
        );

  final Clock _now;

  static Future<String> _noBrowser({
    required String url,
    required String callbackUrlScheme,
  }) =>
      throw UnsupportedError('No browser in Strava demo mode');

  /// Long enough that the demo never needs a refresh.
  static const _validFor = Duration(days: 3650);

  @override
  Future<StravaSession> connect() async {
    // A short pause so the connect button's progress state is visible.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final now = _now();
    return StravaSession(
      accessToken: 'demo',
      refreshToken: 'demo',
      expiresAt: now.add(_validFor).millisecondsSinceEpoch ~/ 1000,
      connectedAt: now,
      athleteId: 0,
      athleteName: 'Demo athlete',
      scopes: StravaConfig.scope.split(','),
    );
  }

  @override
  Future<StravaSession> refresh(StravaSession session) async =>
      session.copyWith(
        expiresAt: _now().add(_validFor).millisecondsSinceEpoch ~/ 1000,
      );

  @override
  Future<void> deauthorize(String accessToken) async {}
}

class DemoStravaApi extends StravaApi {
  DemoStravaApi({required Clock clock})
      : _now = clock,
        super(dio: Dio(), token: () async => 'demo');

  final Clock _now;

  @override
  Future<List<StravaActivity>> activities({
    required int perPage,
    int page = 1,
    DateTime? before,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final all = demoActivities(_now());
    final matching = before == null
        ? all
        : all.where((a) => a.startDate.isBefore(before)).toList();
    return matching.skip((page - 1) * perPage).take(perPage).toList();
  }

  @override
  Future<StravaActivity> activity(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final summary = demoActivities(_now()).firstWhere((a) => a.id == id);
    return summary.copyWith(
      // Roughly 10 kcal a minute, like the design's 320 kcal for 33 min.
      calories: (summary.movingTime / 6).roundToDouble(),
      splitsMetric: demoSplits(summary, 1000),
      splitsStandard: demoSplits(summary, 1609.344),
    );
  }

  @override
  Future<List<(double, double)>> elevation(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final summary = demoActivities(_now()).firstWhere((a) => a.id == id);
    const points = 200;
    return [
      for (var i = 0; i < points; i++)
        (
          summary.distance * i / (points - 1),
          40 +
              25 * math.sin(i / points * math.pi * 2 + id) +
              8 * math.sin(i / points * math.pi * 9 + id * 2),
        ),
    ];
  }

  @override
  Future<StravaGear> gear(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return switch (id) {
      demoBikeId => const StravaGear(
          id: demoBikeId,
          name: 'Gravel bike',
          distance: 3210000,
        ),
      _ => const StravaGear(
          id: demoShoeId,
          name: 'Pegasus 41',
          distance: 412300,
        ),
    };
  }
}

const demoShoeId = 'g-demo-shoe';
const demoBikeId = 'b-demo-bike';

/// Splits of [unit] metres with a little natural variation.
List<StravaSplit> demoSplits(StravaActivity a, double unit) {
  if (a.distance <= 0 || a.movingTime <= 0) return const [];
  final speed = a.distance / a.movingTime;
  final full = (a.distance / unit).floor();
  final rest = a.distance - full * unit;
  return [
    for (var i = 0; i < full + (rest > 50 ? 1 : 0); i++)
      StravaSplit(
        distance: i < full ? unit : rest,
        movingTime: ((i < full ? unit : rest) /
                (speed * (1 + 0.05 * math.sin(i * 1.7 + a.id))))
            .round(),
        elevationDifference: 6 * math.sin(i * 0.9 + a.id),
      ),
  ];
}

/// A loop of about [metres], wobbly enough to look like a real route.
String demoRoute(int seed, double metres) {
  const lat0 = 38.72;
  const lng0 = -9.14;
  final radius = metres / (2 * math.pi) / 111000;
  const points = 64;
  return encodePolyline([
    for (var i = 0; i <= points; i++)
      () {
        final t = i / points * 2 * math.pi;
        final wobble =
            1 + 0.25 * math.sin(3 * t + seed) + 0.12 * math.cos(5 * t + seed);
        return (
          lat0 + radius * wobble * math.sin(t),
          lng0 + radius * wobble * math.cos(t) * 1.3,
        );
      }(),
  ]);
}

/// Sample activities, newest first, dated relative to [now]: seven named
/// ones (the first three match the design's Home artboard) and about two
/// months of older runs and rides, so loading older pages can be tried.
List<StravaActivity> demoActivities(DateTime now) {
  DateTime at(int daysAgo, int hour, int minute) {
    final day = now.subtract(Duration(days: daysAgo));
    // Wall-clock time, like Strava's start_date_local.
    return DateTime.utc(day.year, day.month, day.day, hour, minute);
  }

  StravaActivity activity(
    int id,
    String name,
    String sportType,
    DateTime start, {
    required double metres,
    required int seconds,
    double? heartRate,
    int? prCount,
    int? workoutType,
  }) =>
      StravaActivity(
        polyline: metres > 0 ? demoRoute(id, metres) : null,
        gearId: metres <= 0
            ? null
            : sportType == 'Ride'
                ? demoBikeId
                : demoShoeId,
        id: id,
        name: name,
        sportType: sportType,
        startDate: start,
        startDateLocal: start,
        distance: metres,
        movingTime: seconds,
        elapsedTime: seconds + 90,
        averageSpeed: metres > 0 ? metres / seconds : null,
        averageHeartrate: heartRate,
        prCount: prCount,
        workoutType: workoutType,
      );

  return [
    activity(
      1,
      'Lunch Run',
      'Run',
      at(0, 12, 31),
      metres: 5020,
      seconds: 1994,
      heartRate: 152,
    ),
    activity(
      2,
      'Evening Ride',
      'Ride',
      at(2, 18, 5),
      metres: 22500,
      seconds: 3490,
      heartRate: 138,
    ),
    // A race with a PR: earns Record, Race day and Sub-50.
    activity(
      8,
      'City 10K',
      'Run',
      at(3, 8, 0),
      metres: 10050,
      seconds: 2820,
      heartRate: 171,
      prCount: 2,
      workoutType: 1,
    ),
    activity(
      3,
      'Morning Hike',
      'Hike',
      at(4, 9, 12),
      metres: 8100,
      seconds: 6720,
      heartRate: 121,
    ),
    activity(
      4,
      'Track Intervals',
      'Run',
      at(6, 7, 0),
      metres: 8000,
      seconds: 2280,
      heartRate: 164,
    ),
    activity(
      5,
      'Sunday Long Run',
      'Run',
      at(8, 8, 15),
      metres: 21100,
      seconds: 6950,
      heartRate: 148,
    ),
    activity(
      6,
      'Lunch Walk',
      'Walk',
      at(9, 12, 40),
      metres: 3200,
      seconds: 2400,
    ),
    activity(
      7,
      'Lunch Weight Training',
      'WeightTraining',
      at(10, 12, 40),
      metres: 0,
      seconds: 1818,
    ),
    for (var i = 0; i < 40; i++)
      if (i.isEven)
        activity(
          100 + i,
          'Easy Run',
          'Run',
          at(12 + i * 2, 7, 10),
          metres: 6000 + i * 50.0,
          seconds: 2100 + i * 15,
          heartRate: 140,
        )
      else
        activity(
          100 + i,
          'Commute Ride',
          'Ride',
          at(12 + i * 2, 18, 20),
          metres: 15000 + i * 100.0,
          seconds: 2700 + i * 10,
        ),
  ];
}
