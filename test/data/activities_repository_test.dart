import 'package:blockday/features/activities/data/app_database.dart'
    hide Activity, ActivityExclusion;
import 'package:blockday/features/activities/data/repositories/activities_repository.dart';
import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/activities/domain/recurrence_end.dart';
import 'package:blockday/features/activities/domain/recurrence_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ActivitiesRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = ActivitiesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ActivitiesRepository', () {
    test('save and fetch single activity', () async {
      final activity = Activity(
        id: 'a1',
        title: 'Curso virtual',
        notes: 'Jueves 08:00',
        color: 2,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 9, 8, 0),
        singleEnd: DateTime(2025, 1, 9, 10, 0),
      );
      await repo.save(activity);
      final fetched = await repo.getById('a1');
      expect(fetched, isNotNull);
      expect(fetched!.id, 'a1');
      expect(fetched.title, 'Curso virtual');
      expect(fetched.notes, 'Jueves 08:00');
      expect(fetched.singleStart, DateTime(2025, 1, 9, 8, 0));
      expect(fetched.singleEnd, DateTime(2025, 1, 9, 10, 0));
      expect(fetched.excludedDates, isEmpty);
    });

    test('save and fetch recurring with never', () async {
      final activity = Activity(
        id: 'r1',
        title: 'Buscar trabajo',
        color: 0,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
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
          end: const RecurrenceNever(),
        ),
      );
      await repo.save(activity);
      final fetched = await repo.getById('r1');
      expect(fetched, isNotNull);
      expect(fetched!.kind, ActivityKind.recurring);
      expect(fetched.rule!.startMinutes, 17 * 60);
      expect(fetched.rule!.endMinutes, 19 * 60);
      expect(fetched.rule!.weekdays, containsAll([1, 2, 3, 4, 5]));
      expect(fetched.rule!.firstDate, DateTime(2025, 1, 6));
      expect(fetched.rule!.end, isA<RecurrenceNever>());
    });

    test('save and fetch recurring with until', () async {
      final activity = Activity(
        id: 'r2',
        title: 'Repasar entrevistas',
        color: 1,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 19 * 60,
          endMinutes: 21 * 60,
          weekdays: {DateTime.tuesday, DateTime.thursday},
          firstDate: DateTime(2025, 1, 1),
          end: RecurrenceUntil(DateTime(2025, 1, 31)),
        ),
      );
      await repo.save(activity);
      final fetched = await repo.getById('r2');
      expect(fetched!.rule!.end, isA<RecurrenceUntil>());
      expect(
        (fetched.rule!.end as RecurrenceUntil).date,
        DateTime(2025, 1, 31),
      );
    });

    test('save and fetch recurring with count', () async {
      final activity = Activity(
        id: 'r3',
        title: 'Practicar desarrollo',
        color: 3,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 14 * 60,
          endMinutes: 15 * 60,
          weekdays: {DateTime.monday, DateTime.wednesday, DateTime.friday},
          firstDate: DateTime(2025, 1, 1),
          end: const RecurrenceCount(8),
        ),
      );
      await repo.save(activity);
      final fetched = await repo.getById('r3');
      expect(fetched!.rule!.end, isA<RecurrenceCount>());
      expect((fetched.rule!.end as RecurrenceCount).count, 8);
    });

    test('save and fetch with excluded dates', () async {
      final activity = Activity(
        id: 'r4',
        title: 'Con exclusiones',
        color: 4,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {DateTime.monday},
          firstDate: DateTime(2025, 1, 6),
        ),
        excludedDates: {DateTime(2025, 1, 13), DateTime(2025, 1, 20)},
      );
      await repo.save(activity);
      final fetched = await repo.getById('r4');
      expect(fetched!.excludedDates.length, 2);
      expect(
        fetched.excludedDates,
        containsAll([DateTime(2025, 1, 13), DateTime(2025, 1, 20)]),
      );
      final occ = fetched.occurrencesInRange(
        DateTime(2025, 1, 6),
        DateTime(2025, 1, 27),
      );
      expect(
        occ.map((o) => o.date),
        equals([DateTime(2025, 1, 6), DateTime(2025, 1, 27)]),
      );
    });

    test('update existing activity', () async {
      final a1 = Activity(
        id: 'a1',
        title: 'Original',
        color: 0,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 9, 8),
        singleEnd: DateTime(2025, 1, 9, 9),
      );
      await repo.save(a1);
      final a2 = Activity(
        id: 'a1',
        title: 'Modificado',
        color: 5,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 9, 10),
        singleEnd: DateTime(2025, 1, 9, 11),
      );
      await repo.save(a2);
      final fetched = await repo.getById('a1');
      expect(fetched!.title, 'Modificado');
      expect(fetched.color, 5);
      final all = await repo.getAll();
      expect(all.length, 1);
    });

    test('getAll returns all activities', () async {
      final single = Activity(
        id: 's1',
        title: 'Single',
        color: 0,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 10, 8),
        singleEnd: DateTime(2025, 1, 10, 9),
      );
      final recurring = Activity(
        id: 'r1',
        title: 'Recurring',
        color: 1,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {DateTime.monday},
          firstDate: DateTime(2025, 1, 1),
        ),
      );
      await repo.save(single);
      await repo.save(recurring);
      final all = await repo.getAll();
      expect(all.length, 2);
      expect(all.map((a) => a.id), containsAll(['s1', 'r1']));
    });

    test('delete removes activity and exclusions', () async {
      final activity = Activity(
        id: 'r1',
        title: 'Para borrar',
        color: 0,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {DateTime.monday},
          firstDate: DateTime(2025, 1, 6),
        ),
        excludedDates: {DateTime(2025, 1, 13)},
      );
      await repo.save(activity);
      expect(await repo.getById('r1'), isNotNull);
      await repo.delete('r1');
      expect(await repo.getById('r1'), isNull);
      expect(await repo.getAll(), isEmpty);
    });

    test('getById returns null for missing id', () async {
      expect(await repo.getById('no-existe'), isNull);
    });

    test('addExclusion and removeExclusion', () async {
      final activity = Activity(
        id: 'r1',
        title: 'Test',
        color: 0,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {DateTime.monday},
          firstDate: DateTime(2025, 1, 6),
        ),
      );
      await repo.save(activity);
      await repo.addExclusion('r1', DateTime(2025, 1, 13));
      var fetched = await repo.getById('r1');
      expect(fetched!.excludedDates, contains(DateTime(2025, 1, 13)));
      await repo.removeExclusion('r1', DateTime(2025, 1, 13));
      fetched = await repo.getById('r1');
      expect(fetched!.excludedDates, isEmpty);
    });

    test('watchAll emits updates', () async {
      final stream = repo.watchAll();
      final first = await stream.first;
      expect(first, isEmpty);
      final activity = Activity(
        id: 'w1',
        title: 'Watch test',
        color: 0,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 10, 8),
        singleEnd: DateTime(2025, 1, 10, 9),
      );
      await repo.save(activity);
      final second = await stream.first;
      expect(second.length, 1);
      expect(second.first.id, 'w1');
    });

    test('update clears old exclusions', () async {
      final a1 = Activity(
        id: 'r1',
        title: 'Test',
        color: 0,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {DateTime.monday},
          firstDate: DateTime(2025, 1, 6),
        ),
        excludedDates: {DateTime(2025, 1, 13), DateTime(2025, 1, 20)},
      );
      await repo.save(a1);
      final a2 = Activity(
        id: 'r1',
        title: 'Test',
        color: 0,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 540,
          endMinutes: 600,
          weekdays: {DateTime.monday},
          firstDate: DateTime(2025, 1, 6),
        ),
        excludedDates: {DateTime(2025, 1, 27)},
      );
      await repo.save(a2);
      final fetched = await repo.getById('r1');
      expect(fetched!.excludedDates, equals({DateTime(2025, 1, 27)}));
    });
  });
}
