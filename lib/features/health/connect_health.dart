import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/health/health_connect_sync.dart';
import 'package:run4share/features/health/health_hub.dart';
import 'package:run4share/l10n/l10n.dart';

/// Connects Health Connect, explaining in a snack bar what went wrong
/// (not installed or outdated: with an Install action).
Future<void> connectHealthConnect(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  void say(String text, {SnackBarAction? action}) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), action: action));
  final install = SnackBarAction(
    label: l10n.hubInstall,
    onPressed: () => unawaited(ref.read(healthHubProvider).install()),
  );
  try {
    await ref.read(healthConnectProvider.notifier).connect();
    say(l10n.hubConnected);
  } on HubException catch (e) {
    switch (e.failure) {
      case HubFailure.notInstalled:
        say(l10n.hubNotInstalled, action: install);
      case HubFailure.updateRequired:
        say(l10n.hubUpdate, action: install);
      case HubFailure.denied:
        say(l10n.hubDenied);
    }
  }
}
