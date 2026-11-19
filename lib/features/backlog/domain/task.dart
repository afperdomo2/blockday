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
    List<String> tags = const [],
    DateTime? createdAt,
    this.completedAt,
  }) : tags = List.unmodifiable(normalizeTags(tags)),
       createdAt = createdAt ?? DateTime.now() {
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

  static List<String> normalizeTags(Iterable<String> tags) {
    final seen = <String>{};
    final result = <String>[];
    for (final tag in tags) {
      final t = tag.trim();
      if (t.isEmpty) continue;
      final key = t.toLowerCase();
      if (seen.add(key)) result.add(t);
    }
    return result;
  }

  final String id;
  final String title;
  final String? notes;
  final TaskKind kind;
  final int? estimatedMinutes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  Task copyWith({
    String? id,
    String? title,
    String? notes,
    TaskKind? kind,
    int? estimatedMinutes,
    List<String>? tags,
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
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  bool hasTag(String tag) {
    final key = tag.trim().toLowerCase();
    return tags.any((t) => t.toLowerCase() == key);
  }

  @override
  bool operator ==(Object other) =>
      other is Task &&
      id == other.id &&
      title == other.title &&
      notes == other.notes &&
      kind == other.kind &&
      estimatedMinutes == other.estimatedMinutes &&
      _listEquals(tags, other.tags) &&
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
    Object.hashAll(tags),
    createdAt.millisecondsSinceEpoch,
    completedAt?.millisecondsSinceEpoch,
  );

  @override
  String toString() =>
      'Task($id, $title, $kind, tags:$tags, completed:$isCompleted)';
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
