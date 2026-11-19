import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/editor_screen.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/pro/pro_screen.dart';
import 'package:run4share/features/templates/template_activity_screen.dart';
import 'package:run4share/features/templates/template_preview_screen.dart';
import 'package:run4share/features/templates/templates_screen.dart';

import '../helpers/pump_app.dart';
import '../photos/fake_photo_library.dart';
import '../photos/photo_flow_test.dart' show settle;
import '../strava/fakes.dart';

/// The preview's own button (Home has one too, under the carousel).
final Finder useButton = find.descendant(
  of: find.byType(TemplatePreviewScreen),
  matching: find.text('Use this template'),
);

void main() {
  testWidgets('Story Hero: preview, choose activity, photo, crop, editor', (
    tester,
  ) async {
    final db = testDatabase();
    await tester.runAsync(() async {
      final repo = ActivityRepository(db);
      await repo.saveManual(
        name: 'Gym',
        sportType: 'Workout',
        startLocal: DateTime.utc(2026, 11, 13, 19),
        movingTime: 1818,
        calories: 189,
      );
      await repo.saveManual(
        name: 'Lunch Run',
        sportType: 'Run',
        startLocal: DateTime.utc(2026, 11, 12, 12, 31),
        movingTime: 1994,
        distance: 5020,
      );
    });
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(db: db),
        clockProvider.overrideWithValue(() => testNow),
        photoLibraryProvider.overrideWithValue(
          FakePhotoLibrary(),
        ),
      ],
    );

    // Story Hero is a free template, under See all.
    await tester.tap(find.text('See all'));
    await settle(tester);
    await tester.scrollUntilVisible(
      find.bySemanticsLabel(RegExp('^Story Hero, ')),
      300,
      scrollable: find.descendant(
        of: find.byType(TemplatesScreen),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.bySemanticsLabel(RegExp('^Story Hero, ')));
    await settle(tester);
    expect(useButton, findsOneWidget);
    expect(find.text('Sample data · 9:16 · shows distance'), findsOneWidget);
    expect(find.text('Adjust the sticker and share'), findsOneWidget);

    await tester.tap(useButton);
    await settle(tester);
    expect(find.byType(TemplateActivityScreen), findsOneWidget);
    expect(find.text('Choose an activity'), findsOneWidget);
    expect(
      find.text(
        'No distance in this activity, so this template can’t use it',
      ),
      findsOneWidget,
    );

    // The workout can't be chosen.
    await tester.tap(find.text('Gym'));
    await settle(tester);
    expect(find.byType(TemplateActivityScreen), findsOneWidget);

    await tester.tap(find.text('Lunch Run'));
    await settle(tester);
    // The system picker (faked) returns a photo by itself.
    await settle(tester, rounds: 20);
    await tester.tap(find.text('Next'));
    await settle(tester, rounds: 15);

    expect(find.byType(EditorScreen), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(EditorScreen)),
    );
    final draft = container.read(creationDraftProvider)!;
    expect(draft.format, ShareFormat.story);
    expect(draft.themeId, 'big-distance');
  });

  Future<ProviderContainer> start(
    WidgetTester tester, {
    bool pro = false,
  }) async {
    final db = testDatabase();
    await tester.runAsync(
      () => ActivityRepository(db).saveManual(
        name: 'Lunch Run',
        sportType: 'Run',
        startLocal: DateTime.utc(2026, 11, 12, 12, 31),
        movingTime: 1994,
        distance: 5020,
      ),
    );
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(db: db),
        clockProvider.overrideWithValue(() => testNow),
        photoLibraryProvider.overrideWithValue(
          FakePhotoLibrary(),
        ),
        proAtLaunchProvider.overrideWithValue(pro),
      ],
    );
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  /// Opens a template's preview, as Home's carousel or See all would.
  Future<void> preview(ProviderContainer container, String id) async {
    unawaited(container.read(routerProvider).push(AppRoutes.template(id)));
  }

  testWidgets('a Pro template: badged preview, Use leads to Pro', (
    tester,
  ) async {
    final container = await start(tester);
    await preview(container, 'race-day');
    await settle(tester);
    expect(useButton, findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('PRO')),
      findsOneWidget,
      reason: 'title badge',
    );
    await tester.tap(useButton);
    await settle(tester);
    expect(find.byType(ProScreen), findsOneWidget);
    expect(find.byType(TemplateActivityScreen), findsNothing);
  });

  testWidgets('with Pro: Run Receipt goes all the way to the editor', (
    tester,
  ) async {
    final container = await start(tester, pro: true);
    await preview(container, 'run-receipt');
    await settle(tester);
    await tester.tap(useButton);
    await settle(tester);
    await tester.tap(find.text('Lunch Run'));
    await settle(tester);
    // The system picker (faked) returns a photo by itself.
    await settle(tester, rounds: 20);
    await tester.tap(find.text('Next'));
    await settle(tester, rounds: 15);
    expect(find.byType(EditorScreen), findsOneWidget);
    expect(container.read(creationDraftProvider)!.themeId, 'receipt');
  });

  test('every template has a theme; Pro as decided', () {
    expect(storyTemplates.map((t) => t.id).toSet(), hasLength(11));
    expect(
      [
        for (final t in storyTemplates)
          if (t.pro) t.id,
      ],
      [
        'summit-day',
        'mountain-climb',
        'final-score',
        'race-day',
        'run-receipt',
      ],
    );
  });
}
