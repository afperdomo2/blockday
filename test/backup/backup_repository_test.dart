import 'package:blockday/features/activities/data/app_database.dart'
    hide Activity, Task;
import 'package:blockday/features/activities/data/repositories/activities_repository.dart';
import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/activities/domain/recurrence_end.dart';
import 'package:blockday/features/activities/domain/recurrence_rule.dart';
import 'package:blockday/features/backup/data/backup_repository.dart';
import 'package:blockday/features/backup/domain/backup_document.dart';
import 'package:blockday/features/backlog/data/repositories/tasks_repository.dart';
import 'package:blockday/features/backlog/data/repositories/sessions_repository.dart';
import 'package:blockday/features/backlog/domain/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase source;
  late AppDatabase target;

  setUp(() {
    source = AppDatabase.memory();
    target = AppDatabase.memory();
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  Future<void> seed(AppDatabase db) async {
    final tasksRepo = TasksRepository(db);
    final activitiesRepo = ActivitiesRepository(db);
    await tasksRepo.save(
      Task(
        id: 't1',
        title: 'Estudiar AWS',
        tags: ['estudio'],
        estimatedMinutes: 600,
      ),
    );
    final start = DateTime(2026, 11, 19, 10, 0);
    await activitiesRepo.save(
      Activity(
        id: 'a1',
        title: 'Curso',
        color: 2,
        kind: ActivityKind.single,
        singleStart: start,
        singleEnd: start.add(const Duration(hours: 2)),
        taskId: 't1',
        reminderMinutes: 15,
      ),
    );
    await activitiesRepo.save(
      Activity(
        id: 'a2',
        title: 'Rutina',
        color: 0,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 9 * 60,
          endMinutes: 10 * 60,
          weekdays: {DateTime.tuesday},
          firstDate: DateTime(2026, 11, 3),
          end: const RecurrenceNever(),
        ),
      ),
    );
    await activitiesRepo.addExclusion('a2', DateTime(2026, 11, 10));
    await SessionsRepository(db)
        .markCompleted('a1', DateTime(2026, 11, 19), actualMinutes: 110);
  }

  test('export → import no pierde datos', () async {
    await seed(source);
    final json = await BackupRepository(source).exportJson();

    await BackupRepository(target).importReplaceAll(json);

    final targetTasks = await TasksRepository(target).getAll();
    final sourceTasks = await TasksRepository(source).getAll();
    expect(targetTasks, sourceTasks);

    final targetActivities = await ActivitiesRepository(target).getAll();
    final sourceActivities = await ActivitiesRepository(source).getAll();
    expect(targetActivities, sourceActivities);
    expect(targetActivities.first.reminderMinutes, 15);
    expect(targetActivities.firstWhere((a) => a.id == 'a2').excludedDates, {
      DateTime(2026, 11, 10),
    });

    final sourceJson = await BackupRepository(source).exportJson();
    final targetJson = await BackupRepository(target).exportJson();
    final sourceData = decodeBackup(sourceJson);
    final targetData = decodeBackup(targetJson);
    expect(targetData.sessions, sourceData.sessions);
  });

  test('importar reemplaza los datos existentes', () async {
    await seed(source);
    final json = await BackupRepository(source).exportJson();

    await TasksRepository(target)
        .save(Task(id: 'previa', title: 'Tarea previa'));
    await BackupRepository(target).importReplaceAll(json);

    final targetTasks = await TasksRepository(target).getAll();
    expect(targetTasks.map((t) => t.id), ['t1']);
  });

  test('importar un archivo inválido no toca los datos', () async {
    await seed(target);
    final before = await TasksRepository(target).getAll();

    expect(
      () => BackupRepository(target).importReplaceAll('no es json'),
      throwsA(isA<BackupFormatException>()),
    );

    final after = await TasksRepository(target).getAll();
    expect(after, before);
  });

  test('exportar una base vacía produce una copia válida', () async {
    final json = await BackupRepository(source).exportJson();
    final data = decodeBackup(json);
    expect(data.tasks, isEmpty);
    expect(data.activities, isEmpty);
    expect(data.sessions, isEmpty);
  });
}
