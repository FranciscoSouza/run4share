import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/health/health_hub.dart';

enum HubFailure { notInstalled, updateRequired, denied }

class HubException implements Exception {
  const HubException(this.failure);

  final HubFailure failure;

  @override
  String toString() => 'HubException($failure)';
}

@immutable
class HubState {
  const HubState({
    this.connected = false,
    this.syncing = false,
    this.failed = false,
    this.lastSyncedAt,
  });

  final bool connected;
  final bool syncing;
  final bool failed;
  final DateTime? lastSyncedAt;

  HubState copyWith({
    bool? connected,
    bool? syncing,
    bool? failed,
    DateTime? lastSyncedAt,
  }) =>
      HubState(
        connected: connected ?? this.connected,
        syncing: syncing ?? this.syncing,
        failed: failed ?? this.failed,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );
}

/// Health Connect: connecting, copying workouts into the local database,
/// disconnecting.
final healthConnectProvider = NotifierProvider<HealthConnectSync, HubState>(
  HealthConnectSync.new,
);

/// Whether Health Connect was connected, read in main() before the first
/// frame.
final healthConnectAtLaunchProvider = Provider<bool>((ref) => false);

class HealthConnectSync extends Notifier<HubState> {
  static const staleAfter = Duration(minutes: 15);

  /// First sync without past-data access: what Health Connect allows.
  static const recentWindow = Duration(days: 30);

  /// First sync with past-data access.
  static const historyWindow = Duration(days: 365);

  /// Later syncs re-read a little before the last one, for late uploads.
  static const overlap = Duration(days: 2);

  static const _connectedKey = 'healthConnect.connected';
  static const _lastSyncedKey = 'healthConnect.lastSyncedAt';

  HealthHub get _hub => ref.read(healthHubProvider);
  AppDatabase get _db => ref.read(appDatabaseProvider);
  DateTime _now() => ref.read(clockProvider)();

  @override
  HubState build() {
    unawaited(Future.microtask(_loadLastSync));
    return HubState(connected: ref.read(healthConnectAtLaunchProvider));
  }

  Future<void> _loadLastSync() async {
    final last = DateTime.tryParse(
      await _db.readPreference(_lastSyncedKey) ?? '',
    );
    if (last != null) state = state.copyWith(lastSyncedAt: last);
  }

  /// Asks for access; throws [HubException] when Health Connect is missing
  /// or the user refuses. Syncs on success.
  Future<void> connect() async {
    switch (await _hub.status()) {
      case HubStatus.unavailable:
        throw const HubException(HubFailure.notInstalled);
      case HubStatus.updateRequired:
        throw const HubException(HubFailure.updateRequired);
      case HubStatus.available:
        break;
    }
    if (!await _hub.requestAccess()) {
      throw const HubException(HubFailure.denied);
    }
    await _db.writePreference(_connectedKey, 'true');
    state = state.copyWith(connected: true, failed: false);
    await sync();
  }

  Future<void> syncIfStale() async {
    final last = state.lastSyncedAt;
    if (last != null && _now().difference(last) < staleAfter) return;
    await sync();
  }

  Future<void> sync() async {
    if (!state.connected || state.syncing) return;
    state = state.copyWith(syncing: true, failed: false);
    try {
      // Revoked in the phone's settings: treat as disconnected.
      if (!await _hub.hasAccess()) {
        await _forget(revoke: false);
        return;
      }
      final now = _now();
      final last = state.lastSyncedAt;
      final from = last != null
          ? last.subtract(overlap)
          : now.subtract(
              await _hub.hasHistory() ? historyWindow : recentWindow,
            );
      final workouts = await _hub.workouts(from, now);
      await ref.read(activityRepositoryProvider).upsertHub(workouts);
      await _db.writePreference(_lastSyncedKey, now.toIso8601String());
      state = state.copyWith(syncing: false, lastSyncedAt: now);
    } on Object catch (error, stack) {
      debugPrint('Health Connect sync failed: $error\n$stack');
      state = state.copyWith(syncing: false, failed: true);
    }
  }

  /// Removes Health Connect's workouts from run4share and gives the
  /// permissions back. Manual and Strava activities stay.
  Future<void> disconnect() => _forget(revoke: true);

  Future<void> _forget({required bool revoke}) async {
    if (revoke) await _hub.revoke();
    await ref
        .read(activityRepositoryProvider)
        .deleteSource(ActivitySource.healthConnect);
    await _db.writePreference(_connectedKey, null);
    await _db.writePreference(_lastSyncedKey, null);
    state = const HubState();
  }

  static Future<bool> wasConnected(AppDatabase db) async =>
      await db.readPreference(_connectedKey) == 'true';
}
