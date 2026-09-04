enum TaskKind { task, learning, note, project }

enum TaskStatus { pending, scheduled, inProgress, completed }

TaskStatus deriveTaskStatus({
  required bool isCompleted,
  required int linkedActivitiesCount,
  required int completedSessions,
}) {
  if (isCompleted) return TaskStatus.completed;
  if (linkedActivitiesCount == 0) return TaskStatus.pending;
  if (completedSessions > 0) return TaskStatus.inProgress;
  return TaskStatus.scheduled;
}

class Task {
  Task({
    required this.id,
    required this.title,
    this.notes,
    this.kind = TaskKind.task,
    this.estimatedMinutes,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'No puede estar vacío');
    }
    if (estimatedMinutes != null && estimatedMinutes! <= 0) {
      throw ArgumentError.value(
        estimatedMinutes,
        'estimatedMinutes',
        'Debe ser mayor a 0',
      );
    }
  }

  final String id;
  final String title;
  final String? notes;
  final TaskKind kind;
  final int? estimatedMinutes;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  Task copyWith({
    String? id,
    String? title,
    String? notes,
    TaskKind? kind,
    int? estimatedMinutes,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearNotes = false,
    bool clearEstimatedMinutes = false,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: clearNotes ? null : (notes ?? this.notes),
      kind: kind ?? this.kind,
      estimatedMinutes: clearEstimatedMinutes
          ? null
          : (estimatedMinutes ?? this.estimatedMinutes),
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Task &&
      id == other.id &&
      title == other.title &&
      notes == other.notes &&
      kind == other.kind &&
      estimatedMinutes == other.estimatedMinutes &&
      createdAt.millisecondsSinceEpoch ==
          other.createdAt.millisecondsSinceEpoch &&
      completedAt?.millisecondsSinceEpoch ==
          other.completedAt?.millisecondsSinceEpoch;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    kind,
    estimatedMinutes,
    createdAt.millisecondsSinceEpoch,
    completedAt?.millisecondsSinceEpoch,
  );

  @override
  String toString() => 'Task($id, $title, $kind, completed:$isCompleted)';
}
