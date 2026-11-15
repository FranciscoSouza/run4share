import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/editor_screen.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/templates/template_activity_screen.dart';

import '../helpers/pump_app.dart';
import '../photos/fake_photo_library.dart';
import '../photos/photo_flow_test.dart' show settle;
import '../strava/fakes.dart';

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
          FakePhotoLibrary(current: PhotoAccess.granted),
        ),
      ],
    );

    await tester.tap(find.text('Story Hero'));
    await settle(tester);
    expect(find.text('Use this template'), findsOneWidget);
    expect(find.text('Sample data · 9:16 · shows distance'), findsOneWidget);
    expect(find.text('Adjust the sticker and share'), findsOneWidget);

    await tester.tap(find.text('Use this template'));
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
    await tester.tap(find.bySemanticsLabel('Photo 1'));
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
}
