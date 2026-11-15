import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/features/strava/strava_config.dart';
import 'package:run4share/features/strava/strava_models.dart';

enum StravaAuthFailure {
  /// The user closed the sign-in page. Not an error to show.
  cancelled,

  /// The user pressed Cancel on Strava's consent page.
  denied,

  /// The user unticked activity access on Strava's consent page.
  missingScope,

  /// Strava or the worker could not be reached or refused the exchange.
  network,

  /// The build has no client ID or worker URL.
  notConfigured,
}

class StravaAuthException implements Exception {
  const StravaAuthException(this.failure, [this.cause]);

  final StravaAuthFailure failure;
  final Object? cause;

  @override
  String toString() => 'StravaAuthException($failure, $cause)';
}

/// Opens a sign-in page and returns the URL it redirected to.
typedef WebAuthenticate = Future<String> Function({
  required String url,
  required String callbackUrlScheme,
});

/// OAuth with Strava: consent in the browser (or the Strava app), then the
/// code is swapped for tokens by the worker, which holds the client secret.
class StravaAuth {
  StravaAuth({
    required this.config,
    required Dio dio,
    required WebAuthenticate authenticate,
    required Clock clock,
  })  : _dio = dio,
        _authenticate = authenticate,
        _clock = clock;

  final StravaConfig config;
  final Dio _dio;
  final WebAuthenticate _authenticate;
  final Clock _clock;

  Uri authorizeUri() => Uri.https('www.strava.com', '/oauth/mobile/authorize', {
        'client_id': config.clientId,
        'redirect_uri': StravaConfig.redirectUri,
        'response_type': 'code',
        'approval_prompt': 'auto',
        'scope': StravaConfig.scope,
      });

  Future<StravaSession> connect() async {
    if (!config.isConfigured) {
      throw const StravaAuthException(StravaAuthFailure.notConfigured);
    }

    final String result;
    try {
      result = await _authenticate(
        url: authorizeUri().toString(),
        callbackUrlScheme: StravaConfig.callbackScheme,
      );
    } on PlatformException catch (e) {
      throw StravaAuthException(StravaAuthFailure.cancelled, e);
    }

    final params = Uri.parse(result).queryParameters;
    final code = params['code'];
    if (params['error'] != null || code == null || code.isEmpty) {
      throw StravaAuthException(StravaAuthFailure.denied, params['error']);
    }
    final granted = (params['scope'] ?? '').split(',');
    if (!granted.contains('activity:read_all') &&
        !granted.contains('activity:read')) {
      throw const StravaAuthException(StravaAuthFailure.missingScope);
    }

    final data = await _post('/token', {'code': code});
    final athlete = data['athlete'] as Map<String, dynamic>?;
    final name = [athlete?['firstname'], athlete?['lastname']]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
    return StravaSession(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      expiresAt: (data['expires_at'] as num).toInt(),
      connectedAt: _clock(),
      athleteId: (athlete?['id'] as num?)?.toInt(),
      athleteName: name.isEmpty ? null : name,
    );
  }

  /// New tokens for [session]; Strava may also rotate the refresh token.
  Future<StravaSession> refresh(StravaSession session) async {
    final data = await _post('/refresh', {
      'refresh_token': session.refreshToken,
    });
    return session.copyWith(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      expiresAt: (data['expires_at'] as num).toInt(),
    );
  }

  /// Revokes run4share's access on Strava. Best effort: the local session
  /// is removed whatever happens here.
  Future<void> deauthorize(String accessToken) async {
    try {
      await _dio.post<void>(
        'https://www.strava.com/oauth/deauthorize',
        data: {'access_token': accessToken},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException {
      // Already revoked or offline; nothing more to do.
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${config.tokenUrl}$path',
        data: body,
      );
      final data = response.data;
      if (data == null || data['access_token'] is! String) {
        throw const StravaAuthException(StravaAuthFailure.network);
      }
      return data;
    } on DioException catch (e) {
      throw StravaAuthException(StravaAuthFailure.network, e);
    }
  }
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

final webAuthenticateProvider = Provider<WebAuthenticate>(
  (ref) => FlutterWebAuth2.authenticate,
);

final stravaAuthProvider = Provider<StravaAuth>(
  (ref) => StravaAuth(
    config: ref.watch(stravaConfigProvider),
    dio: ref.watch(dioProvider),
    authenticate: ref.watch(webAuthenticateProvider),
    clock: ref.watch(clockProvider),
  ),
);
