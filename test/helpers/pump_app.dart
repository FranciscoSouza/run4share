import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/app.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_theme.dart';
import 'package:run4share/l10n/app_localizations.dart';

/// A 390 x 844 phone, the size the design is drawn at.
const phoneSize = Size(390, 844);

extension PumpApp on WidgetTester {
  void _usePhone() {
    view
      ..physicalSize = phoneSize * 3
      ..devicePixelRatio = 3;
    addTearDown(view.reset);
  }

  /// Pumps the whole app (router, theme, l10n) in [locale].
  Future<void> pumpApp({Locale locale = const Locale('en')}) async {
    _usePhone();
    await pumpWidget(ProviderScope(child: App(locale: locale)));
    await pumpAndSettle();
  }

  /// Pumps a single widget with the app's theme and l10n around it.
  Future<void> pumpInApp(Widget child) async {
    _usePhone();
    await pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
    await pumpAndSettle();
  }
}
