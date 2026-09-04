class Occurrence {
  const Occurrence({
    required this.activityId,
    required this.title,
    required this.color,
    required this.date,
    required this.start,
    required this.end,
    this.taskId,
  });

  final String activityId;
  final String title;
  final int color;
  final DateTime date;
  final DateTime start;
  final DateTime end;
  final String? taskId;

  bool get isLinkedToTask => taskId != null;

  @override
  bool operator ==(Object other) =>
      other is Occurrence &&
      activityId == other.activityId &&
      title == other.title &&
      color == other.color &&
      date == other.date &&
      start == other.start &&
      end == other.end &&
      taskId == other.taskId;

  @override
  int get hashCode => Object.hash(activityId, date, start, end, taskId);

  @override
  String toString() => 'Occurrence($activityId $date $start-$end task:$taskId)';
}
