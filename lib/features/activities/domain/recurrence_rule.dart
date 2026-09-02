import 'recurrence_end.dart';

class RecurrenceRule {
  RecurrenceRule({
    required this.startMinutes,
    required this.endMinutes,
    required Set<int> weekdays,
    required DateTime firstDate,
    this.end = const RecurrenceNever(),
  }) : weekdays = Set.unmodifiable(weekdays),
       firstDate = DateTime(firstDate.year, firstDate.month, firstDate.day) {
    if (startMinutes < 0 || startMinutes >= 1440) {
      throw ArgumentError.value(
        startMinutes,
        'startMinutes',
        'Debe estar entre 0 y 1439',
      );
    }
    if (endMinutes <= 0 || endMinutes > 1440) {
      throw ArgumentError.value(
        endMinutes,
        'endMinutes',
        'Debe estar entre 1 y 1440',
      );
    }
    if (endMinutes <= startMinutes) {
      throw ArgumentError('endMinutes debe ser mayor que startMinutes');
    }
    if (weekdays.isEmpty) {
      throw ArgumentError.value(weekdays, 'weekdays', 'No puede estar vacío');
    }
    for (final d in weekdays) {
      if (d < DateTime.monday || d > DateTime.sunday) {
        throw ArgumentError.value(d, 'weekdays', 'Día inválido: $d');
      }
    }
    if (end is RecurrenceCount && (end as RecurrenceCount).count < 1) {
      throw ArgumentError.value(end, 'end', 'count debe ser >= 1');
    }
    if (end is RecurrenceUntil) {
      final untilDate = (end as RecurrenceUntil).date;
      final normalized = DateTime(
        untilDate.year,
        untilDate.month,
        untilDate.day,
      );
      if (normalized.isBefore(this.firstDate)) {
        throw ArgumentError('until no puede ser anterior a firstDate');
      }
    }
  }

  final int startMinutes;
  final int endMinutes;
  final Set<int> weekdays;
  final DateTime firstDate;
  final RecurrenceEnd end;

  RecurrenceRule copyWith({
    int? startMinutes,
    int? endMinutes,
    Set<int>? weekdays,
    DateTime? firstDate,
    RecurrenceEnd? end,
  }) {
    return RecurrenceRule(
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      weekdays: weekdays ?? this.weekdays,
      firstDate: firstDate ?? this.firstDate,
      end: end ?? this.end,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RecurrenceRule &&
      startMinutes == other.startMinutes &&
      endMinutes == other.endMinutes &&
      _setEquals(weekdays, other.weekdays) &&
      firstDate == other.firstDate &&
      end == other.end;

  @override
  int get hashCode =>
      Object.hash(startMinutes, endMinutes, weekdays.length, firstDate, end);

  @override
  String toString() =>
      'RecurrenceRule($startMinutes-$endMinutes $weekdays desde $firstDate $end)';
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  for (final e in a) {
    if (!b.contains(e)) return false;
  }
  return true;
}
