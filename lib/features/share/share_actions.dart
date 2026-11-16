import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
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

  /// Opens the system share sheet with [text] (the invite).
  Future<void> shareText(String text);

  /// Puts [png] on the clipboard as an image, to paste into a story.
  /// False when the phone wouldn't take it.
  Future<bool> copyImage(Uint8List png);
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
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Future<void> shareFile(String path) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path, mimeType: 'image/png')]),
    );
  }

  static const _system = MethodChannel('run4share/system');

  /// Flutter's clipboard is text only: the PNG goes through the app's
  /// cache (Android hands the clipboard a content URI to it; iOS reads the
  /// bytes into the pasteboard).
  @override
  Future<bool> copyImage(Uint8List png) async {
    try {
      final dir = Directory(
        '${(await getTemporaryDirectory()).path}/clipboard',
      )..createSync(recursive: true);
      // One file, replaced each time: the clipboard holds one image.
      final file = File('${dir.path}/run4share-sticker.png');
      await file.writeAsBytes(png, flush: true);
      return await _system.invokeMethod<bool>(
            'copyImage',
            {'path': file.path},
          ) ??
          false;
    } on Object catch (error) {
      debugPrint('Copy failed: $error');
      return false;
    }
  }
}

final shareActionsProvider = Provider<ShareActions>(
  (ref) => DeviceShareActions(),
);
