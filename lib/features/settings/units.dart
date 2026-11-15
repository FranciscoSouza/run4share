import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/data/database.dart';

enum Units { km, mi }

const unitsPreference = 'units';

/// The saved units, read in main() before the first frame.
final unitsAtLaunchProvider = Provider<Units>((ref) => Units.km);

/// Distance units for display, saved between launches.
final unitsProvider = NotifierProvider<UnitsNotifier, Units>(
  UnitsNotifier.new,
);

class UnitsNotifier extends Notifier<Units> {
  @override
  Units build() => ref.read(unitsAtLaunchProvider);

  Future<void> select(Units units) async {
    state = units;
    await ref.read(appDatabaseProvider).writePreference(
          unitsPreference,
          units.name,
        );
  }
}
