import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/editor_screen.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/stickers/activity_streams.dart';
import 'package:run4share/features/stickers/data_sticker_views.dart';

import '../helpers/pump_app.dart';
import '../photos/fake_photo_library.dart';
import '../photos/photo_flow_test.dart' show settle;
import '../strava/fakes.dart';

void main() {
  /// A manual run, with [streams] when given; returns its id.
  Future<(ProviderContainer, int)> start(
    WidgetTester tester, {
    ActivityStreams? streams,
  }) async {
    final db = testDatabase();
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
          FakePhotoLibrary(),
        ),
        proAtLaunchProvider.overrideWithValue(true),
      ],
    );
    return (
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp))),
      id,
    );
  }

  /// Sunrise Half (big-distance + pace chart) through to the editor.
  Future<void> useSunriseHalf(
    WidgetTester tester,
    ProviderContainer container,
    int activityId,
  ) async {
    container.read(templateChoiceProvider.notifier).choose('sunrise-half');
    unawaited(
      container.read(routerProvider).push(AppRoutes.choosePhoto(activityId)),
    );
    await settle(tester);
    // The system picker (faked) returns a photo by itself.
    await settle(tester, rounds: 20);
    await tester.tap(find.text('Next'));
    await settle(tester, rounds: 15);
    expect(find.byType(EditorScreen), findsOneWidget);
  }

  /// The pace chart on the editor's canvas.
  Finder paceOnCanvas() => find.descendant(
        of: find.byType(EditorScreen),
        matching: find.byType(PaceSticker),
      );

  testWidgets('the template brings its pace chart when there is pace', (
    tester,
  ) async {
    final (container, id) = await start(
      tester,
      streams: ActivityStreams.fromStrava({
        'time': {
          'data': [for (var t = 0; t <= 1994; t++) t],
        },
        'velocity_smooth': {
          'data': [for (var t = 0; t <= 1994; t++) 5020 / 1994],
        },
      }),
    );
    await useSunriseHalf(tester, container, id);
    expect(paceOnCanvas(), findsOneWidget);
    expect(find.textContaining('left out'), findsNothing);
  });

  testWidgets('no pace: the chart is left out, with one note', (
    tester,
  ) async {
    final (container, id) = await start(tester);
    await useSunriseHalf(tester, container, id);
    expect(paceOnCanvas(), findsNothing);
    expect(
      find.text("Pace isn't in this activity, so it was left out."),
      findsOneWidget,
    );
  });
}
