import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/sticker_view.dart';
import 'package:run4share/features/editor/story_canvas.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/l10n/app_localizations.dart';

import '../helpers/pump_app.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('rotation snaps to straight within 3 degrees', () {
    expect(snapRotation(2 * math.pi / 180), 0);
    expect(snapRotation(-2 * math.pi / 180), 0);
    expect(snapRotation(10 * math.pi / 180), 10 * math.pi / 180);
    expect(snapRotation(math.pi / 2 + 0.01), math.pi / 2);
  });

  test('rotating a vector a quarter turn', () {
    final v = rotateVector(const Offset(1, 0), math.pi / 2);
    expect(v.dx, closeTo(0, 1e-9));
    expect(v.dy, closeTo(1, 1e-9));
  });

  // Every theme, in every language, with full sample data: no overflow
  // and a sticker that fits the canvas at its designed size.
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('every theme draws in ${locale.languageCode}', (
      tester,
    ) async {
      final data = stickerDataFor(
        sampleActivity,
        ActivityFormat(
          l10n: lookupAppLocalizations(locale),
          locale: locale.languageCode,
          units: Units.km,
        ),
      );
      for (final theme in stickerThemes) {
        await tester.pumpInApp(
          Center(
            child: SizedBox(
              width: 360,
              child: StoryCanvas(
                format: ShareFormat.story,
                background: const ColoredBox(color: Colors.blueGrey),
                theme: theme,
                data: data,
                placement: StickerPlacement(center: theme.position),
                // The widest case: a backing panel around the sticker.
                style: const StickerStyle(
                  colour: StickerColour.black,
                  background: -0.8,
                ),
              ),
            ),
          ),
        );
        final size = tester.getSize(find.byType(StickerView));
        expect(
          size.width,
          lessThanOrEqualTo(canvasUnits),
          reason: '${theme.id} in ${locale.languageCode} is too wide',
        );
      }
    });
  }
}
