import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// An activity's time series, on one time axis split into `buckets` equal
/// slices. Each series holds the mean of the readings that fell in each
/// slice, or null where there were none. Slices are short (a 30-minute
/// run: 9 s), so a source sampling less often (a route point every 10 s)
/// leaves empty slices between readings: those holes are bridged when
/// the real readings either side are at most [maxBridge] seconds apart.
/// Longer holes (pauses, a lost strap) stay gaps.
///
/// Built from Strava's streams (aligned arrays) or from Health Connect /
/// Apple Health samples (each series with its own timestamps) by
/// [ActivityStreams.bucketed], so both sources look the same downstream.
@immutable
class ActivityStreams {
  const ActivityStreams({
    required this.duration,
    this.distance = const [],
    this.altitude = const [],
    this.heartRate = const [],
    this.velocity = const [],
    this.moving = const [],
  });

  /// Places each (seconds from start, value) reading in its time slice.
  /// Readings outside [0, duration] are ignored.
  factory ActivityStreams.bucketed({
    required double duration,
    List<(double, double)> distance = const [],
    List<(double, double)> altitude = const [],
    List<(double, double)> heartRate = const [],
    List<(double, double)> velocity = const [],
    List<(double, bool)> moving = const [],
    int buckets = defaultBuckets,
  }) {
    if (duration <= 0) return const ActivityStreams(duration: 0);
    int slice(double t) =>
        math.min(buckets - 1, (t / duration * buckets).floor());

    List<double?> mean(List<(double, double)> readings) {
      if (readings.isEmpty) return const [];
      final sums = List<double>.filled(buckets, 0);
      final counts = List<int>.filled(buckets, 0);
      final first = List<double>.filled(buckets, double.infinity);
      final last = List<double>.filled(buckets, double.negativeInfinity);
      for (final (t, v) in readings) {
        if (t < 0 || t > duration || !v.isFinite) continue;
        final i = slice(t);
        sums[i] += v;
        counts[i]++;
        first[i] = math.min(first[i], t);
        last[i] = math.max(last[i], t);
      }
      if (counts.every((c) => c == 0)) return const [];
      final values = [
        for (var i = 0; i < buckets; i++)
          if (counts[i] == 0) null else sums[i] / counts[i],
      ];
      // Bridge sampling holes: straight between the slices either side.
      int? previous;
      for (var i = 0; i < buckets; i++) {
        if (values[i] == null) continue;
        final p = previous;
        if (p != null && i - p > 1 && first[i] - last[p] <= maxBridge) {
          for (var k = p + 1; k < i; k++) {
            values[k] =
                values[p]! + (values[i]! - values[p]!) * (k - p) / (i - p);
          }
        }
        previous = i;
      }
      return values;
    }

    List<bool?> majority(List<(double, bool)> readings) {
      if (readings.isEmpty) return const [];
      final yes = List<int>.filled(buckets, 0);
      final all = List<int>.filled(buckets, 0);
      for (final (t, v) in readings) {
        if (t < 0 || t > duration) continue;
        final i = slice(t);
        all[i]++;
        if (v) yes[i]++;
      }
      final values = [
        for (var i = 0; i < buckets; i++)
          if (all[i] == 0) null else yes[i] * 2 >= all[i],
      ];
      // A hole between two moving slices is moving; anything else stays
      // unknown (and the pace chart leaves it out).
      for (var i = 1; i < buckets - 1; i++) {
        if (values[i] != null) continue;
        var j = i;
        while (j < buckets && values[j] == null) {
          j++;
        }
        if (j < buckets && values[i - 1] == true && values[j] == true) {
          for (var k = i; k < j; k++) {
            values[k] = true;
          }
        }
        i = j;
      }
      return values;
    }

    return ActivityStreams(
      duration: duration,
      distance: mean(distance),
      altitude: mean(altitude),
      heartRate: mean(heartRate),
      velocity: mean(velocity),
      moving: majority(moving),
    );
  }

  /// Strava's streams endpoint answer (key_by_type=true): aligned arrays
  /// under "time", "distance", "altitude", "heartrate", "velocity_smooth"
  /// and "moving", each as {"data": [...]}. Missing streams stay empty.
  factory ActivityStreams.fromStrava(
    Map<String, dynamic> json, {
    int buckets = defaultBuckets,
  }) {
    List<dynamic> data(String key) =>
        (json[key] as Map?)?['data'] as List? ?? const [];
    final time = [for (final t in data('time')) (t as num).toDouble()];
    if (time.isEmpty) return const ActivityStreams(duration: 0);
    List<(double, double)> series(String key) {
      final values = data(key);
      return [
        for (var i = 0; i < math.min(time.length, values.length); i++)
          if (values[i] is num) (time[i], (values[i] as num).toDouble()),
      ];
    }

    final moving = data('moving');
    return ActivityStreams.bucketed(
      duration: time.last,
      distance: series('distance'),
      altitude: series('altitude'),
      heartRate: series('heartrate'),
      velocity: series('velocity_smooth'),
      moving: [
        for (var i = 0; i < math.min(time.length, moving.length); i++)
          if (moving[i] is bool) (time[i], moving[i] as bool),
      ],
      buckets: buckets,
    );
  }

  /// Fine enough for a sticker, small enough to cache per activity.
  static const defaultBuckets = 200;

  /// Longest hole between real readings drawn as a straight line.
  static const maxBridge = 30.0;

  /// Seconds from start to finish (elapsed, pauses included).
  final double duration;

  /// Metres covered so far, per time slice.
  final List<double?> distance;

  /// Metres above sea level.
  final List<double?> altitude;

  /// Beats per minute.
  final List<double?> heartRate;

  /// Metres per second.
  final List<double?> velocity;

  /// Whether the athlete was moving (Strava's own pause detection).
  final List<bool?> moving;

  bool get isEmpty =>
      duration <= 0 ||
      (distance.isEmpty &&
          altitude.isEmpty &&
          heartRate.isEmpty &&
          velocity.isEmpty);

  /// Seconds from start at the middle of slice [i] of [count].
  double timeAt(int i, int count) => duration * (i + 0.5) / count;

  String toJson() {
    List<num?> round(List<double?> values, int digits) => [
          for (final v in values)
            if (v == null) null else num.parse(v.toStringAsFixed(digits)),
        ];
    return jsonEncode({
      'duration': duration,
      'distance': round(distance, 0),
      'altitude': round(altitude, 1),
      'heartRate': round(heartRate, 0),
      'velocity': round(velocity, 2),
      'moving': [
        for (final m in moving)
          if (m == null) null else if (m) 1 else 0,
      ],
    });
  }

  static ActivityStreams? fromJson(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      List<double?> numbers(String key) => [
            for (final v in json[key] as List? ?? const [])
              (v as num?)?.toDouble(),
          ];
      return ActivityStreams(
        duration: (json['duration'] as num).toDouble(),
        distance: numbers('distance'),
        altitude: numbers('altitude'),
        heartRate: numbers('heartRate'),
        velocity: numbers('velocity'),
        moving: [
          for (final v in json['moving'] as List? ?? const [])
            if (v == null) null else v == 1,
        ],
      );
    } on Object {
      return null;
    }
  }
}
