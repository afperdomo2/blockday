import 'package:flutter/material.dart';

import '../domain/task.dart';

/// Presentation helpers for [TaskKind] / [TaskStatus].
/// Single source of truth for labels and icons (previously duplicated).

String kindLabel(TaskKind kind) {
  switch (kind) {
    case TaskKind.task:
      return 'Tarea';
    case TaskKind.learning:
      return 'Aprendizaje';
    case TaskKind.note:
      return 'Nota';
    case TaskKind.project:
      return 'Proyecto';
  }
}

String statusLabel(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return 'Sin programar';
    case TaskStatus.scheduled:
      return 'Programada';
    case TaskStatus.inProgress:
      return 'En progreso';
    case TaskStatus.completed:
      return 'Hecha';
  }
}

IconData kindIcon(TaskKind kind) {
  switch (kind) {
    case TaskKind.task:
      return Icons.check_circle_outline;
    case TaskKind.learning:
      return Icons.school_outlined;
    case TaskKind.note:
      return Icons.note_outlined;
    case TaskKind.project:
      return Icons.folder_outlined;
  }
}
