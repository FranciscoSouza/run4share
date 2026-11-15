import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:run4share/features/strava/strava_auth.dart';
import 'package:run4share/features/strava/strava_models.dart';

/// 14 Nov 2026, 10:00 UTC.
final testNow = DateTime.utc(2026, 11, 14, 10);
int epoch(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;

const grantedRedirect =
    'run4share://localhost?state=&code=abc123&scope=read,activity:read_all';

/// A sign-in page that returns [redirect], or throws like a closed page.
WebAuthenticate fakeAuthenticate({
  String redirect = grantedRedirect,
  bool cancel = false,
  List<String>? openedUrls,
}) =>
    ({required url, required callbackUrlScheme}) async {
      openedUrls?.add(url);
      if (cancel) throw PlatformException(code: 'CANCELED');
      return redirect;
    };

Map<String, dynamic> tokenResponse({
  String access = 'access-1',
  String refresh = 'refresh-1',
  DateTime? expires,
}) =>
    {
      'access_token': access,
      'refresh_token': refresh,
      'expires_at': epoch(expires ?? testNow.add(const Duration(hours: 6))),
      'athlete': {'id': 42, 'firstname': 'Francisco', 'lastname': 'Souza'},
    };

StravaSession session({
  String access = 'access-1',
  DateTime? expires,
}) =>
    StravaSession(
      accessToken: access,
      refreshToken: 'refresh-1',
      expiresAt: epoch(expires ?? testNow.add(const Duration(hours: 6))),
      connectedAt: testNow,
      athleteId: 42,
      athleteName: 'Francisco Souza',
    );

Map<String, dynamic> activityJson({
  int id = 1,
  String name = 'Lunch Run',
  String sportType = 'Run',
  double distance = 5020,
  int movingTime = 1994,
}) =>
    {
      'id': id,
      'name': name,
      'sport_type': sportType,
      'start_date': '2026-11-12T11:31:00Z',
      'start_date_local': '2026-11-12T12:31:00Z',
      'distance': distance,
      'moving_time': movingTime,
      'elapsed_time': movingTime + 60,
      'average_speed': distance / movingTime,
      'total_elevation_gain': 12.0,
    };

(Dio, DioAdapter) mockDio() {
  final dio = Dio();
  final adapter = DioAdapter(dio: dio, matcher: const UrlRequestMatcher());
  return (dio, adapter);
}
