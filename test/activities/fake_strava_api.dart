import 'package:dio/dio.dart';
import 'package:run4share/features/stickers/activity_streams.dart';
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

  /// Detail calls, by Strava ID.
  final detailCalls = <int>[];

  @override
  Future<StravaActivity> activity(int id) async {
    detailCalls.add(id);
    return all.firstWhere((a) => a.id == id).copyWith(
      calories: 321,
      splitsMetric: const [
        StravaSplit(distance: 1000, movingTime: 300),
        StravaSplit(distance: 1000, movingTime: 290),
      ],
    );
  }

  final gearCalls = <String>[];

  @override
  Future<StravaGear> gear(String id) async {
    gearCalls.add(id);
    return StravaGear(id: id, name: 'Pegasus 41', distance: 412300);
  }

  final streamsCalls = <int>[];

  /// Strava's answer for every activity: 500 samples, one every 4 s.
  Map<String, dynamic> streamsJson = {
    'time': {
      'data': [for (var i = 0; i < 500; i++) i * 4],
    },
    'distance': {
      'data': [for (var i = 0; i < 500; i++) i * 10.0],
    },
    'altitude': {
      'data': [for (var i = 0; i < 500; i++) 40.0 + i % 9],
    },
    'heartrate': {
      'data': [for (var i = 0; i < 500; i++) 140 + i % 20],
    },
    'velocity_smooth': {
      'data': [for (var i = 0; i < 500; i++) 2.5],
    },
    'moving': {
      'data': [for (var i = 0; i < 500; i++) true],
    },
  };

  @override
  Future<ActivityStreams> streams(int id) async {
    streamsCalls.add(id);
    return ActivityStreams.fromStrava(streamsJson);
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
        polyline: '_p~iF~ps|U_ulLnnqC',
        gearId: 'g1',
      ),
  ];
}
