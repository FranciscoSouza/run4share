import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:run4share/features/photos/strava_photos.dart';

/// Photo IDs for photos chosen in the system picker: `photo:<uuid>`, a
/// copy in the app's storage (`<documents>/photos/<uuid>.jpg`).
const pickedPhotoPrefix = 'photo:';

/// Where picked photos are kept: the app's own storage, not the cache, so
/// the crop, the full-size export and "Edit again" work without any
/// access to the photo library.
typedef PhotosFolder = Future<Directory> Function();

Future<Directory> appPhotosFolder() async {
  final docs = await getApplicationDocumentsDirectory();
  return await Directory(p.join(docs.path, 'photos')).create(recursive: true);
}

final photosFolderProvider = Provider<PhotosFolder>((ref) => appPhotosFolder);

/// The photos run4share works with, behind an interface so tests can fake
/// it. Photos are chosen in the system picker (Android Photo Picker,
/// iPhone PHPicker), which needs no photo-library permission (Google
/// Play's Photo and Video Permissions policy).
abstract interface class PhotoLibrary {
  /// Opens the system picker and keeps a copy of the chosen photo; its ID,
  /// or null if the user backed out.
  Future<String?> pick();

  /// A thumbnail no bigger than [size] on its longest side.
  Future<Uint8List?> thumbnail(String photoId, {required int size});

  /// The photo no bigger than [maxSide] on its longest side, upright.
  Future<Uint8List?> preview(String photoId, {required int maxSide});
}

/// The kept copy of [photoId] in [folder], or null if it isn't a picked
/// photo.
File? pickedPhotoFile(Directory folder, String photoId) {
  if (!photoId.startsWith(pickedPhotoPrefix)) return null;
  // basename: an ID can't point outside the folder.
  final name = p.basename(photoId.substring(pickedPhotoPrefix.length));
  return File(p.join(folder.path, '$name.jpg'));
}

/// Deletes kept copies that no creation uses (at start-up, and after a
/// creation is deleted). Photos being edited and not saved yet don't
/// survive a restart anyway.
Future<void> forgetUnusedPhotoCopies(
  Directory folder,
  Set<String> used,
) async {
  if (!folder.existsSync()) return;
  final keep = {
    for (final id in used)
      if (pickedPhotoFile(folder, id) case final file?) p.basename(file.path),
  };
  for (final entry in folder.listSync()) {
    if (entry is File && !keep.contains(p.basename(entry.path))) {
      entry.deleteSync();
    }
  }
}

class DevicePhotoLibrary implements PhotoLibrary {
  DevicePhotoLibrary(this._folder, [ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  final PhotosFolder _folder;
  final ImagePicker _picker;

  static final _random = Random.secure();

  static String _uuid() => [
        for (var i = 0; i < 16; i++)
          _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ].join();

  @override
  Future<String?> pick() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      // Above the 3072 px export, so nothing the app outputs loses detail;
      // also makes iPhone HEIC come back as JPEG.
      maxWidth: 4096,
      maxHeight: 4096,
      imageQuality: 95,
      // Full metadata would need photo-library permission on iPhone.
      requestFullMetadata: false,
    );
    if (picked == null) return null;
    final id = '$pickedPhotoPrefix${_uuid()}';
    final file = pickedPhotoFile(await _folder(), id)!;
    await file.writeAsBytes(await picked.readAsBytes(), flush: true);
    return id;
  }

  Future<Uint8List?> _bytes(String photoId) async {
    final file = pickedPhotoFile(await _folder(), photoId);
    // Anything else (an asset ID from before phase 20) is a missing photo.
    if (file == null || !file.existsSync()) return null;
    return await file.readAsBytes();
  }

  // Flutter's decoder applies the EXIF orientation, so what comes back is
  // upright.
  @override
  Future<Uint8List?> preview(String photoId, {required int maxSide}) async {
    final bytes = await _bytes(photoId);
    return bytes == null ? null : await fitWithin(bytes, maxSide);
  }

  @override
  Future<Uint8List?> thumbnail(String photoId, {required int size}) async {
    final bytes = await _bytes(photoId);
    return bytes == null ? null : await fitWithin(bytes, size);
  }
}

final photoLibraryProvider = Provider<PhotoLibrary>(
  (ref) => WithStravaPhotos(
    DevicePhotoLibrary(ref.watch(photosFolderProvider)),
    ref.watch(stravaPhotoStoreProvider),
  ),
);
