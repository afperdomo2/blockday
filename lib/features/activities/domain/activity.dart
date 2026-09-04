import 'occurrence.dart';
import 'recurrence_end.dart';
import 'recurrence_rule.dart';

enum ActivityKind { single, recurring }

class Activity {
  Activity({
    required this.id,
    required this.title,
    this.notes,
    required this.color,
    required this.kind,
    this.singleStart,
    this.singleEnd,
    this.rule,
    Set<DateTime>? excludedDates,
    this.taskId,
  }) : excludedDates = excludedDates == null
           ? const {}
           : Set.unmodifiable(
               excludedDates.map((d) => DateTime(d.year, d.month, d.day)),
             ) {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'No puede estar vacío');
    }
    if (kind == ActivityKind.single) {
      if (singleStart == null || singleEnd == null) {
        throw ArgumentError(
          'singleStart y singleEnd son obligatorios para kind single',
        );
      }
      if (!singleStart!.isBefore(singleEnd!)) {
        throw ArgumentError('singleEnd debe ser posterior a singleStart');
      }
      if (!_isSameDay(singleStart!, singleEnd!)) {
        throw ArgumentError(
          'La actividad debe empezar y terminar el mismo día',
        );
      }
      if (rule != null) {
        throw ArgumentError('rule debe ser null para kind single');
      }
    } else {
      if (rule == null) {
        throw ArgumentError('rule es obligatorio para kind recurring');
      }
      if (singleStart != null || singleEnd != null) {
        throw ArgumentError(
          'singleStart/singleEnd deben ser null para kind recurring',
        );
      }
    }
  }

  final String id;
  final String title;
  final String? notes;
  final int color;
  final ActivityKind kind;
  final DateTime? singleStart;
  final DateTime? singleEnd;
  final RecurrenceRule? rule;
  final Set<DateTime> excludedDates;
  final String? taskId;

  Activity copyWith({
    String? id,
    String? title,
    String? notes,
    int? color,
    ActivityKind? kind,
    DateTime? singleStart,
    DateTime? singleEnd,
    RecurrenceRule? rule,
    Set<DateTime>? excludedDates,
    String? taskId,
    bool clearNotes = false,
    bool clearTaskId = false,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: clearNotes ? null : (notes ?? this.notes),
      color: color ?? this.color,
      kind: kind ?? this.kind,
      singleStart: singleStart ?? this.singleStart,
      singleEnd: singleEnd ?? this.singleEnd,
      rule: rule ?? this.rule,
      excludedDates: excludedDates ?? this.excludedDates,
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
    );
  }

  bool isExcluded(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return excludedDates.contains(normalized);
  }

  List<Occurrence> occurrencesInRange(DateTime rangeStart, DateTime rangeEnd) {
    final start = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
    final end = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
    if (end.isBefore(start)) return const [];
    if (kind == ActivityKind.single) {
      final singleDate = DateTime(
        singleStart!.year,
        singleStart!.month,
        singleStart!.day,
      );
      if (singleDate.isBefore(start) || singleDate.isAfter(end)) {
        return const [];
      }
      if (isExcluded(singleDate)) return const [];
      return [
        Occurrence(
          activityId: id,
          title: title,
          color: color,
          date: singleDate,
          start: singleStart!,
          end: singleEnd!,
          taskId: taskId,
        ),
      ];
    }
    return _expandRecurring(start, end);
  }

  List<Occurrence> _expandRecurring(DateTime rangeStart, DateTime rangeEnd) {
    final r = rule!;
    DateTime effectiveEnd = rangeEnd;
    final endCondition = r.end;
    if (endCondition is RecurrenceUntil) {
      final until = DateTime(
        endCondition.date.year,
        endCondition.date.month,
        endCondition.date.day,
      );
      if (until.isBefore(effectiveEnd)) effectiveEnd = until;
    }
    if (rangeStart.isAfter(effectiveEnd)) return const [];
    if (r.firstDate.isAfter(effectiveEnd)) return const [];

    final countLimit = endCondition is RecurrenceCount
        ? endCondition.count
        : null;
    final result = <Occurrence>[];
    var emitted = 0;
    var cursor = DateTime(r.firstDate.year, r.firstDate.month, r.firstDate.day);
    final rangeStartDate = DateTime(
      rangeStart.year,
      rangeStart.month,
      rangeStart.day,
    );

    while (!cursor.isAfter(effectiveEnd)) {
      if (countLimit != null && emitted >= countLimit) break;
      final isWeekday = r.weekdays.contains(cursor.weekday);
      final isAfterFirst = !cursor.isBefore(r.firstDate);
      if (isAfterFirst && isWeekday) {
        emitted++;
        if (countLimit != null && emitted > countLimit) break;
        if (!cursor.isBefore(rangeStartDate) &&
            !cursor.isAfter(effectiveEnd) &&
            !isExcluded(cursor)) {
          result.add(
            Occurrence(
              activityId: id,
              title: title,
              color: color,
              date: cursor,
              start: DateTime(
                cursor.year,
                cursor.month,
                cursor.day,
                r.startMinutes ~/ 60,
                r.startMinutes % 60,
              ),
              end: DateTime(
                cursor.year,
                cursor.month,
                cursor.day,
                r.endMinutes ~/ 60,
                r.endMinutes % 60,
              ),
              taskId: taskId,
            ),
          );
        }
      }
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
      if (cursor.year > 2100) break;
    }
    return result;
  }

  @override
  bool operator ==(Object other) =>
      other is Activity &&
      id == other.id &&
      title == other.title &&
      notes == other.notes &&
      color == other.color &&
      kind == other.kind &&
      singleStart == other.singleStart &&
      singleEnd == other.singleEnd &&
      rule == other.rule &&
      _setEquals(excludedDates, other.excludedDates) &&
      taskId == other.taskId;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    color,
    kind,
    singleStart,
    singleEnd,
    rule,
    excludedDates.length,
    taskId,
  );

  @override
  String toString() => 'Activity($id, $title, $kind, task:$taskId)';
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  for (final e in a) {
    if (!b.contains(e)) return false;
  }
  return true;
}
