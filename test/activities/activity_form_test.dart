import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_form_screen.dart';

import '../helpers/pump_app.dart';
import '../strava/fakes.dart';

Finder field(String name) => find.byKey(ValueKey('activity.$name'));

void main() {
  group('parsing', () {
    test('durations', () {
      expect(parseDuration('0:33:14'), 1994);
      expect(parseDuration('33:14'), 1994);
      expect(parseDuration('45'), 2700);
      expect(parseDuration('1:02:05'), 3725);
      expect(parseDuration('33:75'), isNull);
      expect(parseDuration(''), isNull);
      expect(parseDuration('0:00'), isNull);
    });

    test('numbers accept a decimal comma', () {
      expect(parseNumber('5,02'), 5.02);
      expect(parseNumber('5.02'), 5.02);
      expect(parseNumber(''), isNull);
      expect(parseNumber('0'), isNull);
    });
  });

  late AppDatabase db;

  Future<void> pump(WidgetTester tester) async {
    // In-memory; not closed, since closing inside the widget-test fake
    // clock never completes.
    db = testDatabase();
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(db: db),
        clockProvider.overrideWithValue(() => testNow),
      ],
    );
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ),
      );

  testWidgets('add, edit and delete a manual activity without Strava', (
    tester,
  ) async {
    await pump(tester);

    await tester.showOnHome(find.text('Add activity manually'));
    await tester.tap(find.text('Add activity manually'));
    await tester.pumpAndSettle();
    expect(find.text('Add activity'), findsOneWidget);

    // Duration is required.
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a time like 0:33:14'), findsOneWidget);

    await tester.enterText(field('name'), 'Treadmill Run');
    await tester.enterText(field('duration'), '0:33:14');
    await tester.enterText(field('distance'), '5,02');
    await tester.enterText(field('bpm'), '152');
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();

    expect(find.text('Activity saved'), findsOneWidget);
    expect(find.text('Your activities'), findsOneWidget);
    await scrollTo(tester, find.text('Treadmill Run'));
    expect(find.text('Manual · Sat 14 Nov · 10:00'), findsOneWidget);
    expect(
      find.text('6:37 /km', findRichText: true),
      findsWidgets,
      reason: 'pace from 5.02 km',
    );
    // Strava can still be connected below the list.
    expect(find.text('Bring in your workouts'), findsOneWidget);

    final saved = (await tester.runAsync(
      () => db.select(db.activities).get(),
    ))!
        .single;
    expect(saved.distance, closeTo(5020, 0.001));
    expect(saved.movingTime, 1994);
    expect(saved.averageHeartrate, 152);

    // Edit through the card's menu.
    await tester.tap(find.byTooltip('Activity options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit activity'), findsOneWidget);
    expect(find.text('Treadmill Run'), findsOneWidget);
    await tester.tap(find.text('Ride'));
    await tester.enterText(field('name'), 'Spin class');
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();
    final edited = (await tester.runAsync(
      () => db.select(db.activities).get(),
    ))!
        .single;
    expect(edited.name, 'Spin class');
    expect(edited.sportType, 'Ride');
    await scrollTo(tester, find.text('Spin class'));
    expect(find.text('SPEED'), findsOneWidget);

    // Delete, after confirming.
    await tester.tap(find.byTooltip('Activity options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this activity?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Spin class'), findsNothing);
    expect(
      await tester.runAsync(
        () => ActivityRepository(db).count(ActivitySource.manual),
      ),
      0,
    );
    // Back to the empty Home.
    expect(find.text('Add activity manually'), findsOneWidget);
  });

  testWidgets('a workout without distance saves with calories', (
    tester,
  ) async {
    await pump(tester);
    await tester.showOnHome(find.text('Add activity manually'));
    await tester.tap(find.text('Add activity manually'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Workout'));
    await tester.enterText(field('duration'), '30:18');
    await tester.enterText(field('calories'), '189');
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('CALORIES'));
    expect(find.text('Workout'), findsOneWidget, reason: 'default name');
    expect(find.text('189 kcal', findRichText: true), findsOneWidget);
  });

  testWidgets('a typed shoe is saved like Strava gear', (tester) async {
    await pump(tester);
    await tester.showOnHome(find.text('Add activity manually'));
    await tester.tap(find.text('Add activity manually'));
    await tester.pumpAndSettle();

    await tester.enterText(field('duration'), '30:00');
    await tester.enterText(field('shoe'), 'Pegasus 41');
    await tester.enterText(field('shoeKm'), '412');
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();

    final saved = (await tester.runAsync(
      () => db.select(db.activities).get(),
    ))!
        .single;
    expect(saved.gearId, 'manual:pegasus 41');
    final gear = await tester.runAsync(
      () => ActivityRepository(db).gearById('manual:pegasus 41'),
    );
    expect(gear?.name, 'Pegasus 41');
    expect(gear?.distance, 412000);
  });

  testWidgets('heart rate outside 30–250 is rejected', (tester) async {
    await pump(tester);
    await tester.showOnHome(find.text('Add activity manually'));
    await tester.tap(find.text('Add activity manually'));
    await tester.pumpAndSettle();

    await tester.enterText(field('duration'), '20:00');
    await tester.enterText(field('bpm'), '400');
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();

    expect(find.text('Between 30 and 250'), findsOneWidget);
    expect(find.text('Add activity'), findsOneWidget);
  });
}
