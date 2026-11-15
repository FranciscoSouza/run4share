import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/rate/rate_prompt.dart';

import '../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late RatePrompt prompt;

  setUp(() {
    db = testDatabase();
    now = DateTime.utc(2026, 11, 15);
    prompt = RatePrompt(db, () => now);
    addTearDown(db.close);
  });

  Future<void> saves(int count) async {
    for (var i = 0; i < count; i++) {
      await prompt.recordSave();
    }
  }

  test('not before the third saved image', () async {
    await saves(2);
    expect(await prompt.shouldAsk(), isFalse);
    await saves(1);
    expect(await prompt.shouldAsk(), isTrue);
  });

  test('at most every 90 days', () async {
    await saves(3);
    expect(await prompt.shouldAsk(), isTrue);
    await prompt.notNow();
    now = now.add(const Duration(days: 89));
    expect(await prompt.shouldAsk(), isFalse);
    now = now.add(const Duration(days: 2));
    expect(await prompt.shouldAsk(), isTrue);
  });

  test('never again after a second "Not now"', () async {
    await saves(3);
    await prompt.notNow();
    await prompt.notNow();
    now = now.add(const Duration(days: 400));
    expect(await prompt.shouldAsk(), isFalse);
  });

  test('never again after rating or feedback', () async {
    await saves(3);
    await prompt.answered();
    now = now.add(const Duration(days: 400));
    expect(await prompt.shouldAsk(), isFalse);
  });
}
