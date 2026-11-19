import 'package:blockday/features/backlog/domain/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task.normalizeTags', () {
    test('recorta espacios y descarta vacíos', () {
      expect(Task.normalizeTags(['  trabajo ', '', '   ']), ['trabajo']);
    });

    test('deduplica ignorando mayúsculas conservando la primera forma', () {
      expect(Task.normalizeTags(['Trabajo', 'trabajo', 'TRABAJO']), [
        'Trabajo',
      ]);
    });

    test('conserva el orden de aparición', () {
      expect(Task.normalizeTags(['b', 'a', 'c']), ['b', 'a', 'c']);
    });
  });

  group('Task con etiquetas', () {
    test('normaliza las etiquetas al construir', () {
      final task = Task(
        id: '1',
        title: 'Tarea',
        tags: [' casa ', '', 'casa', 'salud'],
      );
      expect(task.tags, ['casa', 'salud']);
    });

    test('sin etiquetas queda como lista vacía', () {
      final task = Task(id: '1', title: 'Tarea');
      expect(task.tags, isEmpty);
    });

    test('hasTag ignora mayúsculas y espacios', () {
      final task = Task(id: '1', title: 'Tarea', tags: ['Casa']);
      expect(task.hasTag('casa'), true);
      expect(task.hasTag('  CASA '), true);
      expect(task.hasTag('otra'), false);
    });

    test('copyWith reemplaza las etiquetas', () {
      final task = Task(id: '1', title: 'Tarea', tags: ['a']);
      expect(task.copyWith(tags: ['b', 'c']).tags, ['b', 'c']);
    });

    test('igualdad incluye etiquetas', () {
      final a = Task(id: '1', title: 'Tarea', tags: ['a']);
      final b = Task(id: '1', title: 'Tarea', tags: ['a']);
      final c = Task(id: '1', title: 'Tarea', tags: ['b']);
      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
