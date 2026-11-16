import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/onboarding/onboarding.dart';
import 'package:run4share/features/strava/strava_session_store.dart';

import '../helpers/pump_app.dart';
import '../strava/fakes.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  test('a fresh install: not done', () async {
    expect(
      await onboardingAlreadyDone(db, MemoryStravaSessionStore()),
      isFalse,
    );
  });

  test('done once the preference says so', () async {
    await db.writePreference(onboardingPreference, 'true');
    expect(await onboardingAlreadyDone(db, MemoryStravaSessionStore()), isTrue);
  });

  test('an update with an activity: done, never shown', () async {
    await ActivityRepository(db).saveManual(
      name: 'Old run',
      sportType: 'Run',
      startLocal: DateTime.utc(2026, 11, 10, 7),
      movingTime: 1800,
    );
    expect(await onboardingAlreadyDone(db, MemoryStravaSessionStore()), isTrue);
  });

  test('an update with a creation: done', () async {
    await db.into(db.creations).insert(
          CreationsCompanion.insert(
            activityName: 'Old run',
            createdAt: DateTime.utc(2026, 11, 10, 8),
            format: 'story',
            fileName: 'x.png',
            width: 1080,
            height: 1920,
            settings: '{}',
          ),
        );
    expect(await onboardingAlreadyDone(db, MemoryStravaSessionStore()), isTrue);
  });

  test('an update with a Strava connection: done', () async {
    expect(
      await onboardingAlreadyDone(db, MemoryStravaSessionStore(session())),
      isTrue,
    );
  });

  test('complete() remembers it', () async {
    final container = ProviderContainer.test(
      overrides: baseOverrides(db: db, onboardingDone: false),
    );
    expect(container.read(onboardingDoneProvider), isFalse);
    await container.read(onboardingDoneProvider.notifier).complete();
    expect(container.read(onboardingDoneProvider), isTrue);
    expect(await db.readPreference(onboardingPreference), 'true');
  });
}
