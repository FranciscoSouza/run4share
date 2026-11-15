import 'dart:async';

import 'package:run4share/features/pro/pro_store.dart';

class FakeProStore implements ProStore {
  FakeProStore({this.price, this.owned = false});

  /// Null: no product in the store yet.
  String? price;

  /// Whether a past purchase exists (for restore).
  bool owned;
  int buys = 0;
  int restores = 0;
  final _events = StreamController<ProEvent>.broadcast();

  @override
  Stream<ProEvent> get events => _events.stream;

  @override
  Future<ProOffer?> offer() async =>
      price == null ? null : ProOffer(price: price!);

  @override
  Future<void> buy() async {
    buys++;
    owned = true;
    _events.add(ProEvent.unlocked);
  }

  @override
  Future<void> restore() async {
    restores++;
    if (owned) _events.add(ProEvent.unlocked);
  }

  /// Simulates the store reporting [event].
  void emit(ProEvent event) => _events.add(event);
}
