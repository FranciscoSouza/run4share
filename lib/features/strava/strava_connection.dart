import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/features/activities/strava_sync.dart';
import 'package:run4share/features/strava/strava_auth.dart';
import 'package:run4share/features/strava/strava_models.dart';
import 'package:run4share/features/strava/strava_session_store.dart';

/// The Strava connection: null when not connected.
final stravaConnectionProvider =
    AsyncNotifierProvider<StravaConnection, StravaSession?>(
  StravaConnection.new,
);

class StravaConnection extends AsyncNotifier<StravaSession?> {
  Future<StravaSession>? _refreshing;

  StravaSessionStore get _store => ref.read(stravaSessionStoreProvider);
  StravaAuth get _auth => ref.read(stravaAuthProvider);

  @override
  Future<StravaSession?> build() => _store.read();

  /// Runs the OAuth flow. Throws [StravaAuthException] on failure and
  /// leaves the current state unchanged.
  Future<StravaSession> connect() async {
    final session = await _auth.connect();
    await _store.write(session);
    state = AsyncData(session);
    return session;
  }

  /// Revokes access on Strava and removes Strava activities from the
  /// phone, as Strava's API terms ask. Manual activities stay.
  Future<void> disconnect() async {
    final session = state.value;
    state = const AsyncData(null);
    await _store.clear();
    await ref.read(stravaSyncProvider.notifier).reset();
    if (session != null) unawaited(_auth.deauthorize(session.accessToken));
  }

  /// An access token valid for at least five more minutes, refreshing it
  /// first if needed. Concurrent callers share one refresh.
  Future<String> accessToken() async {
    final session = await future;
    if (session == null) throw StateError('Strava is not connected');
    if (!session.expiresSoon(ref.read(clockProvider)())) {
      return session.accessToken;
    }
    final refreshed = await (_refreshing ??= _refresh(session));
    return refreshed.accessToken;
  }

  Future<StravaSession> _refresh(StravaSession session) async {
    try {
      final refreshed = await _auth.refresh(session);
      await _store.write(refreshed);
      state = AsyncData(refreshed);
      return refreshed;
    } finally {
      _refreshing = null;
    }
  }
}
