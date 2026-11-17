import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:run4share/features/photos/strava_photos.dart';

enum PhotoAccess {
  /// Every photo.
  granted,

  /// Only photos the user picked (iOS limited, Android 14+ partial).
  limited,

  /// No access: not asked yet, denied, or restricted.
  denied,
}

@immutable
class PhotoAlbum {
  const PhotoAlbum({
    required this.id,
    required this.name,
    required this.count,
    this.isAll = false,
  });

  final String id;
  final String name;
  final int count;

  /// The system's "all photos" album (Recents / Recent).
  final bool isAll;
}

/// The phone's photo library, behind an interface so tests can fake it.
abstract interface class PhotoLibrary {
  /// Current access, without asking.
  Future<PhotoAccess> access();

  /// Shows the system permission prompt (when the OS still allows it).
  Future<PhotoAccess> requestAccess();

  Future<void> openSettings();

  /// Lets the user change which photos are shared under limited access.
  Future<void> manageLimitedAccess();

  /// Albums with at least one photo; the "all photos" album first.
  Future<List<PhotoAlbum>> albums();

  /// Photo IDs in [album], newest first.
  Future<List<String>> photos(
    PhotoAlbum album, {
    required int page,
    required int pageSize,
  });

  /// A square-cropped thumbnail for the grid.
  Future<Uint8List?> thumbnail(String photoId, {required int size});

  /// A JPEG no bigger than [maxSide] on its longest side, upright.
  Future<Uint8List?> preview(String photoId, {required int maxSide});
}

class DevicePhotoLibrary implements PhotoLibrary {
  static const _option = PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.image,
      mediaLocation: false,
    ),
  );

  final _albums = <String, AssetPathEntity>{};
  final _assets = <String, AssetEntity>{};

  PhotoAccess _map(PermissionState state) => switch (state) {
        PermissionState.authorized => PhotoAccess.granted,
        PermissionState.limited => PhotoAccess.limited,
        _ => PhotoAccess.denied,
      };

  @override
  Future<PhotoAccess> access() async =>
      _map(await PhotoManager.getPermissionState(requestOption: _option));

  @override
  Future<PhotoAccess> requestAccess() async =>
      _map(await PhotoManager.requestPermissionExtend(requestOption: _option));

  @override
  Future<void> openSettings() => PhotoManager.openSetting();

  @override
  Future<void> manageLimitedAccess() =>
      PhotoManager.presentLimited(type: RequestType.image);

  @override
  Future<List<PhotoAlbum>> albums() async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [const OrderOption()],
      ),
    );
    final albums = <PhotoAlbum>[];
    for (final path in paths) {
      final count = await path.assetCountAsync;
      if (count == 0) continue;
      _albums[path.id] = path;
      albums.add(
        PhotoAlbum(
          id: path.id,
          name: path.name,
          count: count,
          isAll: path.isAll,
        ),
      );
    }
    albums.sort((a, b) => (b.isAll ? 1 : 0) - (a.isAll ? 1 : 0));
    return albums;
  }

  @override
  Future<List<String>> photos(
    PhotoAlbum album, {
    required int page,
    required int pageSize,
  }) async {
    final path = _albums[album.id];
    if (path == null) return const [];
    final assets = await path.getAssetListPaged(page: page, size: pageSize);
    for (final asset in assets) {
      _assets[asset.id] = asset;
    }
    return [for (final asset in assets) asset.id];
  }

  Future<AssetEntity?> _asset(String id) async {
    final cached = _assets[id];
    if (cached != null) return cached;
    final asset = await AssetEntity.fromId(id);
    if (asset != null) _assets[id] = asset;
    return asset;
  }

  @override
  Future<Uint8List?> thumbnail(String photoId, {required int size}) async {
    final asset = await _asset(photoId);
    return await asset?.thumbnailDataWithSize(
      ThumbnailSize.square(size),
      quality: 80,
    );
  }

  @override
  Future<Uint8List?> preview(String photoId, {required int maxSide}) async {
    final asset = await _asset(photoId);
    if (asset == null) return null;
    final w = asset.orientatedWidth;
    final h = asset.orientatedHeight;
    final scale = w <= 0 || h <= 0 ? 1.0 : maxSide / (w > h ? w : h);
    final size = scale >= 1
        ? ThumbnailSize(w, h)
        : ThumbnailSize((w * scale).round(), (h * scale).round());
    return await asset.thumbnailDataWithSize(size, quality: 90);
  }
}

final photoLibraryProvider = Provider<PhotoLibrary>(
  (ref) => WithStravaPhotos(
    DevicePhotoLibrary(),
    ref.watch(stravaPhotoStoreProvider),
  ),
);
