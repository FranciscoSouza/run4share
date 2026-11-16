import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/editor_screen.dart';
import 'package:run4share/features/editor/sticker_view.dart';
import 'package:run4share/features/editor/style_panels.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/pro/pro_screen.dart';
import 'package:run4share/features/share/share_screen.dart';
import 'package:run4share/features/stickers/activity_streams.dart';

import '../helpers/pump_app.dart';
import '../photos/fake_photo_library.dart';
import '../photos/photo_flow_test.dart' show settle;
import '../strava/fakes.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  CreationDraft draft() => container.read(creationDraftProvider)!;

  /// Scrolls the theme carousel to [name] and taps it.
  Future<void> tapTheme(WidgetTester tester, String name) async {
    // The carousel builds lazily: from the start, scroll until the
    // thumbnail exists.
    final carousel = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
    );
    tester.state<ScrollableState>(carousel).position.jumpTo(0);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.bySemanticsLabel(name),
      150,
      scrollable: carousel,
    );
    await settle(tester);
    await tester.tap(find.bySemanticsLabel(name));
    await settle(tester);
  }

  Future<void> openEditor(
    WidgetTester tester, {
    bool pro = false,
    ActivityStreams? streams,
  }) async {
    db = testDatabase();
    late int id;
    await tester.runAsync(() async {
      final repo = ActivityRepository(db);
      id = await repo.saveManual(
        name: 'Lunch Run',
        sportType: 'Run',
        startLocal: DateTime.utc(2026, 11, 12, 12, 31),
        movingTime: 1994,
        distance: 5020,
      );
      if (streams != null) await repo.setStreams(id, streams);
    });
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(db: db),
        clockProvider.overrideWithValue(() => testNow),
        photoLibraryProvider.overrideWithValue(
          FakePhotoLibrary(current: PhotoAccess.granted),
        ),
        proAtLaunchProvider.overrideWithValue(pro),
      ],
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(creationDraftProvider.notifier).set(
          CreationDraft(
            activityId: id,
            photoId: 'photo-0',
            format: ShareFormat.feed,
            crop: const Rect.fromLTWH(0.1, 0, 0.8, 1),
            themeId: 'inline-top',
            sticker: const StickerPlacement(center: Offset(0.5, 0.72)),
          ),
        );
    // push completes only when the editor is closed, so don't await it.
    unawaited(container.read(routerProvider).push(AppRoutes.editor));
    await settle(tester, rounds: 15);
    expect(find.byType(EditorScreen), findsOneWidget);
  }

  testWidgets('themes: choose, and unusable ones say why', (tester) async {
    await openEditor(tester);

    expect(find.text('Lunch Run'), findsOneWidget);
    expect(find.text('10 themes · more added over time'), findsOneWidget);

    await tapTheme(tester, 'Heart Ring');
    expect(find.text('No heart rate in this activity'), findsOneWidget);
    expect(draft().themeId, 'inline-top');

    await tapTheme(tester, 'Big Distance');
    expect(draft().themeId, 'big-distance');
    expect(draft().sticker?.center, const Offset(0.5, 0.2));
    expect(
      await tester.runAsync(() => db.readPreference(themePreference)),
      'big-distance',
    );
  });

  testWidgets('select, move, remove and bring back the sticker', (
    tester,
  ) async {
    await openEditor(tester);
    final sticker = find.byType(StickerView).first;

    await tester.tap(sticker);
    await settle(tester);
    expect(find.bySemanticsLabel('Remove sticker'), findsOneWidget);
    expect(find.bySemanticsLabel('Rotate sticker'), findsOneWidget);
    // Selecting closes the theme carousel; the toolbar shows instead.
    expect(find.text('10 themes · more added over time'), findsNothing);

    final before = draft().sticker!.center;
    await tester.drag(sticker, const Offset(0, -60));
    await settle(tester);
    expect(draft().sticker!.center.dy, lessThan(before.dy));
    expect(draft().sticker!.center.dx, closeTo(before.dx, 0.001));

    await tester.tap(find.bySemanticsLabel('Remove sticker'));
    await settle(tester);
    expect(draft().sticker, isNull);
    expect(find.text('Pick a theme to add the sticker back'), findsOneWidget);

    await tester.tap(find.text('Theme'));
    await settle(tester);
    await tapTheme(tester, 'Inline Top');
    expect(draft().sticker, isNotNull);
    expect(draft().themeId, 'inline-top');
  });

  testWidgets('text colour and background from the sticker handles', (
    tester,
  ) async {
    await openEditor(tester);
    await tester.tap(find.byType(StickerView).first);
    await settle(tester);

    await tester.tap(find.bySemanticsLabel('Text colour'));
    await settle(tester);
    expect(find.text('Text colour'), findsOneWidget);
    expect(find.text('White'), findsOneWidget, reason: 'current colour');

    await tester.tap(find.bySemanticsLabel('Amber'));
    await settle(tester);
    expect(draft().style.colour, StickerColour.amber);
    expect(find.text('Amber'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Sticker background'));
    await settle(tester);
    expect(find.text('Transparent'), findsWidgets);

    final slider = find.byType(BackgroundSlider);
    final box = tester.getRect(slider);
    await tester.tapAt(Offset(box.right - 4, box.center.dy));
    await settle(tester);
    expect(draft().style.background, 1);
    expect(find.text('Black 100%'), findsOneWidget);

    await tester.tapAt(box.center);
    await settle(tester);
    expect(draft().style.background, 0, reason: 'snaps to transparent');

    await tester.tapAt(Offset(box.left + box.width * 0.2, box.center.dy));
    await settle(tester);
    expect(draft().style.background, lessThan(0));
    expect(find.textContaining('White '), findsOneWidget);

    // Tapping the photo closes the style panel.
    await tester.tapAt(
      tester.getTopLeft(find.byType(StickerView).first) - const Offset(0, 30),
    );
    await settle(tester);
    expect(find.byType(BackgroundSlider), findsNothing);
  });

  testWidgets('Share opens the share screen', (tester) async {
    await openEditor(tester);
    await tester.tap(find.text('Share'));
    await settle(tester, rounds: 15);
    expect(find.byType(ShareScreen), findsOneWidget);
  });

  Future<void> openStickers(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Hide themes'));
    await settle(tester);
    await tester.tap(find.text('Stickers'));
    await settle(tester);
  }

  Future<void> openData(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Hide themes'));
    await settle(tester);
    await tester.tap(find.text('Your data'));
    await settle(tester);
  }

  testWidgets('Your data is its own tool; Stickers no longer lists it', (
    tester,
  ) async {
    await openEditor(tester);
    await openStickers(tester);
    expect(find.text('YOUR DATA', skipOffstage: false), findsNothing);
    await tester.tap(find.byTooltip('Close'));
    await settle(tester);

    await tester.tap(find.text('Your data'));
    await settle(tester);
    // A manual run without a route, shoe or streams.
    expect(find.text('Your data'), findsOneWidget, reason: 'panel title');
    expect(find.text('Stickers'), findsNothing, reason: 'toolbar hidden');
  });

  testWidgets('Stickers without Pro lead to the Pro screen', (tester) async {
    await openEditor(tester);
    await openStickers(tester);
    expect(find.text('For this activity'.toUpperCase()), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Start time'));
    await settle(tester);
    expect(find.byType(ProScreen), findsOneWidget);
    expect(draft().extras, isEmpty);
  });

  testWidgets('with Pro: add, recolour and remove extra stickers', (
    tester,
  ) async {
    await openEditor(tester, pro: true);
    await openStickers(tester);

    await tester.tap(find.bySemanticsLabel('Start time'));
    await settle(tester);
    expect(draft().extras.single.kind, ExtraKind.time);
    expect(find.text('12:31'), findsOneWidget, reason: 'the start time');
    // The new sticker is selected: its handles are showing.
    expect(find.bySemanticsLabel('Remove sticker'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Text colour'));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('Red'));
    await settle(tester);
    expect(draft().extras.single.colour, StickerColour.red);
    expect(draft().style.colour, isNull, reason: 'theme sticker untouched');

    await tester.tap(find.bySemanticsLabel('Remove sticker'));
    await settle(tester);
    expect(draft().extras, isEmpty);
    expect(draft().sticker, isNotNull, reason: 'theme sticker stays');

    // A phrase, by mood.
    await tester.tap(find.text('Stickers'));
    await settle(tester);
    // The panel scrolls: Your data comes before the phrases.
    await tester.ensureVisible(find.text('Tired'));
    await settle(tester);
    await tester.tap(find.text('Tired'));
    await settle(tester);
    await tester.ensureVisible(find.text('Tired, but not done.'));
    await settle(tester);
    await tester.tap(find.text('Tired, but not done.'));
    await settle(tester);
    expect(draft().extras.single.value, 'tired.1');
  });

  testWidgets('chart stickers appear only for the streams the activity has', (
    tester,
  ) async {
    await openEditor(tester, pro: true);
    await openData(tester);
    for (final chart in ['Heart rate', 'Pace', 'Elevation']) {
      expect(
        find.bySemanticsLabel(chart, skipOffstage: false),
        findsNothing,
        reason: 'a manual run has no streams',
      );
    }
  });

  testWidgets('with heart rate and speed: both charts, real figures', (
    tester,
  ) async {
    // 1994 s at 1000/300 m/s (5:00 /km), heart rate 150, no altitude.
    final streams = ActivityStreams.fromStrava({
      'time': {
        'data': [for (var t = 0; t <= 1994; t++) t],
      },
      'velocity_smooth': {
        'data': [for (var t = 0; t <= 1994; t++) 1000 / 300],
      },
      'heartrate': {
        'data': [for (var t = 0; t <= 1994; t++) 150],
      },
    });
    await openEditor(tester, pro: true, streams: streams);
    await openData(tester);
    expect(
      find.bySemanticsLabel('Elevation', skipOffstage: false),
      findsNothing,
    );

    final heart = find.bySemanticsLabel('Heart rate', skipOffstage: false);
    await tester.ensureVisible(heart);
    await settle(tester);
    await tester.tap(heart);
    await settle(tester);
    expect(draft().extras.single.kind, ExtraKind.heartRate);
    expect(find.text('Avg 150 bpm'), findsWidgets);

    await tester.tap(find.text('Your data'));
    await settle(tester);
    final pace = find.bySemanticsLabel('Pace', skipOffstage: false);
    await tester.ensureVisible(pace);
    await settle(tester);
    await tester.tap(pace);
    await settle(tester);
    expect(draft().extras.last.kind, ExtraKind.pace);
    expect(find.text('Avg 5:00 /km'), findsWidgets);
  });

  testWidgets('Your data without Pro leads to the Pro screen', (tester) async {
    await openEditor(
      tester,
      streams: ActivityStreams.fromStrava({
        'time': {
          'data': [for (var t = 0; t <= 1994; t++) t],
        },
        'heartrate': {
          'data': [for (var t = 0; t <= 1994; t++) 150],
        },
      }),
    );
    await openData(tester);
    await tester.tap(find.bySemanticsLabel('Heart rate'));
    await settle(tester);
    expect(find.byType(ProScreen), findsOneWidget);
    expect(draft().extras, isEmpty);
  });

  testWidgets('Pro themes: badged and locked without Pro, usable with it', (
    tester,
  ) async {
    await openEditor(tester);
    // Free themes carry no badge; Pro ones do.
    expect(find.text('PRO'), findsNothing, reason: 'first themes are free');
    await tapTheme(tester, 'Race Bib');
    expect(find.byType(ProScreen), findsOneWidget);
    expect(draft().themeId, 'inline-top');
    await tester.tap(find.byTooltip('Close'));
    await settle(tester);
    expect(find.text('PRO'), findsWidgets, reason: 'Pro thumbnails badged');
  });

  testWidgets('with Pro the new themes apply', (tester) async {
    await openEditor(tester, pro: true);
    for (final (name, id) in [
      ('Race Bib', 'race-bib'),
      ('Receipt', 'receipt'),
      ('Scoreboard', 'scoreboard'),
    ]) {
      await tapTheme(tester, name);
      expect(draft().themeId, id);
    }
    await tapTheme(tester, 'Receipt');
    expect(find.text('TOTAL'), findsWidgets, reason: 'the receipt drew');
    expect(find.text('PRO'), findsNothing, reason: 'no badges with Pro');
  });
}
