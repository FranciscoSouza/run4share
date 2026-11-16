import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/app.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/system.dart';
import 'package:run4share/app/theme/app_theme.dart';
import 'package:run4share/data/creation_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/health/health_hub.dart';
import 'package:run4share/features/lab/lab.dart';
import 'package:run4share/features/onboarding/onboarding.dart';
import 'package:run4share/features/pro/pro_store.dart';
import 'package:run4share/features/share/share_actions.dart';
import 'package:run4share/features/strava/strava_config.dart';
import 'package:run4share/features/strava/strava_session_store.dart';
import 'package:run4share/l10n/app_localizations.dart';

import '../health/fake_health_hub.dart';
import '../pro/fake_pro_store.dart';
import '../share/fake_share_actions.dart';
import 'fake_system_actions.dart';

/// A 390 x 844 phone, the size the design is drawn at.
const phoneSize = Size(390, 844);

const testStravaConfig = StravaConfig(
  clientId: '12345',
  tokenUrl: 'https://token.test',
);

/// Overrides every test needs: no platform storage, a known Strava config.
List<Override> baseOverrides({
  MemoryStravaSessionStore? store,
  StravaConfig config = testStravaConfig,
  LabStore? lab,
  AppDatabase? db,
  Directory? folder,
  ShareActions? share,
  SystemActions? system,
  ProStore? pro,
  HealthHub? hub,
  bool onboardingDone = true,
}) =>
    [
      // Tests start on Home unless they're about the introduction.
      onboardingDoneAtLaunchProvider.overrideWithValue(onboardingDone),
      stravaSessionStoreProvider.overrideWithValue(
        store ?? MemoryStravaSessionStore(),
      ),
      stravaConfigProvider.overrideWithValue(config),
      labStoreProvider.overrideWithValue(lab ?? MemoryLabStore()),
      appDatabaseProvider.overrideWithValue(db ?? testDatabase()),
      creationsFolderProvider.overrideWithValue(
        () async => folder ?? Directory.systemTemp.createTempSync('creations'),
      ),
      shareActionsProvider.overrideWithValue(share ?? FakeShareActions()),
      systemActionsProvider.overrideWithValue(system ?? FakeSystemActions()),
      proStoreProvider.overrideWithValue(pro ?? FakeProStore()),
      healthHubProvider.overrideWithValue(hub ?? FakeHealthHub()),
    ];

/// A fresh in-memory database.
AppDatabase testDatabase() => AppDatabase.forTesting(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

extension PumpApp on WidgetTester {
  void _usePhone() {
    view
      ..physicalSize = phoneSize * 3
      ..devicePixelRatio = 3;
    addTearDown(view.reset);
  }

  /// Pumps the whole app (router, theme, l10n) in [locale].
  /// [locale] null follows the test device (English), like the app
  /// following the phone.
  Future<void> pumpApp({
    Locale? locale,
    List<Override>? overrides,
  }) async {
    _usePhone();
    await pumpWidget(
      ProviderScope(
        overrides: overrides ?? baseOverrides(),
        child: App(locale: locale),
      ),
    );
    await pumpAndSettle();
  }

  /// Pumps a single widget with the app's theme and l10n around it.
  Future<void> pumpInApp(Widget child) async {
    _usePhone();
    await pumpWidget(
      ProviderScope(
        overrides: baseOverrides(),
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
