import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/creation_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/photos/photo_library.dart';

import '../helpers/pump_app.dart';
import '../strava/fakes.dart';
import 'fake_photo_library.dart' show testPhoto;
import 'photo_flow_test.dart' show settle;

/// The system picker, answering with a file like image_picker does.
class _Picker extends ImagePicker {
  _Picker(this.path);

  final String? path;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async =>
      path == null ? null : XFile(path!);
}

String pickerCacheFile() {
  final dir = Directory.systemTemp.createTempSync('picker_cache');
  return (File('${dir.path}/image_picker_1.jpg')..writeAsBytesSync(testPhoto))
      .path;
}

CreationDraft draftWith(String photoId) => CreationDraft(
      activityId: 1,
      photoId: photoId,
      format: ShareFormat.story,
      crop: const Rect.fromLTWH(0, 0, 1, 1),
      themeId: 'inline-top',
    );

void main() {
  test('a picked photo is copied into the app and survives a restart',
      () async {
    final folder = Directory.systemTemp.createTempSync('photos');
    final library = DevicePhotoLibrary(
      () async => folder,
      _Picker(pickerCacheFile()),
    );
    final id = await library.pick();
    expect(id, startsWith('photo:'));
    expect(folder.listSync().whereType<File>(), hasLength(1));

    // A new instance, as after closing and reopening the app.
    final again = DevicePhotoLibrary(() async => folder, _Picker(null));
    final bytes = await again.preview(id!, maxSide: 3072);
    expect(bytes, isNotNull);
    final codec = await ui.instantiateImageCodec(bytes!);
    final frame = await codec.getNextFrame();
    expect([frame.image.width, frame.image.height], [400, 300]);
    final small = await again.thumbnail(id, size: 40);
    final thumb = await (await ui.instantiateImageCodec(small!)).getNextFrame();
    expect([thumb.image.width, thumb.image.height], [40, 30]);
  });

  test('backing out of the picker keeps nothing', () async {
    final folder = Directory.systemTemp.createTempSync('photos');
    final library = DevicePhotoLibrary(() async => folder, _Picker(null));
    expect(await library.pick(), isNull);
    expect(folder.listSync(), isEmpty);
  });

  test('an asset ID from before this change is a missing photo', () async {
    final folder = Directory.systemTemp.createTempSync('photos');
    final library = DevicePhotoLibrary(() async => folder, _Picker(null));
    expect(await library.preview('A1B2-C3D4/L0/001', maxSide: 2048), isNull);
    expect(await library.thumbnail('photo:../../etc/passwd', size: 64), isNull);
  });

  group('copies go when no creation uses them', () {
    late AppDatabase db;
    late Directory photos;
    late CreationRepository repo;

    setUp(() {
      db = testDatabase();
      photos = Directory.systemTemp.createTempSync('photos');
      repo = CreationRepository(
        db,
        () async => Directory.systemTemp.createTempSync('creations'),
        () async => photos,
      );
    });
    tearDown(() => db.close());

    File copy(String id) =>
        pickedPhotoFile(photos, id)!..writeAsBytesSync(testPhoto);

    Future<Creation> save(String photoId) async {
      final id = await repo.add(
        png: Uint8List.fromList(testPhoto),
        width: 400,
        height: 300,
        draft: draftWith(photoId),
        activityName: 'Run',
        stickerOnly: false,
        now: DateTime.utc(2026, 11, 19),
      );
      return (await repo.watchById(id).first)!;
    }

    test('deleting a creation removes its photo unless another uses it',
        () async {
      final shared = copy('photo:shared');
      final first = await save('photo:shared');
      final second = await save('photo:shared');

      await repo.delete(first);
      expect(shared.existsSync(), isTrue, reason: 'the second still uses it');
      await repo.delete(second);
      expect(shared.existsSync(), isFalse);
    });

    test('start-up clean-up removes copies nothing uses', () async {
      final used = copy('photo:used');
      final orphan = copy('photo:orphan');
      await save('photo:used');
      await repo.forgetUnusedPhotos();
      expect(used.existsSync(), isTrue);
      expect(orphan.existsSync(), isFalse);
    });
  });

  testWidgets('Edit again with an old asset ID: the photo is gone', (
    tester,
  ) async {
    final db = testDatabase();
    final photos = Directory.systemTemp.createTempSync('photos');
    late int creationId;
    await tester.runAsync(() async {
      final activityId = await ActivityRepository(db).saveManual(
        name: 'Lunch Run',
        sportType: 'Run',
        startLocal: DateTime.utc(2026, 11, 12, 12, 31),
        movingTime: 1994,
        distance: 5020,
      );
      final repo = CreationRepository(
        db,
        () async => Directory.systemTemp.createTempSync('creations'),
      );
      creationId = await repo.add(
        png: Uint8List.fromList(testPhoto),
        width: 400,
        height: 300,
        draft: CreationDraft(
          activityId: activityId,
          // A photo_manager asset ID, as saved before this change.
          photoId: 'A1B2-C3D4/L0/001',
          format: ShareFormat.story,
          crop: const Rect.fromLTWH(0, 0, 1, 1),
          themeId: 'inline-top',
        ),
        activityName: 'Lunch Run',
        stickerOnly: false,
        now: testNow,
      );
    });
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(db: db),
        clockProvider.overrideWithValue(() => testNow),
        photoLibraryProvider.overrideWithValue(
          DevicePhotoLibrary(() async => photos, _Picker(null)),
        ),
      ],
    );
    final container =
        ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    container
        .read(routerProvider)
        .push(AppRoutes.creation(creationId))
        .ignore();
    await settle(tester);
    await tester.tap(find.text('Edit'));
    await settle(tester);
    expect(
      find.text('The original photo is no longer on this phone.'),
      findsOneWidget,
    );
  });
}
