import 'package:freezed_annotation/freezed_annotation.dart';

part 'strava_models.freezed.dart';
part 'strava_models.g.dart';

/// A connected Strava account: tokens plus what the UI shows about it.
/// Stored as JSON in secure storage.
@freezed
abstract class StravaSession with _$StravaSession {
  const factory StravaSession({
    required String accessToken,
    required String refreshToken,

    /// When [accessToken] expires, in seconds since the epoch (Strava's
    /// `expires_at`).
    required int expiresAt,
    required DateTime connectedAt,
    int? athleteId,
    String? athleteName,
  }) = _StravaSession;

  const StravaSession._();

  factory StravaSession.fromJson(Map<String, dynamic> json) =>
      _$StravaSessionFromJson(json);

  /// True when the access token expires within [margin] of [now].
  bool expiresSoon(
    DateTime now, {
    Duration margin = const Duration(minutes: 5),
  }) =>
      DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
          .isBefore(now.add(margin));
}

/// The fields of Strava's SummaryActivity that run4share uses.
@freezed
abstract class StravaActivity with _$StravaActivity {
  const factory StravaActivity({
    required int id,
    required String name,
    required String sportType,

    /// When it started, in UTC.
    required DateTime startDate,

    /// Wall-clock start time where the activity happened. Strava marks it
    /// with a Z, but it is not UTC: show its fields as they are and never
    /// call toLocal() on it.
    required DateTime startDateLocal,

    /// Metres.
    @Default(0) double distance,

    /// Seconds.
    @Default(0) int movingTime,
    @Default(0) int elapsedTime,

    /// Metres per second.
    double? averageSpeed,
    double? averageHeartrate,
    double? totalElevationGain,

    /// Only in Strava's single-activity detail, not in the list.
    double? calories,

    /// Personal records Strava found in it.
    int? prCount,

    /// Strava's workout type: 1 is a run race, 11 a ride race.
    int? workoutType,
  }) = _StravaActivity;

  const StravaActivity._();

  factory StravaActivity.fromJson(Map<String, dynamic> json) =>
      _$StravaActivityFromJson(json);

  /// Marked as a race on Strava.
  bool get isRace => workoutType == 1 || workoutType == 11;
}
