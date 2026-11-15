import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/sticker_view.dart';
import 'package:run4share/features/editor/style_panels.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/l10n/app_localizations.dart';

import '../helpers/pump_app.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  late StickerData data;

  setUpAll(() async {
    await initializeDateFormatting();
    data = stickerDataFor(
      sampleActivity,
      ActivityFormat(l10n: en, locale: 'en', units: Units.km),
    );
  });

  group('draft style', () {
    late ProviderContainer container;
    CreationDraftNotifier notifier() =>
        container.read(creationDraftProvider.notifier);
    StickerStyle style() => container.read(creationDraftProvider)!.style;

    setUp(() {
      container = ProviderContainer.test();
      notifier().set(
        const CreationDraft(
          activityId: 1,
          photoId: 'p',
          format: ShareFormat.story,
          crop: Rect.fromLTWH(0, 0, 1, 1),
          themeId: 'inline-top',
          sticker: StickerPlacement(center: Offset(0.5, 0.5)),
        ),
      );
    });

    test('starts with the theme colour and no background', () {
      expect(style().colour, isNull);
      expect(style().background, 0);
    });

    test('background clamps and snaps to none near the middle', () {
      notifier().setBackground(0.6);
      expect(style().background, 0.6);
      notifier().setBackground(0.04);
      expect(style().background, 0);
      notifier().setBackground(-3);
      expect(style().background, -1);
    });

    test('colour and background survive a theme change', () {
      notifier()
        ..setColour(StickerColour.amber)
        ..setBackground(0.6)
        ..setTheme('big-distance', const Offset(0.5, 0.2));
      expect(style().colour, StickerColour.amber);
      expect(style().background, 0.6);
    });
  });

  test('background names', () {
    expect(backgroundName(en, 0), 'Transparent');
    expect(backgroundName(en, 0.6), 'Black 60%');
    expect(backgroundName(en, -0.4), 'White 40%');
  });

  /// Colour of the distance value ("5.02 km").
  Color valueColour(WidgetTester tester) {
    final text = tester.widget<Text>(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            (w.textSpan?.toPlainText().startsWith('5.02') ?? false),
      ),
    );
    return text.textSpan!.style!.color!;
  }

  testWidgets('text takes the chosen colour', (tester) async {
    await tester.pumpInApp(
      Center(
        child: FittedBox(
          child: StickerView(
            theme: themeById('inline-top')!,
            data: data,
            style: const StickerStyle(colour: StickerColour.amber),
          ),
        ),
      ),
    );
    expect(valueColour(tester), StickerColour.amber.color);
  });

  testWidgets('Poster: a dark fill turns its text white', (tester) async {
    await tester.pumpInApp(
      Center(
        child: FittedBox(
          child: StickerView(
            theme: themeById('poster')!,
            data: data,
            style: const StickerStyle(colour: StickerColour.blue),
          ),
        ),
      ),
    );
    expect(valueColour(tester), AppColors.neutral100);
    expect(
      tester
          .widgetList<Container>(find.byType(Container))
          .any((c) => c.color == StickerColour.blue.color),
      isTrue,
    );
  });

  testWidgets('a background adds a backing panel', (tester) async {
    Future<Size> sizeWith(double background) async {
      await tester.pumpInApp(
        Center(
          child: FittedBox(
            child: StickerView(
              theme: themeById('inline-top')!,
              data: data,
              style: StickerStyle(background: background),
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(StickerView));
    }

    final plain = await sizeWith(0);
    final backed = await sizeWith(0.6);
    expect(backed.width, greaterThan(plain.width));
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color ==
                AppColors.neutral0.withValues(alpha: 0.6),
      ),
      findsOneWidget,
    );
  });
}
