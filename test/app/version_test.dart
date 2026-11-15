import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/app_info.dart';

void main() {
  test('Settings shows the pubspec version', () {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    final version = line.split(':').last.trim().split('+').first;
    expect(AppInfo.version, version, reason: 'update lib/app/app_info.dart');
  });
}
