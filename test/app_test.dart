import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/creations/creations_screen.dart';
import 'package:run4share/features/home/home_screen.dart';
import 'package:run4share/features/settings/settings_screen.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/shared/widgets/logo.dart';

import 'helpers/pump_app.dart';

void main() {
  group('App', () {
    testWidgets('opens on Activities with no source connected', (
      tester,
    ) async {
      await tester.pumpApp();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('Connect Strava'), findsOneWidget);
      expect(find.text('Popular templates'), findsOneWidget);
      expect(find.text('Bring in your workouts'), findsOneWidget);
      expect(find.text('Strava'), findsOneWidget);
      expect(find.text('Apple Health'), findsOneWidget);
      expect(find.text('Health Connect'), findsOneWidget);
      expect(find.text('Add activity manually'), findsOneWidget);
      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('My Creations'), findsOneWidget);
    });

    testWidgets('My Creations tab shows the empty state and leads back', (
      tester,
    ) async {
      await tester.pumpApp();

      await tester.tap(find.text('My Creations'));
      await tester.pumpAndSettle();

      expect(find.byType(CreationsScreen), findsOneWidget);
      expect(find.text('No images'), findsOneWidget);
      expect(find.text('Nothing here yet'), findsOneWidget);

      await tester.tap(find.text('Create your first image'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('gear opens Settings and back returns to the tab', (
      tester,
    ) async {
      await tester.pumpApp();

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Settings lists every section and the version', (
      tester,
    ) async {
      await tester.pumpApp();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      for (final text in [
        'WORKOUT SOURCES',
        'PURCHASE',
        'PREFERENCES',
        'run4share Pro',
        'Follows your phone · English',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }

      await tester.scrollUntilVisible(find.text('run4share 1.0.0'), 200);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
    });

    testWidgets('units toggle switches to miles', (tester) async {
      await tester.pumpApp();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(container.read(unitsProvider), Units.km);

      await tester.tap(find.text('mi'));
      await tester.pumpAndSettle();

      expect(container.read(unitsProvider), Units.mi);
    });

    testWidgets('unfinished actions say they are coming', (tester) async {
      await tester.pumpApp();

      await tester.tap(find.text('Connect Strava'));
      await tester.pump();

      expect(find.text('Coming in a later update'), findsOneWidget);
    });
  });
}
