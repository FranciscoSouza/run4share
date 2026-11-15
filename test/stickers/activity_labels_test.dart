import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/stickers/activity_labels.dart';

int _ids = 0;

Activity run(
  double metres,
  int seconds, {
  String sport = 'Run',
  int? prCount,
  bool race = false,
}) =>
    Activity(
      id: ++_ids,
      source: ActivitySource.manual,
      name: 'Run',
      sportType: sport,
      startLocal: DateTime.utc(2026, 11, 15, 7),
      distance: metres,
      movingTime: seconds,
      prCount: prCount,
      race: race,
    );

List<LabelKind> kinds(Activity a, [List<Activity> history = const []]) =>
    labelsFor(a, history).map((l) => l.kind).toList();

void main() {
  test('mark texts', () {
    expect(markText(25 * 60), '25');
    expect(markText(105 * 60), '1:45');
    expect(markText(180 * 60), '3');
  });

  group('Sub-X', () {
    String? sub(double metres, int seconds) => labelsFor(
          run(metres, seconds),
          const [],
        ).where((l) => l.kind == LabelKind.subMark).firstOrNull?.mark;

    test('the best round mark beaten', () {
      expect(sub(5000, 24 * 60 + 59), '25');
      expect(sub(5000, 19 * 60 + 30), '20');
      expect(sub(5000, 25 * 60), '30', reason: '25:00 is not under 25');
      expect(sub(10050, 47 * 60), '50');
      expect(sub(21100, 6950), '2');
      expect(sub(21097, 104 * 60), '1:45');
      expect(sub(42195, 3 * 3600 + 59 * 60), '4');
    });

    test('only near race distances, and only runs', () {
      expect(sub(7000, 20 * 60), isNull);
      expect(sub(5600, 20 * 60), isNull, reason: 'too long for a 5K');
      expect(sub(5000, 40 * 60), isNull, reason: 'slower than every mark');
      expect(
        labelsFor(run(5000, 20 * 60, sport: 'Ride'), const []),
        isEmpty,
      );
    });
  });

  test('long run is a run of 15 km or more', () {
    expect(kinds(run(15000, 5400)), contains(LabelKind.longRun));
    expect(kinds(run(14999, 5400)), isNot(contains(LabelKind.longRun)));
    expect(
      kinds(run(40000, 5400, sport: 'Ride')),
      isNot(contains(LabelKind.longRun)),
    );
  });

  test('race day comes from the race flag', () {
    expect(kinds(run(7000, 2400, race: true)), contains(LabelKind.raceDay));
    expect(kinds(run(7000, 2400)), isNot(contains(LabelKind.raceDay)));
  });

  group('record', () {
    test('a Strava PR', () {
      expect(kinds(run(7000, 2400, prCount: 1)), contains(LabelKind.record));
    });

    test('the longest of its sport in run4share', () {
      final history = [run(8000, 2800), run(6000, 2000)];
      final longest = run(9000, 3600);
      expect(kinds(longest, history), contains(LabelKind.record));
    });

    test('the fastest among activities at least as long', () {
      final history = [run(10000, 3600), run(12000, 4200)];
      final fast = run(10000, 3000);
      expect(kinds(fast, history), contains(LabelKind.record));
      final slow = run(10000, 4000);
      expect(kinds(slow, history), isNot(contains(LabelKind.record)));
    });

    test('nothing to compare with: no record', () {
      expect(kinds(run(10000, 3000)), isNot(contains(LabelKind.record)));
    });

    test('other sports do not count', () {
      final history = [run(30000, 3600, sport: 'Ride')];
      final labels = kinds(run(10000, 3000), history);
      expect(labels, isNot(contains(LabelKind.record)));
    });
  });
}
