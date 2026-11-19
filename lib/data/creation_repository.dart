import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/photos/photo_library.dart';

/// Where creation images live: a folder only run4share can see.
typedef CreationsFolder = Future<Directory> Function();

Future<Directory> appCreationsFolder() async {
  final docs = await getApplicationDocumentsDirectory();
  return await Directory(
    p.join(docs.path, 'creations'),
  ).create(recursive: true);
}

/// My Creations: image files plus their settings in the database.
class CreationRepository {
  CreationRepository(this._db, this._folder, [this._photos]);

  final AppDatabase _db;
  final CreationsFolder _folder;

  /// Where picked photos are kept; their copies go when no creation uses
  /// them any more.
  final PhotosFolder? _photos;

  /// Newest first.
  Stream<List<Creation>> watchAll() => (_db.select(
        _db.creations,
      )..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
          .watch();

  Stream<Creation?> watchById(int id) => (_db.select(
        _db.creations,
      )..where((c) => c.id.equals(id)))
          .watchSingleOrNull();

  Future<File> file(Creation creation) async =>
      File(p.join((await _folder()).path, creation.fileName));

  /// Stores [png] and its settings; returns the new creation's ID.
  Future<int> add({
    required Uint8List png,
    required int width,
    required int height,
    required CreationDraft draft,
    required String activityName,
    required bool stickerOnly,
    required DateTime now,
  }) async {
    final name = 'creation-${now.microsecondsSinceEpoch}.png';
    await File(p.join((await _folder()).path, name)).writeAsBytes(png);
    return await _db.into(_db.creations).insert(
          CreationsCompanion.insert(
            activityId: Value(draft.activityId),
            activityName: activityName,
            createdAt: now,
            format: draft.format.name,
            stickerOnly: Value(stickerOnly),
            fileName: name,
            width: width,
            height: height,
            settings: jsonEncode(draft.toJson()),
          ),
        );
  }

  /// Removes it from My Creations; copies saved to Photos stay there.
  Future<void> delete(Creation creation) async {
    final f = await file(creation);
    if (f.existsSync()) await f.delete();
    await (_db.delete(
      _db.creations,
    )..where((c) => c.id.equals(creation.id)))
        .go();
    // Its photo copy too, unless another creation uses the same photo.
    final photoId = settingsOf(creation)?.photoId;
    final photos = _photos;
    if (photoId == null || photos == null) return;
    if ((await usedPhotoIds()).contains(photoId)) return;
    final copy = pickedPhotoFile(await photos(), photoId);
    // Synchronous: one file, and it finishes in widget tests.
    if (copy != null && copy.existsSync()) copy.deleteSync();
  }

  /// The photo of every stored creation.
  Future<Set<String>> usedPhotoIds() async => {
        for (final c in await _db.select(_db.creations).get())
          if (settingsOf(c)?.photoId case final id?) id,
      };

  /// One-off clean-up at start-up: copies of photos no creation uses
  /// (picked but never saved, or left from deleted creations).
  Future<void> forgetUnusedPhotos() async {
    final photos = _photos;
    if (photos == null) return;
    await forgetUnusedPhotoCopies(await photos(), await usedPhotoIds());
  }

  CreationDraft? settingsOf(Creation creation) {
    try {
      return CreationDraft.fromJson(
        jsonDecode(creation.settings) as Map<String, Object?>,
      );
    } on Object {
      return null;
    }
  }
}

final creationsFolderProvider = Provider<CreationsFolder>(
  (ref) => appCreationsFolder,
);

final creationRepositoryProvider = Provider<CreationRepository>(
  (ref) => CreationRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(creationsFolderProvider),
    ref.watch(photosFolderProvider),
  ),
);

final creationsProvider = StreamProvider<List<Creation>>(
  (ref) => ref.watch(creationRepositoryProvider).watchAll(),
);

final StreamProviderFamily<Creation?, int> creationByIdProvider =
    StreamProvider.family<Creation?, int>(
  (ref, id) => ref.watch(creationRepositoryProvider).watchById(id),
);
