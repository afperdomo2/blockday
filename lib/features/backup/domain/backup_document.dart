import 'dart:convert';

import '../../activities/domain/activity.dart';
import '../../activities/domain/recurrence_end.dart';
import '../../activities/domain/recurrence_rule.dart';
import '../../backlog/domain/task.dart';

const String backupAppId = 'blockday';
const int backupFormatVersion = 1;

class BackupFormatException implements Exception {
  BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

class SessionEntry {
  const SessionEntry({
    required this.activityId,
    required this.date,
    this.completedAt,
    this.actualMinutes,
  });

  final String activityId;
  final DateTime date;
  final DateTime? completedAt;
  final int? actualMinutes;

  @override
  bool operator ==(Object other) =>
      other is SessionEntry &&
      activityId == other.activityId &&
      date == other.date &&
      completedAt == other.completedAt &&
      actualMinutes == other.actualMinutes;

  @override
  int get hashCode => Object.hash(activityId, date, completedAt, actualMinutes);
}

class BackupData {
  const BackupData({
    this.tasks = const [],
    this.activities = const [],
    this.sessions = const [],
  });

  final List<Task> tasks;
  final List<Activity> activities;
  final List<SessionEntry> sessions;
}

String encodeBackup(BackupData data, {DateTime? exportedAt}) {
  final at = exportedAt ?? DateTime.now();
  return jsonEncode({
    'app': backupAppId,
    'version': backupFormatVersion,
    'exportedAt': at.millisecondsSinceEpoch,
    'tasks': data.tasks.map(_taskToMap).toList(),
    'activities': data.activities.map(_activityToMap).toList(),
    'sessions': data.sessions.map(_sessionToMap).toList(),
  });
}

BackupData decodeBackup(String json) {
  final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } catch (_) {
    throw BackupFormatException('El archivo no es JSON válido');
  }
  if (decoded is! Map<String, dynamic>) {
    throw BackupFormatException('Estructura de copia no reconocida');
  }
  if (decoded['app'] != backupAppId) {
    throw BackupFormatException('El archivo no es una copia de Blockday');
  }
  final version = decoded['version'];
  if (version != backupFormatVersion) {
    throw BackupFormatException('Versión de copia no soportada: $version');
  }

  final tasks = _decodeList(decoded['tasks'], 'tasks', _taskFromMap);
  final activities = _decodeList(
    decoded['activities'],
    'activities',
    _activityFromMap,
  );
  final sessions = _decodeList(
    decoded['sessions'],
    'sessions',
    _sessionFromMap,
  );

  final taskIds = tasks.map((t) => t.id).toSet();
  final activityIds = activities.map((a) => a.id).toSet();
  for (final activity in activities) {
    final taskId = activity.taskId;
    if (taskId != null && !taskIds.contains(taskId)) {
      throw BackupFormatException(
        'La actividad ${activity.id} referencia una tarea inexistente',
      );
    }
  }
  for (final session in sessions) {
    if (!activityIds.contains(session.activityId)) {
      throw BackupFormatException(
        'La sesión de ${session.activityId} referencia una actividad inexistente',
      );
    }
  }

  return BackupData(tasks: tasks, activities: activities, sessions: sessions);
}

List<T> _decodeList<T>(
  Object? raw,
  String field,
  T Function(Map<String, dynamic>) decode,
) {
  if (raw == null) return const [];
  if (raw is! List) {
    throw BackupFormatException('"$field" debe ser una lista');
  }
  return raw.map((item) {
    if (item is! Map<String, dynamic>) {
      throw BackupFormatException('Elemento inválido en "$field"');
    }
    try {
      return decode(item);
    } on BackupFormatException {
      rethrow;
    } catch (e) {
      throw BackupFormatException('Elemento inválido en "$field": $e');
    }
  }).toList();
}

Map<String, Object?> _taskToMap(Task task) => {
  'id': task.id,
  'title': task.title,
  'notes': task.notes,
  'kind': task.kind.name,
  'estimatedMinutes': task.estimatedMinutes,
  'tags': task.tags,
  'createdAt': task.createdAt.millisecondsSinceEpoch,
  'completedAt': task.completedAt?.millisecondsSinceEpoch,
};

Task _taskFromMap(Map<String, dynamic> map) {
  return Task(
    id: _reqString(map, 'id'),
    title: _reqString(map, 'title'),
    notes: map['notes'] as String?,
    kind: TaskKind.values.byName(_reqString(map, 'kind')),
    estimatedMinutes: map['estimatedMinutes'] as int?,
    tags: (map['tags'] as List?)?.whereType<String>().toList() ?? const [],
    createdAt: _reqDate(map, 'createdAt'),
    completedAt: _optDate(map, 'completedAt'),
  );
}

Map<String, Object?> _activityToMap(Activity activity) => {
  'id': activity.id,
  'title': activity.title,
  'notes': activity.notes,
  'color': activity.color,
  'kind': activity.kind.name,
  'singleStart': activity.singleStart?.millisecondsSinceEpoch,
  'singleEnd': activity.singleEnd?.millisecondsSinceEpoch,
  'weekdays': _sortedWeekdays(activity.rule?.weekdays),
  'firstDate': activity.rule?.firstDate.millisecondsSinceEpoch,
  'startMinutes': activity.rule?.startMinutes,
  'endMinutes': activity.rule?.endMinutes,
  'endType': _endTypeName(activity.rule?.end),
  'endValue': _endTypeValue(activity.rule?.end),
  'taskId': activity.taskId,
  'reminderMinutes': activity.reminderMinutes,
  'excludedDates':
      activity.excludedDates.map((d) => d.millisecondsSinceEpoch).toList()
        ..sort(),
};

Activity _activityFromMap(Map<String, dynamic> map) {
  final kind = ActivityKind.values.byName(_reqString(map, 'kind'));
  if (kind == ActivityKind.single) {
    return Activity(
      id: _reqString(map, 'id'),
      title: _reqString(map, 'title'),
      notes: map['notes'] as String?,
      color: _reqInt(map, 'color'),
      kind: kind,
      singleStart: _optDate(map, 'singleStart'),
      singleEnd: _optDate(map, 'singleEnd'),
      taskId: map['taskId'] as String?,
      reminderMinutes: map['reminderMinutes'] as int?,
      excludedDates: _dateSet(map['excludedDates']),
    );
  }
  return Activity(
    id: _reqString(map, 'id'),
    title: _reqString(map, 'title'),
    notes: map['notes'] as String?,
    color: _reqInt(map, 'color'),
    kind: kind,
    rule: RecurrenceRule(
      startMinutes: _reqInt(map, 'startMinutes'),
      endMinutes: _reqInt(map, 'endMinutes'),
      weekdays:
          (map['weekdays'] as List?)?.whereType<int>().toSet() ??
          (throw BackupFormatException('"weekdays" es obligatorio')),
      firstDate: _reqDate(map, 'firstDate'),
      end: _endFromMap(map),
    ),
    taskId: map['taskId'] as String?,
    reminderMinutes: map['reminderMinutes'] as int?,
    excludedDates: _dateSet(map['excludedDates']),
  );
}

String? _endTypeName(RecurrenceEnd? end) {
  if (end == null || end is RecurrenceNever) return 'never';
  if (end is RecurrenceUntil) return 'until';
  return 'count';
}

int? _endTypeValue(RecurrenceEnd? end) {
  if (end is RecurrenceUntil) return end.date.millisecondsSinceEpoch;
  if (end is RecurrenceCount) return end.count;
  return null;
}

RecurrenceEnd _endFromMap(Map<String, dynamic> map) {
  switch (map['endType']) {
    case 'never':
      return const RecurrenceNever();
    case 'until':
      return RecurrenceUntil(_reqDate(map, 'endValue'));
    case 'count':
      return RecurrenceCount(_reqInt(map, 'endValue'));
    default:
      throw BackupFormatException('"endType" no reconocido');
  }
}

Map<String, Object?> _sessionToMap(SessionEntry session) => {
  'activityId': session.activityId,
  'date': session.date.millisecondsSinceEpoch,
  'completedAt': session.completedAt?.millisecondsSinceEpoch,
  'actualMinutes': session.actualMinutes,
};

SessionEntry _sessionFromMap(Map<String, dynamic> map) {
  return SessionEntry(
    activityId: _reqString(map, 'activityId'),
    date: _reqDate(map, 'date'),
    completedAt: _optDate(map, 'completedAt'),
    actualMinutes: map['actualMinutes'] as int?,
  );
}

Set<DateTime> _dateSet(Object? raw) {
  if (raw == null) return const {};
  if (raw is! List) {
    throw BackupFormatException('"excludedDates" debe ser una lista');
  }
  return raw
      .map((ms) => DateTime.fromMillisecondsSinceEpoch(_asInt(ms)))
      .toSet();
}

List<int>? _sortedWeekdays(Set<int>? weekdays) {
  if (weekdays == null) return null;
  return weekdays.toList()..sort();
}

String _reqString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! String || value.isEmpty) {
    throw BackupFormatException('"$key" es obligatorio');
  }
  return value;
}

int _reqInt(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! int) {
    throw BackupFormatException('"$key" es obligatorio');
  }
  return value;
}

int _asInt(Object? value) {
  if (value is! int) {
    throw BackupFormatException('Se esperaba un número entero');
  }
  return value;
}

DateTime _reqDate(Map<String, dynamic> map, String key) {
  return DateTime.fromMillisecondsSinceEpoch(_reqInt(map, key));
}

DateTime? _optDate(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(_asInt(value));
}
