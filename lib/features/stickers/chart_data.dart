import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/activity_streams.dart';

/// Chart data prepared for the chart stickers: no maths happens in the
/// widgets, and nothing here is invented. Where readings are missing the
/// line has a gap.

@immutable
class ChartPoint {
  const ChartPoint(this.x, this.y);

  final double x;
  final double y;

  @override
  String toString() => '($x, $y)';
}

/// A line drawn in pieces: a gap (pause, missing reading) ends a segment.
@immutable
class ChartSeries {
  const ChartSeries({
    required this.segments,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  /// Builds the ranges from [segments]; null if there's nothing to draw.
  static ChartSeries? of(List<List<ChartPoint>> segments, {double? minX}) {
    final points = [for (final s in segments) ...s];
    if (points.isEmpty) return null;
    return ChartSeries(
      segments: segments,
      minX: minX ?? points.map((p) => p.x).reduce(math.min),
      maxX: points.map((p) => p.x).reduce(math.max),
      minY: points.map((p) => p.y).reduce(math.min),
      maxY: points.map((p) => p.y).reduce(math.max),
    );
  }

  final List<List<ChartPoint>> segments;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  int get pointCount => segments.fold(0, (n, s) => n + s.length);

  /// Where the line is highest (the first, if it's there more than once).
  ChartPoint get highest => _extreme((a, b) => b.y > a.y);

  /// Where the line is lowest.
  ChartPoint get lowest => _extreme((a, b) => b.y < a.y);

  ChartPoint _extreme(bool Function(ChartPoint best, ChartPoint p) better) {
    var best = segments.first.first;
    for (final segment in segments) {
      for (final p in segment) {
        if (better(best, p)) best = p;
      }
    }
    return best;
  }
}

/// Fewer real readings than this and the chart isn't offered.
const minChartPoints = 10;

/// Splits values (null = gap) into segments of consecutive points.
List<List<ChartPoint>> _segments(List<ChartPoint?> points) {
  final segments = <List<ChartPoint>>[];
  var current = <ChartPoint>[];
  for (final p in points) {
    if (p == null) {
      if (current.length > 1) segments.add(current);
      current = [];
    } else {
      current.add(p);
    }
  }
  if (current.length > 1) segments.add(current);
  return segments;
}

double _median(List<double> values) {
  final sorted = [...values]..sort();
  final mid = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[mid]
      : (sorted[mid - 1] + sorted[mid]) / 2;
}

double metresPerUnit(Units units) => units == Units.km ? 1000 : 1609.344;

// Heart rate --------------------------------------------------------------

@immutable
class HeartRateChart {
  const HeartRateChart({
    required this.series,
    required this.average,
    required this.max,
    required this.duration,
  });

  /// x: seconds from start; y: beats per minute.
  final ChartSeries series;
  final double average;
  final double max;
  final double duration;

  /// The lowest plausible reading drawn.
  double get min => series.minY;
}

/// Plausible readings only: a strap losing contact reads 0 or wild values.
const _minBpm = 30.0;
const _maxBpm = 240.0;

HeartRateChart? heartRateChart(ActivityStreams streams) {
  final hr = streams.heartRate;
  if (hr.isEmpty) return null;
  final points = [
    for (var i = 0; i < hr.length; i++)
      switch (hr[i]) {
        final bpm? when bpm >= _minBpm && bpm <= _maxBpm => ChartPoint(
            streams.timeAt(i, hr.length),
            bpm,
          ),
        _ => null,
      },
  ];
  final valid = [
    for (final p in points)
      if (p != null) p,
  ];
  if (valid.length < minChartPoints) return null;
  final series = ChartSeries.of(_segments(points), minX: 0);
  if (series == null) return null;
  return HeartRateChart(
    series: series,
    average: valid.map((p) => p.y).reduce((a, b) => a + b) / valid.length,
    max: series.maxY,
    duration: streams.duration,
  );
}

// Pace --------------------------------------------------------------------

@immutable
class PaceChart {
  const PaceChart({
    required this.series,
    required this.average,
    required this.best,
    required this.units,
    required this.duration,
  });

  /// x: seconds from start; y: seconds per km or mile (lower is faster).
  final ChartSeries series;

  /// Seconds per unit over the moving parts.
  final double average;

  /// Fastest slice, seconds per unit.
  final double best;

  /// Slowest moving slice drawn, seconds per unit.
  double get slowest => series.maxY;
  final Units units;
  final double duration;
}

/// Slower than this (about 33 min/km) isn't moving: a pause or GPS drift.
const minMovingSpeed = 0.5;

/// Slices further than this factor from the median pace are GPS spikes.
const _spikeFactor = 2.5;

/// Pace from Strava's `velocity_smooth` (metres per second): seconds per
/// unit = metres per unit / speed. Paused slices (Strava's `moving`
/// stream says no, or the speed is implausibly low) are gaps, never
/// interpolated; spikes far from the median pace are dropped.
PaceChart? paceChart(ActivityStreams streams, Units units) {
  final v = streams.velocity;
  if (v.isEmpty) return null;
  final unit = metresPerUnit(units);
  final moving = streams.moving;
  final raw = <ChartPoint?>[
    for (var i = 0; i < v.length; i++)
      switch (v[i]) {
        final speed?
            when speed >= minMovingSpeed &&
                (moving.length != v.length || moving[i] != false) =>
          ChartPoint(streams.timeAt(i, v.length), unit / speed),
        _ => null,
      },
  ];
  final paces = [
    for (final p in raw)
      if (p != null) p.y,
  ];
  if (paces.length < minChartPoints) return null;
  final median = _median(paces);
  final points = [
    for (final p in raw)
      if (p != null &&
          p.y <= median * _spikeFactor &&
          p.y >= median / _spikeFactor)
        p
      else
        null,
  ];
  final valid = [
    for (final p in points)
      if (p != null) p,
  ];
  if (valid.length < minChartPoints) return null;
  final series = ChartSeries.of(_segments(points), minX: 0);
  if (series == null) return null;
  // Average pace = distance over moving time, i.e. from the mean speed of
  // the moving slices, not the mean of the paces.
  final speeds = [for (final p in valid) unit / p.y];
  final meanSpeed = speeds.reduce((a, b) => a + b) / speeds.length;
  return PaceChart(
    series: series,
    average: unit / meanSpeed,
    best: series.minY,
    units: units,
    duration: streams.duration,
  );
}

// Elevation ----------------------------------------------------------------

@immutable
class ElevationChart {
  const ElevationChart({
    required this.series,
    required this.gain,
    required this.units,
    required this.byDistance,
  });

  /// x: metres along (or seconds, when there's no distance);
  /// y: altitude in metres (km users) or feet (mile users).
  final ChartSeries series;

  /// Total climb, in the same unit as y.
  final double gain;
  final Units units;
  final bool byDistance;
}

const _feetPerMetre = 3.28084;

double _height(double metres, Units units) =>
    units == Units.km ? metres : metres * _feetPerMetre;

/// Altitude over distance (over time if there's no distance stream).
ElevationChart? elevationChart(ActivityStreams streams, Units units) {
  final alt = streams.altitude;
  if (alt.isEmpty) return null;
  final distance = streams.distance;
  final byDistance =
      distance.length == alt.length && distance.any((d) => d != null);
  final points = [
    for (var i = 0; i < alt.length; i++)
      switch ((
        alt[i],
        byDistance ? distance[i] : streams.timeAt(i, alt.length),
      )) {
        (final a?, final x?) => ChartPoint(x, _height(a, units)),
        _ => null,
      },
  ];
  return _elevation(points, units, byDistance: byDistance);
}

/// The profile stored by phases 8b-9 ([[metres, altitude], ...]), for
/// activities cached before streams existed.
ElevationChart? elevationChartFromProfile(String? json, Units units) {
  if (json == null) return null;
  try {
    final points = [
      for (final p in jsonDecode(json) as List)
        ChartPoint(
          ((p as List)[0] as num).toDouble(),
          _height((p[1] as num).toDouble(), units),
        ),
    ];
    return _elevation(points, units, byDistance: true);
  } on Object {
    return null;
  }
}

ElevationChart? _elevation(
  List<ChartPoint?> points,
  Units units, {
  required bool byDistance,
}) {
  final valid = [
    for (final p in points)
      if (p != null) p,
  ];
  if (valid.length < minChartPoints) return null;
  final series = ChartSeries.of(_segments(points));
  if (series == null) return null;
  var gain = 0.0;
  for (final segment in series.segments) {
    for (var i = 1; i < segment.length; i++) {
      gain += math.max(0, segment[i].y - segment[i - 1].y);
    }
  }
  return ElevationChart(
    series: series,
    gain: gain,
    units: units,
    byDistance: byDistance,
  );
}

/// "33:14" or "1:02:05".
String formatClock(double seconds) {
  final s = seconds.round();
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final ss = (s % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$ss' : '$m:$ss';
}

/// The charts an activity can offer, in the user's units. Each is null
/// when its readings are missing or too few.
@immutable
class ActivityCharts {
  const ActivityCharts({this.heartRate, this.pace, this.elevation});

  /// From the cached streams, else (elevation only) the stored profile.
  factory ActivityCharts.of({
    required String? streamsJson,
    required String? elevationJson,
    required Units units,
  }) {
    final streams = ActivityStreams.fromJson(streamsJson);
    return ActivityCharts(
      heartRate: streams == null ? null : heartRateChart(streams),
      pace: streams == null ? null : paceChart(streams, units),
      elevation: (streams == null ? null : elevationChart(streams, units)) ??
          elevationChartFromProfile(elevationJson, units),
    );
  }

  static const none = ActivityCharts();

  final HeartRateChart? heartRate;
  final PaceChart? pace;
  final ElevationChart? elevation;
}

/// The climb to show: Strava's own total when known (it's measured
/// better than a downsampled profile), else the chart's; in m or ft.
double elevationGainShown(ElevationChart chart, double? stravaMetres) =>
    stravaMetres == null || stravaMetres <= 0
        ? chart.gain
        : _height(stravaMetres, chart.units);
