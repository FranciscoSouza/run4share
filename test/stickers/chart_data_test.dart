import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/features/health/health_hub.dart';
import 'package:run4share/features/health/route_metrics.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/activity_streams.dart';
import 'package:run4share/features/stickers/chart_data.dart';

/// Strava-shaped streams: one sample a second for [seconds].
Map<String, dynamic> strava({
  int seconds = 1200,
  double Function(int t)? speed,
  bool Function(int t)? moving,
  double? Function(int t)? heart,
  bool altitude = true,
}) {
  final time = [for (var t = 0; t <= seconds; t++) t];
  var along = 0.0;
  final distance = <double>[];
  for (final t in time) {
    along += speed?.call(t) ?? 0;
    distance.add(along);
  }
  return {
    'time': {'data': time},
    if (speed != null) 'distance': {'data': distance},
    if (speed != null)
      'velocity_smooth': {
        'data': [for (final t in time) speed(t)],
      },
    if (moving != null)
      'moving': {
        'data': [for (final t in time) moving(t)],
      },
    if (heart != null)
      'heartrate': {
        'data': [for (final t in time) heart(t)],
      },
    if (altitude)
      'altitude': {
        'data': [for (final t in time) 100 + t / 10],
      },
  };
}

void main() {
  group('streams', () {
    test('Strava arrays are averaged into time slices', () {
      final s = ActivityStreams.fromStrava(
        strava(speed: (_) => 3, heart: (t) => 140),
        buckets: 10,
      );
      expect(s.duration, 1200);
      expect(s.velocity, List.filled(10, 3));
      expect(s.heartRate, List.filled(10, 140));
      expect(s.moving, isEmpty, reason: 'not sent');
    });

    test('missing streams stay empty, not zero', () {
      final s = ActivityStreams.fromStrava(strava(altitude: false));
      expect(s.heartRate, isEmpty);
      expect(s.velocity, isEmpty);
      expect(s.altitude, isEmpty);
      expect(s.isEmpty, isTrue);
      expect(ActivityStreams.fromStrava(const {}).isEmpty, isTrue);
    });

    test('slices without readings are gaps', () {
      // Heart rate only in the first half (strap lost).
      final s = ActivityStreams.fromStrava(
        strava(heart: (t) => t < 600 ? 150 : null),
        buckets: 10,
      );
      expect(s.heartRate.sublist(0, 5), everyElement(150.0));
      expect(s.heartRate.sublist(5), everyElement(isNull));
    });

    test('survives the cache round trip', () {
      final s = ActivityStreams.fromStrava(
        strava(speed: (_) => 2.75, moving: (t) => t < 900, heart: (_) => 151),
        buckets: 20,
      );
      final back = ActivityStreams.fromJson(s.toJson())!;
      expect(back.duration, s.duration);
      expect(back.velocity, s.velocity);
      expect(back.heartRate, s.heartRate);
      expect(back.moving, s.moving);
      expect(back.altitude.length, 20);
      expect(ActivityStreams.fromJson('not json'), isNull);
    });
  });

  group('pace', () {
    test('seconds per km or mile from speed, not from the average', () {
      // 1000 m / 3.3333 m/s = 300 s: 5:00 /km.
      final s = ActivityStreams.fromStrava(strava(speed: (_) => 1000 / 300));
      final km = paceChart(s, Units.km)!;
      expect(km.average, closeTo(300, 0.01));
      expect(km.series.segments.single.first.y, closeTo(300, 0.01));
      final mi = paceChart(s, Units.mi)!;
      expect(mi.average, closeTo(482.8, 0.1), reason: '8:03 /mi');
    });

    test('a pause is a gap, never joined across', () {
      final s = ActivityStreams.fromStrava(
        strava(
          speed: (t) => t >= 500 && t < 700 ? 0 : 3,
          moving: (t) => t < 500 || t >= 700,
        ),
      );
      final chart = paceChart(s, Units.km)!;
      expect(chart.series.segments, hasLength(2));
      final before = chart.series.segments.first.last.x;
      final after = chart.series.segments.last.first.x;
      expect(before, lessThan(500));
      expect(after, greaterThan(700));
    });

    test('standing still counts as paused even without a moving stream', () {
      final s = ActivityStreams.fromStrava(
        strava(speed: (t) => t >= 500 && t < 700 ? 0.1 : 3),
      );
      expect(paceChart(s, Units.km)!.series.segments, hasLength(2));
    });

    test('GPS spikes are dropped', () {
      final s = ActivityStreams.fromStrava(
        strava(speed: (t) => t >= 600 && t < 612 ? 40 : 3),
        buckets: 100,
      );
      final chart = paceChart(s, Units.km)!;
      expect(chart.best, closeTo(1000 / 3, 0.01), reason: 'no 0:25 /km');
    });

    test('stopped readings never make a fake slowest moment', () {
      // Paused 500-700 s at 0 m/s, flagged by Strava; 100 slices of 12 s
      // put moving and paused seconds in the same slices at the edges.
      final s = ActivityStreams.fromStrava(
        strava(
          speed: (t) => t >= 500 && t < 700 ? 0 : 3,
          moving: (t) => t < 500 || t >= 700,
        ),
        buckets: 100,
      );
      final chart = paceChart(s, Units.km)!;
      expect(chart.slowest, closeTo(1000 / 3, 0.01));
      expect(chart.best, closeTo(1000 / 3, 0.01));
    });

    test('the extremes are where the line peaks and dips', () {
      // 3 m/s, then a slow stretch at 2 m/s, then a fast one at 4 m/s.
      final s = ActivityStreams.fromStrava(
        strava(speed: (t) => t < 400 ? 3 : (t < 800 ? 2 : 4)),
        buckets: 12,
      );
      final chart = paceChart(s, Units.km)!;
      expect(chart.slowest, 500, reason: '8:20 /km');
      expect(chart.best, 250, reason: '4:10 /km');
      expect(chart.series.highest.x, inInclusiveRange(400, 800));
      expect(chart.series.lowest.x, greaterThanOrEqualTo(800));
    });

    test('no speed stream (treadmill without a pod): no pace chart', () {
      final s = ActivityStreams.fromStrava(strava(heart: (_) => 150));
      expect(paceChart(s, Units.km), isNull);
      expect(heartRateChart(s), isNotNull);
    });
  });

  group('heart rate', () {
    test('average and max of plausible readings; dropouts are gaps', () {
      final s = ActivityStreams.fromStrava(
        strava(heart: (t) => t >= 300 && t < 400 ? 0 : (t < 600 ? 140 : 160)),
        buckets: 12,
      );
      final chart = heartRateChart(s)!;
      expect(chart.max, 160);
      expect(chart.average, closeTo(150.9, 0.1));
      expect(chart.series.segments, hasLength(2));
      expect(chart.series.minY, greaterThanOrEqualTo(30));
    });

    test('max and min, with where they happened', () {
      final s = ActivityStreams.fromStrava(
        strava(heart: (t) => t < 200 ? 120 : (t > 1000 ? 175 : 150)),
        buckets: 12,
      );
      final chart = heartRateChart(s)!;
      expect(chart.max, 175);
      expect(chart.min, 120);
      expect(chart.series.highest.x, greaterThan(1000));
      expect(chart.series.lowest.x, lessThan(200));
    });

    test('too few readings: not offered', () {
      final s = ActivityStreams.fromStrava(
        strava(heart: (t) => t < 30 ? 150 : null),
      );
      expect(heartRateChart(s), isNull);
    });
  });

  group('elevation', () {
    test('over distance, in metres or feet', () {
      final s = ActivityStreams.fromStrava(strava(speed: (_) => 3));
      final m = elevationChart(s, Units.km)!;
      expect(m.byDistance, isTrue);
      expect(m.series.maxX, closeTo(3600, 20));
      expect(m.gain, closeTo(120, 1));
      final ft = elevationChart(s, Units.mi)!;
      expect(ft.gain, closeTo(120 * 3.28084, 3));
      expect(elevationGainShown(ft, 100), closeTo(328.1, 0.1));
    });

    test('older activities fall back to the stored profile', () {
      final charts = ActivityCharts.of(
        streamsJson: null,
        elevationJson: '[${[
          for (var i = 0; i < 20; i++) '[${i * 100}, ${50 + i}]',
        ].join(',')}]',
        units: Units.km,
      );
      expect(charts.elevation!.gain, 19);
      expect(charts.heartRate, isNull);
      expect(charts.pace, isNull);
    });
  });

  test('a health-hub workout gives heart rate, pace and elevation', () {
    final start = DateTime.utc(2026, 11, 16, 7);
    // 1200 s, a point every 10 s moving north 30 m (3 m/s).
    final route = [
      for (var i = 0; i <= 120; i++)
        (
          latitude: 38.7 + i * 30 / 111195,
          longitude: -9.14,
          time: start.add(Duration(seconds: i * 10)),
          altitude: 20.0 + i / 4,
        ),
    ];
    final workout = HubWorkout(
      id: 'w',
      sportType: 'Run',
      startLocal: start,
      startUtc: start,
      movingTime: 1200,
      route: route,
      heartRate: [
        for (var i = 0; i < 240; i++)
          (start.add(Duration(seconds: i * 5)), 150.0),
      ],
    );
    final s = hubStreams(workout);
    expect(heartRateChart(s)!.average, 150);
    expect(paceChart(s, Units.km)!.average, closeTo(333.3, 2));
    expect(elevationChart(s, Units.km)!.gain, closeTo(30, 1));
  });

  test('clock format', () {
    expect(formatClock(59.6), '1:00');
    expect(formatClock(1994), '33:14');
    expect(formatClock(3725), '1:02:05');
  });
}
