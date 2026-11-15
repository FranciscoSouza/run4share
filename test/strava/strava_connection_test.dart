import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/features/strava/strava_api.dart';
import 'package:run4share/features/strava/strava_auth.dart';
import 'package:run4share/features/strava/strava_connection.dart';
import 'package:run4share/features/strava/strava_session_store.dart';

import '../helpers/pump_app.dart';
import 'fakes.dart';

void main() {
  late MemoryStravaSessionStore store;
  late ProviderContainer container;
  late DioAdapter adapter;

  setUp(() {
    store = MemoryStravaSessionStore();
    final (dio, mock) = mockDio();
    adapter = mock;
    container = ProviderContainer.test(
      overrides: [
        ...baseOverrides(store: store),
        dioProvider.overrideWithValue(dio),
        webAuthenticateProvider.overrideWithValue(fakeAuthenticate()),
        clockProvider.overrideWithValue(() => testNow),
      ],
    );
  });

  test('starts disconnected with an empty store', () async {
    expect(await container.read(stravaConnectionProvider.future), isNull);
  });

  test('connect stores the session; disconnect clears and revokes', () async {
    adapter
      ..onPost(
        'https://token.test/token',
        (server) => server.reply(200, tokenResponse()),
        data: {'code': 'abc123'},
      )
      ..onPost(
        'https://www.strava.com/oauth/deauthorize',
        (server) => server.reply(200, <String, dynamic>{}),
        data: {'access_token': 'access-1'},
      );
    final notifier = container.read(stravaConnectionProvider.notifier);
    await container.read(stravaConnectionProvider.future);

    await notifier.connect();
    expect(store.session?.athleteName, 'Francisco Souza');
    expect(container.read(stravaConnectionProvider).value, isNotNull);

    await notifier.disconnect();
    expect(store.session, isNull);
    expect(container.read(stravaConnectionProvider).value, isNull);
  });

  test('a fresh token is used as it is', () async {
    store.session = session();
    final token =
        await container.read(stravaConnectionProvider.notifier).accessToken();
    expect(token, 'access-1');
  });

  test('a token about to expire is refreshed once and stored', () async {
    store.session = session(expires: testNow.add(const Duration(minutes: 2)));
    adapter.onPost(
      'https://token.test/refresh',
      (server) => server.reply(
        200,
        tokenResponse(access: 'access-2', refresh: 'refresh-2'),
      ),
      data: {'refresh_token': 'refresh-1'},
    );
    final notifier = container.read(stravaConnectionProvider.notifier);

    final tokens = await Future.wait([
      notifier.accessToken(),
      notifier.accessToken(),
    ]);

    expect(tokens, ['access-2', 'access-2']);
    expect(store.session?.refreshToken, 'refresh-2');
  });

  test('activities are read with the bearer token', () async {
    store.session = session();
    adapter.onGet(
      'https://www.strava.com/api/v3/athlete/activities',
      (server) => server.reply(200, [
        activityJson(),
        activityJson(id: 2, name: 'Evening Ride', sportType: 'Ride'),
      ]),
      queryParameters: {'page': 1, 'per_page': 30},
      headers: {'Authorization': 'Bearer access-1'},
    );

    final activities = await container.read(stravaActivitiesProvider.future);

    expect(activities.map((a) => a.name), ['Lunch Run', 'Evening Ride']);
    expect(activities.first.startDateLocal.hour, 12);
    expect(activities.first.distance, 5020);
  });

  test('no activities are fetched while disconnected', () async {
    expect(await container.read(stravaActivitiesProvider.future), isEmpty);
  });
}
