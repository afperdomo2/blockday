sealed class RecurrenceEnd {
  const RecurrenceEnd();
}

class RecurrenceNever extends RecurrenceEnd {
  const RecurrenceNever();

  @override
  bool operator ==(Object other) => other is RecurrenceNever;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'RecurrenceNever()';
}

class RecurrenceUntil extends RecurrenceEnd {
  const RecurrenceUntil(this.date);

  final DateTime date;

  @override
  bool operator ==(Object other) =>
      other is RecurrenceUntil &&
      date.year == other.date.year &&
      date.month == other.date.month &&
      date.day == other.date.day;

  @override
  int get hashCode => Object.hash(date.year, date.month, date.day);

  @override
  String toString() => 'RecurrenceUntil($date)';
}

class RecurrenceCount extends RecurrenceEnd {
  const RecurrenceCount(this.count);

  final int count;

  @override
  bool operator ==(Object other) =>
      other is RecurrenceCount && count == other.count;

  @override
  int get hashCode => count.hashCode;

  @override
  String toString() => 'RecurrenceCount($count)';
}
