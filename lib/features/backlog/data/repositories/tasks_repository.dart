import '../../../activities/data/app_database.dart';
import '../../domain/task.dart' as domain;
import '../mappers/task_mapper.dart';

class TasksRepository {
  TasksRepository(this._db);

  final AppDatabase _db;

  Future<List<domain.Task>> getAll() async {
    final rows = await _db.select(_db.tasks).get();
    return rows.map(taskFromRow).toList();
  }

  Stream<List<domain.Task>> watchAll() {
    return _db
        .select(_db.tasks)
        .watch()
        .map((rows) => rows.map(taskFromRow).toList());
  }

  Future<domain.Task?> getById(String id) async {
    final row = await (_db.select(
      _db.tasks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return taskFromRow(row);
  }

  Future<void> save(domain.Task task) async {
    await _db.into(_db.tasks).insertOnConflictUpdate(toTaskCompanion(task));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteTaskOnly(String id) async {
    await delete(id);
  }

  Future<void> deleteTaskAndActivities(String taskId) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.activities,
      )..where((t) => t.taskId.equals(taskId))).go();
      await (_db.delete(_db.tasks)..where((t) => t.id.equals(taskId))).go();
    });
  }

  Future<int> countLinkedActivities(String taskId) async {
    final rows = await (_db.select(
      _db.activities,
    )..where((t) => t.taskId.equals(taskId))).get();
    return rows.length;
  }

  Future<void> setCompleted(String id, bool completed) async {
    final task = await getById(id);
    if (task == null) return;
    final updated = completed
        ? task.copyWith(completedAt: DateTime.now())
        : task.copyWith(clearCompletedAt: true);
    await save(updated);
  }
}
