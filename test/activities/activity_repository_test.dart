import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';

import '../helpers/pump_app.dart';
import 'fake_strava_api.dart';

void main() {
  late AppDatabase db;
  late ActivityRepository repo;

  setUp(() {
    db = testDatabase();
    repo = ActivityRepository(db);
    addTearDown(db.close);
  });

  test('lists every source together, newest first', () async {
    await repo.upsertStrava(runs(2));
    await repo.saveManual(
      name: 'Gym',
      sportType: 'Workout',
      startLocal: DateTime.utc(2026, 11, 13, 20),
      movingTime: 2700,
      calories: 300,
    );

    final all = await repo.watchAll().first;
    expect(all.map((a) => a.name), ['Run 1', 'Gym', 'Run 2']);
    expect(all[1].source, ActivitySource.manual);
    expect(all[1].distance, isNull);
    expect(all[1].calories, 300);
  });

  test('wall-clock start times come back unchanged', () async {
    final start = DateTime.utc(2026, 11, 12, 12, 31);
    await repo.saveManual(
      name: 'Lunch Run',
      sportType: 'Run',
      startLocal: start,
      movingTime: 1994,
    );
    final stored = (await repo.watchAll().first).single.startLocal;
    expect(stored, start);
    expect(stored.isUtc, isTrue);
    expect(stored.hour, 12);
  });

  test('manual activities can be edited and deleted', () async {
    final id = await repo.saveManual(
      name: 'Run',
      sportType: 'Run',
      startLocal: DateTime.utc(2026, 11, 13, 7),
      movingTime: 1800,
      distance: 5000,
    );

    await repo.saveManual(
      id: id,
      name: 'Morning Run',
      sportType: 'Run',
      startLocal: DateTime.utc(2026, 11, 13, 7),
      movingTime: 1800,
      distance: 6000,
    );
    final edited = await repo.byId(id);
    expect(edited?.name, 'Morning Run');
    expect(edited?.distance, 6000);
    expect(edited?.averageSpeed, closeTo(6000 / 1800, 1e-9));

    await repo.deleteManual(id);
    expect(await repo.byId(id), isNull);
  });

  test('Strava activities cannot be edited or deleted as manual', () async {
    await repo.upsertStrava(runs(1));
    final strava = (await repo.watchAll().first).single;

    await repo.deleteManual(strava.id);
    await repo.saveManual(
      id: strava.id,
      name: 'Hacked',
      sportType: 'Run',
      startLocal: DateTime.utc(2026),
      movingTime: 1,
    );

    final still = await repo.byId(strava.id);
    expect(still?.name, 'Run 1');
  });

  test('the same Strava activity is stored once', () async {
    await repo.upsertStrava(runs(3));
    await repo.upsertStrava(runs(3));
    expect(await repo.count(ActivitySource.strava), 3);
  });
}
