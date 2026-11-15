import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// The one-off Pro product, as created in Play Console and App Store
/// Connect (see docs/release-checklist.md).
const proProductId = 'run4share_pro';

/// What the store says about Pro.
@immutable
class ProOffer {
  const ProOffer({required this.price});

  /// Localised by the store, e.g. "US$ 2.99" or "R$ 14,90".
  final String price;
}

enum ProEvent {
  /// Bought or restored: unlock.
  unlocked,

  /// The store is processing (e.g. a pending card payment).
  pending,

  /// The user backed out.
  cancelled,

  /// Something went wrong.
  failed,
}

/// The store, behind an interface so tests can fake it.
abstract interface class ProStore {
  /// Null when the store or the product isn't available (no Play Console
  /// product yet, no store on the device, offline).
  Future<ProOffer?> offer();

  Future<void> buy();

  /// Asks the store for past purchases; results arrive on [events].
  Future<void> restore();

  Stream<ProEvent> get events;
}

class DeviceProStore implements ProStore {
  DeviceProStore() {
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchases,
      onError: (Object _) => _events.add(ProEvent.failed),
    );
  }

  final _events = StreamController<ProEvent>.broadcast();
  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  ProductDetails? _product;

  @override
  Stream<ProEvent> get events => _events.stream;

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != proProductId) continue;
      final event = switch (purchase.status) {
        PurchaseStatus.purchased => ProEvent.unlocked,
        PurchaseStatus.restored => ProEvent.unlocked,
        PurchaseStatus.pending => ProEvent.pending,
        PurchaseStatus.canceled => ProEvent.cancelled,
        PurchaseStatus.error => ProEvent.failed,
      };
      _events.add(event);
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  @override
  Future<ProOffer?> offer() async {
    try {
      if (!await InAppPurchase.instance.isAvailable()) return null;
      final response = await InAppPurchase.instance.queryProductDetails({
        proProductId,
      });
      final products = response.productDetails;
      if (products.isEmpty) return null;
      _product = products.first;
      return ProOffer(price: products.first.price);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> buy() async {
    final product = _product;
    if (product == null) {
      _events.add(ProEvent.failed);
      return;
    }
    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  @override
  Future<void> restore() => InAppPurchase.instance.restorePurchases();

  void dispose() {
    unawaited(_subscription.cancel());
    unawaited(_events.close());
  }
}

final proStoreProvider = Provider<ProStore>((ref) {
  final store = DeviceProStore();
  ref.onDispose(store.dispose);
  return store;
});
