import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/lab/lab.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/pro/pro_screen.dart';
import 'package:run4share/features/pro/pro_store.dart';
import 'package:run4share/features/settings/settings_screen.dart';

import '../helpers/pump_app.dart';
import '../photos/photo_flow_test.dart' show settle;
import 'fake_pro_store.dart';

void main() {
  test('only Pro themes lock, and only without Pro', () {
    const free = StickerTheme(
      id: 'a',
      name: 'A',
      layout: StickerLayout.inline,
      metrics: [Metric.time],
      position: Offset(0.5, 0.5),
    );
    const paid = StickerTheme(
      id: 'b',
      name: 'B',
      layout: StickerLayout.inline,
      metrics: [Metric.time],
      position: Offset(0.5, 0.5),
      pro: true,
    );
    expect(themeLocked(free, isPro: false), isFalse);
    expect(themeLocked(paid, isPro: false), isTrue);
    expect(themeLocked(paid, isPro: true), isFalse);
    expect(
      stickerThemes.where((t) => t.pro),
      isEmpty,
      reason: 'the launch themes stay free',
    );
  });

  late AppDatabase db;
  late FakeProStore store;
  late ProviderContainer container;

  Future<void> openPro(WidgetTester tester, {String? price}) async {
    db = testDatabase();
    store = FakeProStore(price: price);
    await tester.pumpApp(overrides: baseOverrides(db: db, pro: store));
    container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await tester.tap(find.text('Unlock'));
    await settle(tester);
    expect(find.byType(ProScreen), findsOneWidget);
  }

  testWidgets('no product in the store yet: says so, cannot buy', (
    tester,
  ) async {
    await openPro(tester);
    expect(find.text('Unlock everything, once'), findsOneWidget);
    expect(find.text('No run4share watermark'), findsOneWidget);
    expect(find.text('Pro isn’t available yet'), findsOneWidget);
    await tester.tap(find.text('Pro isn’t available yet'));
    await settle(tester);
    expect(store.buys, 0);
  });

  testWidgets('buy with the store price; unlock is saved', (tester) async {
    await openPro(tester, price: r'US$ 2.99');
    await tester.tap(find.text(r'Unlock for US$ 2.99'));
    await settle(tester);

    expect(store.buys, 1);
    expect(container.read(isProProvider), isTrue);
    expect(find.text('Thanks for supporting run4share'), findsOneWidget);
    expect(
      await tester.runAsync(() => db.readPreference(proPreference)),
      'true',
    );

    await tester.tap(find.text('Done'));
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Thanks for supporting run4share'), findsOneWidget);
    expect(find.text('Unlock'), findsNothing);
  });

  testWidgets('restore finds an earlier purchase', (tester) async {
    await openPro(tester, price: r'US$ 2.99');
    store.owned = true;
    // Settings, underneath, has the same row; tap the Pro screen's.
    await tester.tap(find.text('Restore purchase').last);
    await settle(tester);
    expect(store.restores, 1);
    expect(container.read(isProProvider), isTrue);
  });

  testWidgets('a failed purchase says so and stays free', (tester) async {
    await openPro(tester, price: r'US$ 2.99');
    store.emit(ProEvent.failed);
    await settle(tester);
    expect(find.text('The purchase didn’t go through.'), findsOneWidget);
    expect(container.read(isProProvider), isFalse);
  });

  test('Pro bought earlier is on at launch', () {
    final c = ProviderContainer.test(
      overrides: [
        ...baseOverrides(),
        proAtLaunchProvider.overrideWithValue(true),
      ],
    );
    expect(c.read(isProProvider), isTrue);
  });

  test('Laboratory can pretend Pro (test builds)', () async {
    final c = ProviderContainer.test(overrides: baseOverrides());
    expect(c.read(isProProvider), isFalse);
    await c.read(pretendProProvider.notifier).setEnabled(enabled: true);
    expect(c.read(isProProvider), isTrue);
  });
}
