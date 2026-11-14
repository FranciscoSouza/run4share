import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the bundled fonts so widget tests measure text as a phone does,
/// which makes the overflow checks in every test meaningful.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await _loadFamily('BarlowCondensed', [
    'BarlowCondensed-SemiBold.ttf',
    'BarlowCondensed-Bold.ttf',
    'BarlowCondensed-ExtraBoldItalic.ttf',
  ]);
  await _loadFamily('Inter', [
    'Inter-Regular.ttf',
    'Inter-Medium.ttf',
    'Inter-SemiBold.ttf',
  ]);
  await testMain();
}

Future<void> _loadFamily(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File('assets/fonts/$file').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}
