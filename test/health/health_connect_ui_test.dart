import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/features/health/health_hub.dart';
import 'package:run4share/features/settings/settings_screen.dart';

import '../helpers/pump_app.dart';
import '../photos/photo_flow_test.dart' show settle;
import 'fake_health_hub.dart';

void main() {
  testWidgets('connect from Home: workouts appear, labelled by source', (
    tester,
  ) async {
    final yesterday = DateTime.now().toUtc().subtract(
          const Duration(days: 1),
        );
    final hub = FakeHealthHub(all: [hubRun(start: yesterday)]);
    await tester.pumpApp(overrides: baseOverrides(hub: hub));

    // Health Connect's Connect on Home (Strava's is the first).
    await tester.tap(find.text('Connect').at(1));
    await settle(tester, rounds: 20);

    expect(find.text('Connected to Health Connect'), findsOneWidget);
    expect(find.text('Morning Run'), findsOneWidget);
    expect(find.textContaining('Health Connect · '), findsOneWidget);
    // Strava can still be connected.
    expect(find.text('Connect Strava'), findsOneWidget);
  });

  testWidgets('not installed: offers to install', (tester) async {
    final hub = FakeHealthHub(hubStatus: HubStatus.unavailable);
    await tester.pumpApp(overrides: baseOverrides(hub: hub));
    await tester.tap(find.text('Connect').at(1));
    await settle(tester);

    expect(
      find.text('Health Connect isn’t installed on this phone.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Install'));
    expect(hub.installs, 1);
  });

  testWidgets('Settings: connect, then disconnect', (tester) async {
    final hub = FakeHealthHub();
    await tester.pumpApp(overrides: baseOverrides(hub: hub));
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);

    final settings = find.byType(SettingsScreen);
    expect(settings, findsOneWidget);
    // Health Connect's row in Settings (Strava's comes first).
    await tester.tap(
      find.descendant(of: settings, matching: find.text('Connect')).at(1),
    );
    await settle(tester, rounds: 20);
    expect(find.text('Connected'), findsOneWidget);

    await tester.tap(
      find.descendant(of: settings, matching: find.text('Disconnect')),
    );
    await settle(tester);
    expect(find.text('Disconnected from Health Connect'), findsOneWidget);
    expect(hub.revokes, 1);
  });
}
