import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/features/create/crop_screen.dart';
import 'package:run4share/features/home/home_screen.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/photos/picked_photos.dart';
import 'package:run4share/features/photos/strava_photos.dart';
import 'package:run4share/features/settings/settings_screen.dart';

import '../helpers/pump_app.dart';
import '../strava/fakes.dart';
import 'fake_photo_library.dart';
import 'photo_flow_test.dart' show settle;

/// A real PNG of [w] x [h], written where the system picker would leave it.
Future<String> pickerFile(int w, int h) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    Paint()..color = const Color(0xFF0077BD),
  );
  final image = await recorder.endRecording().toImage(w, h);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  final dir = Directory.systemTemp.createTempSync('picker_cache');
  final file = File('${dir.path}/picked-1.jpg')
    ..writeAsBytesSync(png!.buffer.asUint8List());
  return file.path;
}

void main() {
  test('picked photos are kept, and scaled to the size asked for', () async {
    final folder = Directory.systemTemp.createTempSync('picked_photos');
    final picked = PickedPhotoStore(() async => folder);
    final gallery = FakePhotoLibrary()
      ..usesSystemPicker = true
      ..systemPick = await pickerFile(1200, 800);
    final library = WithStravaPhotos(
      gallery,
      StravaPhotoStore(
        api: () => throw StateError('not used'),
        folder: () async => folder,
      ),
      picked,
    );
    final id = await library.pickWithSystemPicker();
    expect(id, 'picked:picked-1.jpg');
    expect(File(gallery.systemPick!).existsSync(), isFalse, reason: 'moved');

    Future<Size> sizeOf(List<int>? bytes) async {
      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(bytes!),
      );
      final frame = await codec.getNextFrame();
      return Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
    }

    expect(
      await sizeOf(await library.preview(id!, maxSide: 3072)),
      const Size(1200, 800),
      reason: 'small enough: as it is',
    );
    expect(
      await sizeOf(await library.preview(id, maxSide: 600)),
      const Size(600, 400),
    );
    expect(
      await sizeOf(await library.thumbnail(id, size: 64)),
      const Size(64, 43),
    );
  });

  Future<(ProviderContainer, int)> start(
    WidgetTester tester,
    FakePhotoLibrary library,
  ) async {
    final db = testDatabase();
    late int id;
    await tester.runAsync(() async {
      id = await ActivityRepository(db).saveManual(
        name: 'Lunch Run',
        sportType: 'Run',
        startLocal: DateTime.utc(2026, 11, 12, 12, 31),
        movingTime: 1994,
        distance: 5020,
      );
    });
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(db: db),
        clockProvider.overrideWithValue(() => testNow),
        photoLibraryProvider.overrideWithValue(library),
      ],
    );
    return (
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp))),
      id,
    );
  }

  testWidgets('Android: the system picker opens, then the crop step', (
    tester,
  ) async {
    late String path;
    await tester.runAsync(() async => path = await pickerFile(400, 300));
    final library = FakePhotoLibrary()
      ..usesSystemPicker = true
      // The wrapper isn't in play with a fake: the ID passes straight on.
      ..systemPick = 'picked:$path';
    final (container, id) = await start(tester, library);
    container.read(routerProvider).push(AppRoutes.choosePhoto(id)).ignore();
    await settle(tester, rounds: 15);

    expect(library.systemPicks, 1);
    expect(library.requests, 0, reason: 'no permission asked');
    expect(find.byType(CropScreen), findsOneWidget);
    final router = GoRouter.of(tester.element(find.byType(CropScreen)));
    expect(router.state.uri.path, startsWith('/create/$id/crop/'));
  });

  testWidgets('Android: backing out of the picker goes back', (tester) async {
    final library = FakePhotoLibrary()..usesSystemPicker = true;
    final (container, id) = await start(tester, library);
    container.read(routerProvider).push(AppRoutes.choosePhoto(id)).ignore();
    await settle(tester, rounds: 15);
    expect(library.systemPicks, 1);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(CropScreen), findsNothing);
  });

  testWidgets('Android: Settings has no photo access row', (tester) async {
    final (_, _) = await start(
      tester,
      FakePhotoLibrary()..usesSystemPicker = true,
    );
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Photo access'), findsNothing);
  });
}
