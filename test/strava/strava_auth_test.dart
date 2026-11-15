import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:run4share/features/strava/strava_auth.dart';
import 'package:run4share/features/strava/strava_config.dart';

import '../helpers/pump_app.dart';
import 'fakes.dart';

void main() {
  group('StravaAuth', () {
    StravaAuth auth({
      WebAuthenticate? authenticate,
      StravaConfig config = testStravaConfig,
      void Function(DioAdapter adapter)? routes,
    }) {
      final (dio, adapter) = mockDio();
      routes?.call(adapter);
      return StravaAuth(
        config: config,
        dio: dio,
        authenticate: authenticate ?? fakeAuthenticate(),
        clock: () => testNow,
      );
    }

    test('asks Strava for read and activity:read_all, back to the app', () {
      final uri = auth().authorizeUri();

      expect(uri.host, 'www.strava.com');
      expect(uri.path, '/oauth/mobile/authorize');
      expect(uri.queryParameters, {
        'client_id': '12345',
        'redirect_uri': 'run4share://localhost',
        'response_type': 'code',
        'approval_prompt': 'auto',
        'scope': 'read,activity:read_all',
      });
    });

    test('swaps the code through the worker and keeps the name', () async {
      final opened = <String>[];
      final session = await auth(
        authenticate: fakeAuthenticate(openedUrls: opened),
        routes: (adapter) => adapter.onPost(
          'https://token.test/token',
          (server) => server.reply(200, tokenResponse()),
          data: {'code': 'abc123'},
        ),
      ).connect();

      expect(opened.single, startsWith('https://www.strava.com/oauth/'));
      expect(session.accessToken, 'access-1');
      expect(session.refreshToken, 'refresh-1');
      expect(session.athleteId, 42);
      expect(session.athleteName, 'Francisco Souza');
      expect(session.connectedAt, testNow);
    });

    Future<StravaAuthFailure> failureOf(Future<void> future) async {
      try {
        await future;
      } on StravaAuthException catch (e) {
        return e.failure;
      }
      fail('expected a StravaAuthException');
    }

    test('reports a closed page as cancelled', () async {
      expect(
        await failureOf(
          auth(authenticate: fakeAuthenticate(cancel: true)).connect(),
        ),
        StravaAuthFailure.cancelled,
      );
    });

    test('reports Cancel on the consent page as denied', () async {
      expect(
        await failureOf(
          auth(
            authenticate: fakeAuthenticate(
              redirect: 'run4share://localhost?state=&error=access_denied',
            ),
          ).connect(),
        ),
        StravaAuthFailure.denied,
      );
    });

    test('rejects a grant without activity access', () async {
      expect(
        await failureOf(
          auth(
            authenticate: fakeAuthenticate(
              redirect: 'run4share://localhost?code=abc123&scope=read',
            ),
          ).connect(),
        ),
        StravaAuthFailure.missingScope,
      );
    });

    test('reports a worker failure as a network problem', () async {
      expect(
        await failureOf(
          auth(
            routes: (adapter) => adapter.onPost(
              'https://token.test/token',
              (server) => server.reply(502, {'error': 'strava_error'}),
              data: {'code': 'abc123'},
            ),
          ).connect(),
        ),
        StravaAuthFailure.network,
      );
    });

    test('refuses to start without client ID or worker URL', () async {
      expect(
        await failureOf(
          auth(
            config: const StravaConfig(clientId: '', tokenUrl: ''),
          ).connect(),
        ),
        StravaAuthFailure.notConfigured,
      );
    });

    test('refresh replaces both tokens', () async {
      final refreshed = await auth(
        routes: (adapter) => adapter.onPost(
          'https://token.test/refresh',
          (server) => server.reply(
            200,
            tokenResponse(access: 'access-2', refresh: 'refresh-2'),
          ),
          data: {'refresh_token': 'refresh-1'},
        ),
      ).refresh(session());

      expect(refreshed.accessToken, 'access-2');
      expect(refreshed.refreshToken, 'refresh-2');
      expect(refreshed.athleteName, 'Francisco Souza');
    });
  });
}
