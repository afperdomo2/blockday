import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../activities/domain/activity.dart';
import '../../activities/domain/recurrence_end.dart';
import '../../activities/providers/activities_providers.dart';
import '../../activities/providers/activities_stream_provider.dart';
import '../data/repositories/sessions_repository.dart';
import '../data/repositories/tasks_repository.dart';
import '../domain/task.dart';
import '../domain/task_progress.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TasksRepository(db);
});

final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionsRepository(db);
});

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(tasksRepositoryProvider).watchAll();
});

final taskByIdProvider = FutureProvider.family<Task?, String>((ref, id) async {
  return ref.watch(tasksRepositoryProvider).getById(id);
});

final sessionsStreamProvider = StreamProvider((ref) {
  return ref.watch(sessionsRepositoryProvider).watchAll();
});

final taskProgressProvider = Provider.family<TaskProgress, String>((
  ref,
  taskId,
) {
  final activitiesAsync = ref.watch(activitiesStreamProvider);
  final sessionsAsync = ref.watch(sessionsStreamProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);

  final activities = activitiesAsync.asData?.value ?? const <Activity>[];
  final sessions = sessionsAsync.asData?.value ?? const [];
  final tasks = tasksAsync.asData?.value ?? const <Task>[];
  final task = tasks.where((t) => t.id == taskId).firstOrNull;

  final linkedActivities = activities.where((a) => a.taskId == taskId).toList();
  final isCompleted = task?.isCompleted ?? false;

  TaskStatus derivedStatus(int completedSessions, int linkedCount) =>
      deriveTaskStatus(
        isCompleted: isCompleted,
        linkedActivitiesCount: linkedCount,
        completedSessions: completedSessions,
      );

  if (linkedActivities.isEmpty) {
    return TaskProgress(
      taskId: taskId,
      totalPlannedSessions: 0,
      completedSessions: 0,
      totalPlannedMinutes: 0,
      totalActualMinutes: 0,
      linkedActivitiesCount: 0,
      hasFutureOccurrence: false,
      status: derivedStatus(0, 0),
    );
  }

  int totalPlanned = 0;
  int totalPlannedMinutes = 0;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  bool hasFuture = false;

  int completed = 0;
  int actualMinutes = 0;
  for (final s in sessions) {
    if (s.completedAt != null &&
        linkedActivities.any((a) => a.id == s.activityId)) {
      completed++;
      if (s.actualMinutes != null) actualMinutes += s.actualMinutes!;
    }
  }

  for (final activity in linkedActivities) {
    if (activity.kind == ActivityKind.single) {
      final d = activity.singleStart!;
      totalPlanned += 1;
      final dur = activity.singleEnd!
          .difference(activity.singleStart!)
          .inMinutes;
      totalPlannedMinutes += dur;
      if (!DateTime(d.year, d.month, d.day).isBefore(today)) hasFuture = true;
    } else {
      final rule = activity.rule!;
      final rangeStart = rule.firstDate;
      late DateTime rangeEnd;
      final end = rule.end;
      if (end is RecurrenceCount) {
        rangeEnd = DateTime(
          rangeStart.year + 2,
          rangeStart.month,
          rangeStart.day,
        );
      } else if (end is RecurrenceUntil) {
        rangeEnd = end.date;
      } else {
        rangeEnd = DateTime.now().add(const Duration(days: 365));
      }
      final occs = activity.occurrencesInRange(rangeStart, rangeEnd);
      totalPlanned += occs.length;
      final minsPer = rule.endMinutes - rule.startMinutes;
      totalPlannedMinutes += occs.length * minsPer;
      for (final o in occs) {
        if (!o.date.isBefore(today)) {
          hasFuture = true;
          break;
        }
      }
    }
  }

  return TaskProgress(
    taskId: taskId,
    totalPlannedSessions: totalPlanned,
    completedSessions: completed,
    totalPlannedMinutes: totalPlannedMinutes,
    totalActualMinutes: actualMinutes,
    linkedActivitiesCount: linkedActivities.length,
    hasFutureOccurrence: hasFuture,
    status: derivedStatus(completed, linkedActivities.length),
  );
});

final isTaskScheduledProvider = Provider.family<bool, String>((ref, taskId) {
  final progress = ref.watch(taskProgressProvider(taskId));
  return progress.linkedActivitiesCount > 0;
});

final taskStatusProvider = Provider.family<TaskStatus, String>((ref, taskId) {
  return ref.watch(taskProgressProvider(taskId)).status;
});
