import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/strava_sync.dart';
import 'package:run4share/features/strava/strava_api.dart';
import 'package:run4share/features/strava/strava_config.dart';
import 'package:run4share/features/strava/strava_connection.dart';
import 'package:run4share/features/strava/strava_session_store.dart';

import '../helpers/pump_app.dart';
import '../strava/fakes.dart';
import 'fake_strava_api.dart';

void main() {
  late AppDatabase db;
  late FakeStravaApi api;
  late ProviderContainer container;
  late DateTime now;

  ActivityRepository repo() => container.read(activityRepositoryProvider);
  StravaSync sync() => container.read(stravaSyncProvider.notifier);
  Future<List<String>> names() async =>
      (await repo().watchAll().first).map((a) => a.name).toList();

  setUp(() {
    db = testDatabase();
    api = FakeStravaApi(runs(75));
    now = testNow;
    container = ProviderContainer.test(
      overrides: [
        ...baseOverrides(store: MemoryStravaSessionStore(session()), db: db),
        stravaApiProvider.overrideWithValue(api),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(db.close);
  });

  test('first sync stores the newest 30 only', () async {
    await sync().sync();

    expect(await repo().count(ActivitySource.strava), 30);
    expect((await names()).first, 'Run 1');
    expect(api.calls, hasLength(1));
    final state = container.read(stravaSyncProvider);
    expect(state.lastSyncedAt, now);
    expect(state.reachedEnd, isFalse);
    expect(state.syncing, isFalse);
  });

  test('scrolling loads older pages until the first activity', () async {
    await sync().sync();
    await sync().loadOlder();
    expect(await repo().count(ActivitySource.strava), 60);
    final oldestOfFirstPage = DateTime.utc(
      2026,
      11,
      14,
      7,
    ).subtract(const Duration(days: 29));
    expect(api.calls.last.before, oldestOfFirstPage);

    await sync().loadOlder();
    expect(await repo().count(ActivitySource.strava), 75);
    expect(container.read(stravaSyncProvider).reachedEnd, isTrue);

    final calls = api.calls.length;
    await sync().loadOlder();
    expect(api.calls, hasLength(calls), reason: 'nothing older to fetch');
  });

  test('a later sync fetches only until it meets known activities', () async {
    await sync().sync();
    api.all = [
      ...runs(3, firstId: 500, newest: DateTime.utc(2026, 11, 16, 7)),
      ...api.all,
    ];

    await sync().sync();

    expect(await repo().count(ActivitySource.strava), 33);
    expect((await names()).take(3), ['Run 500', 'Run 501', 'Run 502']);
    expect(api.calls, hasLength(2));
  });

  test('changes on Strava update stored activities', () async {
    await sync().sync();
    api.all = [
      api.all.first.copyWith(name: 'Renamed run'),
      ...api.all.skip(1),
    ];

    await sync().sync();

    expect((await names()).first, 'Renamed run');
    expect(await repo().count(ActivitySource.strava), 30);
  });

  test('syncIfStale waits 15 minutes between syncs', () async {
    await sync().syncIfStale();
    now = now.add(const Duration(minutes: 10));
    await sync().syncIfStale();
    expect(api.calls, hasLength(1));

    now = now.add(const Duration(minutes: 6));
    await sync().syncIfStale();
    expect(api.calls, hasLength(2));
  });

  test('the last sync time survives a restart', () async {
    await sync().sync();
    final restarted = ProviderContainer.test(
      overrides: [
        ...baseOverrides(store: MemoryStravaSessionStore(session()), db: db),
        stravaApiProvider.overrideWithValue(api),
        clockProvider.overrideWithValue(() => now),
      ],
    );

    await restarted.read(stravaSyncProvider.notifier).syncIfStale();

    expect(api.calls, hasLength(1), reason: 'still fresh');
    expect(restarted.read(stravaSyncProvider).lastSyncedAt, now);
  });

  test('a failed sync is reported and keeps stored activities', () async {
    await sync().sync();
    container.updateOverrides([
      ...baseOverrides(store: MemoryStravaSessionStore(session()), db: db),
      stravaApiProvider.overrideWithValue(_FailingApi()),
      clockProvider.overrideWithValue(() => now),
    ]);

    await sync().sync();

    expect(container.read(stravaSyncProvider).failed, isTrue);
    expect(await repo().count(ActivitySource.strava), 30);
  });

  test('disconnect removes Strava activities, keeps manual ones', () async {
    await sync().sync();
    await repo().saveManual(
      name: 'Treadmill',
      sportType: 'Run',
      startLocal: DateTime.utc(2026, 11, 13, 19),
      movingTime: 1500,
    );

    await container.read(stravaConnectionProvider.notifier).disconnect();

    expect(await names(), ['Treadmill']);
    expect(container.read(stravaSyncProvider).lastSyncedAt, isNull);
    expect(await db.readPreference('strava.lastSyncedAt'), isNull);
  });

  test('details add calories once, for Strava activities only', () async {
    await sync().sync();
    final first = (await repo().watchAll().first).first;
    expect(first.calories, isNull);

    await sync().fetchDetails(first);
    final updated = await repo().byId(first.id);
    expect(updated?.calories, 321);
    expect(api.detailCalls, [1]);

    await sync().fetchDetails(updated!);
    expect(api.detailCalls, [1], reason: 'calories already known');

    // A later list sync must not wipe the calories.
    await sync().sync();
    expect((await repo().byId(first.id))?.calories, 321);
  });

  test('details fill in splits, elevation and the shoe', () async {
    container = ProviderContainer.test(
      overrides: [
        ...baseOverrides(
          store: MemoryStravaSessionStore(
            session().copyWith(scopes: StravaConfig.scope.split(',')),
          ),
          db: db,
        ),
        stravaApiProvider.overrideWithValue(api),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    await sync().sync();
    final first = (await repo().watchAll().first).first;
    expect(first.polyline, isNotNull);
    expect(first.gearId, 'g1');

    await sync().fetchDetails(first);
    final updated = (await repo().byId(first.id))!;
    expect(updated.splitsJson, contains('"km"'));
    final elevation = jsonDecode(updated.elevationJson!) as List;
    expect(elevation.length, lessThanOrEqualTo(120), reason: 'downsampled');
    expect((await repo().gearById('g1'))?.name, 'Pegasus 41');

    // Known gear is not fetched again.
    await sync().fetchDetails(updated);
    expect(api.gearCalls, ['g1']);
  });

  test('without the gear permission the shoe is not fetched', () async {
    await sync().sync();
    final first = (await repo().watchAll().first).first;
    await sync().fetchDetails(first);
    expect(api.gearCalls, isEmpty);
    expect(await repo().gearById('g1'), isNull);
  });

  test('nothing is fetched while disconnected', () async {
    final offline = ProviderContainer.test(
      overrides: [
        ...baseOverrides(db: db),
        stravaApiProvider.overrideWithValue(api),
      ],
    );
    await offline.read(stravaSyncProvider.notifier).sync();
    expect(api.calls, isEmpty);
  });
}

class _FailingApi extends FakeStravaApi {
  _FailingApi() : super(const []);

  @override
  Future<Never> activities({
    required int perPage,
    int page = 1,
    DateTime? before,
  }) async =>
      throw Exception('offline');
}
