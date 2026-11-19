import 'package:drift/drift.dart';

import '../../activities/data/app_database.dart' hide Activity;
import '../../activities/data/mappers/activity_mapper.dart' as activity_mapper;
import '../../activities/domain/activity.dart';
import '../../backlog/data/mappers/task_mapper.dart' as task_mapper;
import '../domain/backup_document.dart';

class BackupRepository {
  BackupRepository(this._db);

  final AppDatabase _db;

  Future<String> exportJson({DateTime? exportedAt}) async {
    final taskRows = await _db.select(_db.tasks).get();
    final tasks = taskRows.map(task_mapper.taskFromRow).toList();

    final activityRows = await _db.select(_db.activities).get();
    final activities = <Activity>[];
    for (final row in activityRows) {
      final exclusions = await (_db.select(
        _db.activityExclusions,
      )..where((e) => e.activityId.equals(row.id))).get();
      activities.add(activity_mapper.fromRow(row, exclusions));
    }

    final sessionRows = await _db.select(_db.activitySessions).get();
    final sessions = sessionRows
        .map(
          (r) => SessionEntry(
            activityId: r.activityId,
            date: DateTime.fromMillisecondsSinceEpoch(r.date),
            completedAt: r.completedAt == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(r.completedAt!),
            actualMinutes: r.actualMinutes,
          ),
        )
        .toList();

    return encodeBackup(
      BackupData(tasks: tasks, activities: activities, sessions: sessions),
      exportedAt: exportedAt,
    );
  }

  Future<void> importReplaceAll(String json) async {
    final data = decodeBackup(json);
    await _db.transaction(() async {
      await _db.delete(_db.activitySessions).go();
      await _db.delete(_db.activityExclusions).go();
      await _db.delete(_db.activities).go();
      await _db.delete(_db.tasks).go();

      for (final task in data.tasks) {
        await _db
            .into(_db.tasks)
            .insertOnConflictUpdate(task_mapper.toTaskCompanion(task));
      }
      for (final activity in data.activities) {
        await _db
            .into(_db.activities)
            .insertOnConflictUpdate(activity_mapper.toCompanion(activity));
        for (final date in activity.excludedDates) {
          await _db
              .into(_db.activityExclusions)
              .insertOnConflictUpdate(
                ActivityExclusionsCompanion(
                  activityId: Value(activity.id),
                  excludedDate: Value(date.millisecondsSinceEpoch),
                ),
              );
        }
      }
      for (final session in data.sessions) {
        await _db
            .into(_db.activitySessions)
            .insertOnConflictUpdate(
              ActivitySessionsCompanion(
                activityId: Value(session.activityId),
                date: Value(session.date.millisecondsSinceEpoch),
                completedAt: Value(session.completedAt?.millisecondsSinceEpoch),
                actualMinutes: Value(session.actualMinutes),
              ),
            );
      }
    });
  }
}
