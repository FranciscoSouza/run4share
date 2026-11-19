// Renders Home (templates carousel) and See all at 390x844 with the real
// fonts, for a visual check. Not part of the suite: flutter test tool/preview/
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/home/featured_templates.dart';

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
  testWidgets('render Home', (tester) async {
    await tester.runAsync(_fonts);
    await initializeDateFormatting();
    final out =
        Directory(Platform.environment['PREVIEW_DIR'] ?? 'build/preview')
          ..createSync(recursive: true);
    await tester.pumpApp();
    tester.view
      ..physicalSize = const Size(390, 844) * 2
      ..devicePixelRatio = 2;
    await tester.pumpAndSettle();

    Future<void> images() async {
      // Asset images decode outside fake time.
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pump();
      }
    }

    Future<void> shot(String name) => tester.runAsync(() async {
          final layer =
              tester.binding.renderViews.first.debugLayer! as OffsetLayer;
          // The root layer is in physical pixels.
          final image =
              await layer.toImage(Offset.zero & const Size(780, 1688));
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          File('${out.path}/$name.png')
              .writeAsBytesSync(png!.buffer.asUint8List());
        });

    await images();
    await shot('home-1');
    await tester.timedDrag(
      find.descendant(
        of: find.byType(FeaturedTemplates),
        matching: find.byType(PageView),
      ),
      const Offset(-145, 0),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();
    await shot('home-2');
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    await shot('see-all');
  });
}
