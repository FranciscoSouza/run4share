import 'package:dio/dio.dart';
import 'package:run4share/features/strava/strava_api.dart';
import 'package:run4share/features/strava/strava_models.dart';

/// Serves activities from a list, newest first, and records each call.
class FakeStravaApi extends StravaApi {
  FakeStravaApi(this.all) : super(dio: Dio(), token: () async => 'token');

  List<StravaActivity> all;
  final calls = <({int page, DateTime? before})>[];

  @override
  Future<List<StravaActivity>> activities({
    required int perPage,
    int page = 1,
    DateTime? before,
  }) async {
    calls.add((page: page, before: before));
    final matching = before == null
        ? all
        : all.where((a) => a.startDate.isBefore(before)).toList();
    return matching.skip((page - 1) * perPage).take(perPage).toList();
  }
}

/// [count] runs, one a day, newest first, IDs from [firstId] upwards.
List<StravaActivity> runs(int count, {int firstId = 1, DateTime? newest}) {
  final start = newest ?? DateTime.utc(2026, 11, 14, 7);
  return [
    for (var i = 0; i < count; i++)
      StravaActivity(
        id: firstId + i,
        name: 'Run ${firstId + i}',
        sportType: 'Run',
        startDate: start.subtract(Duration(days: i)),
        startDateLocal: start.subtract(Duration(days: i)),
        distance: 5000,
        movingTime: 1800,
      ),
  ];
}
