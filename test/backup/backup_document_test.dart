import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/activities/domain/recurrence_end.dart';
import 'package:blockday/features/activities/domain/recurrence_rule.dart';
import 'package:blockday/features/backup/domain/backup_document.dart';
import 'package:blockday/features/backlog/domain/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final singleStart = DateTime(2026, 11, 19, 10, 0);

  BackupData sampleData() {
    return BackupData(
      tasks: [
        Task(
          id: 't1',
          title: 'Estudiar AWS',
          notes: 'Certificación',
          kind: TaskKind.learning,
          estimatedMinutes: 600,
          tags: ['estudio', 'certificación'],
          createdAt: DateTime(2026, 11, 1),
          completedAt: DateTime(2026, 11, 10),
        ),
        Task(id: 't2', title: 'Comprar regalo'),
      ],
      activities: [
        Activity(
          id: 'a1',
          title: 'Curso virtual',
          color: 3,
          kind: ActivityKind.single,
          singleStart: singleStart,
          singleEnd: singleStart.add(const Duration(hours: 2)),
          taskId: 't1',
          reminderMinutes: 15,
          excludedDates: {DateTime(2026, 11, 20)},
        ),
        Activity(
          id: 'a2',
          title: 'Buscar trabajo',
          color: 1,
          kind: ActivityKind.recurring,
          rule: RecurrenceRule(
            startMinutes: 17 * 60,
            endMinutes: 19 * 60,
            weekdays: {DateTime.monday, DateTime.friday},
            firstDate: DateTime(2026, 11, 2),
            end: RecurrenceUntil(DateTime(2027, 1, 1)),
          ),
        ),
      ],
      sessions: [
        SessionEntry(
          activityId: 'a1',
          date: DateTime(2026, 11, 19),
          completedAt: DateTime(2026, 11, 19, 12, 5),
          actualMinutes: 110,
        ),
        SessionEntry(activityId: 'a2', date: DateTime(2026, 11, 2)),
      ],
    );
  }

  group('encode/decode round-trip', () {
    test('conserva tareas, actividades, exclusiones y sesiones', () {
      final data = sampleData();
      final decoded = decodeBackup(encodeBackup(data));

      expect(decoded.tasks, data.tasks);
      expect(decoded.activities, data.activities);
      expect(decoded.sessions, data.sessions);
    });

    test('conserva el recordatorio y las etiquetas', () {
      final decoded = decodeBackup(encodeBackup(sampleData()));
      expect(decoded.tasks.first.tags, ['estudio', 'certificación']);
      expect(decoded.activities.first.reminderMinutes, 15);
    });

    test('conserva la regla de recurrencia completa', () {
      final decoded = decodeBackup(encodeBackup(sampleData()));
      final rule = decoded.activities[1].rule!;
      expect(rule.weekdays, {DateTime.monday, DateTime.friday});
      expect(rule.firstDate, DateTime(2026, 11, 2));
      expect(rule.end, RecurrenceUntil(DateTime(2027, 1, 1)));
    });

    test('una copia vacía hace round-trip', () {
      final decoded = decodeBackup(encodeBackup(const BackupData()));
      expect(decoded.tasks, isEmpty);
      expect(decoded.activities, isEmpty);
      expect(decoded.sessions, isEmpty);
    });
  });

  group('decodeBackup valida el archivo', () {
    test('JSON inválido', () {
      expect(
        () => decodeBackup('esto no es json'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('no es un mapa', () {
      expect(
        () => decodeBackup('[1, 2]'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('app incorrecta', () {
      expect(
        () => decodeBackup('{"app":"otra","version":1}'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('versión no soportada', () {
      expect(
        () => decodeBackup('{"app":"blockday","version":99}'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('tarea con campos obligatorios faltantes', () {
      expect(
        () => decodeBackup(
          '{"app":"blockday","version":1,"tasks":[{"id":"t1"}]}',
        ),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('actividad que referencia una tarea inexistente', () {
      expect(
        () => decodeBackup(
          '{"app":"blockday","version":1,"activities":['
          '{"id":"a1","title":"x","color":0,"kind":"single",'
          '"singleStart":0,"singleEnd":1,"taskId":"fantasma"}]}',
        ),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('sesión que referencia una actividad inexistente', () {
      expect(
        () => decodeBackup(
          '{"app":"blockday","version":1,"sessions":['
          '{"activityId":"fantasma","date":0}]}',
        ),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });
}
