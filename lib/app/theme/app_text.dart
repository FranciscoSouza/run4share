import 'package:flutter/painting.dart';

/// Type scale from the Foundations artboard.
///
/// Barlow Condensed for display (titles, numbers), Inter for UI text.
/// Colours are left out so each style inherits from the theme.
abstract final class AppText {
  static const display = 'BarlowCondensed';
  static const ui = 'Inter';

  /// Sticker value. The design uses 30–84; 30 is the in-card size.
  static const stickerValue = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w700,
    fontSize: 30,
    height: 1,
  );

  /// Screen title, e.g. "Unlock everything, once".
  static const screenTitle = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 1.1,
  );

  /// Section heading, e.g. "Your activities".
  static const section = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    height: 1.15,
  );

  /// App bar title and card titles, e.g. "Lunch Run".
  static const barTitle = TextStyle(
    fontFamily: ui,
    fontWeight: FontWeight.w600,
    fontSize: 17,
    height: 1.25,
  );

  static const body = TextStyle(
    fontFamily: ui,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.4,
  );

  /// Secondary line, e.g. "Strava · Thu 12 Nov · 12:31".
  static const secondary = TextStyle(
    fontFamily: ui,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.35,
  );

  /// Label, 11 px caps, e.g. "DISTANCE".
  static const label = TextStyle(
    fontFamily: ui,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 1.1,
    height: 1.2,
  );

  static const button = TextStyle(
    fontFamily: ui,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.2,
  );

  /// Wordmark "run4share".
  static const logo = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
    fontSize: 26,
    height: 1,
    letterSpacing: -0.3,
  );
}
