import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart' show HealthDataType;
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/platform.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/health/health_connect_sync.dart';
import 'package:run4share/features/health/health_hub.dart';
import 'package:run4share/features/health/route_metrics.dart';
import 'package:run4share/features/strava/strava_models.dart';

import '../helpers/pump_app.dart';
import 'fake_health_hub.dart';

void main() {
  group('route maths', () {
    final route = hubRun().route;

    test('distance and splits from timestamps', () {
      expect(distanceBetween(route.first, route.last), closeTo(2500, 30));
      final splits = routeSplits(route, 1000);
      expect(splits.map((s) => s.distance), [1000, 1000, closeTo(500, 30)]);
      expect(splits.first.movingTime, closeTo(300, 5), reason: '5 min/km');
      expect(splits.first.elevationDifference, closeTo(10, 0.5));
    });

    test('elevation profile along the route', () {
      final profile = elevationProfile(route);
      expect(profile.first, (0.0, 40.0));
      expect(profile.last.$1, closeTo(2500, 30));
      expect(profile.last.$2, 65);
    });
  });

  test("Health Connect's exercise types as Strava sports", () {
    expect(sportTypeFor('RUNNING_TREADMILL'), 'Run');
    expect(sportTypeFor('BIKING_STATIONARY'), 'Ride');
    expect(sportTypeFor('WALKING'), 'Walk');
    expect(sportTypeFor('HIKING'), 'Hike');
    expect(sportTypeFor('YOGA'), 'Workout');
  });

  group('duplicates', () {
    Activity a({
      required ActivitySource source,
      int id = 1,
      String sport = 'Run',
      int minute = 0,
      double? metres = 10000,
    }) =>
        Activity(
          id: id,
          source: source,
          name: 'x',
          sportType: sport,
          startLocal: DateTime.utc(2026, 11, 15, 7, minute),
          distance: metres,
          movingTime: 3000,
          race: false,
        );

    test('a Health Connect copy of a Strava run is hidden', () {
      final strava = a(source: ActivitySource.strava);
      final copy = a(source: ActivitySource.healthConnect, id: 2, minute: 1);
      expect(hideDuplicates([strava, copy]), [strava]);
    });

    test('different enough: both stay', () {
      final strava = a(source: ActivitySource.strava);
      for (final other in [
        a(source: ActivitySource.healthConnect, id: 2, minute: 3),
        a(source: ActivitySource.healthConnect, id: 2, metres: 11000),
        a(source: ActivitySource.healthConnect, id: 2, sport: 'Ride'),
      ]) {
        expect(hideDuplicates([strava, other]), hasLength(2));
      }
    });

    test('manual activities are never hidden', () {
      final strava = a(source: ActivitySource.strava);
      final manual = a(source: ActivitySource.manual, id: 2);
      expect(hideDuplicates([strava, manual]), hasLength(2));
    });
  });

  group('sync', () {
    late AppDatabase db;
    late FakeHealthHub hub;
    late ProviderContainer container;
    late DateTime now;

    HealthConnectSync sync() => container.read(healthConnectProvider.notifier);
    HubState state() => container.read(healthConnectProvider);
    ActivityRepository repo() => container.read(activityRepositoryProvider);

    setUp(() {
      db = testDatabase();
      addTearDown(db.close);
      now = DateTime.utc(2026, 11, 16, 9);
      hub = FakeHealthHub(all: [hubRun()]);
      container = ProviderContainer.test(
        overrides: [
          ...baseOverrides(db: db, hub: hub),
          clockProvider.overrideWithValue(() => now),
        ],
      );
    });

    Future<HubFailure?> failureOf(Future<void> future) async {
      try {
        await future;
        return null;
      } on HubException catch (e) {
        return e.failure;
      }
    }

    test('missing, outdated or refused: says why, stays off', () async {
      hub.hubStatus = HubStatus.unavailable;
      expect(await failureOf(sync().connect()), HubFailure.notInstalled);
      hub.hubStatus = HubStatus.updateRequired;
      expect(await failureOf(sync().connect()), HubFailure.updateRequired);
      hub
        ..hubStatus = HubStatus.available
        ..grant = false;
      expect(await failureOf(sync().connect()), HubFailure.denied);
      expect(state().connected, isFalse);
    });

    test('connect reads a year with past data, stores route data', () async {
      await sync().connect();
      expect(state().connected, isTrue);
      expect(hub.reads.single.$1, now.subtract(const Duration(days: 365)));

      final run = (await repo().watchAll().first).single;
      expect(run.source, ActivitySource.healthConnect);
      expect(run.name, 'Morning Run');
      expect(run.averageHeartrate, 150);
      expect(run.polyline, isNotNull);
      expect(run.elevationJson, isNotNull);
      final splits = jsonDecode(run.splitsJson!) as Map<String, dynamic>;
      expect((splits['km'] as List).length, 3);
      expect(
        await db.readPreference('healthConnect.connected'),
        'true',
      );
    });

    test('without past data: 30 days; later syncs only the new part', () async {
      hub.history = false;
      await sync().connect();
      expect(hub.reads.single.$1, now.subtract(const Duration(days: 30)));

      now = now.add(const Duration(hours: 1));
      await sync().sync();
      expect(
        hub.reads.last.$1,
        DateTime.utc(2026, 11, 16, 9).subtract(const Duration(days: 2)),
      );
      expect(await repo().count(ActivitySource.healthConnect), 1);
    });

    test('revoked in phone settings: disconnects on next sync', () async {
      await sync().connect();
      hub.access = false;
      now = now.add(const Duration(hours: 1));
      await sync().sync();
      expect(state().connected, isFalse);
      expect(await repo().count(ActivitySource.healthConnect), 0);
    });

    test('disconnect removes its workouts only and gives access back',
        () async {
      await sync().connect();
      await repo().saveManual(
        name: 'Treadmill',
        sportType: 'Run',
        startLocal: DateTime.utc(2026, 11, 14, 19),
        movingTime: 1500,
      );
      await sync().disconnect();
      expect(hub.revokes, 1);
      expect(
        (await repo().watchAll().first).map((a) => a.name),
        ['Treadmill'],
      );
    });

    test('on iPhone the workouts are Apple Health ones', () async {
      container = ProviderContainer.test(
        overrides: [
          ...baseOverrides(db: db, hub: hub),
          clockProvider.overrideWithValue(() => now),
          platformProvider.overrideWithValue(TargetPlatform.iOS),
        ],
      );
      await sync().connect();
      final run = (await repo().watchAll().first).single;
      expect(run.source, ActivitySource.appleHealth);
      expect(state().empty, isFalse);

      await sync().disconnect();
      expect(await repo().count(ActivitySource.appleHealth), 0);
    });

    test('nothing found: flagged, for the iPhone hint', () async {
      hub.all = const [];
      await sync().connect();
      expect(state().empty, isTrue);
    });

    test('a Strava copy hides the Health Connect one', () async {
      await sync().connect();
      await repo().upsertStrava([
        StravaActivity(
          id: 99,
          name: 'Strava run',
          sportType: 'Run',
          startDate: DateTime.utc(2026, 11, 15, 7, 1),
          startDateLocal: DateTime.utc(2026, 11, 15, 7, 1),
          distance: 2480,
          movingTime: 750,
        ),
      ]);
      final shown = await repo().watchAll().first;
      expect(shown.map((a) => a.name), ['Strava run']);
      expect(await repo().count(ActivitySource.healthConnect), 1);
    });
  });

  // The health plugin reads steps with every workout and returns nothing
  // when it may not: steps must be requested and checked (18 Nov 2026).
  test('steps are requested and required, or no workouts come back', () {
    expect(DeviceHealthHub.requested, contains(HealthDataType.STEPS));
    expect(
      DeviceHealthHub.needed,
      containsAll([
        HealthDataType.WORKOUT,
        HealthDataType.STEPS,
      ]),
    );
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android.permission.health.READ_STEPS'));
  });
}
