import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:run4share/app/material.dart';

/// Every icon the app uses, by its name in the Foundations artboard.
///
/// Lucide, as drawn in the design. Screens use these names, never
/// LucideIcons directly, so the set can change in one place.
abstract final class AppIcons {
  static const IconData gear = LucideIcons.settings;
  static const IconData back = LucideIcons.chevronLeft;
  static const IconData right = LucideIcons.chevronRight;
  static const IconData plus = LucideIcons.plus;
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData link = LucideIcons.link;
  static const IconData heart = LucideIcons.heart;
  static const IconData pulse = LucideIcons.activity;
  static const IconData grid = LucideIcons.layoutGrid;
  static const IconData star = LucideIcons.star;
  static const IconData ruler = LucideIcons.ruler;
  static const IconData globe = LucideIcons.globe;
  static const IconData image = LucideIcons.image;
  static const IconData sparkle = LucideIcons.sparkle;
  static const IconData invite = LucideIcons.userPlus;
  static const IconData shield = LucideIcons.shield;
  static const IconData run = LucideIcons.footprints;
  static const IconData bike = LucideIcons.bike;
  static const IconData hike = LucideIcons.mountain;
}
