import 'package:run4share/features/strava/strava_auth.dart';
import 'package:run4share/l10n/l10n.dart';

/// What to tell the user when connecting fails; null when there is nothing
/// to say (they closed the page themselves).
String? stravaFailureMessage(AppLocalizations l10n, Object error) {
  final failure =
      error is StravaAuthException ? error.failure : StravaAuthFailure.network;
  return switch (failure) {
    StravaAuthFailure.cancelled => null,
    StravaAuthFailure.denied => l10n.stravaErrorDenied,
    StravaAuthFailure.missingScope => l10n.stravaErrorScope,
    StravaAuthFailure.network => l10n.stravaErrorNetwork,
    StravaAuthFailure.notConfigured => l10n.stravaErrorNotConfigured,
  };
}
