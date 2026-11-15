import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/creation_repository.dart';
import 'package:run4share/features/create/creation_draft.dart';

import '../helpers/pump_app.dart';

const draft = CreationDraft(
  activityId: 7,
  photoId: 'photo-1',
  format: ShareFormat.feed,
  crop: Rect.fromLTWH(0.1, 0.05, 0.8, 0.9),
  themeId: 'poster',
  sticker:
      StickerPlacement(center: Offset(0.4, 0.6), scale: 1.3, rotation: 0.2),
  style: StickerStyle(colour: StickerColour.blue, background: -0.4),
);

void main() {
  test('settings round-trip through JSON', () {
    final back = CreationDraft.fromJson(draft.toJson())!;
    expect(back.activityId, 7);
    expect(back.photoId, 'photo-1');
    expect(back.format, ShareFormat.feed);
    expect(back.crop, draft.crop);
    expect(back.themeId, 'poster');
    expect(back.sticker, draft.sticker);
    expect(back.style, draft.style);
  });

  test('a removed sticker and theme colour survive too', () {
    final plain = CreationDraft.fromJson(
      const CreationDraft(
        activityId: 1,
        photoId: 'p',
        format: ShareFormat.story,
        crop: Rect.fromLTWH(0, 0, 1, 1),
        themeId: 'inline-top',
      ).toJson(),
    )!;
    expect(plain.sticker, isNull);
    expect(plain.style, const StickerStyle());
  });

  test('broken settings give null, not a crash', () {
    expect(CreationDraft.fromJson({'photoId': 3}), isNull);
  });

  test('add writes the file; delete removes file and row', () async {
    final db = testDatabase();
    addTearDown(db.close);
    final folder = Directory.systemTemp.createTempSync('creations');
    final repo = CreationRepository(db, () async => folder);

    final id = await repo.add(
      png: Uint8List.fromList([1, 2, 3]),
      width: 1080,
      height: 1350,
      draft: draft,
      activityName: 'Lunch Run',
      stickerOnly: false,
      now: DateTime(2026, 11, 15, 9, 16),
    );
    final creation = (await repo.watchAll().first).single;
    expect(creation.id, id);
    expect(creation.activityName, 'Lunch Run');
    expect(creation.format, 'feed');
    expect(repo.settingsOf(creation)?.themeId, 'poster');
    final file = await repo.file(creation);
    expect(file.readAsBytesSync(), [1, 2, 3]);

    await repo.delete(creation);
    expect(await repo.watchAll().first, isEmpty);
    expect(file.existsSync(), isFalse);
  });
}
