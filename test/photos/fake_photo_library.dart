import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:run4share/features/photos/photo_library.dart';

/// A 400 x 300 PNG, so the cropper has something real to decode.
final Uint8List testPhoto = img.encodePng(
  img.Image(width: 400, height: 300)..clear(img.ColorRgb8(200, 120, 60)),
);

/// The system picker, faked: [pick] returns [next] (null: backed out),
/// and every photo is [testPhoto] unless listed in [missing].
class FakePhotoLibrary implements PhotoLibrary {
  FakePhotoLibrary({this.next = 'photo:test-1'});

  /// What the picker returns on the next [pick].
  String? next;
  int picks = 0;

  /// Photos that are gone (a deleted copy, an old asset ID).
  final missing = <String>{};

  @override
  Future<String?> pick() async {
    picks++;
    return next;
  }

  @override
  Future<Uint8List?> thumbnail(String photoId, {required int size}) async =>
      missing.contains(photoId) ? null : testPhoto;

  @override
  Future<Uint8List?> preview(String photoId, {required int maxSide}) async =>
      missing.contains(photoId) ? null : testPhoto;
}
