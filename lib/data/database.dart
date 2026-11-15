import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'database.g.dart';

/// Where an activity came from.
enum ActivitySource { strava, manual }

/// Every activity the app knows, from any source.
@DataClassName('Activity')
class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get source => textEnum<ActivitySource>()();

  /// The source's own ID (Strava activity ID); null for manual ones.
  TextColumn get sourceId => text().nullable()();
  TextColumn get name => text()();

  /// Strava's sport_type names (Run, Ride, Hike, Walk, WeightTraining...).
  TextColumn get sportType => text()();

  /// Wall-clock start time where the activity happened, stored as UTC.
  /// Show its fields as they are; never call toLocal() on it.
  DateTimeColumn get startLocal => dateTime()();

  /// The real instant it started, used to page through Strava. Null for
  /// manual activities.
  DateTimeColumn get startUtc => dateTime().nullable()();

  /// Metres; null when the activity has no distance.
  RealColumn get distance => real().nullable()();

  /// Seconds.
  IntColumn get movingTime => integer()();
  IntColumn get elapsedTime => integer().nullable()();

  /// Metres per second.
  RealColumn get averageSpeed => real().nullable()();
  RealColumn get averageHeartrate => real().nullable()();
  RealColumn get calories => real().nullable()();
  RealColumn get elevationGain => real().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {source, sourceId},
      ];
}

/// Small key/value settings (units, sync state).
class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Activities, Preferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'run4share'));

  /// In-memory database for tests.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  Future<String?> readPreference(String key) async {
    final row = await (select(
      preferences,
    )..where((p) => p.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> writePreference(String key, String? value) async {
    if (value == null) {
      await (delete(preferences)..where((p) => p.key.equals(key))).go();
    } else {
      await into(
        preferences,
      ).insertOnConflictUpdate(
        PreferencesCompanion.insert(key: key, value: value),
      );
    }
  }
}

/// Opened in main() and overridden there; tests pass an in-memory one.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Override appDatabaseProvider'),
);
