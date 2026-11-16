import 'package:run4share/features/health/health_hub.dart';

class FakeHealthHub implements HealthHub {
  FakeHealthHub({
    this.hubStatus = HubStatus.available,
    this.grant = true,
    this.history = true,
    this.all = const [],
  });

  HubStatus hubStatus;

  /// What the consent screen answers.
  bool grant;
  bool history;
  bool access = false;
  List<HubWorkout> all;
  final reads = <(DateTime, DateTime)>[];
  int installs = 0;
  int revokes = 0;

  @override
  Future<HubStatus> status() async => hubStatus;

  @override
  Future<void> install() async => installs++;

  @override
  Future<bool> requestAccess() async => access = grant;

  @override
  Future<bool> hasAccess() async => access;

  @override
  Future<bool> hasHistory() async => history;

  @override
  Future<List<HubWorkout>> workouts(DateTime from, DateTime to) async {
    reads.add((from, to));
    return [
      for (final w in all)
        if (!w.startUtc.isBefore(from) && !w.startUtc.isAfter(to)) w,
    ];
  }

  @override
  Future<void> revoke() async {
    revokes++;
    access = false;
  }
}

/// A run with a straight 2.5 km route going north, 5 min per km.
HubWorkout hubRun({
  String id = 'hc-1',
  DateTime? start,
  double metres = 2500,
  bool withRoute = true,
}) {
  final at = start ?? DateTime.utc(2026, 11, 15, 7);
  // 0.009 degrees of latitude is about 1 km.
  const perKm = 0.009;
  final route = withRoute
      ? [
          for (var i = 0; i <= 25; i++)
            (
              latitude: 38.7 + perKm * i / 10,
              longitude: -9.14,
              time: at.add(Duration(seconds: 30 * i)),
              altitude: 40.0 + i,
            ),
        ]
      : const <({
          double latitude,
          double longitude,
          DateTime time,
          double? altitude
        })>[];
  return HubWorkout(
    id: id,
    sportType: 'Run',
    startLocal: at,
    startUtc: at,
    movingTime: 750,
    distance: metres,
    calories: 180,
    averageHeartrate: 150,
    route: route,
  );
}
