import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../activities/providers/activities_stream_provider.dart';
import '../../domain/task.dart';
import '../../providers/tasks_providers.dart';

String _kindLabel(TaskKind k) {
  switch (k) {
    case TaskKind.task:
      return 'Tarea';
    case TaskKind.learning:
      return 'Curso';
    case TaskKind.note:
      return 'Nota';
    case TaskKind.project:
      return 'Proyecto';
  }
}

IconData _kindIcon(TaskKind k) {
  switch (k) {
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

String _statusLabel(TaskStatus s) {
  switch (s) {
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

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key, this.taskId});

  final String? taskId;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _estimatedCtrl = TextEditingController();
  TaskKind _kind = TaskKind.task;
  DateTime? _completedAt;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _estimatedCtrl.dispose();
    super.dispose();
  }

  void _populate(Task t) {
    _titleCtrl.text = t.title;
    _notesCtrl.text = t.notes ?? '';
    _kind = t.kind;
    _completedAt = t.completedAt;
    _estimatedCtrl.text = t.estimatedMinutes == null
        ? ''
        : (t.estimatedMinutes! / 60).toStringAsFixed(1);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleCtrl.text.trim();
    final notes = _notesCtrl.text.trim().isEmpty
        ? null
        : _notesCtrl.text.trim();
    int? estimated;
    if (_estimatedCtrl.text.trim().isNotEmpty) {
      final h = double.tryParse(
        _estimatedCtrl.text.trim().replaceAll(',', '.'),
      );
      if (h != null) estimated = (h * 60).round();
    }

    setState(() => _saving = true);
    final id = widget.taskId ?? const Uuid().v4();
    final existing = widget.taskId != null
        ? await ref.read(tasksRepositoryProvider).getById(widget.taskId!)
        : null;

    final task = Task(
      id: id,
      title: title,
      notes: notes,
      kind: _kind,
      estimatedMinutes: estimated,
      createdAt: existing?.createdAt ?? DateTime.now(),
      completedAt: _completedAt,
    );

    try {
      await ref.read(tasksRepositoryProvider).save(task);
      if (mounted) context.go('/backlog');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleCompleted() async {
    if (widget.taskId == null) {
      setState(() {
        _completedAt = _completedAt == null ? DateTime.now() : null;
      });
      return;
    }
    final isCompleted = _completedAt != null;
    if (isCompleted) {
      setState(() => _completedAt = null);
      await ref
          .read(tasksRepositoryProvider)
          .setCompleted(widget.taskId!, false);
    } else {
      setState(() => _completedAt = DateTime.now());
      await ref
          .read(tasksRepositoryProvider)
          .setCompleted(widget.taskId!, true);
    }
    if (mounted) setState(() {});
  }

  Future<void> _delete() async {
    final id = widget.taskId;
    if (id == null) return;
    final repo = ref.read(tasksRepositoryProvider);
    final linkedCount = await repo.countLinkedActivities(id);
    if (!mounted) return;

    if (linkedCount == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Eliminar tarea'),
          content: const Text('¿Seguro que quieres eliminar esta tarea?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      await repo.delete(id);
      if (mounted) context.go('/backlog');
      return;
    }

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea con bloques'),
        content: Text(
          'Esta tarea tiene $linkedCount bloque(s) en el calendario. ¿Qué quieres hacer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'unlink'),
            child: const Text('Solo tarea'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'cascade'),
            child: const Text('Tarea y bloques'),
          ),
        ],
      ),
    );
    if (choice == null || choice == 'cancel') return;
    if (choice == 'unlink') {
      await repo.deleteTaskOnly(id);
    } else if (choice == 'cascade') {
      await repo.deleteTaskAndActivities(id);
    }
    if (mounted) context.go('/backlog');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskId != null;
    final asyncTask = isEditing
        ? ref.watch(taskByIdProvider(widget.taskId!))
        : null;

    if (isEditing && asyncTask != null) {
      return asyncTask.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Cargando...')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Error: $e')),
        ),
        data: (task) {
          if (task != null && !_loaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_loaded && mounted) {
                setState(() {
                  _populate(task);
                  _loaded = true;
                });
              }
            });
          }
          return _buildScaffold(isEditing);
        },
      );
    }
    return _buildScaffold(isEditing);
  }

  Widget _buildScaffold(bool isEditing) {
    final derivedStatus = isEditing && widget.taskId != null
        ? ref.watch(taskStatusProvider(widget.taskId!))
        : (_completedAt != null ? TaskStatus.completed : TaskStatus.pending);
    final isCompleted = _completedAt != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar tarea' : 'Nueva tarea'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/backlog'),
        ),
        actions: [
          if (isEditing)
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _save, child: const Text('Guardar')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'El título es obligatorio'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
                hintText: 'Descripción, links, markdown futuro...',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskKind>(
              initialValue: _kind,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: TaskKind.values
                  .map(
                    (k) => DropdownMenuItem(
                      value: k,
                      child: Row(
                        children: [
                          Icon(_kindIcon(k), size: 20),
                          const SizedBox(width: 8),
                          Text(_kindLabel(k)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _kind = v ?? TaskKind.task),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.hourglass_empty,
                    size: 18,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado: ${_statusLabel(derivedStatus)}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          isCompleted ? 'Marcada como hecha' : 'Cambia automáticamente al programar o completar sesiones',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _toggleCompleted,
                    child: Text(isCompleted ? 'Reabrir' : 'Marcar hecha'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _estimatedCtrl,
              decoration: const InputDecoration(
                labelText: 'Estimación (horas)',
                border: OutlineInputBorder(),
                hintText: 'ej. 10',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final h = double.tryParse(v.trim().replaceAll(',', '.'));
                if (h == null || h <= 0) return 'Debe ser > 0';
                return null;
              },
            ),
            if (widget.taskId != null) ...[
              const SizedBox(height: 24),
              _LinkedActivitiesSection(taskId: widget.taskId!),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinkedActivitiesSection extends ConsumerWidget {
  const _LinkedActivitiesSection({required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(taskProgressProvider(taskId));
    final hasLink = progress.linkedActivitiesCount > 0;
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    final linkedActivity = activitiesAsync.asData?.value
        .where((a) => a.taskId == taskId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vinculación', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(hasLink ? Icons.link : Icons.link_off),
            title: Text(hasLink ? '1 bloque vinculado' : 'Sin bloques aún'),
            subtitle: hasLink
                ? progress.totalPlannedSessions > 0
                      ? Text(
                          '${progress.completedSessions}/${progress.totalPlannedSessions} sesiones · ${(progress.totalPlannedMinutes / 60).toStringAsFixed(1)} h planificadas',
                        )
                      : const Text('Bloque programado')
                : const Text(
                    'Una tarea puede tener un bloque en el calendario',
                  ),
            trailing: FilledButton.tonal(
              onPressed: hasLink && linkedActivity != null
                  ? () => context.go(
                      '/activity/${linkedActivity.id}?from=/backlog/task/$taskId',
                    )
                  : () => context.go(
                      '/activity/new?taskId=$taskId&from=/backlog/task/$taskId',
                    ),
              child: Text(hasLink ? 'Ver' : 'Programar'),
            ),
          ),
        ),
        if (hasLink)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Una tarea admite un solo bloque (puntual o recurrente con muchas ocurrencias).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
