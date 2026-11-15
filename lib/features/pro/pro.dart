import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/lab/lab.dart';
import 'package:run4share/features/pro/pro_store.dart';

const proPreference = 'pro.unlocked';

/// The saved Pro state, read in main() before the first frame.
final proAtLaunchProvider = Provider<bool>((ref) => false);

/// Whether Pro was bought (or restored) on this phone. Kept locally; the
/// store confirms it again on Restore purchase.
final proPurchasedProvider = NotifierProvider<ProPurchased, bool>(
  ProPurchased.new,
);

class ProPurchased extends Notifier<bool> {
  @override
  bool build() {
    // Unlock as soon as the store reports a purchase, wherever the user is.
    final subscription = ref.watch(proStoreProvider).events.listen((event) {
      if (event == ProEvent.unlocked) unawaited(unlock());
    });
    ref.onDispose(subscription.cancel);
    return ref.read(proAtLaunchProvider);
  }

  Future<void> unlock() async {
    state = true;
    await ref.read(appDatabaseProvider).writePreference(proPreference, 'true');
  }
}

/// Pro for the app: bought, or pretended in Laboratory (test builds only).
final isProProvider = Provider<bool>(
  (ref) =>
      ref.watch(proPurchasedProvider) ||
      (labVisible && ref.watch(pretendProProvider)),
);

/// A theme the user can't use yet: Pro-only and no Pro.
bool themeLocked(StickerTheme theme, {required bool isPro}) =>
    theme.pro && !isPro;
