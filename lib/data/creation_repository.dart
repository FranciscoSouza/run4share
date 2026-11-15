import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';

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
  CreationRepository(this._db, this._folder);

  final AppDatabase _db;
  final CreationsFolder _folder;

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
  ),
);

final creationsProvider = StreamProvider<List<Creation>>(
  (ref) => ref.watch(creationRepositoryProvider).watchAll(),
);

final StreamProviderFamily<Creation?, int> creationByIdProvider =
    StreamProvider.family<Creation?, int>(
  (ref, id) => ref.watch(creationRepositoryProvider).watchById(id),
);
