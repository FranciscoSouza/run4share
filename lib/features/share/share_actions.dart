import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

enum SaveFailure {
  /// The user refused access to Photos.
  noAccess,

  /// Anything else (full storage, unsupported format...).
  failed,
}

class SaveException implements Exception {
  const SaveException(this.failure, [this.cause]);

  final SaveFailure failure;
  final Object? cause;

  @override
  String toString() => 'SaveException($failure, $cause)';
}

/// Where a finished image can go, behind an interface for tests.
abstract interface class ShareActions {
  /// Adds [png] to the phone's photos, in a "run4share" album.
  Future<void> saveToPhotos(Uint8List png, {required String name});

  /// Opens the system share sheet with the file at [path].
  Future<void> shareFile(String path);
}

class DeviceShareActions implements ShareActions {
  static const album = 'run4share';

  @override
  Future<void> saveToPhotos(Uint8List png, {required String name}) async {
    try {
      if (!await Gal.hasPermission(toAlbum: true) &&
          !await Gal.requestPermission(toAlbum: true)) {
        throw const SaveException(SaveFailure.noAccess);
      }
      await Gal.putImageBytes(png, album: album, name: name);
    } on GalException catch (e) {
      throw SaveException(
        e.type == GalExceptionType.permissionDenied
            ? SaveFailure.noAccess
            : SaveFailure.failed,
        e,
      );
    }
  }

  @override
  Future<void> shareFile(String path) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path, mimeType: 'image/png')]),
    );
  }
}

final shareActionsProvider = Provider<ShareActions>(
  (ref) => DeviceShareActions(),
);
