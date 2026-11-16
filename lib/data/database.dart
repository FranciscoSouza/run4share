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

  /// Personal records Strava found in it (best efforts); null when not
  /// from Strava.
  IntColumn get prCount => integer().nullable()();

  /// A race: Strava's "Race" workout type, or the manual form's switch.
  BoolColumn get race => boolean().withDefault(const Constant(false))();

  /// The route, as an encoded polyline (Strava only).
  TextColumn get polyline => text().nullable()();

  /// The shoe: a Strava gear ID, or `manual:<name>` for typed ones.
  TextColumn get gearId => text().nullable()();

  /// Per-kilometre splits as JSON: [[metres, seconds, climb], ...].
  TextColumn get splitsJson => text().nullable()();

  /// Elevation profile as JSON, downsampled: [[metres, altitude], ...].
  TextColumn get elevationJson => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {source, sourceId},
      ];
}

/// Images the user saved or shared, with what's needed to edit them again.
@DataClassName('Creation')
class Creations extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The activity it was made from; null once that activity is deleted.
  IntColumn get activityId => integer().nullable()();

  /// Copied so the creation keeps its caption after the activity goes.
  TextColumn get activityName => text()();
  DateTimeColumn get createdAt => dateTime()();

  /// story, feed or square.
  TextColumn get format => text()();

  /// Sticker on a transparent background, without the photo.
  BoolColumn get stickerOnly => boolean().withDefault(const Constant(false))();

  /// File name inside the app's creations folder.
  TextColumn get fileName => text()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();

  /// The editor settings (photo, crop, theme, sticker, style) as JSON.
  TextColumn get settings => text()();
}

/// Shoes (and bikes): from Strava's gear, or typed for manual activities.
@DataClassName('Gear')
class GearTable extends Table {
  @override
  String get tableName => 'gear';

  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Lifetime metres with it, as last known.
  RealColumn get distance => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small key/value settings (units, sync state).
class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Activities, Preferences, Creations, GearTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'run4share'));

  /// In-memory database for tests.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // 2: My Creations.
          if (from < 2) await m.createTable(creations);
          // 3: records and races, for the automatic labels.
          if (from < 3) {
            await m.addColumn(activities, activities.prCount);
            await m.addColumn(activities, activities.race);
          }
          // 4: route, shoe, splits and elevation, for the data stickers.
          if (from < 4) {
            await m.addColumn(activities, activities.polyline);
            await m.addColumn(activities, activities.gearId);
            await m.addColumn(activities, activities.splitsJson);
            await m.addColumn(activities, activities.elevationJson);
            await m.createTable(gearTable);
          }
        },
      );

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
