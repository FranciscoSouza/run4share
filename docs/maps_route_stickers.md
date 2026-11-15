# Route maps — implementation guide

_15 Nov 2026 · written against commit `ed07685` (Phase 7)_

Adds route maps to run4share: one **free theme** that shows the route plus
distance and time, and **Pro route stickers** in several styles, all drawn by a
`CustomPainter` (no map tiles, no new packages, no running cost).

Today the app stores no route at all: `StravaActivity` ignores Strava's `map`
object and the `Activities` table has no column for it. Steps 1–3 fix that;
steps 4–9 draw it.

---

## The list of maps

### Launch (no tiles, drawn by the app)

| # | Name | What it looks like | Where | Free/Pro |
|---|---|---|---|---|
| 1 | **Route Line** theme | Route on top, distance · time under it | Theme carousel | Free |
| 2 | `line` | Thin solid route | Stickers → Route | Pro |
| 3 | `bold` | Thick route with a dark outline, readable on any photo | Stickers → Route | Pro |
| 4 | `dotted` | Route as a row of dots | Stickers → Route | Pro |
| 5 | `glow` | Soft halo under a bright core line | Stickers → Route | Pro |
| 6 | `startFinish` | Route with a hollow start dot and a filled finish dot | Stickers → Route | Pro |
| 7 | `kmMarks` | Route with a numbered dot every km (or mile) | Stickers → Route | Pro |
| 8 | `seal` | Route inside a circular seal with the date around it | Stickers → Route | Pro |
| — | Privacy trim | Hides the first and last 300 m of every route | Settings, **on by default** | Free |

### Later (need extra data or a tile provider)

| Name | Needs | Notes |
|---|---|---|
| Route coloured by pace / heart rate | Strava streams (`latlng`, `velocity_smooth`, `heartrate`) | One extra API call per activity |
| Route + elevation profile | Strava streams (`altitude`, `distance`) | Same call |
| Street map (light, dark, poster) | Tile provider (Mapbox, MapTiler, Stadia…) | Usage cost and an on-map credit (© OpenStreetMap) — **decision** |
| Topographic / satellite / 3D | Tile provider with terrain | Same decision |

---

## 1. Read the route from Strava

`lib/features/strava/strava_models.dart` — Strava nests the route as
`map.summary_polyline` (an encoded Google polyline; empty string when the
activity has no GPS). Read it with `readValue`, since `field_rename: snake`
can't reach a nested key.

```dart
/// Reads Strava's nested map.summary_polyline.
Object? _summaryPolyline(Map<dynamic, dynamic> json, String key) =>
    (json['map'] as Map<dynamic, dynamic>?)?['summary_polyline'];
```

Add to the `StravaActivity` factory, after `workoutType`:

```dart
    /// The route as an encoded Google polyline. Empty when the activity
    /// has no GPS; null when Strava didn't send a map.
    @JsonKey(readValue: _summaryPolyline) String? summaryPolyline,
```

`summary_polyline` is in both the list and the detail response, so nothing
else changes in `strava_api.dart`. Update `DemoStravaApi`
(`strava_demo.dart`) to return a polyline on a couple of its sample
activities so the Laboratory demo shows routes. Real data you can use for the demo:
`_p~iF~ps|U_ulLnnqC_mqNvxq`@` (Google's documented example).

## 2. Store it

`lib/data/database.dart` — new column and migration 4:

```dart
  /// Strava's encoded route. Empty: the activity has no GPS. Null: not
  /// known yet (manual, or synced before schema 4).
  TextColumn get routePolyline => text().nullable()();
```

```dart
  @override
  int get schemaVersion => 4;
  ...
          // 4: route maps.
          if (from < 4) {
            await m.addColumn(activities, activities.routePolyline);
          }
```

Then `dart run build_runner build --delete-conflicting-outputs`.

`lib/data/activity_repository.dart`:

- in `upsertStrava`, add `routePolyline: Value(a.summaryPolyline),` to the
  `insert` companion, and to the `DoUpdate` companion as
  `routePolyline: a.summaryPolyline == null ? const Value.absent() : Value(a.summaryPolyline),`
- add a setter next to `setCalories`:

```dart
  Future<void> setRoute(int id, String polyline) =>
      (_db.update(_table)..where((a) => a.id.equals(id))).write(
        ActivitiesCompanion(routePolyline: Value(polyline)),
      );
```

## 3. Backfill activities synced before this change

Activities already in the database have `routePolyline == null`. The detail
call in `StravaSync.fetchDetails` (`strava_sync.dart`) already runs when an
activity is opened; widen it so it also fills the route:

```dart
  Future<void> fetchDetails(Activity activity) async {
    final needsCalories = activity.calories == null;
    final needsRoute = activity.routePolyline == null;
    if (activity.source != ActivitySource.strava ||
        !(needsCalories || needsRoute) ||
        !await _connected()) {
      return;
    }
    ...
      final detail = await _api.activity(id);
      if (needsCalories) {
        if (detail.calories case final kcal? when kcal > 0) {
          await _repo.setCalories(activity.id, kcal);
        }
      }
      if (needsRoute) {
        // Store '' too, so an activity without GPS isn't fetched again.
        await _repo.setRoute(activity.id, detail.summaryPolyline ?? '');
      }
```

Watch for one side effect: an activity with no calories was re-fetched every
time it was opened before this change as well; that behaviour is unchanged.

## 4. Geometry: decode, trim, fit

New file `lib/features/route/route_geometry.dart`. Pure Dart, no package.

```dart
import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

@immutable
class LatLng {
  const LatLng(this.lat, this.lng);
  final double lat;
  final double lng;
}

/// Decodes a Google encoded polyline (precision 5). Returns an empty list
/// for a malformed string.
List<LatLng> decodePolyline(String encoded) {
  final points = <LatLng>[];
  var index = 0;
  var lat = 0;
  var lng = 0;
  try {
    while (index < encoded.length) {
      for (var axis = 0; axis < 2; axis++) {
        var shift = 0;
        var result = 0;
        int byte;
        do {
          byte = encoded.codeUnitAt(index++) - 63;
          result |= (byte & 0x1f) << shift;
          shift += 5;
        } while (byte >= 0x20);
        final delta = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
        if (axis == 0) {
          lat += delta;
        } else {
          lng += delta;
        }
      }
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
  } on RangeError {
    return const [];
  }
  return points;
}

double _rad(double degrees) => degrees * math.pi / 180;

/// Great-circle distance in metres.
double distanceMetres(LatLng a, LatLng b) {
  const earth = 6371000.0;
  final dLat = _rad(b.lat - a.lat);
  final dLng = _rad(b.lng - a.lng);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.lat)) *
          math.cos(_rad(b.lat)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * earth * math.asin(math.sqrt(h));
}

/// Drops the first and last [metres] of [points], so the photo doesn't
/// show where the athlete lives. Empty when too little would remain.
List<LatLng> trimEnds(List<LatLng> points, double metres) {
  if (metres <= 0 || points.length < 2) return points;
  var total = 0.0;
  for (var i = 1; i < points.length; i++) {
    total += distanceMetres(points[i - 1], points[i]);
  }
  if (total < metres * 3) return const [];
  var start = 0;
  for (var walked = 0.0; start < points.length - 1 && walked < metres;) {
    walked += distanceMetres(points[start], points[start + 1]);
    start++;
  }
  var end = points.length - 1;
  for (var walked = 0.0; end > start && walked < metres;) {
    walked += distanceMetres(points[end], points[end - 1]);
    end--;
  }
  final kept = points.sublist(start, end + 1);
  return kept.length < 2 ? const [] : kept;
}

/// A route ready to draw: points as fractions (0–1) of a box whose
/// width / height is [aspectRatio], y pointing down.
@immutable
class RouteShape {
  const RouteShape({
    required this.points,
    required this.aspectRatio,
    required this.marks,
  });

  final List<Offset> points;
  final double aspectRatio;

  /// One point every [markEvery] metres (km or mile marks), same space.
  final List<Offset> marks;

  /// Null when there is no route to draw: no GPS, manual activity, or too
  /// short once trimmed.
  static RouteShape? fromPolyline(
    String? encoded, {
    double trimMetres = 0,
    double markEvery = 1000,
  }) {
    if (encoded == null || encoded.isEmpty) return null;
    final geo = trimEnds(decodePolyline(encoded), trimMetres);
    if (geo.length < 2) return null;

    // Equirectangular projection: fine at the scale of one activity.
    final meanLat =
        geo.map((p) => p.lat).reduce((a, b) => a + b) / geo.length;
    final k = math.cos(_rad(meanLat));
    Offset project(LatLng p) => Offset(p.lng * k, -p.lat);

    final raw = geo.map(project).toList();
    var minX = raw.first.dx, maxX = minX, minY = raw.first.dy, maxY = minY;
    for (final p in raw) {
      minX = math.min(minX, p.dx);
      maxX = math.max(maxX, p.dx);
      minY = math.min(minY, p.dy);
      maxY = math.max(maxY, p.dy);
    }
    var w = maxX - minX;
    var h = maxY - minY;
    if (w == 0 && h == 0) return null;
    // A straight out-and-back has no width (or height): give it some.
    w = math.max(w, h * 0.05);
    h = math.max(h, w * 0.05);
    Offset normalise(Offset p) => Offset((p.dx - minX) / w, (p.dy - minY) / h);

    final marks = <Offset>[];
    var walked = 0.0;
    var next = markEvery;
    for (var i = 1; i < geo.length; i++) {
      final step = distanceMetres(geo[i - 1], geo[i]);
      while (step > 0 && walked + step >= next) {
        final t = (next - walked) / step;
        final a = raw[i - 1];
        final b = raw[i];
        marks.add(normalise(Offset.lerp(a, b, t)!));
        next += markEvery;
      }
      walked += step;
    }

    return RouteShape(
      points: raw.map(normalise).toList(growable: false),
      aspectRatio: w / h,
      marks: marks,
    );
  }
}
```

Use `markEvery: 1609.344` when the user's units are imperial
(`lib/features/settings/units.dart`).

## 5. The painter

New file `lib/features/route/route_painter.dart`.

```dart
import 'package:run4share/app/material.dart';
import 'package:run4share/features/route/route_geometry.dart';

/// The route sticker styles. The name is stored in ExtraSticker.value.
enum RouteStyle { line, bold, dotted, glow, startFinish, kmMarks, seal }

class RoutePainter extends CustomPainter {
  RoutePainter({
    required this.shape,
    required this.style,
    required this.colour,
    this.stroke = 12,
  });

  final RouteShape shape;
  final RouteStyle style;
  final Color colour;

  /// In canvas units (the 1080-wide canvas), like the other stickers.
  final double stroke;

  Rect _fit(Size size) {
    final inset = stroke * 1.5;
    final box = Size(size.width - 2 * inset, size.height - 2 * inset);
    final fitted = box.width / box.height > shape.aspectRatio
        ? Size(box.height * shape.aspectRatio, box.height)
        : Size(box.width, box.width / shape.aspectRatio);
    return Alignment.center.inscribe(fitted, Offset(inset, inset) & box);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = _fit(size);
    Offset at(Offset p) =>
        Offset(r.left + p.dx * r.width, r.top + p.dy * r.height);

    final path = Path()..moveTo(at(shape.points.first).dx, at(shape.points.first).dy);
    for (final p in shape.points.skip(1)) {
      final q = at(p);
      path.lineTo(q.dx, q.dy);
    }

    Paint line(Color c, double width) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final outline = line(const Color(0x59000000), stroke * 1.8);
    switch (style) {
      case RouteStyle.line:
        canvas.drawPath(path, line(colour, stroke * 0.6));
      case RouteStyle.bold:
      case RouteStyle.seal:
        canvas
          ..drawPath(path, outline)
          ..drawPath(path, line(colour, stroke));
      case RouteStyle.dotted:
        final dot = Paint()..color = colour;
        for (final metric in path.computeMetrics()) {
          for (var d = 0.0; d < metric.length; d += stroke * 2.2) {
            final pos = metric.getTangentForOffset(d)!.position;
            canvas.drawCircle(pos, stroke * 0.55, dot);
          }
        }
      case RouteStyle.glow:
        canvas
          ..drawPath(
            path,
            line(colour.withValues(alpha: 0.45), stroke * 3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
          )
          ..drawPath(path, line(Colors.white, stroke * 0.6));
      case RouteStyle.startFinish:
        canvas
          ..drawPath(path, outline)
          ..drawPath(path, line(colour, stroke))
          ..drawCircle(at(shape.points.first), stroke * 1.6,
              Paint()..color = const Color(0xFF0D0C0A))
          ..drawCircle(at(shape.points.first), stroke * 1.6,
              line(colour, stroke * 0.6))
          ..drawCircle(at(shape.points.last), stroke * 1.8,
              Paint()..color = colour);
      case RouteStyle.kmMarks:
        canvas
          ..drawPath(path, outline)
          ..drawPath(path, line(colour, stroke));
        for (var i = 0; i < shape.marks.length; i++) {
          final c = at(shape.marks[i]);
          canvas.drawCircle(c, stroke * 2.4, Paint()..color = colour);
          final text = TextPainter(
            text: TextSpan(
              text: '${i + 1}',
              style: TextStyle(
                fontFamily: 'BarlowCondensed',
                fontWeight: FontWeight.w700,
                fontSize: stroke * 3,
                color: colour.computeLuminance() > 0.4
                    ? const Color(0xFF0D0C0A)
                    : Colors.white,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          text.paint(canvas, c - Offset(text.width / 2, text.height / 2));
        }
    }
  }

  @override
  bool shouldRepaint(RoutePainter old) =>
      old.shape != shape || old.style != style ||
      old.colour != colour || old.stroke != stroke;
}

/// The route sized for the 1080-wide canvas: longest side [extent].
class RouteView extends StatelessWidget {
  const RouteView({
    required this.shape,
    required this.style,
    required this.colour,
    this.extent = 620,
    super.key,
  });

  final RouteShape shape;
  final RouteStyle style;
  final Color colour;
  final double extent;

  @override
  Widget build(BuildContext context) {
    final a = shape.aspectRatio.clamp(0.45, 2.2);
    final size = a >= 1 ? Size(extent, extent / a) : Size(extent * a, extent);
    return CustomPaint(
      size: size,
      painter: RoutePainter(shape: shape, style: style, colour: colour),
    );
  }
}
```

Glow uses a blur, which looks right in the editor and in the export because
both draw through the same widget (`RepaintBoundary.toImage` in
`share_screen.dart`). Check it once on the Android phone; if the blur looks
too weak at export scale, raise the sigma.

## 6. Feed the route into stickers

### Privacy setting

Add next to `units.dart` a `route_privacy.dart`, built like units: preference
key `'route.trimEnds'`, **default true**, read in `main()` and overridden there
like `unitsPreference`. Expose:

```dart
const routeTrimMetres = 300.0;
final routeTrimProvider = Provider<double>(
  (ref) => ref.watch(routeTrimEndsProvider) ? routeTrimMetres : 0,
);
```

Add a switch to `settings_screen.dart` ("Hide the start and end of routes",
with a one-line hint).

### `StickerData` (`sticker_data.dart`)

```dart
  const StickerData({
    required this.stats,
    required this.sport,
    required this.weekday,
    this.route,
  });
  ...
  /// The route, trimmed for privacy; null without GPS.
  final RouteShape? route;

  /// Whether [theme] can be drawn for this activity.
  bool supports(StickerTheme theme) =>
      theme.metrics.every(has) && (!theme.needsRoute || route != null);
```

`stickerDataFor` gains `{double trimMetres = 0, double markEvery = 1000}` and
sets `route: RouteShape.fromPolyline(activity.routePolyline, trimMetres: trimMetres, markEvery: markEvery)`.
Find the call sites with `grep -rn stickerDataFor lib` and pass
`ref.watch(routeTrimProvider)` and the unit-based `markEvery`.

`missingFor` returns only metrics, so where a theme is refused, also check
`theme.needsRoute && data.route == null` and show a new message in
`theme_messages.dart` ("This activity has no GPS route").

### The free theme (`sticker_theme.dart`)

```dart
  /// The route on top, the metrics in a row under it.
  route,
```

Add `this.needsRoute = false` / `final bool needsRoute;` to `StickerTheme`, and
the theme:

```dart
  StickerTheme(
    id: 'route-line',
    name: 'Route Line',
    layout: StickerLayout.route,
    metrics: [Metric.distance, Metric.time],
    position: Offset(0.5, 0.58),
    needsRoute: true,
  ),
```

In `sticker_view.dart`, the `switch (theme.layout)` is exhaustive, so the
analyzer will point at it:

```dart
      StickerLayout.route => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RouteView(
              shape: data.route!,
              style: RouteStyle.bold,
              colour: ink.colour,
            ),
            const SizedBox(height: 36),
            _Inline(stats: _stats, ink: ink),
          ],
        ),
```

This way the colour swatches and the background gauge from Phase 4b work on the
route theme with no extra code.

### Pro route stickers

`creation_draft.dart` — new kind; `ExtraSticker.value` holds the
`RouteStyle` name, so the JSON format and saved creations don't change:

```dart
  /// The route, in a RouteStyle ("bold", "kmMarks"...).
  route,
```

`sticker_catalogue.dart`: `ExtraKind.route => StickerColour.white` in
`defaultColour` (the switch already has `_`, so add it explicitly).

`extra_sticker_view.dart`:

- add `this.route` (`final RouteShape? route;`) to `ExtraStickerView`;
- new case:

```dart
        ExtraKind.route => switch ((route, RouteStyle.values.asNameMap()[value])) {
            (final shape?, RouteStyle.seal) => _RouteSeal(
                shape: shape, start: start, colour: c),
            (final shape?, final style?) =>
              RouteView(shape: shape, style: style, colour: c.color),
            _ => const SizedBox.shrink(),
          },
```

- `_RouteSeal`: a 700×700 circle with a 10-unit border in `c.color`, the
  `RouteView` at `extent: 400` in the middle, and the date
  (`DateFormat('d MMM yyyy')` of `start`, upper-case) set on the ring.
  Reuse the ring-text drawing from the existing `_Seal` widget in the same
  file.
- pass `route:` wherever `start:` is passed: the wrapper at about line 311 of
  the same file, `stickers_panel.dart`, and `share_screen.dart:235`. Take it
  from the `StickerData` the editor already builds, so the trim setting is
  applied in one place.

`stickers_panel.dart` — new section after "For this activity", only when there
is a route:

```dart
            if (widget.route != null) ...[
              _Section(title: l10n.stickersRoute),
              _Row(
                children: [
                  for (final style in RouteStyle.values)
                    tile(ExtraKind.route, style.name, routeStyleName(l10n, style)),
                ],
              ),
            ],
```

The panel is already Pro-gated (`isPro` / `_ProMark`), so the route stickers
are Pro with no extra code.

## 7. Texts (all 5 languages)

Add to every `.arb` file, then `flutter gen-l10n` (or a build):

- `stickersRoute` — Route / Percurso / Recorrido / Parcours / Strecke
- `routeStyleLine`, `routeStyleBold`, `routeStyleDotted`, `routeStyleGlow`,
  `routeStyleStartFinish`, `routeStyleKmMarks`, `routeStyleSeal`
- `themeNeedsRoute` — "This activity has no GPS route"
- `settingsHideRouteEnds`, `settingsHideRouteEndsHint`

`test/l10n_test.dart` will flag any language missing a key.

## 8. Tests

| File | What it checks |
|---|---|
| `test/route/route_geometry_test.dart` (new) | `decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@')` gives (38.5, −120.2), (40.7, −120.95), (43.252, −126.453); malformed string → empty; `trimEnds` drops ≈ 300 m each side and returns empty for a short route; `fromPolyline('')` and `fromPolyline(null)` are null; all points within 0–1; km marks count ≈ distance ÷ 1000 |
| `test/data/migration_test.dart` | 3 → 4 adds `route_polyline`, existing rows keep their data |
| `test/editor/…` (sticker data) | `route-line` supported only when `route != null` |
| `test/stickers/extra_stickers_test.dart` | an `ExtraKind.route` sticker survives `toJson` / `fromJson`; unknown style draws nothing |
| `test/strava/…` | `StravaActivity.fromJson` reads `map.summary_polyline`; `fetchDetails` stores `''` for an activity without GPS and doesn't fetch it again |

## 9. Build order and check-points

1. Steps 1–3 + migration test → build, sync, confirm in the Laboratory or a
   debug print that `routePolyline` is filled for an outdoor run and `''` for a
   treadmill run.
2. Steps 4–5 + geometry tests (pure Dart, fastest feedback).
3. Step 6 free theme → check on the phone: route shape correct, not mirrored,
   colours and background gauge work, export matches the editor.
4. Step 6 Pro stickers + step 7 → check the Pro lock, each style on a light and a
   dark photo, the seal date in each language.
5. Privacy switch → the route visibly loses its ends when on.

6. Update `docs/privacy-policy.md`: the app now stores each activity's route
   on the phone (it never leaves the device except inside an image the user
   shares), and explain the trim setting.

## Open decisions

- **Route Line theme free?** The code's note says the seven launch themes are
  free and later themes can be Pro. This guide proposes keeping Route Line
  free, because the Strava sticker already shows the route for free.
- **Trim distance**: 300 m proposed; Strava's own privacy zones range from
  200 m to 1.6 km.
- **Tile maps** (street/topo/satellite): provider and cost, for a later phase.
