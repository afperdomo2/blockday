import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

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

@DriftDatabase(tables: [Activities, ActivityExclusions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'blockday.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
