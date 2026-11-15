import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/lab/lab.dart';
import 'package:run4share/features/strava/strava_demo.dart';
import 'package:run4share/features/strava/strava_session_store.dart';

import '../helpers/pump_app.dart';
import 'fakes.dart';

final Finder _page = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);

void main() {
  testWidgets('Laboratory switch turns on demo data; connect lists samples', (
    tester,
  ) async {
    final labStore = MemoryLabStore();
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(lab: labStore),
        clockProvider.overrideWithValue(() => testNow),
      ],
    );

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Strava demo data'), 200);
    expect(find.text('LABORATORY'), findsOneWidget);

    await tester.ensureVisible(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(labStore.stravaDemo, isTrue);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connect Strava'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Connect with Strava'));
    await tester.pumpAndSettle();

    expect(find.text('Connected as Demo athlete'), findsOneWidget);
    expect(find.text('Lunch Run'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Lunch Weight Training'),
      300,
      scrollable: _page,
    );
  });

  testWidgets('switching demo off disconnects the demo athlete', (
    tester,
  ) async {
    final store = MemoryStravaSessionStore();
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(store: store, lab: MemoryLabStore(stravaDemo: true)),
        stravaDemoAtLaunchProvider.overrideWithValue(true),
        clockProvider.overrideWithValue(() => testNow),
      ],
    );

    await tester.tap(find.text('Connect Strava'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Connect with Strava'));
    await tester.pumpAndSettle();
    expect(store.session?.athleteName, 'Demo athlete');

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Strava demo data'), 200);
    await tester.ensureVisible(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(store.session, isNull);
    await tester.scrollUntilVisible(find.text('WORKOUT SOURCES'), -200);
    expect(find.text('Not connected'), findsNWidgets(2));
  });

  test('samples are newest first and dated from now', () {
    final samples = demoActivities(testNow);
    expect(samples.first.name, 'Lunch Run');
    expect(samples.first.startDateLocal.day, testNow.day);
    for (var i = 1; i < samples.length; i++) {
      expect(
        samples[i].startDateLocal.isBefore(samples[i - 1].startDateLocal),
        isTrue,
      );
    }
  });
}
