import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get kind => text()();
  IntColumn get estimatedMinutes => integer().nullable()();
  TextColumn get tags => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get completedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  IntColumn get color => integer()();
  TextColumn get kind => text()();
  IntColumn get singleStart => integer().nullable()();
  IntColumn get singleEnd => integer().nullable()();
  IntColumn get weekdays => integer().nullable()();
  IntColumn get firstDate => integer().nullable()();
  IntColumn get startMinutes => integer().nullable()();
  IntColumn get endMinutes => integer().nullable()();
  TextColumn get endType => text().nullable()();
  IntColumn get endValue => integer().nullable()();
  TextColumn get taskId => text().nullable().customConstraint(
    'NULL REFERENCES tasks(id) ON DELETE SET NULL',
  )();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ActivityExclusions extends Table {
  TextColumn get activityId =>
      text().customConstraint('REFERENCES activities(id) ON DELETE CASCADE')();
  IntColumn get excludedDate => integer()();

  @override
  Set<Column<Object>> get primaryKey => {activityId, excludedDate};
}

class ActivitySessions extends Table {
  TextColumn get activityId =>
      text().customConstraint('REFERENCES activities(id) ON DELETE CASCADE')();
  IntColumn get date => integer()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get actualMinutes => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {activityId, date};
}

@DriftDatabase(
  tables: [Tasks, Activities, ActivityExclusions, ActivitySessions],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(tasks);
        await m.createTable(activitySessions);
        await m.addColumn(activities, activities.taskId);
      }
      if (from < 3) {
        await m.addColumn(tasks, tasks.completedAt);
        try {
          await customStatement('ALTER TABLE tasks DROP COLUMN status');
        } catch (_) {}
      }
      if (from < 4) {
        await m.addColumn(tasks, tasks.tags);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'blockday.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
