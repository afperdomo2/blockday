import 'package:blockday/core/debug/seed_data.dart';
import 'package:blockday/features/activities/data/app_database.dart';
import 'package:blockday/features/activities/data/repositories/activities_repository.dart';
import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/backlog/data/repositories/tasks_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'seedDebugData puebla tareas, actividades, exclusiones y sesiones',
    () async {
      await seedDebugData(db);

      final tasks = await db.select(db.tasks).get();
      final activities = await db.select(db.activities).get();
      final exclusions = await db.select(db.activityExclusions).get();
      final sessions = await db.select(db.activitySessions).get();

      expect(tasks, hasLength(seedTaskCount));
      expect(activities, hasLength(seedActivityCount));
      expect(exclusions, hasLength(seedExclusionCount));
      expect(sessions, hasLength(48));
    },
  );

  test('seedDebugDataIfEmpty puebla la base vacía una sola vez', () async {
    await seedDebugDataIfEmpty(db);
    final first = await db.select(db.activities).get();

    await seedDebugDataIfEmpty(db);
    final second = await db.select(db.activities).get();

    expect(first, hasLength(seedActivityCount));
    expect(second, hasLength(seedActivityCount));
  });

  test('las actividades son válidas y referencian tareas existentes', () async {
    await seedDebugData(db);

    final tasks = await TasksRepository(db).getAll();
    final activities = await ActivitiesRepository(db).getAll();
    final taskIds = tasks.map((t) => t.id).toSet();

    expect(activities, hasLength(seedActivityCount));
    expect(
      activities.where((a) => a.kind == ActivityKind.single),
      hasLength(7),
    );
    expect(
      activities.where((a) => a.kind == ActivityKind.recurring),
      hasLength(24),
    );
    for (final activity in activities) {
      if (activity.taskId != null) {
        expect(taskIds, contains(activity.taskId));
      }
    }
  });

  test(
    'las actividades del seed generan ocurrencias alrededor de hoy',
    () async {
      await seedDebugData(db);

      final activities = await ActivitiesRepository(db).getAll();
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day - 7);
      final end = DateTime(now.year, now.month, now.day + 30);

      final occurrences = [
        for (final activity in activities)
          ...activity.occurrencesInRange(start, end),
      ];

      expect(occurrences.length, greaterThan(100));
      final byDay = <int>{for (final o in occurrences) o.date.weekday};
      expect(byDay, hasLength(7));
      for (final occurrence in occurrences) {
        expect(occurrence.end.isAfter(occurrence.start), isTrue);
      }
    },
  );

  test('las sesiones son pasadas y consistentes', () async {
    await seedDebugData(db);

    final activities = await ActivitiesRepository(db).getAll();
    final activityIds = activities.map((a) => a.id).toSet();
    final sessions = await db.select(db.activitySessions).get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    var completed = 0;
    var pending = 0;
    for (final session in sessions) {
      expect(activityIds, contains(session.activityId));
      expect(session.date, lessThan(today));
      if (session.completedAt != null) {
        completed++;
        expect(session.actualMinutes, isNotNull);
      } else {
        pending++;
        expect(session.actualMinutes, isNull);
      }
    }
    expect(completed, greaterThan(0));
    expect(pending, greaterThan(0));
  });
}
