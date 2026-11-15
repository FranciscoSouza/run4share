import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('a schema-1 database (phase 2-4 phones) upgrades and keeps data',
      () async {
    final dir = Directory.systemTemp.createTempSync('migration');
    final file = File('${dir.path}/run4share.sqlite');

    // What phases 2-4 created: activities and preferences, user_version 1.
    sqlite.sqlite3.open(file.path)
      ..execute('''
        CREATE TABLE activities (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          source TEXT NOT NULL, source_id TEXT NULL, name TEXT NOT NULL,
          sport_type TEXT NOT NULL, start_local TEXT NOT NULL,
          start_utc TEXT NULL, distance REAL NULL,
          moving_time INTEGER NOT NULL, elapsed_time INTEGER NULL,
          average_speed REAL NULL, average_heartrate REAL NULL,
          calories REAL NULL, elevation_gain REAL NULL,
          UNIQUE (source, source_id));
        CREATE TABLE preferences (
          "key" TEXT NOT NULL, value TEXT NOT NULL, PRIMARY KEY ("key"));
        INSERT INTO activities (source, name, sport_type, start_local,
          moving_time) VALUES ('manual', 'Old run', 'Run',
          '2026-11-10T07:00:00.000Z', 1800);
        INSERT INTO preferences VALUES ('units', 'mi');
        PRAGMA user_version = 1;
      ''')
      ..close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final activities = await ActivityRepository(db).watchAll().first;
    expect(activities.single.name, 'Old run');
    expect(await db.readPreference('units'), 'mi');
    expect(await db.select(db.creations).get(), isEmpty);
  });
}
