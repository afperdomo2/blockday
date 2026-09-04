import 'task.dart';

class TaskProgress {
  const TaskProgress({
    required this.taskId,
    required this.totalPlannedSessions,
    required this.completedSessions,
    required this.totalPlannedMinutes,
    required this.totalActualMinutes,
    required this.linkedActivitiesCount,
    required this.hasFutureOccurrence,
    required this.status,
  });

  final String taskId;
  final int totalPlannedSessions;
  final int completedSessions;
  final int totalPlannedMinutes;
  final int totalActualMinutes;
  final int linkedActivitiesCount;
  final bool hasFutureOccurrence;
  final TaskStatus status;

  int get remainingSessions => totalPlannedSessions - completedSessions;
  double get completionRatio =>
      totalPlannedSessions == 0 ? 0 : completedSessions / totalPlannedSessions;

  bool get isUnscheduled => linkedActivitiesCount == 0;
}
