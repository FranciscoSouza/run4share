import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/create/crop_screen.dart';
import 'package:run4share/features/editor/editor_screen.dart';
import 'package:run4share/features/home/home_screen.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/photos/photo_step_screen.dart';

import '../helpers/pump_app.dart';
import '../strava/fakes.dart';
import 'fake_photo_library.dart';

/// Pumps frames while real async work (image decoding, isolates) runs.
/// pumpAndSettle would wait forever on the croppers' progress spinners.
Future<void> settle(WidgetTester tester, {int rounds = 10}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late AppDatabase db;
  late FakePhotoLibrary photos;

  Future<void> pump(
    WidgetTester tester, {
    String? picked = 'photo:test-1',
  }) async {
    db = testDatabase();
    photos = FakePhotoLibrary(next: picked);
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
        photoLibraryProvider.overrideWithValue(photos),
      ],
    );
    await tester.showOnHome(find.text('Lunch Run'));
    await tester.tap(find.text('Lunch Run'));
    await settle(tester, rounds: 15);
  }

  testWidgets('tap an activity: the system picker, then crop, then editor', (
    tester,
  ) async {
    await pump(tester);
    expect(photos.picks, 1, reason: 'opens straight away, no permission');
    expect(find.byType(PhotoStepScreen), findsNothing, reason: 'replaced');
    expect(find.byType(CropScreen), findsOneWidget);

    await tester.tap(find.text('Next'));
    await settle(tester, rounds: 15);
    expect(find.byType(EditorScreen), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(EditorScreen)),
    );
    expect(container.read(creationDraftProvider)!.photoId, 'photo:test-1');
  });

  testWidgets('backing out of the picker goes back home', (tester) async {
    await pump(tester, picked: null);
    expect(photos.picks, 1);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(CropScreen), findsNothing);
  });
}
