import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/backlog/domain/task.dart';
import 'package:blockday/features/search/domain/search_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final task = Task(
    id: 't1',
    title: 'Estudiar AWS',
    notes: 'Certificación de la nube',
    tags: ['estudio', 'casa'],
  );
  final plainTask = Task(id: 't2', title: 'Comprar regalo');
  final start = DateTime(2026, 11, 19, 10, 0);
  final activity = Activity(
    id: 'a1',
    title: 'Curso virtual',
    notes: 'Traer apuntes',
    color: 0,
    kind: ActivityKind.single,
    singleStart: start,
    singleEnd: start.add(const Duration(hours: 2)),
  );

  group('textMatches', () {
    test('query vacío matchea todo', () {
      expect(textMatches(null, ''), true);
      expect(textMatches('cualquier cosa', '  '), true);
    });

    test('insensible a mayúsculas y espacios', () {
      expect(textMatches('Estudiar AWS', '  aws '), true);
      expect(textMatches('Estudiar AWS', 'AWS'), true);
    });

    test('no matchea ausencia de texto', () {
      expect(textMatches(null, 'aws'), false);
      expect(textMatches('otra cosa', 'aws'), false);
    });
  });

  group('taskMatchesQuery', () {
    test('busca en título', () {
      expect(taskMatchesQuery(task, 'aws'), true);
    });

    test('busca en notas', () {
      expect(taskMatchesQuery(task, 'nube'), true);
    });

    test('busca en etiquetas', () {
      expect(taskMatchesQuery(task, 'casa'), true);
    });

    test('no matchea sin coincidencia', () {
      expect(taskMatchesQuery(plainTask, 'aws'), false);
    });
  });

  group('activityMatchesQuery', () {
    test('busca en título y notas', () {
      expect(activityMatchesQuery(activity, 'curso'), true);
      expect(activityMatchesQuery(activity, 'apuntes'), true);
      expect(activityMatchesQuery(activity, 'aws'), false);
    });
  });

  group('filtros de listas', () {
    test('filterTasks conserva solo coincidencias', () {
      expect(filterTasks([task, plainTask], 'aws'), [task]);
      expect(filterTasks([task, plainTask], ''), hasLength(2));
    });

    test('filterActivities conserva solo coincidencias', () {
      expect(filterActivities([activity], 'curso'), [activity]);
      expect(filterActivities([activity], 'nada'), isEmpty);
    });
  });
}
