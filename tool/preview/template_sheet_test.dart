// Renders every template on its picture in one sheet (4 columns), with
// the real fonts, to check sticker positions. Not part of the suite:
// PREVIEW_DIR=... flutter test tool/preview/template_sheet_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/templates/template_canvas.dart';
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
  testWidgets('render template sheet', (tester) async {
    await tester.runAsync(_fonts);
    await initializeDateFormatting();
    final out =
        Directory(Platform.environment['PREVIEW_DIR'] ?? 'build/preview')
          ..createSync(recursive: true);
    const tile = Size(270, 480);
    const size = Size(4 * 270 + 5 * 10, 3 * (480 + 30) + 10);
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    final key = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        overrides: baseOverrides(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(
            key: key,
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Wrap(
                  spacing: 10,
                  children: [
                    for (final t in storyTemplates)
                      SizedBox(
                        width: tile.width,
                        height: tile.height + 30,
                        child: Column(
                          children: [
                            SizedBox.fromSize(
                              size: tile,
                              child: TemplateCanvas(
                                template: t,
                                watermark: false,
                              ),
                            ),
                            Text(t.name, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // Asset images decode outside fake time.
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
    }
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('${out.path}/template-sheet.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
    });
  });
}
