import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Units { km, mi }

/// Distance units for display. Kept in memory for now; persisted later.
final unitsProvider = NotifierProvider<UnitsNotifier, Units>(
  UnitsNotifier.new,
);

class UnitsNotifier extends Notifier<Units> {
  @override
  Units build() => Units.km;

  // Not a setter: Notifier already has `state`, and this reads as an action.
  // ignore: use_setters_to_change_properties
  void select(Units units) => state = units;
}
