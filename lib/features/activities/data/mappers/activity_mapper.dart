import 'package:drift/drift.dart';

import '../../domain/activity.dart' as domain;
import '../../domain/recurrence_end.dart';
import '../../domain/recurrence_rule.dart';
import '../app_database.dart' as db;

int weekdaysToMask(Set<int> weekdays) {
  var mask = 0;
  for (final d in weekdays) {
    mask |= 1 << (d - 1);
  }
  return mask;
}

Set<int> maskToWeekdays(int mask) {
  final result = <int>{};
  for (var i = 1; i <= 7; i++) {
    if ((mask & (1 << (i - 1))) != 0) result.add(i);
  }
  return result;
}

db.ActivitiesCompanion toCompanion(domain.Activity activity) {
  if (activity.kind == domain.ActivityKind.single) {
    return db.ActivitiesCompanion(
      id: Value(activity.id),
      title: Value(activity.title),
      notes: Value(activity.notes),
      color: Value(activity.color),
      kind: Value(activity.kind.name),
      singleStart: Value(activity.singleStart!.millisecondsSinceEpoch),
      singleEnd: Value(activity.singleEnd!.millisecondsSinceEpoch),
      weekdays: const Value.absent(),
      firstDate: const Value.absent(),
      startMinutes: const Value.absent(),
      endMinutes: const Value.absent(),
      endType: const Value.absent(),
      endValue: const Value.absent(),
      taskId: Value(activity.taskId),
    );
  }
  final rule = activity.rule!;
  final String endType;
  final int? endValue;
  final end = rule.end;
  if (end is RecurrenceNever) {
    endType = 'never';
    endValue = null;
  } else if (end is RecurrenceUntil) {
    endType = 'until';
    final d = DateTime(end.date.year, end.date.month, end.date.day);
    endValue = d.millisecondsSinceEpoch;
  } else if (end is RecurrenceCount) {
    endType = 'count';
    endValue = end.count;
  } else {
    throw StateError('Unknown RecurrenceEnd: $end');
  }

  return db.ActivitiesCompanion(
    id: Value(activity.id),
    title: Value(activity.title),
    notes: Value(activity.notes),
    color: Value(activity.color),
    kind: Value(activity.kind.name),
    singleStart: const Value.absent(),
    singleEnd: const Value.absent(),
    weekdays: Value(weekdaysToMask(rule.weekdays)),
    firstDate: Value(rule.firstDate.millisecondsSinceEpoch),
    startMinutes: Value(rule.startMinutes),
    endMinutes: Value(rule.endMinutes),
    endType: Value(endType),
    endValue: Value(endValue),
    taskId: Value(activity.taskId),
  );
}

domain.Activity fromRow(
  db.Activity row,
  List<db.ActivityExclusion> exclusions,
) {
  final kind = domain.ActivityKind.values.byName(row.kind);
  final excludedDates = exclusions.map((e) {
    final dt = DateTime.fromMillisecondsSinceEpoch(e.excludedDate);
    return DateTime(dt.year, dt.month, dt.day);
  }).toSet();

  if (kind == domain.ActivityKind.single) {
    return domain.Activity(
      id: row.id,
      title: row.title,
      notes: row.notes,
      color: row.color,
      kind: kind,
      singleStart: DateTime.fromMillisecondsSinceEpoch(row.singleStart!),
      singleEnd: DateTime.fromMillisecondsSinceEpoch(row.singleEnd!),
      excludedDates: excludedDates,
      taskId: row.taskId,
    );
  }

  final weekdays = maskToWeekdays(row.weekdays!);
  final firstDate = DateTime.fromMillisecondsSinceEpoch(row.firstDate!);
  final RecurrenceEnd end;
  switch (row.endType) {
    case 'never':
      end = const RecurrenceNever();
    case 'until':
      end = RecurrenceUntil(DateTime.fromMillisecondsSinceEpoch(row.endValue!));
    case 'count':
      end = RecurrenceCount(row.endValue!);
    default:
      throw StateError('Unknown endType: ${row.endType}');
  }

  return domain.Activity(
    id: row.id,
    title: row.title,
    notes: row.notes,
    color: row.color,
    kind: kind,
    rule: RecurrenceRule(
      startMinutes: row.startMinutes!,
      endMinutes: row.endMinutes!,
      weekdays: weekdays,
      firstDate: DateTime(firstDate.year, firstDate.month, firstDate.day),
      end: end,
    ),
    excludedDates: excludedDates,
    taskId: row.taskId,
  );
}
