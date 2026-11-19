import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/task.dart' as domain;
import '../../../activities/data/app_database.dart' as db;

db.TasksCompanion toTaskCompanion(domain.Task task) {
  return db.TasksCompanion(
    id: Value(task.id),
    title: Value(task.title),
    notes: Value(task.notes),
    kind: Value(task.kind.name),
    estimatedMinutes: Value(task.estimatedMinutes),
    tags: Value(task.tags.isEmpty ? null : jsonEncode(task.tags)),
    createdAt: Value(task.createdAt.millisecondsSinceEpoch),
    completedAt: Value(task.completedAt?.millisecondsSinceEpoch),
  );
}

domain.Task taskFromRow(db.Task row) {
  return domain.Task(
    id: row.id,
    title: row.title,
    notes: row.notes,
    kind: domain.TaskKind.values.byName(row.kind),
    estimatedMinutes: row.estimatedMinutes,
    tags: _decodeTags(row.tags),
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    completedAt: row.completedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row.completedAt!),
  );
}

List<String> _decodeTags(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.whereType<String>().toList();
    }
  } catch (_) {}
  return const [];
}
