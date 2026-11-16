import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
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

  // The longest figures and name a sticker is likely to get: a marathon
  // in over four hours with a long name, in every language.
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('every theme fits a long run in ${locale.languageCode}', (
      tester,
    ) async {
      final data = stickerDataFor(
        sampleActivity.copyWith(
          name: 'Maratona Internacional de São Paulo com chuva e vento forte',
          distance: const Value(42195),
          movingTime: 14733,
          averageSpeed: const Value(42195 / 14733),
          averageHeartrate: const Value(158),
          calories: const Value(2840),
        ),
        ActivityFormat(
          l10n: lookupAppLocalizations(locale),
          locale: locale.languageCode,
          units: Units.mi,
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
                style: const StickerStyle(background: -0.8),
              ),
            ),
          ),
        );
        expect(
          tester.getSize(find.byType(StickerView)).width,
          lessThanOrEqualTo(canvasUnits),
          reason: '${theme.id} in ${locale.languageCode} is too wide',
        );
      }
    });
  }
}
