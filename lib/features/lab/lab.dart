import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:run4share/features/strava/strava_connection.dart';

/// Whether Settings shows the Laboratory section: always in debug and
/// profile builds, in release builds only with `--dart-define=LAB=true`.
const bool labVisible = !kReleaseMode || bool.fromEnvironment('LAB');

/// Laboratory switches, kept between launches.
abstract interface class LabStore {
  Future<bool> readStravaDemo();
  Future<void> writeStravaDemo({required bool enabled});
}

class SecureLabStore implements LabStore {
  SecureLabStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _stravaDemoKey = 'lab_strava_demo';

  @override
  Future<bool> readStravaDemo() async {
    try {
      return await _storage.read(key: _stravaDemoKey) == 'true';
    } on Object {
      return false;
    }
  }

  @override
  Future<void> writeStravaDemo({required bool enabled}) =>
      _storage.write(key: _stravaDemoKey, value: '$enabled');
}

class MemoryLabStore implements LabStore {
  MemoryLabStore({this.stravaDemo = false});

  bool stravaDemo;

  @override
  Future<bool> readStravaDemo() async => stravaDemo;

  @override
  Future<void> writeStravaDemo({required bool enabled}) async =>
      stravaDemo = enabled;
}

final labStoreProvider = Provider<LabStore>((ref) => SecureLabStore());

/// The saved Strava demo switch, read in main() before the first frame.
final stravaDemoAtLaunchProvider = Provider<bool>((ref) => false);

/// Strava demo data: when on, connecting signs in a demo athlete and the
/// activities are samples. Nothing leaves the phone.
final stravaDemoProvider = NotifierProvider<StravaDemoMode, bool>(
  StravaDemoMode.new,
);

class StravaDemoMode extends Notifier<bool> {
  @override
  bool build() => ref.read(stravaDemoAtLaunchProvider);

  /// Switches mode. The current Strava connection, real or demo, is
  /// disconnected first so the two never mix.
  Future<void> setEnabled({required bool enabled}) async {
    if (enabled == state) return;
    await ref.read(stravaConnectionProvider.notifier).disconnect();
    await ref.read(labStoreProvider).writeStravaDemo(enabled: enabled);
    state = enabled;
  }
}
