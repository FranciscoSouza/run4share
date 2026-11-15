import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/editor/sticker_theme.dart';

/// One figure ready to draw: "DISTANCE", "5.02", "km".
@immutable
class StickerStat {
  const StickerStat({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;
}

/// Everything a sticker can show for one activity, already formatted.
@immutable
class StickerData {
  const StickerData({
    required this.stats,
    required this.sport,
    required this.weekday,
  });

  /// Only the metrics this activity has.
  final Map<Metric, StickerStat> stats;

  /// "RUN", "RIDE"... in the user's language.
  final String sport;

  /// "THURSDAY" in the user's language.
  final String weekday;

  bool has(Metric metric) => stats.containsKey(metric);

  /// Whether [theme] can be drawn for this activity.
  bool supports(StickerTheme theme) => theme.metrics.every(has);

  /// The first metric [theme] needs that this activity lacks.
  Metric? missingFor(StickerTheme theme) {
    for (final metric in theme.metrics) {
      if (!has(metric)) return metric;
    }
    return null;
  }
}

StickerData stickerDataFor(Activity activity, ActivityFormat format) {
  final l10n = format.l10n;
  final kind = sportKindOf(activity.sportType);
  final metres = activity.distance ?? 0;
  final whole = NumberFormat('0', l10n.localeName);
  final stats = <Metric, StickerStat>{
    Metric.time: StickerStat(
      label: l10n.statTime,
      value: format.duration(activity.movingTime),
    ),
  };
  if (metres > 0) {
    stats[Metric.distance] = StickerStat(
      label: l10n.statDistance,
      value: format.distance(metres),
      unit: format.distanceUnit,
    );
    final speed = activity.averageSpeed ??
        (activity.movingTime > 0 ? metres / activity.movingTime : 0.0);
    if (speed > 0) {
      stats[Metric.rate] = kind == SportKind.ride
          ? StickerStat(
              label: l10n.statSpeed,
              value: format.speed(speed),
              unit: format.speedUnit,
            )
          : StickerStat(
              label: l10n.statPace,
              value: format.pace(speed),
              unit: format.paceUnit,
            );
    }
  }
  if (activity.averageHeartrate case final bpm? when bpm > 0) {
    stats[Metric.heartRate] = StickerStat(
      label: l10n.statHeartRate,
      value: whole.format(bpm),
      unit: 'BPM',
    );
  }
  if (activity.calories case final kcal? when kcal > 0) {
    stats[Metric.calories] = StickerStat(
      label: l10n.statCalories,
      value: whole.format(kcal),
      unit: 'kcal',
    );
  }
  final sport = switch (kind) {
    SportKind.run => l10n.typeRun,
    SportKind.ride => l10n.typeRide,
    SportKind.hike => l10n.typeHike,
    SportKind.walk => l10n.typeWalk,
    SportKind.workout || SportKind.other => l10n.typeWorkout,
  };
  return StickerData(
    stats: stats,
    sport: sport.toUpperCase(),
    weekday: DateFormat(
      'EEEE',
      l10n.localeName,
    ).format(activity.startLocal).toUpperCase(),
  );
}

/// The design's sample: Lunch Run, Thursday 12 Nov, 5.02 km in 33:14.
final sampleActivity = Activity(
  id: 0,
  source: ActivitySource.manual,
  name: 'Lunch Run',
  sportType: 'Run',
  startLocal: DateTime.utc(2026, 11, 12, 12, 31),
  distance: 5020,
  movingTime: 1994,
  averageSpeed: 5020 / 1994,
  averageHeartrate: 152,
  calories: 320,
);
