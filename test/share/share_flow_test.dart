import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/creation_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/creations/creation_detail_screen.dart';
import 'package:run4share/features/creations/creations_screen.dart';
import 'package:run4share/features/editor/editor_screen.dart';
import 'package:run4share/features/home/home_screen.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/share/saved_screen.dart';
import 'package:run4share/features/share/share_actions.dart';
import 'package:run4share/features/share/share_screen.dart';

import '../helpers/pump_app.dart';
import '../photos/fake_photo_library.dart';
import '../photos/photo_flow_test.dart' show settle;
import '../strava/fakes.dart';
import 'fake_share_actions.dart';

void main() {
  late AppDatabase db;
  late FakeShareActions share;
  late FakePhotoLibrary photos;
  late ProviderContainer container;
  late int activityId;

  Future<List<Creation>> creations(WidgetTester tester) async =>
      (await tester.runAsync(
        () => container.read(creationRepositoryProvider).watchAll().first,
      ))!;

  Future<void> pump(WidgetTester tester) async {
    db = testDatabase();
    share = FakeShareActions();
    photos = FakePhotoLibrary(current: PhotoAccess.granted);
    await tester.runAsync(() async {
      activityId = await ActivityRepository(db).saveManual(
        name: 'Lunch Run',
        sportType: 'Run',
        startLocal: DateTime.utc(2026, 11, 12, 12, 31),
        movingTime: 1994,
        distance: 5020,
      );
    });
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(
          db: db,
          share: share,
          folder: Directory.systemTemp.createTempSync('creations'),
        ),
        clockProvider.overrideWithValue(() => testNow),
        photoLibraryProvider.overrideWithValue(photos),
      ],
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
  }

  Future<void> openShare(WidgetTester tester) async {
    container.read(creationDraftProvider.notifier).set(
          CreationDraft(
            activityId: activityId,
            photoId: 'photo-0',
            format: ShareFormat.feed,
            crop: const Rect.fromLTWH(0.1, 0, 0.8, 1),
            themeId: 'inline-top',
            sticker: const StickerPlacement(center: Offset(0.5, 0.72)),
          ),
        );
    unawaited(container.read(routerProvider).push(AppRoutes.editor));
    await settle(tester, rounds: 15);
    await tester.tap(find.text('Share'));
    await settle(tester, rounds: 15);
    expect(find.byType(ShareScreen), findsOneWidget);
  }

  testWidgets('save to Photos: 1080-wide image, kept once in My Creations', (
    tester,
  ) async {
    await pump(tester);
    await openShare(tester);

    await tester.tap(find.bySemanticsLabel('Save to Photos'));
    await settle(tester, rounds: 20);

    expect(share.saved, hasLength(1));
    expect(find.byType(SavedScreen), findsOneWidget);
    expect(find.text('Saved to Photos'), findsOneWidget);
    var saved = await creations(tester);
    expect(saved.single.width, exportWidth);
    expect(saved.single.height, 1350);
    expect(saved.single.stickerOnly, isFalse);

    // Sharing the same image afterwards doesn't add it again. (Saved has
    // no back button; Android's back gesture pops it.)
    container.read(routerProvider).pop();
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('More'));
    await settle(tester, rounds: 20);
    expect(share.shared, hasLength(1));
    expect(find.text('Also kept in My Creations'), findsOneWidget);
    saved = await creations(tester);
    expect(saved, hasLength(1));
    expect(share.shared.single, endsWith(saved.single.fileName));
  });

  testWidgets('sticker only is a separate, transparent creation', (
    tester,
  ) async {
    await pump(tester);
    await openShare(tester);

    await tester.tap(find.text('Sticker only'));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('Instagram Stories'));
    await settle(tester, rounds: 20);

    final saved = await creations(tester);
    expect(saved.single.stickerOnly, isTrue);
    expect(saved.single.width, exportWidth);
    expect(saved.single.height, lessThan(saved.single.width));
  });

  testWidgets('no permission for Photos: says so, stays on Share', (
    tester,
  ) async {
    await pump(tester);
    share.failSave = const SaveException(SaveFailure.noAccess);
    await openShare(tester);

    await tester.tap(find.bySemanticsLabel('Save to Photos'));
    await settle(tester, rounds: 20);

    expect(
      find.text('run4share needs permission to save to Photos.'),
      findsOneWidget,
    );
    expect(find.byType(ShareScreen), findsOneWidget);
  });

  testWidgets('Pro row says it is coming', (tester) async {
    await pump(tester);
    await openShare(tester);
    await tester.tap(find.text('Remove watermark'));
    await tester.pump();
    expect(find.text('Coming in a later update'), findsOneWidget);
  });

  testWidgets('My Creations: open, share again, edit, delete', (
    tester,
  ) async {
    await pump(tester);
    await openShare(tester);
    await tester.tap(find.bySemanticsLabel('Save to Photos'));
    await settle(tester, rounds: 20);
    await tester.tap(find.text('View My Creations'));
    // Let the Saved screen's exit transition finish.
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);

    expect(find.byType(CreationsScreen), findsOneWidget);
    expect(find.text('1 image'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Lunch Run, Today'));
    await settle(tester);
    expect(find.byType(CreationDetailScreen), findsOneWidget);

    await tester.tap(find.text('Share again'));
    await settle(tester);
    expect(share.shared, hasLength(1));

    // Edit reopens the editor with the saved settings.
    await tester.tap(find.text('Edit'));
    await settle(tester, rounds: 15);
    expect(find.byType(EditorScreen), findsOneWidget);
    final draft = container.read(creationDraftProvider)!;
    expect(draft.format, ShareFormat.feed);
    expect(draft.themeId, 'inline-top');
    await tester.tap(find.byTooltip('Back'));
    await settle(tester);

    // Without the original photo, Edit explains instead.
    photos.missing.add('photo-0');
    await tester.tap(find.text('Edit'));
    await settle(tester);
    expect(
      find.text('The original photo is no longer on this phone.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Delete'));
    await settle(tester);
    expect(find.text('Delete this image?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await settle(tester);
    expect(await creations(tester), isEmpty);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('the third saved image asks for a rating', (tester) async {
    await pump(tester);
    await tester.runAsync(() => db.writePreference('rate.saves', '2'));
    await openShare(tester);
    await tester.tap(find.bySemanticsLabel('Save to Photos'));
    await settle(tester, rounds: 30);

    expect(find.text('Enjoying run4share?'), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await settle(tester);
    expect(find.text('Enjoying run4share?'), findsNothing);
    expect(
      await tester.runAsync(() => db.readPreference('rate.notNow')),
      '1',
    );
  });

  testWidgets('Saved: Create another goes home', (tester) async {
    await pump(tester);
    await openShare(tester);
    await tester.tap(find.bySemanticsLabel('Save to Photos'));
    await settle(tester, rounds: 20);
    await tester.tap(find.text('Create another'));
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(find.byType(SavedScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(container.read(creationDraftProvider), isNull);
  });
}
