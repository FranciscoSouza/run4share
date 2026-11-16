import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/home/home_screen.dart';
import 'package:run4share/features/onboarding/onboarding.dart';
import 'package:run4share/features/onboarding/onboarding_screen.dart';
import 'package:run4share/features/pro/pro_screen.dart';
import 'package:run4share/features/settings/settings_screen.dart';

import '../helpers/pump_app.dart';
import '../photos/photo_flow_test.dart' show settle;
import '../pro/fake_pro_store.dart';

void main() {
  late AppDatabase db;

  Future<ProviderContainer> launch(
    WidgetTester tester, {
    bool done = false,
    String? price,
  }) async {
    db = testDatabase();
    await tester.pumpApp(
      overrides: baseOverrides(
        db: db,
        onboardingDone: done,
        pro: FakeProStore(price: price),
      ),
    );
    await settle(tester);
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  Finder pageOf(int page) => find.bySemanticsLabel('Page $page of 4');

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.text('Next'));
    await settle(tester);
  }

  testWidgets('first launch opens it; Next walks the four pages', (
    tester,
  ) async {
    await launch(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('YOUR RUN. YOUR STORY.'), findsOneWidget);
    expect(pageOf(1), findsOneWidget);

    await next(tester);
    expect(pageOf(2), findsOneWidget);
    expect(find.text('READY THE MOMENT YOU FINISH'), findsOneWidget);
    // Tests run as Android: Strava, Health Connect, by hand.
    expect(find.text('Health Connect'), findsOneWidget);
    expect(find.text('Or add it by hand'), findsOneWidget);

    await next(tester);
    expect(pageOf(3), findsOneWidget);
    expect(find.text('FULL IMAGE'), findsOneWidget);

    await next(tester);
    expect(pageOf(4), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Skip'), findsNothing, reason: 'PRO badge instead');
    expect(find.text('PRO'), findsOneWidget);
    expect(find.text("See what's in Pro"), findsOneWidget, reason: 'no offer');
  });

  testWidgets('swiping also turns the page', (tester) async {
    await launch(tester);
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await settle(tester);
    expect(pageOf(2), findsOneWidget);
  });

  testWidgets('Skip on page 2: Home, and it stays done', (tester) async {
    final container = await launch(tester);
    await next(tester);
    await tester.tap(find.text('Skip'));
    await settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(container.read(onboardingDoneProvider), isTrue);
    expect(
      await tester.runAsync(() => db.readPreference(onboardingPreference)),
      'true',
    );
  });

  testWidgets('Get started: Home', (tester) async {
    await launch(tester);
    for (var i = 0; i < 3; i++) {
      await next(tester);
    }
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('See what is in Pro, with the price: Pro over Home', (
    tester,
  ) async {
    await launch(tester, price: r'US$ 2.99');
    for (var i = 0; i < 3; i++) {
      await next(tester);
    }
    await tester.tap(find.text(r"See what's in Pro · US$ 2.99"));
    await settle(tester);
    expect(find.byType(ProScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Back on page 3 goes to page 2', (tester) async {
    await launch(tester);
    await next(tester);
    await next(tester);
    expect(pageOf(3), findsOneWidget);
    final handled = await tester.binding.handlePopRoute();
    await settle(tester);
    expect(handled, isTrue);
    expect(pageOf(2), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('with animations off, Next jumps', (tester) async {
    await launch(tester);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(pageOf(2), findsOneWidget, reason: 'no animation frames needed');
  });

  testWidgets('done: the app opens on Home', (tester) async {
    await launch(tester, done: true);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('Settings replays it; finishing returns to Settings', (
    tester,
  ) async {
    await launch(tester, done: true);
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await tester.scrollUntilVisible(
      find.text('Show introduction again'),
      200,
      scrollable: find.descendant(
        of: find.byType(SettingsScreen),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(find.text('Show introduction again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show introduction again'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    final router = GoRouter.of(tester.element(find.byType(SettingsScreen)));
    expect(router.state.uri.path, AppRoutes.settings);
  });
}
