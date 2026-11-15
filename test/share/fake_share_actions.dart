import 'dart:typed_data';

import 'package:run4share/features/share/share_actions.dart';

class FakeShareActions implements ShareActions {
  final saved = <Uint8List>[];
  final shared = <String>[];

  /// Thrown by saveToPhotos when set.
  SaveException? failSave;

  @override
  Future<void> saveToPhotos(Uint8List png, {required String name}) async {
    if (failSave case final error?) throw error;
    saved.add(png);
  }

  @override
  Future<void> shareFile(String path) async => shared.add(path);

  final texts = <String>[];

  @override
  Future<void> shareText(String text) async => texts.add(text);
}
