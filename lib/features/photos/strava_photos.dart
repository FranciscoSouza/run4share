import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/photos/picked_photos.dart';
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

/// The phone's library, plus photos kept in the app's own storage:
/// Strava photos picked from an activity card (`strava:` IDs) and photos
/// chosen in Android's system picker (`picked:` IDs). Crop, editor,
/// export and "edit again" need no other change.
class WithStravaPhotos implements PhotoLibrary {
  WithStravaPhotos(this._gallery, this._strava, this._picked);

  final PhotoLibrary _gallery;
  final StravaPhotoStore _strava;
  final PickedPhotoStore _picked;

  bool _isStrava(String id) => id.startsWith(stravaPhotoPrefix);
  bool _isPicked(String id) => id.startsWith(pickedPhotoPrefix);

  // A downloaded Strava photo is at most 2048 px, within every size the
  // app asks for, so it's served as it is. A picked one is up to 3072 px
  // (the export size) and is scaled down when less is asked for.
  @override
  Future<Uint8List?> preview(String photoId, {required int maxSide}) async {
    if (_isStrava(photoId)) return await _strava.bytes(photoId);
    if (_isPicked(photoId)) {
      final bytes = await _picked.bytes(photoId);
      return bytes == null ? null : await fitWithin(bytes, maxSide);
    }
    return await _gallery.preview(photoId, maxSide: maxSide);
  }

  @override
  Future<Uint8List?> thumbnail(String photoId, {required int size}) async {
    if (_isStrava(photoId)) return await _strava.bytes(photoId);
    if (_isPicked(photoId)) {
      final bytes = await _picked.bytes(photoId);
      return bytes == null ? null : await fitWithin(bytes, size);
    }
    return await _gallery.thumbnail(photoId, size: size);
  }

  @override
  bool get usesSystemPicker => _gallery.usesSystemPicker;

  /// Keeps the chosen photo in the app's storage, as a `picked:` ID.
  @override
  Future<String?> pickWithSystemPicker() async {
    final cachePath = await _gallery.pickWithSystemPicker();
    return cachePath == null ? null : await _picked.keep(cachePath);
  }

  @override
  Future<PhotoAccess> access() => _gallery.access();

  @override
  Future<PhotoAccess> requestAccess() => _gallery.requestAccess();

  @override
  Future<void> openSettings() => _gallery.openSettings();

  @override
  Future<void> manageLimitedAccess() => _gallery.manageLimitedAccess();

  @override
  Future<List<PhotoAlbum>> albums() => _gallery.albums();

  @override
  Future<List<String>> photos(
    PhotoAlbum album, {
    required int page,
    required int pageSize,
  }) =>
      _gallery.photos(album, page: page, pageSize: pageSize);
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
