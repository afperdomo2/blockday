import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/activities/domain/recurrence_end.dart';
import 'package:blockday/features/activities/domain/recurrence_rule.dart';
import 'package:blockday/features/notifications/domain/reminder_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 18, 8, 0);
  final horizonEnd = now.add(const Duration(days: reminderHorizonDays));

  Activity singleActivity({DateTime? start, int? reminder}) {
    final s = start ?? DateTime(2026, 11, 19, 10, 0);
    return Activity(
      id: 'a1',
      title: 'Curso',
      color: 0,
      kind: ActivityKind.single,
      singleStart: s,
      singleEnd: s.add(const Duration(hours: 2)),
      reminderMinutes: reminder,
    );
  }

  group('computeReminders', () {
    test('dispara N minutos antes del inicio', () {
      final reminders = computeReminders(
        activity: singleActivity(),
        reminderMinutesBefore: 15,
        now: now,
        horizonEnd: horizonEnd,
      );
      expect(reminders, hasLength(1));
      expect(reminders.single.fireAt, DateTime(2026, 11, 19, 9, 45));
      expect(reminders.single.occurrenceStart, DateTime(2026, 11, 19, 10, 0));
      expect(reminders.single.title, 'Curso');
    });

    test('con recordatorio de 1 hora dispara a las 9:00', () {
      final reminders = computeReminders(
        activity: singleActivity(),
        reminderMinutesBefore: 60,
        now: now,
        horizonEnd: horizonEnd,
      );
      expect(reminders.single.fireAt, DateTime(2026, 11, 19, 9, 0));
    });

    test('descarta disparos en el pasado o ya pasados', () {
      final reminders = computeReminders(
        activity: singleActivity(start: DateTime(2026, 11, 18, 8, 10)),
        reminderMinutesBefore: 15,
        now: now,
        horizonEnd: horizonEnd,
      );
      expect(reminders, isEmpty);
    });

    test('incluye disparos justo después de ahora', () {
      final reminders = computeReminders(
        activity: singleActivity(start: DateTime(2026, 11, 18, 8, 20)),
        reminderMinutesBefore: 15,
        now: now,
        horizonEnd: horizonEnd,
      );
      expect(reminders.single.fireAt, DateTime(2026, 11, 18, 8, 5));
    });

    test('actividad recurrente agenda cada ocurrencia del horizonte', () {
      final activity = Activity(
        id: 'a2',
        title: 'Buscar trabajo',
        color: 0,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 17 * 60,
          endMinutes: 19 * 60,
          weekdays: {DateTime.monday, DateTime.wednesday, DateTime.friday},
          firstDate: DateTime(2026, 11, 16),
          end: const RecurrenceNever(),
        ),
      );
      final reminders = computeReminders(
        activity: activity,
        reminderMinutesBefore: 10,
        now: now,
        horizonEnd: DateTime(2026, 11, 22),
      );
      expect(reminders, hasLength(2));
      expect(reminders[0].fireAt, DateTime(2026, 11, 18, 16, 50));
      expect(reminders[1].fireAt, DateTime(2026, 11, 20, 16, 50));
    });

    test('las fechas excluidas no generan recordatorio', () {
      final activity = singleActivity().copyWith(
        excludedDates: {DateTime(2026, 11, 19)},
      );
      final reminders = computeReminders(
        activity: activity,
        reminderMinutesBefore: 15,
        now: now,
        horizonEnd: horizonEnd,
      );
      expect(reminders, isEmpty);
    });

    test('solo agenda dentro del horizonte', () {
      final reminders = computeReminders(
        activity: singleActivity(start: DateTime(2026, 12, 20, 10, 0)),
        reminderMinutesBefore: 15,
        now: now,
        horizonEnd: horizonEnd,
      );
      expect(reminders, isEmpty);
    });

    test('rechaza minutos fuera de rango', () {
      expect(
        () => computeReminders(
          activity: singleActivity(),
          reminderMinutesBefore: -1,
          now: now,
          horizonEnd: horizonEnd,
        ),
        throwsArgumentError,
      );
      expect(
        () => computeReminders(
          activity: singleActivity(),
          reminderMinutesBefore: Activity.maxReminderMinutes + 1,
          now: now,
          horizonEnd: horizonEnd,
        ),
        throwsArgumentError,
      );
    });
  });

  group('reminderNotificationId', () {
    test('es estable para la misma actividad y fecha', () {
      final date = DateTime(2026, 11, 19);
      expect(
        reminderNotificationId('a1', date),
        reminderNotificationId('a1', date),
      );
    });

    test('difiere entre actividades y entre fechas', () {
      final date = DateTime(2026, 11, 19);
      expect(
        reminderNotificationId('a1', date),
        isNot(reminderNotificationId('a2', date)),
      );
      expect(
        reminderNotificationId('a1', date),
        isNot(reminderNotificationId('a1', DateTime(2026, 11, 20))),
      );
    });

    test('caben en un entero positivo de 31 bits', () {
      final id = reminderNotificationId(
        'actividad-muy-larga-12345',
        DateTime.now(),
      );
      expect(id, greaterThan(0));
      expect(id, lessThanOrEqualTo(0x7fffffff));
    });
  });
}
