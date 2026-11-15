import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/create/creation_draft.dart';

void main() {
  test('formats', () {
    expect(ShareFormat.story.ratio, 9 / 16);
    expect(ShareFormat.feed.ratio, 4 / 5);
    expect(ShareFormat.square.ratio, 1);
  });

  group('centreCrop', () {
    test('landscape photo, square crop: full height, centred', () {
      final crop = centreCrop(const Size(400, 300), ShareFormat.square);
      expect(crop.top, 0);
      expect(crop.height, 1);
      expect(crop.width, closeTo(0.75, 1e-9));
      expect(crop.left, closeTo(0.125, 1e-9));
    });

    test('portrait photo, story crop: full width when photo is taller', () {
      final crop = centreCrop(const Size(1000, 2000), ShareFormat.story);
      expect(crop.left, 0);
      expect(crop.width, 1);
      expect(crop.height, closeTo((1000 / 2000) / (9 / 16), 1e-9));
    });
  });

  test('fractionalCrop maps the frame onto the photo', () {
    // Photo shown at 200,100 and 400x300 on screen; frame 100x100 at
    // 300,150.
    final crop = fractionalCrop(
      frame: const Rect.fromLTWH(300, 150, 100, 100),
      photo: const Rect.fromLTWH(200, 100, 400, 300),
    );
    expect(crop.left, closeTo(0.25, 1e-9));
    expect(crop.top, closeTo(50 / 300, 1e-9));
    expect(crop.width, closeTo(0.25, 1e-9));
    expect(crop.height, closeTo(100 / 300, 1e-9));
  });

  test('fractionalCrop never leaves the photo', () {
    final crop = fractionalCrop(
      frame: const Rect.fromLTWH(-50, -50, 300, 300),
      photo: const Rect.fromLTWH(0, 0, 200, 200),
    );
    expect(crop, const Rect.fromLTWH(0, 0, 1, 1));
  });
}
