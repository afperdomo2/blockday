import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/activities/domain/recurrence_end.dart';
import 'package:blockday/features/activities/domain/recurrence_engine.dart';
import 'package:blockday/features/activities/domain/recurrence_rule.dart';
import 'package:flutter_test/flutter_test.dart';

Activity _single(
  String id,
  DateTime start,
  DateTime end, {
  Set<DateTime>? excluded,
}) {
  return Activity(
    id: id,
    title: 'Test $id',
    color: 0,
    kind: ActivityKind.single,
    singleStart: start,
    singleEnd: end,
    excludedDates: excluded,
  );
}

Activity _recurring({
  required String id,
  required int startMinutes,
  required int endMinutes,
  required Set<int> weekdays,
  required DateTime firstDate,
  RecurrenceEnd end = const RecurrenceNever(),
  Set<DateTime>? excluded,
}) {
  return Activity(
    id: id,
    title: 'Rec $id',
    color: 1,
    kind: ActivityKind.recurring,
    rule: RecurrenceRule(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      weekdays: weekdays,
      firstDate: firstDate,
      end: end,
    ),
    excludedDates: excluded,
  );
}

void main() {
  group('single activity', () {
    test('inside range returns one occurrence', () {
      final a = _single('1', DateTime(2025, 1, 9, 8), DateTime(2025, 1, 9, 10));
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 9),
        DateTime(2025, 1, 9),
      );
      expect(occ.length, 1);
      expect(occ.first.start, DateTime(2025, 1, 9, 8));
      expect(occ.first.end, DateTime(2025, 1, 9, 10));
    });

    test('outside range returns empty', () {
      final a = _single('1', DateTime(2025, 1, 9, 8), DateTime(2025, 1, 9, 10));
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 10),
        DateTime(2025, 1, 11),
      );
      expect(occ, isEmpty);
    });

    test('boundary inclusive', () {
      final a = _single(
        '1',
        DateTime(2025, 1, 10, 8),
        DateTime(2025, 1, 10, 9),
      );
      expect(
        expandOccurrences(a, DateTime(2025, 1, 10), DateTime(2025, 1, 10)),
        hasLength(1),
      );
      expect(
        expandOccurrences(a, DateTime(2025, 1, 9), DateTime(2025, 1, 9)),
        isEmpty,
      );
      expect(
        expandOccurrences(a, DateTime(2025, 1, 11), DateTime(2025, 1, 11)),
        isEmpty,
      );
    });

    test('excluded single occurrence', () {
      final a = _single(
        '1',
        DateTime(2025, 1, 9, 8),
        DateTime(2025, 1, 9, 10),
        excluded: {DateTime(2025, 1, 9)},
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 9),
        DateTime(2025, 1, 10),
      );
      expect(occ, isEmpty);
    });

    test('inverted range returns empty', () {
      final a = _single('1', DateTime(2025, 1, 9, 8), DateTime(2025, 1, 9, 10));
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 11),
        DateTime(2025, 1, 9),
      );
      expect(occ, isEmpty);
    });
  });

  group('recurring weekly', () {
    test('Lun-Vie una semana', () {
      final a = _recurring(
        id: 'r1',
        startMinutes: 17 * 60,
        endMinutes: 19 * 60,
        weekdays: {
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        },
        firstDate: DateTime(2025, 1, 6),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 6),
        DateTime(2025, 1, 12),
      );
      expect(occ.length, 5);
      expect(
        occ.map((o) => o.date.weekday),
        everyElement(isIn([1, 2, 3, 4, 5])),
      );
      expect(occ.first.date, DateTime(2025, 1, 6));
      expect(occ.last.date, DateTime(2025, 1, 10));
      expect(occ.first.start, DateTime(2025, 1, 6, 17, 0));
      expect(occ.first.end, DateTime(2025, 1, 6, 19, 0));
    });

    test('martes y jueves todo enero 2025', () {
      final a = _recurring(
        id: 'r2',
        startMinutes: 14 * 60,
        endMinutes: 15 * 60,
        weekdays: {DateTime.tuesday, DateTime.thursday},
        firstDate: DateTime(2025, 1, 1),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31),
      );
      expect(occ.length, 9);
      expect(
        occ.map((o) => o.date),
        equals([
          DateTime(2025, 1, 2),
          DateTime(2025, 1, 7),
          DateTime(2025, 1, 9),
          DateTime(2025, 1, 14),
          DateTime(2025, 1, 16),
          DateTime(2025, 1, 21),
          DateTime(2025, 1, 23),
          DateTime(2025, 1, 28),
          DateTime(2025, 1, 30),
        ]),
      );
    });

    test('hasta fecha acota', () {
      final a = _recurring(
        id: 'r3',
        startMinutes: 14 * 60,
        endMinutes: 15 * 60,
        weekdays: {DateTime.tuesday, DateTime.thursday},
        firstDate: DateTime(2025, 1, 1),
        end: RecurrenceUntil(DateTime(2025, 1, 15)),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31),
      );
      expect(occ.length, 4);
      expect(occ.last.date, DateTime(2025, 1, 14));
    });

    test('hasta fecha en el límite inclusive', () {
      final a = _recurring(
        id: 'r4',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.friday},
        firstDate: DateTime(2025, 1, 1),
        end: RecurrenceUntil(DateTime(2025, 1, 10)),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31),
      );
      expect(
        occ.map((o) => o.date),
        equals([DateTime(2025, 1, 3), DateTime(2025, 1, 10)]),
      );
    });

    test('N veces limita ocurrencias', () {
      final a = _recurring(
        id: 'r5',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.tuesday, DateTime.thursday},
        firstDate: DateTime(2025, 1, 1),
        end: const RecurrenceCount(3),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31),
      );
      expect(occ.length, 3);
      expect(
        occ.map((o) => o.date),
        equals([
          DateTime(2025, 1, 2),
          DateTime(2025, 1, 7),
          DateTime(2025, 1, 9),
        ]),
      );
    });

    test('N veces con rango que empieza después', () {
      final a = _recurring(
        id: 'r6',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.tuesday, DateTime.thursday},
        firstDate: DateTime(2025, 1, 1),
        end: const RecurrenceCount(5),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 20),
        DateTime(2025, 1, 31),
      );
      expect(occ, isEmpty);
    });

    test('N veces con rango parcial', () {
      final a = _recurring(
        id: 'r7',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.tuesday, DateTime.thursday},
        firstDate: DateTime(2025, 1, 1),
        end: const RecurrenceCount(10),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 20),
        DateTime(2025, 1, 31),
      );
      expect(
        occ.map((o) => o.date),
        equals([
          DateTime(2025, 1, 21),
          DateTime(2025, 1, 23),
          DateTime(2025, 1, 28),
          DateTime(2025, 1, 30),
        ]),
      );
    });

    test('fechas excluidas se saltan', () {
      final a = _recurring(
        id: 'r8',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.tuesday, DateTime.thursday},
        firstDate: DateTime(2025, 1, 1),
        excluded: {DateTime(2025, 1, 7), DateTime(2025, 1, 9)},
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 15),
      );
      expect(
        occ.map((o) => o.date),
        equals([DateTime(2025, 1, 2), DateTime(2025, 1, 14)]),
      );
    });

    test('excluida con N veces no cuenta como emitida extra', () {
      final a = _recurring(
        id: 'r9',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.monday},
        firstDate: DateTime(2025, 1, 6),
        end: const RecurrenceCount(3),
        excluded: {DateTime(2025, 1, 13)},
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 6),
        DateTime(2025, 1, 31),
      );
      expect(occ.length, 2);
      expect(
        occ.map((o) => o.date),
        equals([DateTime(2025, 1, 6), DateTime(2025, 1, 20)]),
      );
    });

    test('firstDate posterior al rango da vacío', () {
      final a = _recurring(
        id: 'r10',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.monday},
        firstDate: DateTime(2025, 2, 1),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31),
      );
      expect(occ, isEmpty);
    });

    test('rango sin intersección da vacío', () {
      final a = _recurring(
        id: 'r11',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.monday},
        firstDate: DateTime(2025, 1, 1),
        end: RecurrenceUntil(DateTime(2025, 1, 10)),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 20),
        DateTime(2025, 1, 31),
      );
      expect(occ, isEmpty);
    });

    test('fin de mes febrero no bisiesto', () {
      final a = _recurring(
        id: 'r12',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.friday},
        firstDate: DateTime(2025, 2, 1),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 2, 1),
        DateTime(2025, 2, 28),
      );
      expect(
        occ.map((o) => o.date),
        equals([
          DateTime(2025, 2, 7),
          DateTime(2025, 2, 14),
          DateTime(2025, 2, 21),
          DateTime(2025, 2, 28),
        ]),
      );
    });

    test('año bisiesto 29 de febrero', () {
      final a = _recurring(
        id: 'r13',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.thursday},
        firstDate: DateTime(2024, 2, 1),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2024, 2, 1),
        DateTime(2024, 3, 1),
      );
      expect(occ.map((o) => o.date), contains(DateTime(2024, 2, 29)));
      expect(
        occ.map((o) => o.date),
        equals([
          DateTime(2024, 2, 1),
          DateTime(2024, 2, 8),
          DateTime(2024, 2, 15),
          DateTime(2024, 2, 22),
          DateTime(2024, 2, 29),
        ]),
      );
    });

    test('cambio de año', () {
      final a = _recurring(
        id: 'r14',
        startMinutes: 540,
        endMinutes: 600,
        weekdays: {DateTime.wednesday},
        firstDate: DateTime(2024, 12, 25),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2024, 12, 25),
        DateTime(2025, 1, 8),
      );
      expect(
        occ.map((o) => o.date),
        equals([
          DateTime(2024, 12, 25),
          DateTime(2025, 1, 1),
          DateTime(2025, 1, 8),
        ]),
      );
    });

    test('un solo día de semana nunca pierde ocurrencia', () {
      final a = _recurring(
        id: 'r15',
        startMinutes: 8 * 60,
        endMinutes: 10 * 60,
        weekdays: {DateTime.thursday},
        firstDate: DateTime(2025, 1, 1),
      );
      final occ = expandOccurrences(
        a,
        DateTime(2025, 1, 9),
        DateTime(2025, 1, 9),
      );
      expect(occ.length, 1);
      expect(occ.first.date, DateTime(2025, 1, 9));
      expect(occ.first.start, DateTime(2025, 1, 9, 8));
    });
  });

  group('expandAll', () {
    test('ordena por fecha/hora', () {
      final a1 = _single(
        '1',
        DateTime(2025, 1, 10, 14),
        DateTime(2025, 1, 10, 15),
      );
      final a2 = _single(
        '2',
        DateTime(2025, 1, 10, 8),
        DateTime(2025, 1, 10, 9),
      );
      final occ = expandAll(
        [a1, a2],
        DateTime(2025, 1, 10),
        DateTime(2025, 1, 10),
      );
      expect(occ.map((o) => o.activityId), equals(['2', '1']));
    });

    test('combina puntuales y recurrentes', () {
      final single = _single(
        's1',
        DateTime(2025, 1, 7, 8),
        DateTime(2025, 1, 7, 9),
      );
      final recurring = _recurring(
        id: 'r1',
        startMinutes: 10 * 60,
        endMinutes: 11 * 60,
        weekdays: {DateTime.tuesday},
        firstDate: DateTime(2025, 1, 1),
      );
      final occ = expandAll(
        [single, recurring],
        DateTime(2025, 1, 7),
        DateTime(2025, 1, 7),
      );
      expect(occ.length, 2);
      expect(occ.first.activityId, 's1');
      expect(occ.last.activityId, 'r1');
    });

    test('rango vacío retorna vacío', () {
      final a = _single(
        '1',
        DateTime(2025, 1, 10, 8),
        DateTime(2025, 1, 10, 9),
      );
      expect(
        expandAll([a], DateTime(2025, 1, 11), DateTime(2025, 1, 10)),
        isEmpty,
      );
    });
  });
}
