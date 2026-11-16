import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/home/featured_templates.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/pro/pro_screen.dart';
import 'package:run4share/features/templates/template_activity_screen.dart';
import 'package:run4share/features/templates/template_preview_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> launch(WidgetTester tester, {bool pro = false}) async {
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(),
        proAtLaunchProvider.overrideWithValue(pro),
      ],
    );
    await tester.pumpAndSettle();
  }

  Finder carousel() => find.descendant(
        of: find.byType(FeaturedTemplates),
        matching: find.byType(PageView),
      );

  /// The name and "what" line under the carousel.
  void showing(String name, String what) {
    expect(
      find.descendant(
        of: find.byType(FeaturedTemplates),
        matching: find.text(name),
      ),
      findsOneWidget,
    );
    expect(find.text(what), findsOneWidget);
  }

  /// One card's width to the left, at finger speed: the next template.
  Future<void> swipe(WidgetTester tester) async {
    await tester.timedDrag(
      carousel(),
      const Offset(-240, 0),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();
  }

  /// The next card peeks at the right edge (scaled to 0.82): tap there.
  Future<void> tapNext(WidgetTester tester) async {
    final view = tester.getRect(carousel());
    await tester.tapAt(Offset(view.right - 20, view.center.dy));
    await tester.pumpAndSettle();
  }

  testWidgets('featured templates in order; swiping follows', (tester) async {
    await launch(tester);
    showing('Sunrise Half', 'Run · Pace');
    await swipe(tester);
    showing('Summit Day', 'Hike · Elevation · Pro');
    await swipe(tester);
    showing('Mountain Climb', 'Ride · Route · Pro');
    await swipe(tester);
    showing('Night Run', 'Run · Heart rate · Pro');
  });

  testWidgets('with Pro the what line drops "Pro"', (tester) async {
    await launch(tester, pro: true);
    await swipe(tester);
    showing('Summit Day', 'Hike · Elevation');
  });

  testWidgets('a side card comes to the centre; the centre opens', (
    tester,
  ) async {
    await launch(tester);
    await tapNext(tester);
    showing('Summit Day', 'Hike · Elevation · Pro');
    expect(find.byType(TemplatePreviewScreen), findsNothing);

    await tester.tap(find.bySemanticsLabel(RegExp('^Summit Day, ')).first);
    await tester.pumpAndSettle();
    expect(find.byType(TemplatePreviewScreen), findsOneWidget);
  });

  testWidgets('Use this template: free → choose activity', (tester) async {
    await launch(tester);
    await tester.tap(find.text('Use this template'));
    await tester.pumpAndSettle();
    expect(find.byType(TemplateActivityScreen), findsOneWidget);
  });

  testWidgets('Use this template: Pro without Pro → Pro screen', (
    tester,
  ) async {
    await launch(tester);
    await swipe(tester);
    await tester.tap(find.text('Use this template'));
    await tester.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);
  });

  testWidgets('Use this template: Pro with Pro → choose activity', (
    tester,
  ) async {
    await launch(tester, pro: true);
    await swipe(tester);
    await tester.tap(find.text('Use this template'));
    await tester.pumpAndSettle();
    expect(find.byType(TemplateActivityScreen), findsOneWidget);
  });

  testWidgets('advances by itself every 5 s', (tester) async {
    await launch(tester);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    showing('Summit Day', 'Hike · Elevation · Pro');
  });

  testWidgets('a touch pauses it for 10 s', (tester) async {
    await launch(tester);
    // A small drag that springs back: touched, no page change.
    await tester.drag(carousel(), const Offset(20, 0));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    showing('Sunrise Half', 'Run · Pace');
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    showing('Summit Day', 'Hike · Elevation · Pro');
  });

  for (final (name, features) in const [
    ('animations off', FakeAccessibilityFeatures(disableAnimations: true)),
    ('a screen reader', FakeAccessibilityFeatures(accessibleNavigation: true)),
  ]) {
    testWidgets('no auto-advance with $name', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = features;
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await launch(tester);
      await tester.pump(const Duration(seconds: 11));
      await tester.pumpAndSettle();
      showing('Sunrise Half', 'Run · Pace');
    });
  }

  testWidgets('See all opens the grid', (tester) async {
    await launch(tester);
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.text('Templates'), findsOneWidget);
    // The container is still alive for the next test's pumps.
    expect(
      ProviderScope.containerOf(tester.element(find.text('Templates'))),
      isNotNull,
    );
  });
}
