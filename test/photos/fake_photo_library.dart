import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:run4share/features/photos/photo_library.dart';

/// A 400 x 300 PNG, so the cropper has something real to decode.
final Uint8List testPhoto = img.encodePng(
  img.Image(width: 400, height: 300)..clear(img.ColorRgb8(200, 120, 60)),
);

/// Photo library with [photoCount] photos in "Recents" and a second album.
class FakePhotoLibrary implements PhotoLibrary {
  FakePhotoLibrary({
    this.current = PhotoAccess.denied,
    this.onRequest = PhotoAccess.granted,
    this.photoCount = 7,
  });

  PhotoAccess current;

  /// What the system prompt answers.
  PhotoAccess onRequest;
  final int photoCount;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<PhotoAccess> access() async => current;

  @override
  Future<PhotoAccess> requestAccess() async {
    requests++;
    return current = onRequest;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;

  @override
  Future<void> manageLimitedAccess() async {}

  @override
  Future<List<PhotoAlbum>> albums() async => [
        PhotoAlbum(id: 'all', name: 'Recent', count: photoCount, isAll: true),
        const PhotoAlbum(id: 'runs', name: 'Runs', count: 2),
      ];

  @override
  Future<List<String>> photos(
    PhotoAlbum album, {
    required int page,
    required int pageSize,
  }) async {
    final ids = album.id == 'runs'
        ? ['run-a', 'run-b']
        : [for (var i = 0; i < photoCount; i++) 'photo-$i'];
    return ids.skip(page * pageSize).take(pageSize).toList();
  }

  @override
  Future<Uint8List?> thumbnail(String photoId, {required int size}) async =>
      testPhoto;

  @override
  Future<Uint8List?> preview(String photoId, {required int maxSide}) async =>
      testPhoto;
}
