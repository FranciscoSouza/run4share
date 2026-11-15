import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/app.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/lab/lab.dart';
import 'package:run4share/features/settings/language.dart';
import 'package:run4share/features/settings/units.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  // Read before the first frame so the app starts with saved settings.
  final units =
      Units.values.asNameMap()[await db.readPreference(unitsPreference)] ??
          Units.km;
  final stravaDemo = labVisible && await SecureLabStore().readStravaDemo();
  final language = savedLanguage(await db.readPreference(languagePreference));
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        unitsAtLaunchProvider.overrideWithValue(units),
        stravaDemoAtLaunchProvider.overrideWithValue(stravaDemo),
        languageAtLaunchProvider.overrideWithValue(language),
      ],
      child: const App(),
    ),
  );
}
