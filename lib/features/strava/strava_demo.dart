import 'package:dio/dio.dart';
import 'package:run4share/app/clock.dart';
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
  }) =>
      StravaActivity(
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
