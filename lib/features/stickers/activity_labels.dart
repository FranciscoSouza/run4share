import 'package:flutter/foundation.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_format.dart';

enum LabelKind { record, longRun, raceDay, subMark }

/// An automatic label an activity earned, e.g. Sub-25.
@immutable
class ActivityLabel {
  const ActivityLabel(this.kind, {this.mark});

  final LabelKind kind;

  /// For Sub-X: the mark beaten, e.g. "25" or "1:45".
  final String? mark;

  @override
  bool operator ==(Object other) =>
      other is ActivityLabel && other.kind == kind && other.mark == mark;

  @override
  int get hashCode => Object.hash(kind, mark);

  @override
  String toString() => 'ActivityLabel($kind, $mark)';
}

/// A long run is 15 km or more (decided 15 Nov 2026).
const longRunMetres = 15000.0;

/// Race distances: the range of recorded distances that counts as that
/// race (GPS rarely gives exactly 5.00 km), and round marks in seconds,
/// fastest first.
const List<({double min, double max, List<int> marks})> _races = [
  (min: 4950.0, max: 5400.0, marks: [20 * 60, 25 * 60, 30 * 60]),
  (min: 9900.0, max: 10600.0, marks: [40 * 60, 45 * 60, 50 * 60, 60 * 60]),
  (
    min: 21000.0,
    max: 21700.0,
    marks: [90 * 60, 105 * 60, 120 * 60],
  ),
  (
    min: 42100.0,
    max: 43100.0,
    marks: [180 * 60, 210 * 60, 240 * 60],
  ),
];

/// "25" for 25 minutes, "1:45" for an hour and three quarters, "3" for
/// three hours flat.
String markText(int seconds) {
  final minutes = seconds ~/ 60;
  if (minutes < 60) return '$minutes';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h' : '$h:${m.toString().padLeft(2, '0')}';
}

/// The labels [activity] earned. [history] is every stored activity
/// (it may include [activity] itself), used for run4share's own records.
List<ActivityLabel> labelsFor(Activity activity, List<Activity> history) {
  final kind = sportKindOf(activity.sportType);
  final metres = activity.distance ?? 0;
  final run = kind == SportKind.run;
  return [
    if (_isRecord(activity, history)) const ActivityLabel(LabelKind.record),
    if (run && metres >= longRunMetres) const ActivityLabel(LabelKind.longRun),
    if (activity.race) const ActivityLabel(LabelKind.raceDay),
    if (run)
      if (_subMark(metres, activity.movingTime) case final mark?)
        ActivityLabel(LabelKind.subMark, mark: markText(mark)),
  ];
}

int? _subMark(double metres, int seconds) {
  for (final race in _races) {
    if (metres < race.min || metres > race.max) continue;
    for (final mark in race.marks) {
      if (seconds < mark) return mark;
    }
  }
  return null;
}

/// Strava found a personal record in it; or, in run4share's own history
/// of the same sport, it is the longest, or the fastest among activities
/// at least as long.
bool _isRecord(Activity activity, List<Activity> history) {
  if ((activity.prCount ?? 0) > 0) return true;
  final metres = activity.distance ?? 0;
  if (metres <= 0 || activity.movingTime <= 0) return false;
  final kind = sportKindOf(activity.sportType);
  final others = [
    for (final a in history)
      if (a.id != activity.id &&
          sportKindOf(a.sportType) == kind &&
          (a.distance ?? 0) > 0 &&
          a.movingTime > 0)
        a,
  ];
  if (others.isEmpty) return false;
  final longest = others.every((a) => a.distance! < metres);
  final speed = metres / activity.movingTime;
  final fastest = others
      .where((a) => a.distance! >= metres)
      .every((a) => a.distance! / a.movingTime < speed);
  return longest || fastest;
}
