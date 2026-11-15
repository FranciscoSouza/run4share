import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/features/lab/lab.dart';
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
      for (final item in response.data ?? const [])
        StravaActivity.fromJson(item as Map<String, dynamic>),
    ];
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
