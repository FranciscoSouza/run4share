import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/app.dart';
import 'package:run4share/app/error_view.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/health/health_connect_sync.dart';
import 'package:run4share/features/lab/lab.dart';
import 'package:run4share/features/onboarding/onboarding.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/settings/language.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/strava/strava_session_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHandlers();
  // Portrait only (Francisco, 18 Nov 2026); also set natively, so the
  // splash doesn't rotate either.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final db = AppDatabase();
  // Read before the first frame so the app starts with saved settings.
  final units =
      Units.values.asNameMap()[await db.readPreference(unitsPreference)] ??
          Units.km;
  final stravaDemo = labVisible && await SecureLabStore().readStravaDemo();
  final language = savedLanguage(await db.readPreference(languagePreference));
  final pro = await db.readPreference(proPreference) == 'true';
  final healthConnect = await HealthConnectSync.wasConnected(db);
  final pretendPro = labVisible && await SecureLabStore().readPretendPro();
  final onboardingDone =
      await onboardingAlreadyDone(db, SecureStravaSessionStore());
  // Done only because data exists (an update): remember it, so next time
  // it's a single read.
  if (onboardingDone &&
      await db.readPreference(onboardingPreference) != 'true') {
    await db.writePreference(onboardingPreference, 'true');
  }
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        unitsAtLaunchProvider.overrideWithValue(units),
        stravaDemoAtLaunchProvider.overrideWithValue(stravaDemo),
        languageAtLaunchProvider.overrideWithValue(language),
        proAtLaunchProvider.overrideWithValue(pro),
        healthConnectAtLaunchProvider.overrideWithValue(healthConnect),
        pretendProAtLaunchProvider.overrideWithValue(pretendPro),
        onboardingDoneAtLaunchProvider.overrideWithValue(onboardingDone),
      ],
      child: const App(),
    ),
  );
}
