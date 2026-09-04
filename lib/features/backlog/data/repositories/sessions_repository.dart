import 'package:drift/drift.dart';

import '../../../activities/data/app_database.dart';

class SessionsRepository {
  SessionsRepository(this._db);

  final AppDatabase _db;

  Stream<List<ActivitySession>> watchAll() {
    return _db.select(_db.activitySessions).watch();
  }

  Future<List<ActivitySession>> getAll() async {
    return _db.select(_db.activitySessions).get();
  }

  Future<List<ActivitySession>> getForActivity(String activityId) async {
    return (_db.select(
      _db.activitySessions,
    )..where((t) => t.activityId.equals(activityId))).get();
  }

  Stream<List<ActivitySession>> watchForActivity(String activityId) {
    return (_db.select(
      _db.activitySessions,
    )..where((t) => t.activityId.equals(activityId))).watch();
  }

  Future<ActivitySession?> getByActivityAndDate(
    String activityId,
    DateTime date,
  ) async {
    final normalized = DateTime(date.year, date.month, date.day);
    return (_db.select(_db.activitySessions)
          ..where((t) => t.activityId.equals(activityId))
          ..where((t) => t.date.equals(normalized.millisecondsSinceEpoch)))
        .getSingleOrNull();
  }

  Future<void> markCompleted(
    String activityId,
    DateTime date, {
    int? actualMinutes,
  }) async {
    final normalized = DateTime(date.year, date.month, date.day);
    await _db
        .into(_db.activitySessions)
        .insertOnConflictUpdate(
          ActivitySessionsCompanion(
            activityId: Value(activityId),
            date: Value(normalized.millisecondsSinceEpoch),
            completedAt: Value(DateTime.now().millisecondsSinceEpoch),
            actualMinutes: Value(actualMinutes),
          ),
        );
  }

  Future<void> unmarkCompleted(String activityId, DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    await (_db.delete(_db.activitySessions)
          ..where((t) => t.activityId.equals(activityId))
          ..where((t) => t.date.equals(normalized.millisecondsSinceEpoch)))
        .go();
  }

  Future<void> toggleCompleted(
    String activityId,
    DateTime date, {
    int? actualMinutes,
  }) async {
    final existing = await getByActivityAndDate(activityId, date);
    final isCompleted = existing?.completedAt != null;
    if (isCompleted) {
      await unmarkCompleted(activityId, date);
    } else {
      await markCompleted(activityId, date, actualMinutes: actualMinutes);
    }
  }

  Future<bool> isCompleted(String activityId, DateTime date) async {
    final s = await getByActivityAndDate(activityId, date);
    return s?.completedAt != null;
  }
}
