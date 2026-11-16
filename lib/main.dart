import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/app.dart';
import 'package:run4share/app/error_view.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/health/health_connect_sync.dart';
import 'package:run4share/features/lab/lab.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/settings/language.dart';
import 'package:run4share/features/settings/units.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHandlers();
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
      ],
      child: const App(),
    ),
  );
}
