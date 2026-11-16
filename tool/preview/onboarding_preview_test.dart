// Renders the four onboarding pages at 390x844 with the real fonts, for a
// visual check. Not part of the suite: flutter test tool/preview/
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/onboarding/onboarding_screen.dart';
import 'package:run4share/l10n/app_localizations.dart';

import '../../test/helpers/pump_app.dart';

Future<void> _fonts() async {
  for (final (family, files) in [
    ('BarlowCondensed', ['SemiBold', 'Bold', 'ExtraBoldItalic']),
    ('Inter', ['Regular', 'Medium', 'SemiBold']),
  ]) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(
        Future.value(
          ByteData.sublistView(
            File('assets/fonts/$family-$f.ttf').readAsBytesSync(),
          ),
        ),
      );
    }
    await loader.load();
  }
}

void main() {
  for (final lang
      in (Platform.environment['PREVIEW_LANGS'] ?? 'en').split(',')) {
    testWidgets('render onboarding $lang', (tester) async {
      await tester.runAsync(_fonts);
      await initializeDateFormatting();
      final out =
          Directory(Platform.environment['PREVIEW_DIR'] ?? 'build/preview')
            ..createSync(recursive: true);
      final scale =
          double.parse(Platform.environment['PREVIEW_TEXT_SCALE'] ?? '1');
      tester.view
        ..physicalSize = const Size(390, 844) * 2
        ..devicePixelRatio = 2;
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: baseOverrides(),
          child: RepaintBoundary(
            key: key,
            child: MaterialApp(
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  padding: const EdgeInsets.only(top: 47, bottom: 34),
                ),
                child: child!,
              ),
              home: const OnboardingScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var page = 1; page <= 4; page++) {
        if (page > 1) {
          await tester.tap(find.byType(FilledButton));
          await tester.pumpAndSettle();
        }
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          File('${out.path}/onboarding-$lang-$page.png')
              .writeAsBytesSync(png!.buffer.asUint8List());
        });
      }
    });
  }
}
