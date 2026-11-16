import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/strava/strava_session_store.dart';

/// Set once the introduction was finished or skipped.
const onboardingPreference = 'onboarding.done';

/// Whether the introduction was already done when the app started; read
/// in `main()` before the first frame.
final onboardingDoneAtLaunchProvider = Provider<bool>((ref) => false);

final onboardingDoneProvider = NotifierProvider<OnboardingDone, bool>(
  OnboardingDone.new,
);

class OnboardingDone extends Notifier<bool> {
  @override
  bool build() => ref.watch(onboardingDoneAtLaunchProvider);

  Future<void> complete() async {
    state = true;
    await ref
        .read(appDatabaseProvider)
        .writePreference(onboardingPreference, 'true');
  }
}

/// True when the introduction shouldn't show: it was done, or this isn't
/// a first launch (activities, creations or a Strava connection already
/// exist: people updating the app never see it).
Future<bool> onboardingAlreadyDone(
  AppDatabase db,
  StravaSessionStore store,
) async {
  if (await db.readPreference(onboardingPreference) == 'true') return true;
  return await hasExistingData(db, store);
}

/// Any activity, creation or stored Strava session.
Future<bool> hasExistingData(AppDatabase db, StravaSessionStore store) async {
  if (await ActivityRepository(db).any()) return true;
  final creation = await (db.select(db.creations)..limit(1)).getSingleOrNull();
  if (creation != null) return true;
  return await store.read() != null;
}
