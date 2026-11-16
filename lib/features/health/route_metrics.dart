import 'dart:math' as math;

import 'package:run4share/features/stickers/polyline.dart';
import 'package:run4share/features/strava/strava_models.dart';

/// One recorded point of a route.
typedef RoutePoint = ({
  double latitude,
  double longitude,
  DateTime time,
  double? altitude,
});

/// Metres between two points (haversine).
double distanceBetween(RoutePoint a, RoutePoint b) {
  const earth = 6371000.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(b.latitude - a.latitude);
  final dLng = rad(b.longitude - a.longitude);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.latitude)) *
          math.cos(rad(b.latitude)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * earth * math.asin(math.sqrt(h));
}

String routePolyline(List<RoutePoint> route) =>
    encodePolyline([for (final p in route) (p.latitude, p.longitude)]);

/// (metres along the route, altitude) for points with an altitude.
List<(double, double)> elevationProfile(List<RoutePoint> route) {
  final profile = <(double, double)>[];
  var along = 0.0;
  for (var i = 0; i < route.length; i++) {
    if (i > 0) along += distanceBetween(route[i - 1], route[i]);
    if (route[i].altitude case final alt?) profile.add((along, alt));
  }
  return profile;
}

/// Splits of [unit] metres, timed from the route's timestamps; the last
/// one is whatever is left.
List<StravaSplit> routeSplits(List<RoutePoint> route, double unit) {
  if (route.length < 2) return const [];
  final splits = <StravaSplit>[];
  var covered = 0.0;
  var splitStart = route.first.time;
  var splitAltitude = route.first.altitude;
  for (var i = 1; i < route.length; i++) {
    covered += distanceBetween(route[i - 1], route[i]);
    if (covered >= unit) {
      splits.add(
        StravaSplit(
          distance: unit,
          movingTime: route[i].time.difference(splitStart).inSeconds,
          elevationDifference: (route[i].altitude ?? 0) - (splitAltitude ?? 0),
        ),
      );
      covered -= unit;
      splitStart = route[i].time;
      splitAltitude = route[i].altitude;
    }
  }
  if (covered > 50) {
    splits.add(
      StravaSplit(
        distance: covered,
        movingTime: route.last.time.difference(splitStart).inSeconds,
      ),
    );
  }
  return splits;
}
