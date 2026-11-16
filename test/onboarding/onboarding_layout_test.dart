import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/onboarding/onboarding_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  // The rule from Fitshot's mistake: text never runs under the dots and
  // the button. It scrolls in its own area above them instead.
  for (final size in const [Size(360, 640), Size(390, 844)]) {
    for (final scale in const [0.85, 1.0, 2.0]) {
      testWidgets('${size.width.toInt()}x${size.height.toInt()} at $scale', (
        tester,
      ) async {
        await tester.pumpApp(overrides: baseOverrides(onboardingDone: false));
        tester.view
          ..physicalSize = size * 3
          ..devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        expect(find.byType(OnboardingScreen), findsOneWidget);

        for (var page = 1; page <= 4; page++) {
          expect(tester.takeException(), isNull, reason: 'page $page');
          final button = tester.getRect(find.byType(FilledButton));
          final dots = tester.getRect(
            find.bySemanticsLabel('Page $page of 4'),
          );
          for (final text in find
              .descendant(
                of: find.byType(PageView),
                matching: find.byType(SingleChildScrollView),
              )
              .evaluate()) {
            final area = tester.getRect(find.byWidget(text.widget));
            // Pages beside the current one sit off screen.
            if (area.right <= 0 || area.left >= size.width) continue;
            expect(
              area.bottom,
              lessThanOrEqualTo(dots.top),
              reason: 'page $page text area ends above the dots',
            );
          }
          expect(dots.bottom, lessThanOrEqualTo(button.top));
          if (page < 4) {
            await tester.tap(find.byType(FilledButton));
            await tester.pumpAndSettle();
          }
        }
      });
    }
  }
}
