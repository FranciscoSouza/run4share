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
    PhotoAccess access = PhotoAccess.denied,
    PhotoAccess onRequest = PhotoAccess.granted,
    bool askedBefore = false,
  }) async {
    db = testDatabase();
    photos = FakePhotoLibrary(current: access, onRequest: onRequest);
    await tester.runAsync(() async {
      await ActivityRepository(db).saveManual(
        name: 'Lunch Run',
        sportType: 'Run',
        startLocal: DateTime.utc(2026, 11, 12, 12, 31),
        movingTime: 1994,
        distance: 5020,
      );
      if (askedBefore) {
        await db.writePreference(photosAskedPreference, 'true');
      }
    });
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(db: db),
        clockProvider.overrideWithValue(() => testNow),
        photoLibraryProvider.overrideWithValue(photos),
      ],
    );
    await tester.tap(find.text('Lunch Run'));
    await settle(tester);
  }

  testWidgets('first time: explain, ask, choose, crop, then the editor', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Add a photo from your library'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await settle(tester);

    expect(photos.requests, 1);
    expect(find.text('Recents'), findsOneWidget);
    expect(
      find.text('Lunch Run · choose one photo', findRichText: true),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Photo 1'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Photo 3'));
    await settle(tester, rounds: 20);
    expect(find.byType(CropScreen), findsOneWidget);
    expect(find.text('Format'), findsOneWidget);
    expect(
      find.text('Drag and pinch the photo to adjust the crop'),
      findsOneWidget,
    );

    await tester.tap(find.text('Square 1:1', findRichText: true));
    await settle(tester);
    await tester.tap(find.text('Next'));
    await settle(tester);

    expect(find.byType(EditorScreen), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(EditorScreen)),
    );
    final draft = container.read(creationDraftProvider)!;
    expect(draft.photoId, 'photo-2');
    expect(draft.format, ShareFormat.square);
    expect(draft.crop.width, greaterThan(0));
    expect(draft.crop.right, lessThanOrEqualTo(1.0001));
    expect(
      await tester.runAsync(() => db.readPreference(formatPreference)),
      'square',
    );

    expect(draft.themeId, 'inline-top');
    expect(draft.sticker?.center, const Offset(0.5, 0.72));
  });

  testWidgets('denied at the prompt: access-off screen', (tester) async {
    await pump(tester, onRequest: PhotoAccess.denied);

    await tester.tap(find.text('Continue'));
    await settle(tester);

    expect(find.text('Photo access is off'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    expect(photos.settingsOpened, 1);

    await tester.tap(find.text('Back to activities'));
    await settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('asked before and still denied: straight to access-off', (
    tester,
  ) async {
    await pump(tester, askedBefore: true);

    expect(find.text('Photo access is off'), findsOneWidget);
    expect(photos.requests, 0);
  });

  testWidgets('"Not now" goes back without asking', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Not now'));
    await settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(photos.requests, 0);
  });

  testWidgets('limited access shows a banner; albums can be switched', (
    tester,
  ) async {
    await pump(tester, access: PhotoAccess.limited);

    expect(
      find.text('run4share can see only the photos you picked.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Photo 7'), findsOneWidget);

    await tester.tap(find.text('Recents'));
    await settle(tester);
    await tester.tap(find.text('Runs'));
    await settle(tester);

    expect(find.bySemanticsLabel('Photo 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Photo 3'), findsNothing);
  });
}
