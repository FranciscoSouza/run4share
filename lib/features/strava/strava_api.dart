import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/features/lab/lab.dart';
import 'package:run4share/features/stickers/activity_streams.dart';
import 'package:run4share/features/strava/strava_auth.dart';
import 'package:run4share/features/strava/strava_connection.dart';
import 'package:run4share/features/strava/strava_demo.dart';
import 'package:run4share/features/strava/strava_models.dart';

/// Strava REST API v3, read-only.
class StravaApi {
  StravaApi({required Dio dio, required Future<String> Function() token})
      : _dio = dio,
        _token = token;

  final Dio _dio;
  final Future<String> Function() _token;

  static const _base = 'https://www.strava.com/api/v3';

  /// The athlete's activities, newest first; only those that started
  /// before [before] when given.
  Future<List<StravaActivity>> activities({
    required int perPage,
    int page = 1,
    DateTime? before,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '$_base/athlete/activities',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (before != null) 'before': before.millisecondsSinceEpoch ~/ 1000,
      },
      options: Options(headers: {'Authorization': 'Bearer ${await _token()}'}),
    );
    return [
      for (final item in response.data ?? const <dynamic>[])
        StravaActivity.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// A shoe or bike. Needs the profile:read_all permission.
  Future<StravaGear> gear(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_base/gear/$id',
      options: Options(headers: {'Authorization': 'Bearer ${await _token()}'}),
    );
    return StravaGear.fromJson(response.data!);
  }

  /// The activity's time series for the charts, in one request. Strava
  /// leaves out streams it doesn't have (no heart-rate strap, no GPS), so
  /// any of them may be missing; `time` is the axis of the others.
  Future<ActivityStreams> streams(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_base/activities/$id/streams',
      queryParameters: {
        'keys': 'time,distance,altitude,heartrate,velocity_smooth,moving',
        'key_by_type': true,
      },
      options: Options(headers: {'Authorization': 'Bearer ${await _token()}'}),
    );
    return ActivityStreams.fromStrava(response.data ?? const {});
  }

  /// One activity in detail (adds calories).
  Future<StravaActivity> activity(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_base/activities/$id',
      options: Options(headers: {'Authorization': 'Bearer ${await _token()}'}),
    );
    return StravaActivity.fromJson(response.data!);
  }
}

/// Real Strava, or sample activities when Laboratory says so.
final stravaApiProvider = Provider<StravaApi>(
  (ref) => ref.watch(stravaDemoProvider)
      ? DemoStravaApi(clock: ref.watch(clockProvider))
      : StravaApi(
          dio: ref.watch(dioProvider),
          token: () =>
              ref.read(stravaConnectionProvider.notifier).accessToken(),
        ),
);
