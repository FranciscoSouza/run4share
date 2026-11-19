import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

/// What run4share asks of the phone outside itself, behind an interface so
/// tests can fake it.
abstract interface class SystemActions {
  /// Opens the phone's per-app language screen. False when the phone has
  /// none (Android 12 and older), so the app shows its own list.
  Future<bool> openAppLanguage();

  /// Opens [uri] in the browser or the app that handles it.
  Future<void> openLink(Uri uri);

  /// Opens a web page in an in-app browser tab (Chrome Custom Tab, Safari
  /// view), so it feels part of the app; e.g. the privacy policy.
  Future<void> openPage(Uri uri);

  /// The store's in-app rating dialog, or the store page if unavailable.
  Future<void> requestReview();

  /// The app's store page.
  Future<void> openStoreListing();
}

class DeviceSystemActions implements SystemActions {
  static const _channel = MethodChannel('run4share/system');

  @override
  Future<bool> openAppLanguage() async {
    if (Platform.isIOS) {
      // iOS lists the app's language in its own Settings page.
      return await launchUrl(Uri.parse('app-settings:'));
    }
    try {
      return await _channel.invokeMethod<bool>('openAppLanguageSettings') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> openLink(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Future<void> openPage(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Future<void> requestReview() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    } else {
      await review.openStoreListing();
    }
  }

  @override
  Future<void> openStoreListing() => InAppReview.instance.openStoreListing();
}

final systemActionsProvider = Provider<SystemActions>(
  (ref) => DeviceSystemActions(),
);
