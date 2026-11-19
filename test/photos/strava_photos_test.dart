import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/strava_sync.dart';
import 'package:run4share/features/create/crop_screen.dart';
import 'package:run4share/features/home/strava_photo_strip.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/photos/picked_photos.dart';
import 'package:run4share/features/photos/strava_photos.dart';
import 'package:run4share/features/strava/strava_api.dart';
import 'package:run4share/features/strava/strava_config.dart';
import 'package:run4share/features/strava/strava_models.dart';
import 'package:run4share/features/strava/strava_session_store.dart';

import '../activities/fake_strava_api.dart';
import '../helpers/pump_app.dart';
import '../strava/fakes.dart';
import 'fake_photo_library.dart';

/// Answers every GET with a few bytes, like a CDN serving a JPEG.
class _BytesAdapter implements HttpClientAdapter {
  final requested = <Uri>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requested.add(options.uri);
    return ResponseBody.fromBytes(
      List.filled(64, 7),
      200,
      headers: {
        Headers.contentTypeHeader: ['image/jpeg'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Runs with photos, as Strava's list reports them.
List<StravaActivity> withPhotos(int count) => [
      for (final run in runs(count)) run.copyWith(totalPhotoCount: 2),
    ];

void main() {
  test("Strava's list gives the photo count", () {
    final run = StravaActivity.fromJson({
      'id': 1,
      'name': 'Run',
      'sport_type': 'Run',
      'start_date': '2026-11-14T07:00:00Z',
      'start_date_local': '2026-11-14T07:00:00Z',
      'total_photo_count': 3,
    });
    expect(run.totalPhotoCount, 3);
  });

  group('sync', () {
    late AppDatabase db;
    late FakeStravaApi api;
    late ProviderContainer container;

    setUp(() {
      db = testDatabase();
      api = FakeStravaApi(withPhotos(3) + runs(2, firstId: 10));
      container = ProviderContainer.test(
        overrides: [
          ...baseOverrides(
            store: MemoryStravaSessionStore(
              session().copyWith(scopes: StravaConfig.scope.split(',')),
            ),
            db: db,
          ),
          stravaApiProvider.overrideWithValue(api),
          clockProvider.overrideWithValue(() => testNow),
        ],
      );
    });
    tearDown(() => db.close());

    test('thumbnails are fetched once, only for activities with photos',
        () async {
      final sync = container.read(stravaSyncProvider.notifier);
      await sync.sync();
      await sync.fetchPhotoLists();
      expect(
        api.photoCalls.map((c) => c.$1).toSet(),
        {1, 2, 3},
        reason: 'the runs without photos cost nothing',
      );
      expect(api.photoCalls.map((c) => c.$2).toSet(), {600});
      final repo = ActivityRepository(db);
      final first =
          (await repo.watchAll().first).firstWhere((a) => a.sourceId == '1');
      expect(photosOf(first).map((p) => p.id), ['p1-1', 'p1-2']);

      // Cached: a second pass asks Strava nothing.
      api.photoCalls.clear();
      await sync.fetchPhotoLists();
      expect(api.photoCalls, isEmpty);
    });
  });

  test('a picked photo is downloaded at full size and served back', () async {
    final dir = Directory.systemTemp.createTempSync('strava_photos');
    final api = FakeStravaApi(const []);
    final adapter = _BytesAdapter();
    final store = StravaPhotoStore(
      api: () => api,
      folder: () async => dir,
      dio: Dio()..httpClientAdapter = adapter,
    );
    final activity = Activity(
      id: 1,
      source: ActivitySource.strava,
      sourceId: '42',
      name: 'Run',
      sportType: 'Run',
      startLocal: DateTime.utc(2026, 11, 14, 7),
      movingTime: 1800,
      race: false,
    );
    final id = await store.download(activity, 'p42-2');
    expect(id, 'strava:p42-2');
    expect(api.photoCalls, [(42, stravaPhotoFullSize)]);
    expect(adapter.requested.single.path, '/42-2-2048.jpg');
    expect(await store.bytes(id), hasLength(64));

    // Already here: no second download.
    await store.download(activity, 'p42-2');
    expect(adapter.requested, hasLength(1));

    final library = WithStravaPhotos(
      FakePhotoLibrary(),
      store,
      PickedPhotoStore(() async => dir),
    );
    expect(await library.preview(id, maxSide: 2048), hasLength(64));

    await store.clear();
    expect(await store.bytes(id), isNull, reason: 'gone after disconnect');
  });

  testWidgets('tapping a thumbnail takes that photo to the crop step', (
    tester,
  ) async {
    final db = testDatabase();
    final api = FakeStravaApi(withPhotos(1));
    final dir = Directory.systemTemp.createTempSync('strava_photos');
    late int id;
    await tester.runAsync(() async {
      final repo = ActivityRepository(db);
      await repo.upsertStrava(withPhotos(1));
      final run = (await repo.watchAll().first).single;
      id = run.id;
      await repo.setPhotos(
        run.id,
        await api.photos(1, size: 600),
        count: 2,
      );
    });
    await tester.pumpApp(
      overrides: [
        ...baseOverrides(
          db: db,
          store: MemoryStravaSessionStore(session()),
        ),
        stravaApiProvider.overrideWithValue(api),
        clockProvider.overrideWithValue(() => testNow),
        photoLibraryProvider.overrideWithValue(
          FakePhotoLibrary(current: PhotoAccess.granted),
        ),
        stravaPhotoStoreProvider.overrideWithValue(
          StravaPhotoStore(
            api: () => api,
            folder: () async => dir,
            dio: Dio()..httpClientAdapter = _BytesAdapter(),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
    await tester.showOnHome(find.byType(StravaPhotoStrip));
    expect(find.bySemanticsLabel('Strava photo 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Strava photo 2'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Strava photo 2'));
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(CropScreen), findsOneWidget);
    final crop = tester.widget<CropScreen>(find.byType(CropScreen));
    expect(crop.activityId, id);
    expect(crop.photoId, 'strava:p1-2');
    // Straight to crop, not via the gallery picker: Back goes Home.
    final router = GoRouter.of(tester.element(find.byType(CropScreen)));
    expect(router.state.uri.path, startsWith('/create/$id/crop/'));
  });
}
