import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Photo IDs for pictures chosen in Android's system photo picker:
/// `picked:<file name>`.
const pickedPhotoPrefix = 'picked:';

typedef PickedPhotosFolder = Future<Directory> Function();

/// The app's own storage (not the cache), so a creation can be edited
/// again later.
Future<Directory> appPickedPhotosFolder() async {
  final docs = await getApplicationDocumentsDirectory();
  return await Directory(p.join(docs.path, 'picked_photos'))
      .create(recursive: true);
}

final pickedPhotosFolderProvider = Provider<PickedPhotosFolder>(
  (ref) => appPickedPhotosFolder,
);

/// Keeps photos chosen in the system picker (already upright and at most
/// 3072 px, see MainActivity) and serves them back.
class PickedPhotoStore {
  PickedPhotoStore(this._folder);

  final PickedPhotosFolder _folder;

  /// Moves the picker's file from the cache into the app's storage;
  /// returns its photo ID.
  Future<String> keep(String cachePath) async {
    final source = File(cachePath);
    final name = p.basename(cachePath);
    final target = File(p.join((await _folder()).path, name));
    await source.copy(target.path);
    // The cache copy is no longer needed.
    if (source.existsSync()) source.deleteSync();
    return '$pickedPhotoPrefix$name';
  }

  Future<Uint8List?> bytes(String photoId) async {
    final name = p.basename(photoId.substring(pickedPhotoPrefix.length));
    final file = File(p.join((await _folder()).path, name));
    return file.existsSync() ? await file.readAsBytes() : null;
  }
}

final pickedPhotoStoreProvider = Provider<PickedPhotoStore>(
  (ref) => PickedPhotoStore(ref.watch(pickedPhotosFolderProvider)),
);
