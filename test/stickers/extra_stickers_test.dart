import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_view.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/activity_streams.dart';
import 'package:run4share/features/stickers/data_sticker_views.dart';
import 'package:run4share/features/stickers/extra_sticker_view.dart';
import 'package:run4share/features/stickers/polyline.dart';
import 'package:run4share/features/stickers/sticker_catalogue.dart';
import 'package:run4share/features/strava/strava_demo.dart';
import 'package:run4share/l10n/app_localizations.dart';

import '../helpers/pump_app.dart';

const _draft = CreationDraft(
  activityId: 1,
  photoId: 'p',
  format: ShareFormat.story,
  crop: Rect.fromLTWH(0, 0, 1, 1),
  themeId: 'inline-top',
);

/// A run with everything the data stickers use.
final _activity = Activity(
  id: 1,
  source: ActivitySource.strava,
  sourceId: '1',
  name: 'Lunch Run',
  sportType: 'Run',
  startLocal: DateTime.utc(2026, 11, 15, 5, 42),
  distance: 10050,
  movingTime: 2820,
  race: false,
  polyline: demoRoute(1, 10050),
  gearId: 'g1',
  splitsJson: jsonEncode({
    'km': [
      for (var i = 0; i < 10; i++) [1000, 270 + i * 3, 2],
      [50, 14, 0],
    ],
    'mi': [
      for (var i = 0; i < 6; i++) [1609.3, 440 + i * 5, 3],
    ],
  }),
  elevationJson: jsonEncode([
    for (var i = 0; i < 50; i++) [i * 200, 40 + (i % 7) * 3],
  ]),
  // 2820 s at 280 s/km, heart rate rising 140 to 168.
  streamsJson: ActivityStreams.fromStrava({
    'time': {
      'data': [for (var t = 0; t <= 2820; t++) t],
    },
    'velocity_smooth': {
      'data': [for (var t = 0; t <= 2820; t++) 1000 / 280],
    },
    'heartrate': {
      'data': [for (var t = 0; t <= 2820; t++) 140 + t ~/ 101],
    },
  }).toJson(),
);

const _gear = Gear(id: 'g1', name: 'Pegasus 41', distance: 412300);

final _facts = StickerFacts(activity: _activity, gear: _gear);

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
  (ExtraKind.shoe, ''),
  for (final style in RouteStyle.values) (ExtraKind.route, style.name),
  (ExtraKind.elevation, ''),
  (ExtraKind.splits, ''),
  (ExtraKind.heartRate, ''),
  (ExtraKind.pace, ''),
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
                  facts: _facts,
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

  testWidgets('data stickers draw what the activity has', (tester) async {
    Future<void> show(ExtraKind kind, {StickerFacts? facts}) =>
        tester.pumpInApp(
          Center(
            child: FittedBox(
              child: ExtraStickerView(
                kind: kind,
                value: 'neon',
                facts: facts ?? _facts,
              ),
            ),
          ),
        );

    await show(ExtraKind.shoe);
    expect(find.text('Pegasus 41'), findsOneWidget);
    expect(find.text('412 km', findRichText: true), findsOneWidget);

    await show(ExtraKind.shoe, facts: _facts.withUnits(Units.mi));
    expect(find.text('256 mi', findRichText: true), findsOneWidget);

    await show(ExtraKind.splits);
    // Fastest full km is the first: 270 s = 4:30.
    expect(find.text('Best 4:30 /km'), findsOneWidget);

    await show(ExtraKind.elevation);
    expect(find.text('+126 m'), findsOneWidget, reason: '7 ramps of 18 m');
    await show(ExtraKind.elevation, facts: _facts.withUnits(Units.mi));
    expect(find.textContaining(' ft'), findsOneWidget);

    await show(ExtraKind.heartRate);
    // Max and min are painted on the line (see chart_data_test).
    expect(find.textContaining(RegExp(r'^Avg 15\d bpm$')), findsOneWidget);
    expect(find.text('47:00'), findsOneWidget, reason: 'duration');

    await show(ExtraKind.pace);
    expect(find.text('Avg 4:40 /km'), findsOneWidget);
    await show(ExtraKind.pace, facts: _facts.withUnits(Units.mi));
    expect(find.text('Avg 7:31 /mi'), findsOneWidget);

    // Without the data, the sticker draws nothing rather than failing.
    final bare = StickerFacts(
      activity: _activity.copyWith(
        polyline: const Value(null),
        splitsJson: const Value(null),
      ),
    );
    await show(ExtraKind.route, facts: bare);
    expect(tester.getSize(find.byType(ExtraStickerView)), Size.zero);
  });

  test('polylines decode what they encode', () {
    final points = [(38.72, -9.14), (38.7213, -9.1452), (38.7301, -9.1388)];
    final back = decodePolyline(encodePolyline(points));
    for (var i = 0; i < points.length; i++) {
      expect(back[i].$1, closeTo(points[i].$1, 1e-5));
      expect(back[i].$2, closeTo(points[i].$2, 1e-5));
    }
    // Strava's own example from Google's documentation.
    expect(decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@').first, (38.5, -120.2));
    expect(decodePolyline('_p~iF~ps|U_ulL'), hasLength(1), reason: 'truncated');
  });

  testWidgets('the time sticker shows the start time', (tester) async {
    await tester.pumpInApp(
      Center(
        child: FittedBox(
          child: ExtraStickerView(
            kind: ExtraKind.time,
            value: '',
            facts: _facts,
          ),
        ),
      ),
    );
    expect(find.text('05:42'), findsOneWidget);
  });
}
