import '../../activities/domain/activity.dart';

const int reminderHorizonDays = 14;

class ReminderSchedule {
  const ReminderSchedule({
    required this.notificationId,
    required this.activityId,
    required this.title,
    required this.occurrenceStart,
    required this.fireAt,
  });

  final int notificationId;
  final String activityId;
  final String title;
  final DateTime occurrenceStart;
  final DateTime fireAt;

  @override
  bool operator ==(Object other) =>
      other is ReminderSchedule &&
      notificationId == other.notificationId &&
      activityId == other.activityId &&
      title == other.title &&
      occurrenceStart == other.occurrenceStart &&
      fireAt == other.fireAt;

  @override
  int get hashCode =>
      Object.hash(notificationId, activityId, title, occurrenceStart, fireAt);

  @override
  String toString() => 'ReminderSchedule($activityId, $title, fireAt:$fireAt)';
}

int reminderNotificationId(String activityId, DateTime occurrenceDate) {
  final key = '$activityId|${occurrenceDate.toIso8601String()}';
  var hash = 0;
  for (final code in key.codeUnits) {
    hash = (hash * 31 + code) & 0x7fffffff;
  }
  return hash;
}

List<ReminderSchedule> computeReminders({
  required Activity activity,
  required int reminderMinutesBefore,
  required DateTime now,
  required DateTime horizonEnd,
}) {
  if (reminderMinutesBefore < 0 ||
      reminderMinutesBefore > Activity.maxReminderMinutes) {
    throw ArgumentError.value(
      reminderMinutesBefore,
      'reminderMinutesBefore',
      'Debe estar entre 0 y ${Activity.maxReminderMinutes}',
    );
  }
  final rangeStart = DateTime(now.year, now.month, now.day);
  final rangeEnd = DateTime(horizonEnd.year, horizonEnd.month, horizonEnd.day);
  final occurrences = activity.occurrencesInRange(rangeStart, rangeEnd);
  final result = <ReminderSchedule>[];
  for (final occurrence in occurrences) {
    final fireAt = occurrence.start.subtract(
      Duration(minutes: reminderMinutesBefore),
    );
    if (!fireAt.isAfter(now)) continue;
    result.add(
      ReminderSchedule(
        notificationId: reminderNotificationId(activity.id, occurrence.date),
        activityId: activity.id,
        title: occurrence.title,
        occurrenceStart: occurrence.start,
        fireAt: fireAt,
      ),
    );
  }
  return result;
}
