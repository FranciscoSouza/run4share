import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:run4share/data/database.dart';
import 'package:run4share/features/strava/strava_models.dart';

/// Reads and writes activities, whatever their source.
class ActivityRepository {
  ActivityRepository(this._db);

  final AppDatabase _db;

  $ActivitiesTable get _table => _db.activities;

  /// All activities, newest first; emits again on every change.
  Stream<List<Activity>> watchAll() => (_db.select(_table)
        ..orderBy([
          (a) => OrderingTerm.desc(a.startLocal),
          (a) => OrderingTerm.desc(a.id),
        ]))
      .watch();

  Stream<Activity?> watchById(int id) => (_db.select(
        _table,
      )..where((a) => a.id.equals(id)))
          .watchSingleOrNull();

  /// Stores the splits, per kilometre and per mile, as
  /// {"km": [[metres, seconds, climb], ...], "mi": [...]}.
  Future<void> setSplits(
    int id, {
    required List<StravaSplit> metric,
    required List<StravaSplit> standard,
  }) {
    List<List<num>> rows(List<StravaSplit> splits) => [
          for (final s in splits)
            [s.distance, s.movingTime, s.elevationDifference],
        ];
    return (_db.update(_table)..where((a) => a.id.equals(id))).write(
      ActivitiesCompanion(
        splitsJson: Value(
          jsonEncode({'km': rows(metric), 'mi': rows(standard)}),
        ),
      ),
    );
  }

  /// Stores the elevation profile, downsampled to [maxPoints].
  Future<void> setElevation(
    int id,
    List<(double, double)> profile, {
    int maxPoints = 120,
  }) {
    final step =
        profile.length <= maxPoints ? 1 : (profile.length / maxPoints).ceil();
    final points = [
      for (var i = 0; i < profile.length; i += step)
        [profile[i].$1.roundToDouble(), (profile[i].$2 * 10).round() / 10],
    ];
    return (_db.update(_table)..where((a) => a.id.equals(id))).write(
      ActivitiesCompanion(elevationJson: Value(jsonEncode(points))),
    );
  }

  Future<void> saveGear(StravaGear gear) =>
      _db.into(_db.gearTable).insertOnConflictUpdate(
            GearTableCompanion.insert(
              id: gear.id,
              name: gear.name,
              distance: gear.distance,
            ),
          );

  Future<Gear?> gearById(String id) => (_db.select(
        _db.gearTable,
      )..where((g) => g.id.equals(id)))
          .getSingleOrNull();

  Stream<Gear?> watchGear(String id) => (_db.select(
        _db.gearTable,
      )..where((g) => g.id.equals(id)))
          .watchSingleOrNull();

  Future<void> setCalories(int id, double calories) =>
      (_db.update(_table)..where((a) => a.id.equals(id))).write(
        ActivitiesCompanion(calories: Value(calories)),
      );

  Future<Activity?> byId(int id) =>
      (_db.select(_table)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<int> count(ActivitySource source) {
    final expr = _table.id.count();
    final query = _db.selectOnly(_table)
      ..addColumns([expr])
      ..where(_table.source.equalsValue(source));
    return query.getSingle().then((row) => row.read(expr) ?? 0);
  }

  /// IDs Strava already gave us, to tell new activities from known ones.
  Future<Set<String>> knownStravaIds(Iterable<int> ids) async {
    final wanted = ids.map((id) => '$id').toList();
    if (wanted.isEmpty) return {};
    final rows = await (_db.select(_table)
          ..where(
            (a) =>
                a.source.equalsValue(ActivitySource.strava) &
                a.sourceId.isIn(wanted),
          ))
        .get();
    return {for (final row in rows) row.sourceId!};
  }

  /// Start of the oldest Strava activity stored, for fetching older pages.
  Future<DateTime?> oldestStravaStart() async {
    final row = await (_db.select(_table)
          ..where((a) => a.source.equalsValue(ActivitySource.strava))
          ..orderBy([(a) => OrderingTerm.asc(a.startUtc)])
          ..limit(1))
        .getSingleOrNull();
    return row?.startUtc;
  }

  /// Inserts new Strava activities and updates known ones.
  Future<void> upsertStrava(List<StravaActivity> activities) =>
      _db.batch((batch) {
        for (final a in activities) {
          batch.insert(
            _table,
            ActivitiesCompanion.insert(
              source: ActivitySource.strava,
              sourceId: Value('${a.id}'),
              name: a.name,
              sportType: a.sportType,
              startLocal: a.startDateLocal,
              startUtc: Value(a.startDate),
              distance: Value(a.distance > 0 ? a.distance : null),
              movingTime: a.movingTime,
              elapsedTime: Value(a.elapsedTime),
              averageSpeed: Value(a.averageSpeed),
              averageHeartrate: Value(a.averageHeartrate),
              elevationGain: Value(a.totalElevationGain),
              calories: Value(a.calories),
              prCount: Value(a.prCount),
              race: Value(a.isRace),
              polyline: Value(a.polyline),
              gearId: Value(a.gearId),
            ),
            onConflict: DoUpdate(
              (old) => ActivitiesCompanion(
                name: Value(a.name),
                sportType: Value(a.sportType),
                startLocal: Value(a.startDateLocal),
                startUtc: Value(a.startDate),
                distance: Value(a.distance > 0 ? a.distance : null),
                movingTime: Value(a.movingTime),
                elapsedTime: Value(a.elapsedTime),
                averageSpeed: Value(a.averageSpeed),
                averageHeartrate: Value(a.averageHeartrate),
                elevationGain: Value(a.totalElevationGain),
                prCount: Value(a.prCount),
                race: Value(a.isRace),
                polyline: Value(a.polyline),
                gearId: Value(a.gearId),
                // The list has no calories; keep any fetched from detail.
                calories: a.calories == null
                    ? const Value.absent()
                    : Value(a.calories),
              ),
              target: [_table.source, _table.sourceId],
            ),
          );
        }
      });

  /// Removes every activity from [source], e.g. on Strava disconnect.
  Future<void> deleteSource(ActivitySource source) =>
      (_db.delete(_table)..where((a) => a.source.equalsValue(source))).go();

  /// Saves a manual activity: inserts when [id] is null, else updates.
  Future<int> saveManual({
    required String name,
    required String sportType,
    required DateTime startLocal,
    required int movingTime,
    double? distance,
    double? calories,
    double? averageHeartrate,
    bool race = false,
    String? gearId,
    int? id,
  }) async {
    final companion = ActivitiesCompanion(
      source: const Value(ActivitySource.manual),
      name: Value(name),
      sportType: Value(sportType),
      startLocal: Value(startLocal),
      movingTime: Value(movingTime),
      elapsedTime: Value(movingTime),
      distance: Value(distance),
      averageSpeed: Value(
        distance != null && movingTime > 0 ? distance / movingTime : null,
      ),
      calories: Value(calories),
      averageHeartrate: Value(averageHeartrate),
      race: Value(race),
      gearId: Value(gearId),
    );
    if (id == null) return await _db.into(_table).insert(companion);
    await (_db.update(_table)
          ..where(
            (a) =>
                a.id.equals(id) & a.source.equalsValue(ActivitySource.manual),
          ))
        .write(companion);
    return id;
  }

  Future<void> deleteManual(int id) => (_db.delete(_table)
        ..where(
          (a) => a.id.equals(id) & a.source.equalsValue(ActivitySource.manual),
        ))
      .go();
}

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(ref.watch(appDatabaseProvider)),
);

/// Every activity, newest first.
final activitiesProvider = StreamProvider<List<Activity>>(
  (ref) => ref.watch(activityRepositoryProvider).watchAll(),
);

/// One activity by ID; null when it no longer exists.
final StreamProviderFamily<Activity?, int> activityByIdProvider =
    StreamProvider.family<Activity?, int>(
  (ref, id) => ref.watch(activityRepositoryProvider).watchById(id),
);
