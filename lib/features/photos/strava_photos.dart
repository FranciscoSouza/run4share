import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/strava/strava_api.dart';

/// Photo IDs for pictures taken from Strava: `strava:<unique_id>`.
const stravaPhotoPrefix = 'strava:';

/// Full size for a picked Strava photo: enough for the crop and export.
const stravaPhotoFullSize = 2048;

/// Where picked Strava photos are kept: the app's own storage (not the
/// cache), so a creation can be edited again later.
typedef StravaPhotosFolder = Future<Directory> Function();

Future<Directory> appStravaPhotosFolder() async {
  final docs = await getApplicationDocumentsDirectory();
  return await Directory(p.join(docs.path, 'strava_photos'))
      .create(recursive: true);
}

final stravaPhotosFolderProvider = Provider<StravaPhotosFolder>(
  (ref) => appStravaPhotosFolder,
);

/// Downloads a Strava photo to use as a background, and serves it back.
class StravaPhotoStore {
  StravaPhotoStore({
    required StravaApi Function() api,
    required StravaPhotosFolder folder,
    Dio? dio,
  })  : _api = api,
        _folder = folder,
        _dio = dio ?? Dio();

  /// Looked up only when downloading: reading photos from the store (crop,
  /// editor, Settings) never builds the Strava connection.
  final StravaApi Function() _api;
  final StravaPhotosFolder _folder;
  final Dio _dio;

  /// Strava's IDs are UUID-like; keep file names to safe characters.
  static String _fileName(String uniqueId) =>
      '${uniqueId.replaceAll(RegExp('[^A-Za-z0-9-]'), '_')}.jpg';

  Future<File> _file(String uniqueId) async =>
      File(p.join((await _folder()).path, _fileName(uniqueId)));

  /// Fetches photo [uniqueId] of [activity] at full size (one Strava
  /// request, then the image itself) unless it's already here; returns
  /// its photo ID. Throws if Strava no longer has it.
  Future<String> download(Activity activity, String uniqueId) async {
    final file = await _file(uniqueId);
    if (!file.existsSync()) {
      final id = int.parse(activity.sourceId!);
      final photos = await _api().photos(id, size: stravaPhotoFullSize);
      final photo = photos.firstWhere((ph) => ph.id == uniqueId);
      final response = await _dio.get<List<int>>(
        photo.url,
        options: Options(responseType: ResponseType.bytes),
      );
      await file.writeAsBytes(response.data!, flush: true);
    }
    return '$stravaPhotoPrefix$uniqueId';
  }

  /// The image behind a "strava:" photo ID; null if it's gone.
  Future<Uint8List?> bytes(String photoId) async {
    final file = await _file(photoId.substring(stravaPhotoPrefix.length));
    return file.existsSync() ? await file.readAsBytes() : null;
  }

  /// After disconnecting Strava: its photos go too (Strava's API terms).
  Future<void> clear() async {
    final dir = await _folder();
    // Synchronous: a handful of files, and it finishes in widget tests.
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}

final stravaPhotoStoreProvider = Provider<StravaPhotoStore>(
  (ref) => StravaPhotoStore(
    api: () => ref.read(stravaApiProvider),
    folder: ref.watch(stravaPhotosFolderProvider),
  ),
);

/// The picked photos, plus Strava photos chosen from an activity card
/// (`strava:` IDs, served from their own folder). Crop, editor, export and
/// "Edit again" need no other change.
class WithStravaPhotos implements PhotoLibrary {
  WithStravaPhotos(this._photos, this._strava);

  final PhotoLibrary _photos;
  final StravaPhotoStore _strava;

  bool _isStrava(String id) => id.startsWith(stravaPhotoPrefix);

  @override
  Future<String?> pick() => _photos.pick();

  // A downloaded Strava photo is at most 2048 px; scaled down when less is
  // asked for.
  @override
  Future<Uint8List?> preview(String photoId, {required int maxSide}) async {
    if (!_isStrava(photoId)) {
      return await _photos.preview(photoId, maxSide: maxSide);
    }
    final bytes = await _strava.bytes(photoId);
    return bytes == null ? null : await fitWithin(bytes, maxSide);
  }

  @override
  Future<Uint8List?> thumbnail(String photoId, {required int size}) async {
    if (!_isStrava(photoId)) {
      return await _photos.thumbnail(photoId, size: size);
    }
    final bytes = await _strava.bytes(photoId);
    return bytes == null ? null : await fitWithin(bytes, size);
  }
}

/// [bytes] as they are when no side is over [maxSide]; else scaled down
/// to fit, as PNG.
Future<Uint8List> fitWithin(Uint8List bytes, int maxSide) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  final w = descriptor.width;
  final h = descriptor.height;
  if (w <= maxSide && h <= maxSide) {
    descriptor.dispose();
    buffer.dispose();
    return bytes;
  }
  final scale = maxSide / (w > h ? w : h);
  final codec = await descriptor.instantiateCodec(
    targetWidth: (w * scale).round(),
    targetHeight: (h * scale).round(),
  );
  final frame = await codec.getNextFrame();
  final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  frame.image.dispose();
  codec.dispose();
  descriptor.dispose();
  buffer.dispose();
  return png!.buffer.asUint8List();
}
