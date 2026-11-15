import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/features/strava/strava_auth.dart';
import 'package:run4share/features/strava/strava_connection.dart';
import 'package:run4share/features/strava/strava_models.dart';

/// Strava REST API v3, read-only.
class StravaApi {
  StravaApi({required Dio dio, required Future<String> Function() token})
      : _dio = dio,
        _token = token;

  final Dio _dio;
  final Future<String> Function() _token;

  static const _base = 'https://www.strava.com/api/v3';

  /// The athlete's activities, newest first.
  Future<List<StravaActivity>> activities({
    int page = 1,
    int perPage = 30,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '$_base/athlete/activities',
      queryParameters: {'page': page, 'per_page': perPage},
      options: Options(headers: {'Authorization': 'Bearer ${await _token()}'}),
    );
    return [
      for (final item in response.data ?? const [])
        StravaActivity.fromJson(item as Map<String, dynamic>),
    ];
  }
}

final stravaApiProvider = Provider<StravaApi>(
  (ref) => StravaApi(
    dio: ref.watch(dioProvider),
    token: () => ref.read(stravaConnectionProvider.notifier).accessToken(),
  ),
);

/// Latest Strava activities, refetched when the connected athlete changes.
/// Empty when Strava is not connected.
final stravaActivitiesProvider = FutureProvider<List<StravaActivity>>(
  (ref) async {
    final athlete = await ref.watch(
      stravaConnectionProvider.selectAsync(
        (session) => session == null ? null : (session.athleteId ?? 0),
      ),
    );
    if (athlete == null) return const [];
    return await ref.read(stravaApiProvider).activities();
  },
  retry: (count, error) => null,
);
