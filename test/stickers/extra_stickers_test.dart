import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_view.dart';
import 'package:run4share/features/stickers/extra_sticker_view.dart';
import 'package:run4share/features/stickers/sticker_catalogue.dart';
import 'package:run4share/l10n/app_localizations.dart';

import '../helpers/pump_app.dart';

const _draft = CreationDraft(
  activityId: 1,
  photoId: 'p',
  format: ShareFormat.story,
  crop: Rect.fromLTWH(0, 0, 1, 1),
  themeId: 'inline-top',
);

/// Every extra sticker the catalogue offers.
final everySticker = <(ExtraKind, String)>[
  (ExtraKind.label, 'record'),
  (ExtraKind.label, 'longRun'),
  (ExtraKind.label, 'raceDay'),
  (ExtraKind.label, 'subMark:1:45'),
  (ExtraKind.time, ''),
  for (final mood in Mood.values)
    for (var i = 0; i < phrasesPerMood; i++)
      (ExtraKind.phrase, phraseId(mood, i)),
  for (final stamp in StampKind.values) (ExtraKind.stamp, stamp.name),
];

void main() {
  setUpAll(initializeDateFormatting);

  group('draft extras', () {
    late ProviderContainer container;
    CreationDraftNotifier drafts() =>
        container.read(creationDraftProvider.notifier);
    List<ExtraSticker> extras() =>
        container.read(creationDraftProvider)!.extras;

    setUp(() {
      container = ProviderContainer.test();
      drafts().set(_draft);
    });

    test('add, move, recolour and remove', () {
      final a = drafts().addExtra(ExtraKind.label, 'record');
      final b = drafts().addExtra(ExtraKind.time, '');
      expect(a, isNot(b));
      expect(extras().map((e) => e.kind), [ExtraKind.label, ExtraKind.time]);

      drafts()
        ..placeExtra(b, const StickerPlacement(center: Offset(0.2, 0.8)))
        ..setExtraColour(b, StickerColour.red);
      expect(extras().last.placement.center, const Offset(0.2, 0.8));
      expect(extras().last.colour, StickerColour.red);

      drafts().removeExtra(a);
      expect(extras().map((e) => e.id), [b]);
    });

    test('extras survive the JSON round trip', () {
      drafts()
        ..addExtra(ExtraKind.stamp, 'earlyBird')
        ..addExtra(ExtraKind.phrase, 'tired.1');
      drafts().setExtraColour(1, StickerColour.green);
      final json = container.read(creationDraftProvider)!.toJson();
      final back = CreationDraft.fromJson(json)!;
      expect(back.extras.map((e) => (e.kind, e.value, e.colour)), [
        (ExtraKind.stamp, 'earlyBird', StickerColour.green),
        (ExtraKind.phrase, 'tired.1', null),
      ]);
    });

    test('drafts from before phase 8 still load', () {
      final json = _draft.toJson()..remove('extras');
      expect(CreationDraft.fromJson(json)?.extras, isEmpty);
    });
  });

  test('stored label values read back', () {
    expect(labelFromValue('subMark:1:45')?.mark, '1:45');
    expect(labelFromValue('record')?.mark, isNull);
    expect(labelFromValue('nonsense'), isNull);
  });

  // Every extra sticker in every language: no overflow, and it fits the
  // canvas at its designed size.
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('every extra sticker draws in ${locale.languageCode}', (
      tester,
    ) async {
      // A screen as wide as the canvas: stickers are designed up to it.
      tester.view
        ..physicalSize = const Size(canvasUnits + 200, 1400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final (kind, value) in everySticker) {
        await tester.pumpWidget(
          Localizations(
            locale: locale,
            delegates: AppLocalizations.localizationsDelegates,
            child: Center(
              child: UnconstrainedBox(
                child: ExtraStickerView(
                  kind: kind,
                  value: value,
                  start: DateTime.utc(2026, 11, 15, 5, 42),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final size = tester.getSize(find.byType(ExtraStickerView));
        expect(
          size.width,
          lessThanOrEqualTo(canvasUnits),
          reason: '$kind $value in ${locale.languageCode}',
        );
      }
    });
  }

  testWidgets('the time sticker shows the start time', (tester) async {
    await tester.pumpInApp(
      Center(
        child: FittedBox(
          child: ExtraStickerView(
            kind: ExtraKind.time,
            value: '',
            start: DateTime.utc(2026, 11, 15, 5, 42),
          ),
        ),
      ),
    );
    expect(find.text('05:42'), findsOneWidget);
  });
}
