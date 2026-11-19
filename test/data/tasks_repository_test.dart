import 'package:blockday/features/activities/data/app_database.dart' hide Task;
import 'package:blockday/features/backlog/data/repositories/tasks_repository.dart';
import 'package:blockday/features/backlog/domain/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TasksRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = TasksRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('round-trip conserva las etiquetas', () async {
    final task = Task(
      id: 't1',
      title: 'Estudiar AWS',
      tags: ['estudio', 'certificación'],
    );
    await repo.save(task);
    final loaded = await repo.getById('t1');
    expect(loaded, isNotNull);
    expect(loaded!.tags, ['estudio', 'certificación']);
  });

  test('tarea sin etiquetas carga como lista vacía', () async {
    await repo.save(Task(id: 't2', title: 'Sin etiquetas'));
    final loaded = await repo.getById('t2');
    expect(loaded!.tags, isEmpty);
  });

  test('guardar de nuevo actualiza las etiquetas', () async {
    await repo.save(Task(id: 't3', title: 'Tarea', tags: ['a']));
    await repo.save(Task(id: 't3', title: 'Tarea', tags: ['b']));
    final loaded = await repo.getById('t3');
    expect(loaded!.tags, ['b']);
  });

  test('watchAll emite las etiquetas', () async {
    await repo.save(Task(id: 't4', title: 'Tarea', tags: ['casa']));
    final all = await repo.getAll();
    expect(all.single.tags, ['casa']);
  });
}
