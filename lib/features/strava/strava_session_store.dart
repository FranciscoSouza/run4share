import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:run4share/features/strava/strava_models.dart';

/// Keeps the Strava session between launches.
abstract interface class StravaSessionStore {
  Future<StravaSession?> read();
  Future<void> write(StravaSession session);
  Future<void> clear();
}

/// Keychain on iOS, encrypted storage on Android.
class SecureStravaSessionStore implements StravaSessionStore {
  SecureStravaSessionStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'strava_session';

  @override
  Future<StravaSession?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      return StravaSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      // Unreadable (e.g. an older format): treat as not connected.
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(StravaSession session) =>
      _storage.write(key: _key, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// In-memory store for tests.
class MemoryStravaSessionStore implements StravaSessionStore {
  MemoryStravaSessionStore([this.session]);

  StravaSession? session;

  @override
  Future<StravaSession?> read() async => session;

  @override
  Future<void> write(StravaSession session) async => this.session = session;

  @override
  Future<void> clear() async => session = null;
}

final stravaSessionStoreProvider = Provider<StravaSessionStore>(
  (ref) => SecureStravaSessionStore(),
);
