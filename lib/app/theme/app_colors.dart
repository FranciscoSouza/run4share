import 'package:flutter/painting.dart';

/// Colour tokens from the final design's Foundations artboard.
abstract final class AppColors {
  // Primary: actions and selection. Brand blue is primary50.
  static const primary30 = Color(0xFF004A75);
  static const primary40 = Color(0xFF005F96);
  static const primary50 = Color(0xFF0077BD);
  static const primary60 = Color(0xFF2E92CE);
  static const primary70 = Color(0xFF5FACDB);
  static const primary95 = Color(0xFFE1F0F9);

  // Neutral: surfaces and text (warm greys).
  static const neutral0 = Color(0xFF0D0C0A);
  static const neutral10 = Color(0xFF262421);
  static const neutral20 = Color(0xFF3D3A36);
  static const neutral40 = Color(0xFF6B6762);
  static const neutral70 = Color(0xFFA9A49E);
  static const neutral80 = Color(0xFFC9C4BD);
  static const neutral90 = Color(0xFFE5E0D8);
  static const neutral95 = Color(0xFFF7F1E8);
  static const neutral99 = Color(0xFFFEFAF6);
  static const neutral100 = Color(0xFFFFFFFF);

  // Status and accents.
  static const warning60 = Color(0xFFF59A1F); // Pro badge
  static const warning70 = Color(0xFFFFB74D); // Poster theme
  static const success40 = Color(0xFF007D37);
  static const error40 = Color(0xFFB50000);
  static const error70 = Color(0xFFFF6659);
  static const tertiary60 = Color(0xFFA78969);
}
