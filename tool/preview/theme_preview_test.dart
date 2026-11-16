// Renders the phase-12 Pro themes to PNGs for a visual check. Not part of
// the suite (lives under tool/): flutter test tool/preview/
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/story_canvas.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/l10n/app_localizations.dart';

Future<void> _fonts() async {
  for (final (family, files) in [
    ('BarlowCondensed', ['SemiBold', 'Bold', 'ExtraBoldItalic']),
    ('Inter', ['Regular', 'Medium', 'SemiBold']),
  ]) {
    final loader = FontLoader(family);
    for (final f in files) {
      final prefix = family == 'Inter' ? 'Inter' : 'BarlowCondensed';
      loader.addFont(
        Future.value(
          ByteData.sublistView(
            File('assets/fonts/$prefix-$f.ttf').readAsBytesSync(),
          ),
        ),
      );
    }
    await loader.load();
  }
}

void main() {
  testWidgets('render Pro themes', (tester) async {
    await tester.runAsync(_fonts);
    await initializeDateFormatting();
    final out =
        Directory(Platform.environment['PREVIEW_DIR'] ?? 'build/preview')
          ..createSync(recursive: true);
    final data = stickerDataFor(
      sampleActivity,
      ActivityFormat(
        l10n: lookupAppLocalizations(const Locale('en')),
        locale: 'en',
        units: Units.km,
      ),
    );
    tester.view
      ..physicalSize = const Size(540, 960)
      ..devicePixelRatio = 1;
    for (final theme in stickerThemes.where((t) => t.pro)) {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(
            key: key,
            child: StoryCanvas(
              format: ShareFormat.story,
              background: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF6B4E7A),
                      Color(0xFFC07A5A),
                      Color(0xFF2A2235),
                    ],
                  ),
                ),
              ),
              theme: theme,
              data: data,
              placement: StickerPlacement(center: theme.position),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('${out.path}/${theme.id}.png')
            .writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
  });
}
