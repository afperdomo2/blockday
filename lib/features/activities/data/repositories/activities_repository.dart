import 'package:drift/drift.dart';

import '../../domain/activity.dart' as domain;
import '../app_database.dart';
import '../mappers/activity_mapper.dart';

class ActivitiesRepository {
  ActivitiesRepository(this._db);

  final AppDatabase _db;

  Future<List<domain.Activity>> getAll() async {
    final rows = await _db.select(_db.activities).get();
    final result = <domain.Activity>[];
    for (final row in rows) {
      final exclusions = await (_db.select(
        _db.activityExclusions,
      )..where((t) => t.activityId.equals(row.id))).get();
      result.add(fromRow(row, exclusions));
    }
    return result;
  }

  Stream<List<domain.Activity>> watchAll() {
    return _db.select(_db.activities).watch().asyncMap((rows) async {
      final result = <domain.Activity>[];
      for (final row in rows) {
        final exclusions = await (_db.select(
          _db.activityExclusions,
        )..where((t) => t.activityId.equals(row.id))).get();
        result.add(fromRow(row, exclusions));
      }
      return result;
    });
  }

  Future<domain.Activity?> getById(String id) async {
    final row = await (_db.select(
      _db.activities,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final exclusions = await (_db.select(
      _db.activityExclusions,
    )..where((t) => t.activityId.equals(id))).get();
    return fromRow(row, exclusions);
  }

  Future<void> save(domain.Activity activity) async {
    await _db.transaction(() async {
      await _db
          .into(_db.activities)
          .insertOnConflictUpdate(toCompanion(activity));
      await (_db.delete(
        _db.activityExclusions,
      )..where((t) => t.activityId.equals(activity.id))).go();
      for (final d in activity.excludedDates) {
        final normalized = DateTime(d.year, d.month, d.day);
        await _db
            .into(_db.activityExclusions)
            .insert(
              ActivityExclusionsCompanion(
                activityId: Value(activity.id),
                excludedDate: Value(normalized.millisecondsSinceEpoch),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.activities)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addExclusion(String activityId, DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    await _db
        .into(_db.activityExclusions)
        .insert(
          ActivityExclusionsCompanion(
            activityId: Value(activityId),
            excludedDate: Value(normalized.millisecondsSinceEpoch),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> removeExclusion(String activityId, DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    await (_db.delete(_db.activityExclusions)
          ..where((t) => t.activityId.equals(activityId))
          ..where(
            (t) => t.excludedDate.equals(normalized.millisecondsSinceEpoch),
          ))
        .go();
  }
}
