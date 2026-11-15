import 'package:flutter/foundation.dart';
import 'package:run4share/app/material.dart';

/// Release builds: what replaces a widget that failed to build. Debug and
/// profile builds keep Flutter's red error box, which helps fixing it.
///
/// It may be built outside the app's theme and localisations, so it uses
/// neither; just a calm grey box with an icon.
Widget releaseErrorView(FlutterErrorDetails details) => const _BrokenPart();

class _BrokenPart extends StatelessWidget {
  const _BrokenPart();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x14000000),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            Icons.error_outline,
            color: Color(0xFF6B6762),
            semanticLabel: 'Something went wrong here',
          ),
        ),
      ),
    );
  }
}

/// Logs errors nothing else caught instead of letting them pass silently.
/// No reporting service: run4share sends nothing anywhere (see the privacy
/// policy); Google Play's crash reports cover hard crashes.
void installErrorHandlers() {
  if (kReleaseMode) ErrorWidget.builder = releaseErrorView;
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };
}
