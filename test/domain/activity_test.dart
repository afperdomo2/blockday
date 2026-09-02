import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/activities/domain/recurrence_end.dart';
import 'package:blockday/features/activities/domain/recurrence_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurrenceRule validation', () {
    test('rejects empty weekdays', () {
      expect(
        () => RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {},
          firstDate: DateTime(2025, 1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('rejects invalid weekday', () {
      expect(
        () => RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {8},
          firstDate: DateTime(2025, 1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('rejects endMinutes <= startMinutes', () {
      expect(
        () => RecurrenceRule(
          startMinutes: 600,
          endMinutes: 600,
          weekdays: {DateTime.monday},
          firstDate: DateTime(2025, 1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('rejects startMinutes out of range', () {
      expect(
        () => RecurrenceRule(
          startMinutes: -1,
          endMinutes: 600,
          weekdays: {DateTime.monday},
          firstDate: DateTime(2025, 1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('rejects count < 1', () {
      expect(
        () => RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {DateTime.monday},
          firstDate: DateTime(2025, 1, 1),
          end: const RecurrenceCount(0),
        ),
        throwsArgumentError,
      );
    });

    test('rejects until before firstDate', () {
      expect(
        () => RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {DateTime.monday},
          firstDate: DateTime(2025, 1, 10),
          end: RecurrenceUntil(DateTime(2025, 1, 5)),
        ),
        throwsArgumentError,
      );
    });

    test('accepts until equal to firstDate', () {
      expect(
        () => RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {DateTime.friday},
          firstDate: DateTime(2025, 1, 10),
          end: RecurrenceUntil(DateTime(2025, 1, 10)),
        ),
        returnsNormally,
      );
    });
  });

  group('Activity validation', () {
    test('rejects empty title', () {
      expect(
        () => Activity(
          id: '1',
          title: '  ',
          color: 0,
          kind: ActivityKind.single,
          singleStart: DateTime(2025, 1, 10, 8),
          singleEnd: DateTime(2025, 1, 10, 9),
        ),
        throwsArgumentError,
      );
    });

    test('single rejects missing dates', () {
      expect(
        () => Activity(
          id: '1',
          title: 'Test',
          color: 0,
          kind: ActivityKind.single,
        ),
        throwsArgumentError,
      );
    });

    test('single rejects end before start', () {
      expect(
        () => Activity(
          id: '1',
          title: 'Test',
          color: 0,
          kind: ActivityKind.single,
          singleStart: DateTime(2025, 1, 10, 10),
          singleEnd: DateTime(2025, 1, 10, 9),
        ),
        throwsArgumentError,
      );
    });

    test('single rejects cross-day', () {
      expect(
        () => Activity(
          id: '1',
          title: 'Test',
          color: 0,
          kind: ActivityKind.single,
          singleStart: DateTime(2025, 1, 10, 23),
          singleEnd: DateTime(2025, 1, 11, 1),
        ),
        throwsArgumentError,
      );
    });

    test('recurring rejects missing rule', () {
      expect(
        () => Activity(
          id: '1',
          title: 'Test',
          color: 0,
          kind: ActivityKind.recurring,
        ),
        throwsArgumentError,
      );
    });

    test('recurring rejects single dates', () {
      expect(
        () => Activity(
          id: '1',
          title: 'Test',
          color: 0,
          kind: ActivityKind.recurring,
          rule: RecurrenceRule(
            startMinutes: 540,
            endMinutes: 600,
            weekdays: {DateTime.monday},
            firstDate: DateTime(2025, 1, 1),
          ),
          singleStart: DateTime(2025, 1, 1, 9),
        ),
        throwsArgumentError,
      );
    });

    test('copyWith creates new instance', () {
      final a = Activity(
        id: '1',
        title: 'Original',
        color: 0,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 10, 8),
        singleEnd: DateTime(2025, 1, 10, 9),
      );
      final b = a.copyWith(title: 'Modificado');
      expect(b.title, 'Modificado');
      expect(b.id, '1');
      expect(a.title, 'Original');
    });
  });

  group('Activity equality', () {
    test('same fields are equal', () {
      final a1 = Activity(
        id: '1',
        title: 'Test',
        color: 2,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 10, 8),
        singleEnd: DateTime(2025, 1, 10, 9),
      );
      final a2 = Activity(
        id: '1',
        title: 'Test',
        color: 2,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 10, 8),
        singleEnd: DateTime(2025, 1, 10, 9),
      );
      expect(a1, equals(a2));
    });
  });
}
