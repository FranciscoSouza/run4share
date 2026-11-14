/// The app's single import of Material.
///
/// Flutter 3.47+ deprecates `package:flutter/material.dart` in favour of the
/// standalone `material_ui` package, which carries its own copy of `Theme`,
/// `MaterialApp` and the Material localisations. go_router 17 still builds
/// pages with `flutter/material`, so mixing the two would split the theme
/// and localisations. Every file imports Material through here; moving to
/// `material_ui` later is a change to this one line.
library;

// Deliberate: see the library comment above.
// ignore: deprecated_member_use
export 'package:flutter/material.dart';
