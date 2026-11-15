// Renders the app icon masters from the design's "r4s" tile.
//
//   flutter test tool/icon/render_icons_test.dart
//
// Writes assets/icon/*.png; then `dart run flutter_launcher_icons` and
// `dart run flutter_native_splash:create` produce every platform size.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _black = Color(0xFF0D0C0A);
const _white = Color(0xFFFFFFFF);
const _blue = Color(0xFF2E92CE);
const _size = 1024.0;

Future<void> _loadFont() async {
  final loader = FontLoader('BarlowCondensed')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('assets/fonts/BarlowCondensed-ExtraBoldItalic.ttf')
              .readAsBytesSync(),
        ),
      ),
    );
  await loader.load();
}

/// "r4s" in Barlow Condensed ExtraBold Italic.
Widget _mark({required double size, required Color colour, Color? four}) =>
    Text.rich(
      TextSpan(
        style: TextStyle(
          fontFamily: 'BarlowCondensed',
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          fontSize: size,
          height: 1,
          letterSpacing: -size * 0.02,
          color: colour,
        ),
        children: [
          const TextSpan(text: 'r'),
          TextSpan(text: '4', style: TextStyle(color: four ?? colour)),
          const TextSpan(text: 's'),
        ],
      ),
      textDirection: TextDirection.ltr,
    );

Future<void> _render(
  WidgetTester tester,
  String name,
  Widget child, {
  Color? background,
}) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox.square(
            dimension: _size,
            child: ColoredBox(
              color: background ?? const Color(0x00000000),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File('assets/icon/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render icon masters', (tester) async {
    tester.view
      ..physicalSize = const Size(_size, _size)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(_loadFont);

    // iOS and Play Store: full bleed, the system rounds the corners.
    await _render(
      tester,
      'icon',
      _mark(size: 520, colour: _white, four: _blue),
      background: _black,
    );
    // Android adaptive foreground: inside the 66% safe zone.
    await _render(
      tester,
      'foreground',
      _mark(size: 360, colour: _white, four: _blue),
    );
    // Android 13+ themed icons: one colour.
    await _render(tester, 'monochrome', _mark(size: 360, colour: _white));
    // Splash: the tile on the light background.
    await _render(
      tester,
      'splash',
      _mark(size: 300, colour: _black, four: const Color(0xFF0077BD)),
    );
  });
}
