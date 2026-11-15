import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build-time Strava settings, passed with `--dart-define-from-file`
/// (see `config/strava.example.json`). Neither value is secret: the client
/// secret lives only in the token-exchange worker.
class StravaConfig {
  const StravaConfig({required this.clientId, required this.tokenUrl});

  const StravaConfig.fromEnvironment()
      : clientId = const String.fromEnvironment('STRAVA_CLIENT_ID'),
        tokenUrl = const String.fromEnvironment('STRAVA_TOKEN_URL');

  /// Public client ID of the Strava API application.
  final String clientId;

  /// Base URL of the token-exchange worker, without a trailing slash.
  final String tokenUrl;

  bool get isConfigured => clientId.isNotEmpty && tokenUrl.isNotEmpty;

  /// Strava sends the user back here. `localhost` is always an allowed
  /// callback domain, so the Strava app settings need no change for it.
  static const callbackScheme = 'run4share';
  static const redirectUri = '$callbackScheme://localhost';

  /// Profile (for the name) and all activities, private ones included.
  static const scope = 'read,activity:read_all';
}

final stravaConfigProvider = Provider<StravaConfig>(
  (ref) => const StravaConfig.fromEnvironment(),
);
