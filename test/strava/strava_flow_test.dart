import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/strava/connect_strava_screen.dart';
import 'package:run4share/features/strava/strava_auth.dart';
import 'package:run4share/features/strava/strava_config.dart';
import 'package:run4share/features/strava/strava_session_store.dart';

import '../helpers/pump_app.dart';
import 'fakes.dart';

void main() {
  testWidgets('connect from Home, see activities, disconnect in Settings', (
    tester,
  ) async {
    final store = MemoryStravaSessionStore();
    final (dio, adapter) = mockDio();
    adapter
      ..onPost(
        'https://token.test/token',
        (server) => server.reply(200, tokenResponse()),
        data: {'code': 'abc123'},
      )
      ..onGet(
        'https://www.strava.com/api/v3/athlete/activities',
        (server) => server.reply(200, [
          activityJson(),
          activityJson(id: 2, name: 'Evening Ride', sportType: 'Ride'),
        ]),
        queryParameters: {'page': 1, 'per_page': 30},
      )
      ..onPost(
        'https://www.strava.com/oauth/deauthorize',
        (server) => server.reply(200, <String, dynamic>{}),
        data: {'access_token': 'access-1'},
      );

    await tester.pumpApp(
      overrides: [
        ...baseOverrides(store: store),
        dioProvider.overrideWithValue(dio),
        webAuthenticateProvider.overrideWithValue(fakeAuthenticate()),
        clockProvider.overrideWithValue(() => testNow),
      ],
    );

    await tester.tap(find.text('Connect Strava'));
    await tester.pumpAndSettle();
    expect(find.byType(ConnectStravaScreen), findsOneWidget);
    expect(find.text('Never posts for you'), findsOneWidget);

    await tester.tap(find.text('Continue to Strava'));
    await tester.pumpAndSettle();

    expect(find.byType(ConnectStravaScreen), findsNothing);
    expect(find.text('Connected as Francisco Souza'), findsOneWidget);
    expect(find.text('Connect Strava'), findsNothing);
    expect(find.text('Your activities'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Evening Ride'),
      200,
      scrollable: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    );
    expect(find.text('Lunch Run'), findsOneWidget);
    expect(find.text('SPEED'), findsOneWidget);
    expect(store.session?.accessToken, 'access-1');

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Connected as Francisco Souza'), findsWidgets);

    await tester.tap(find.text('Disconnect'));
    await tester.pumpAndSettle();
    expect(find.text('Disconnected from Strava'), findsOneWidget);
    expect(find.text('Not connected'), findsNWidgets(2));
    expect(store.session, isNull);
  });

  testWidgets('a build without Strava settings says so', (tester) async {
    await tester.pumpApp(
      overrides: baseOverrides(
        config: const StravaConfig(clientId: '', tokenUrl: ''),
      ),
    );

    await tester.tap(find.text('Connect Strava'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to Strava'));
    await tester.pumpAndSettle();

    expect(find.text('Strava isn’t set up in this build.'), findsOneWidget);
    expect(find.byType(ConnectStravaScreen), findsOneWidget);
  });
}
