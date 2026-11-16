import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show ProviderFamily, StreamProviderFamily;
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/extra_sticker_view.dart';
import 'package:run4share/features/strava/strava_config.dart';
import 'package:run4share/features/strava/strava_connection.dart';

/// A shoe (or bike) by ID, updating when it's fetched.
final StreamProviderFamily<Gear?, String> gearProvider =
    StreamProvider.family<Gear?, String>(
  (ref, id) => ref.watch(activityRepositoryProvider).watchGear(id),
);

/// What the data stickers need for one activity; null until it loads.
final ProviderFamily<StickerFacts?, int> stickerFactsProvider =
    Provider.family<StickerFacts?, int>((ref, activityId) {
  final activity = ref.watch(activityByIdProvider(activityId)).value;
  if (activity == null) return null;
  final gearId = activity.gearId;
  return StickerFacts(
    activity: activity,
    units: ref.watch(unitsProvider),
    gear: gearId == null ? null : ref.watch(gearProvider(gearId)).value,
  );
});

/// Whether the Strava connection may read gear (profile:read_all).
final canReadGearProvider = Provider<bool>(
  (ref) =>
      ref
          .watch(stravaConnectionProvider)
          .value
          ?.scopes
          ?.contains(StravaConfig.gearScope) ??
      false,
);
