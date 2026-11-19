import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/platform.dart';
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
    await tester.showOnHome(find.text('Bring in your workouts'));
    await tester.showOnHome(find.text('Add activity manually'));
    await tester.tap(find.text('Connect').last);
    await settle(tester, rounds: 20);

    expect(find.text('Connected to Health Connect'), findsOneWidget);
    await tester.homeToTop();
    // Named by the hour it started ("Morning Run", "Afternoon Run"...),
    // and it started this time yesterday.
    await tester.showOnHome(
      find.textContaining(
        RegExp(r'^(Morning|Lunch|Afternoon|Evening|Night) Run$'),
      ),
    );
    expect(find.textContaining('Health Connect · '), findsOneWidget);
    // Strava can still be connected.
    await tester.homeToTop();
    expect(find.text('Connect Strava'), findsOneWidget);
  });

  testWidgets('not installed: offers to install', (tester) async {
    final hub = FakeHealthHub(hubStatus: HubStatus.unavailable);
    await tester.pumpApp(overrides: baseOverrides(hub: hub));
    await tester.showOnHome(find.text('Bring in your workouts'));
    await tester.showOnHome(find.text('Add activity manually'));
    await tester.tap(find.text('Connect').last);
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

  testWidgets('iPhone: Apple Health connects; an empty result hints why', (
    tester,
  ) async {
    final hub = FakeHealthHub();
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(hub: hub),
        platformProvider.overrideWithValue(TargetPlatform.iOS),
      ],
    );
    await tester.showOnHome(find.text('Bring in your workouts'));
    await tester.showOnHome(find.text('Add activity manually'));
    await tester.tap(find.text('Connect').last);
    await settle(tester, rounds: 20);

    expect(find.text('Connected to Apple Health'), findsOneWidget);
    expect(find.textContaining('Profile › Apps › run4share'), findsOneWidget);
  });

  testWidgets('only Health Connect, nothing in it: a message for any app', (
    tester,
  ) async {
    final hub = FakeHealthHub();
    await tester.pumpApp(overrides: baseOverrides(hub: hub));
    await tester.showOnHome(find.text('Bring in your workouts'));
    await tester.showOnHome(find.text('Add activity manually'));
    await tester.tap(find.text('Connect').last);
    await settle(tester, rounds: 20);
    await tester.homeToTop();
    await tester.showOnHome(find.textContaining('No activities yet.'));
    expect(
      find.text(
        'No activities yet. New workouts from your connected apps show up '
        'here.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('on Strava'), findsNothing);
  });
}
