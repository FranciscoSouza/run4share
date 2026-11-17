import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/photos/strava_photos.dart';
import 'package:run4share/features/strava/strava_api.dart';
import 'package:run4share/features/strava/strava_config.dart';
import 'package:run4share/features/strava/strava_connection.dart';

@immutable
class SyncState {
  const SyncState({
    this.syncing = false,
    this.loadingOlder = false,
    this.failed = false,
    this.reachedEnd = false,
    this.lastSyncedAt,
  });

  /// Fetching the newest activities.
  final bool syncing;

  /// Fetching an older page.
  final bool loadingOlder;

  /// The last attempt failed (offline, Strava down, access revoked).
  final bool failed;

  /// Every activity down to the athlete's first is stored.
  final bool reachedEnd;
  final DateTime? lastSyncedAt;

  SyncState copyWith({
    bool? syncing,
    bool? loadingOlder,
    bool? failed,
    bool? reachedEnd,
    DateTime? lastSyncedAt,
  }) =>
      SyncState(
        syncing: syncing ?? this.syncing,
        loadingOlder: loadingOlder ?? this.loadingOlder,
        failed: failed ?? this.failed,
        reachedEnd: reachedEnd ?? this.reachedEnd,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );
}

/// Copies Strava activities into the local database.
///
/// The first sync stores the newest `pageSize`; later syncs fetch from the
/// newest page down until they meet activities already stored (at most
/// `maxPagesPerSync` pages). Older activities are fetched a page at a time
/// as the list is scrolled.
final stravaSyncProvider = NotifierProvider<StravaSync, SyncState>(
  StravaSync.new,
);

class StravaSync extends Notifier<SyncState> {
  static const pageSize = 30;
  static const maxPagesPerSync = 5;
  static const staleAfter = Duration(minutes: 15);

  static const _lastSyncedKey = 'strava.lastSyncedAt';
  static const _reachedEndKey = 'strava.reachedEnd';

  AppDatabase get _db => ref.read(appDatabaseProvider);
  ActivityRepository get _repo => ref.read(activityRepositoryProvider);
  StravaApi get _api => ref.read(stravaApiProvider);
  DateTime _now() => ref.read(clockProvider)();

  bool _loaded = false;

  @override
  SyncState build() => const SyncState();

  Future<void> _loadSaved() async {
    if (_loaded) return;
    _loaded = true;
    final last = await _db.readPreference(_lastSyncedKey);
    final end = await _db.readPreference(_reachedEndKey);
    state = state.copyWith(
      lastSyncedAt: last == null ? null : DateTime.tryParse(last),
      reachedEnd: end == 'true',
    );
  }

  Future<bool> _connected() async =>
      await ref.read(stravaConnectionProvider.future) != null;

  /// Syncs when Strava is connected and the last sync is older than
  /// [staleAfter] (or never happened).
  Future<void> syncIfStale() async {
    await _loadSaved();
    final last = state.lastSyncedAt;
    if (last != null && _now().difference(last) < staleAfter) return;
    await sync();
  }

  /// Fetches the newest activities.
  Future<void> sync() async {
    await _loadSaved();
    if (state.syncing || !await _connected()) return;
    state = state.copyWith(syncing: true, failed: false);
    try {
      final firstSync = await _repo.count(ActivitySource.strava) == 0;
      var reachedEnd = state.reachedEnd;
      for (var page = 1; page <= maxPagesPerSync; page++) {
        final batch = await _api.activities(page: page, perPage: pageSize);
        final known = await _repo.knownStravaIds(batch.map((a) => a.id));
        await _repo.upsertStrava(batch);
        if (batch.length < pageSize) {
          if (firstSync) reachedEnd = true;
          break;
        }
        if (firstSync || known.isNotEmpty) break;
      }
      final now = _now();
      await _db.writePreference(_lastSyncedKey, now.toIso8601String());
      await _db.writePreference(_reachedEndKey, '$reachedEnd');
      state = state.copyWith(
        syncing: false,
        lastSyncedAt: now,
        reachedEnd: reachedEnd,
      );
      // Photos follow in the background; the list doesn't wait for them.
      unawaited(fetchPhotoLists());
    } on Object catch (error, stack) {
      debugPrint('Strava sync failed: $error\n$stack');
      state = state.copyWith(syncing: false, failed: true);
    }
  }

  /// Fetches the page of activities just older than the oldest stored.
  Future<void> loadOlder() async {
    await _loadSaved();
    if (state.loadingOlder || state.syncing || state.reachedEnd) return;
    final oldest = await _repo.oldestStravaStart();
    if (oldest == null || !await _connected()) return;
    state = state.copyWith(loadingOlder: true, failed: false);
    try {
      final batch = await _api.activities(perPage: pageSize, before: oldest);
      await _repo.upsertStrava(batch);
      final reachedEnd = batch.length < pageSize;
      await _db.writePreference(_reachedEndKey, '$reachedEnd');
      state = state.copyWith(loadingOlder: false, reachedEnd: reachedEnd);
      unawaited(fetchPhotoLists());
    } on Object catch (error, stack) {
      debugPrint('Loading older Strava activities failed: $error\n$stack');
      state = state.copyWith(loadingOlder: false, failed: true);
    }
  }

  /// Fills in what the list doesn't have, for the stickers: calories and
  /// splits (detail), the time series for the charts (streams) and the shoe
  /// (gear, if the user allowed it). Each part is best effort; stickers
  /// needing a missing part simply aren't offered.
  Future<void> fetchDetails(Activity activity) async {
    if (activity.source != ActivitySource.strava) return;
    final session = await ref.read(stravaConnectionProvider.future);
    if (session == null) return;
    final id = int.tryParse(activity.sourceId ?? '');
    if (id == null) return;

    if (activity.calories == null || activity.splitsJson == null) {
      try {
        final detail = await _api.activity(id);
        if (detail.calories case final kcal? when kcal > 0) {
          await _repo.setCalories(activity.id, kcal);
        }
        if (detail.splitsMetric.isNotEmpty) {
          await _repo.setSplits(
            activity.id,
            metric: detail.splitsMetric,
            standard: detail.splitsStandard,
          );
        }
      } on Object catch (error) {
        debugPrint('Strava detail failed: $error');
      }
    }

    // Once per activity: an empty answer is stored too. On failure
    // (offline, rate limit) nothing is stored and the next visit retries.
    if (activity.streamsJson == null) {
      try {
        await _repo.setStreams(activity.id, await _api.streams(id));
      } on Object catch (error) {
        debugPrint('Strava streams failed: $error');
      }
    }

    final gearId = activity.gearId;
    final canReadGear =
        session.scopes?.contains(StravaConfig.gearScope) ?? false;
    if (gearId != null && canReadGear && await _repo.gearById(gearId) == null) {
      try {
        await _repo.saveGear(await _api.gear(gearId));
      } on Object catch (error) {
        debugPrint('Strava gear failed: $error');
      }
    }
  }

  /// Thumbnail size: enough for the cards, light to download.
  static const thumbnailSize = 600;

  /// After a sync: thumbnails for activities with photos, one request
  /// each, at most 10 per run (Strava's limits are shared by every user).
  Future<void> fetchPhotoLists() async {
    for (final activity in await _repo.missingPhotos()) {
      final id = int.tryParse(activity.sourceId ?? '');
      if (id == null) continue;
      try {
        final photos = await _api.photos(id, size: thumbnailSize);
        await _repo.setPhotos(
          activity.id,
          photos,
          count: activity.photoCount ?? photos.length,
        );
      } on Object catch (error) {
        debugPrint('Strava photos failed: $error');
        return;
      }
    }
  }

  /// Forgets everything synced, after Strava is disconnected.
  Future<void> reset() async {
    await _repo.deleteSource(ActivitySource.strava);
    await ref.read(stravaPhotoStoreProvider).clear();
    await _db.writePreference(_lastSyncedKey, null);
    await _db.writePreference(_reachedEndKey, null);
    state = const SyncState();
    _loaded = true;
  }
}
