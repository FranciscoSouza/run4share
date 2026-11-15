import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/data/database.dart';

/// When the "Enjoying run4share?" sheet may appear on its own: from the
/// [minSaves]th image saved to Photos, at most every [gap], and never
/// again once the user rated or said "Not now" [maxNotNow] times.
class RatePrompt {
  RatePrompt(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  static const minSaves = 3;
  static const gap = Duration(days: 90);
  static const maxNotNow = 2;

  static const _saves = 'rate.saves';
  static const _done = 'rate.done';
  static const _notNow = 'rate.notNow';
  static const _lastShown = 'rate.lastShown';

  Future<int> _int(String key) async =>
      int.tryParse(await _db.readPreference(key) ?? '') ?? 0;

  /// Counts one more image saved to Photos.
  Future<void> recordSave() async {
    final saves = await _int(_saves);
    await _db.writePreference(_saves, '${saves + 1}');
  }

  /// Whether to show the sheet now; marks it shown if so.
  Future<bool> shouldAsk() async {
    if (await _db.readPreference(_done) == 'true') return false;
    if (await _int(_saves) < minSaves) return false;
    if (await _int(_notNow) >= maxNotNow) return false;
    final last = DateTime.tryParse(await _db.readPreference(_lastShown) ?? '');
    final now = _clock();
    if (last != null && now.difference(last) < gap) return false;
    await _db.writePreference(_lastShown, now.toIso8601String());
    return true;
  }

  /// Rated, or chose to send feedback: don't ask again.
  Future<void> answered() => _db.writePreference(_done, 'true');

  Future<void> notNow() async {
    final count = await _int(_notNow);
    await _db.writePreference(_notNow, '${count + 1}');
  }
}

final ratePromptProvider = Provider<RatePrompt>(
  (ref) => RatePrompt(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);
