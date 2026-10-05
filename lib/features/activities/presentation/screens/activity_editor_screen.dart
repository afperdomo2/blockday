import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/activity_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../backlog/providers/tasks_providers.dart';
import '../../domain/activity.dart';
import '../../domain/recurrence_end.dart';
import '../../domain/recurrence_rule.dart';
import '../../providers/activities_providers.dart';
import '../../providers/activity_by_id_provider.dart';

enum _EditorMode { single, recurring }

enum _EndCondition { never, until, count }

const _weekdayLabels = <int, String>{
  DateTime.monday: 'L',
  DateTime.tuesday: 'M',
  DateTime.wednesday: 'X',
  DateTime.thursday: 'J',
  DateTime.friday: 'V',
  DateTime.saturday: 'S',
  DateTime.sunday: 'D',
};

class ActivityEditorScreen extends ConsumerStatefulWidget {
  const ActivityEditorScreen({super.key, this.activityId});

  final String? activityId;

  @override
  ConsumerState<ActivityEditorScreen> createState() =>
      _ActivityEditorScreenState();
}

class _ActivityEditorScreenState extends ConsumerState<ActivityEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '4');
  int _color = 0;
  _EditorMode _mode = _EditorMode.single;
  DateTime _singleDate = DateTime.now();
  TimeOfDay _singleStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _singleEnd = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _recStart = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _recEnd = const TimeOfDay(hour: 19, minute: 0);
  Set<int> _weekdays = {};
  DateTime _firstDate = DateTime.now();
  _EndCondition _endCondition = _EndCondition.never;
  DateTime _untilDate = DateTime.now().add(const Duration(days: 30));
  Set<DateTime> _excludedDates = {};
  String? _taskId;
  bool _loaded = false;
  bool _saving = false;
  bool _taskPrefilled = false;
  String _returnTo = '/calendar';
  (int, int)? _pendingRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFromQuery());
  }

  void _initFromQuery() {
    final state = GoRouterState.of(context);
    _returnTo = _sanitizeReturn(state.uri.queryParameters['from']);
    final range = _parseRangeQuery(state.uri);
    if (widget.activityId != null) {
      _pendingRange = range;
      return;
    }
    final dateStr = state.uri.queryParameters['date'];
    final hourStr = state.uri.queryParameters['hour'];
    final taskIdParam = state.uri.queryParameters['taskId'];
    if (dateStr != null) {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        setState(() {
          _singleDate = DateTime(parsed.year, parsed.month, parsed.day);
          _firstDate = DateTime(parsed.year, parsed.month, parsed.day);
        });
      }
    }
    if (hourStr != null) {
      final h = int.tryParse(hourStr);
      if (h != null && h >= 0 && h < 24) {
        setState(() {
          _singleStart = TimeOfDay(hour: h, minute: 0);
          _singleEnd = TimeOfDay(hour: (h + 1).clamp(0, 23), minute: 0);
          _recStart = TimeOfDay(hour: h, minute: 0);
          _recEnd = TimeOfDay(hour: (h + 1).clamp(0, 23), minute: 0);
        });
      }
    }
    if (range != null) {
      setState(() => _applyRangeQuery(range));
    }
    if (taskIdParam != null && !_taskPrefilled) {
      _taskId = taskIdParam;
      _prefillFromTask(taskIdParam);
    }
  }

  (int, int)? _parseRangeQuery(Uri uri) {
    final startStr = uri.queryParameters['start'];
    final endStr = uri.queryParameters['end'];
    if (startStr == null || endStr == null) return null;
    final start = int.tryParse(startStr);
    final end = int.tryParse(endStr);
    if (start == null || end == null) return null;
    if (start < 0 || start >= end || end > 1440) return null;
    return (start, end);
  }

  void _applyRangeQuery((int, int) range) {
    _singleStart = _minutesToTimeOfDay(range.$1);
    _singleEnd = _minutesToTimeOfDay(range.$2);
    _recStart = _singleStart;
    _recEnd = _singleEnd;
  }

  TimeOfDay _minutesToTimeOfDay(int minutes) {
    final m = minutes.clamp(0, 1439);
    return TimeOfDay(hour: m ~/ 60, minute: m % 60);
  }

  String _sanitizeReturn(String? from) {
    if (from == null || from.isEmpty) return '/calendar';
    if (from == '/' ||
        from == '/calendar' ||
        from == '/backlog' ||
        from.startsWith('/backlog/')) {
      return from;
    }
    return '/calendar';
  }

  Future<void> _prefillFromTask(String taskId) async {
    final task = await ref.read(tasksRepositoryProvider).getById(taskId);
    if (task == null || !mounted || _taskPrefilled) return;
    setState(() {
      _taskPrefilled = true;
      _titleCtrl.text = task.title;
      if (task.notes != null) _notesCtrl.text = task.notes!;
    });
  }

  Future<void> _pickTask() async {
    final tasks = await ref.read(tasksRepositoryProvider).getAll();
    if (!mounted) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Vincular tarea'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ''),
            child: const Text('Sin vincular'),
          ),
          const Divider(),
          ...tasks.map(
            (t) => SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, t.id),
              child: Text(t.title),
            ),
          ),
        ],
      ),
    );
    if (selected != null) {
      setState(() => _taskId = selected.isEmpty ? null : selected);
    }
  }

  void _populateFromActivity(Activity a) {
    _titleCtrl.text = a.title;
    _notesCtrl.text = a.notes ?? '';
    _color = a.color;
    _excludedDates = a.excludedDates;
    _taskId = a.taskId;
    if (a.kind == ActivityKind.single) {
      _mode = _EditorMode.single;
      _singleDate = DateTime(
        a.singleStart!.year,
        a.singleStart!.month,
        a.singleStart!.day,
      );
      _singleStart = TimeOfDay(
        hour: a.singleStart!.hour,
        minute: a.singleStart!.minute,
      );
      _singleEnd = TimeOfDay(
        hour: a.singleEnd!.hour,
        minute: a.singleEnd!.minute,
      );
    } else {
      _mode = _EditorMode.recurring;
      final r = a.rule!;
      _recStart = TimeOfDay(
        hour: r.startMinutes ~/ 60,
        minute: r.startMinutes % 60,
      );
      _recEnd = TimeOfDay(hour: r.endMinutes ~/ 60, minute: r.endMinutes % 60);
      _weekdays = Set.of(r.weekdays);
      _firstDate = DateTime(
        r.firstDate.year,
        r.firstDate.month,
        r.firstDate.day,
      );
      final end = r.end;
      if (end is RecurrenceNever) {
        _endCondition = _EndCondition.never;
      } else if (end is RecurrenceUntil) {
        _endCondition = _EndCondition.until;
        _untilDate = DateTime(end.date.year, end.date.month, end.date.day);
      } else if (end is RecurrenceCount) {
        _endCondition = _EndCondition.count;
        _countCtrl.text = end.count.toString();
      }
    }
    final pending = _pendingRange;
    if (pending != null) {
      _pendingRange = null;
      _applyRangeQuery(pending);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    DateTime initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es'),
    );
    if (picked != null) {
      onPicked(DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _pickTime(
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onPicked,
  ) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      onPicked(picked);
    }
  }

  int _todToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mode == _EditorMode.single) {
      if (_todToMinutes(_singleEnd) <= _todToMinutes(_singleStart)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La hora de fin debe ser posterior al inicio'),
          ),
        );
        return;
      }
    } else {
      if (_todToMinutes(_recEnd) <= _todToMinutes(_recStart)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La hora de fin debe ser posterior al inicio'),
          ),
        );
        return;
      }
      if (_weekdays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona al menos un día de la semana'),
          ),
        );
        return;
      }
      if (_endCondition == _EndCondition.count) {
        final c = int.tryParse(_countCtrl.text);
        if (c == null || c < 1) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('N debe ser mayor a 0')));
          return;
        }
      }
      if (_endCondition == _EndCondition.until &&
          _untilDate.isBefore(_firstDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La fecha hasta debe ser posterior al inicio'),
          ),
        );
        return;
      }
    }

    final id = widget.activityId ?? const Uuid().v4();
    if (_taskId != null) {
      final all = await ref.read(activitiesRepositoryProvider).getAll();
      final alreadyLinked = all.any((a) => a.taskId == _taskId && a.id != id);
      if (alreadyLinked) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Esta tarea ya tiene un bloque vinculado. Usa "Ver programación" para editarlo.',
              ),
            ),
          );
        }
        return;
      }
    }

    setState(() => _saving = true);
    final title = _titleCtrl.text.trim();
    final notes = _notesCtrl.text.trim().isEmpty
        ? null
        : _notesCtrl.text.trim();
    late Activity activity;
    if (_mode == _EditorMode.single) {
      final start = DateTime(
        _singleDate.year,
        _singleDate.month,
        _singleDate.day,
        _singleStart.hour,
        _singleStart.minute,
      );
      final end = DateTime(
        _singleDate.year,
        _singleDate.month,
        _singleDate.day,
        _singleEnd.hour,
        _singleEnd.minute,
      );
      activity = Activity(
        id: id,
        title: title,
        notes: notes,
        color: _color,
        kind: ActivityKind.single,
        singleStart: start,
        singleEnd: end,
        excludedDates: _excludedDates,
        taskId: _taskId,
      );
    } else {
      RecurrenceEnd end;
      if (_endCondition == _EndCondition.never) {
        end = const RecurrenceNever();
      } else if (_endCondition == _EndCondition.until) {
        end = RecurrenceUntil(_untilDate);
      } else {
        end = RecurrenceCount(int.parse(_countCtrl.text));
      }
      activity = Activity(
        id: id,
        title: title,
        notes: notes,
        color: _color,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: _todToMinutes(_recStart),
          endMinutes: _todToMinutes(_recEnd),
          weekdays: _weekdays,
          firstDate: _firstDate,
          end: end,
        ),
        excludedDates: _excludedDates,
        taskId: _taskId,
      );
    }

    try {
      await ref.read(activitiesRepositoryProvider).save(activity);
      if (mounted) context.go(_returnTo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final id = widget.activityId;
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar actividad'),
        content: const Text('¿Seguro que quieres eliminar esta actividad?'),
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
    await ref.read(activitiesRepositoryProvider).delete(id);
    if (mounted) context.go(_returnTo);
  }

  void _closeEditor() {
    if (mounted) context.go(_returnTo);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activityId != null;
    final asyncActivity = isEditing
        ? ref.watch(activityByIdProvider(widget.activityId!))
        : null;

    if (isEditing && asyncActivity != null) {
      return asyncActivity.when(
        loading: () => PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeEditor();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Cargando...'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _closeEditor,
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
        ),
        error: (e, _) => PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeEditor();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _closeEditor,
              ),
            ),
            body: Center(child: Text('Error: $e')),
          ),
        ),
        data: (activity) {
          if (activity != null && !_loaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_loaded && mounted) {
                setState(() {
                  _populateFromActivity(activity);
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeEditor();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Editar actividad' : 'Nueva actividad'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cerrar',
            onPressed: _closeEditor,
          ),
          actions: [
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Eliminar',
                onPressed: _delete,
              ),
            if (_saving)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
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
            padding: const EdgeInsets.all(AppSpacing.lg),
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
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Color', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(ActivityColors.length, (i) {
                  final selected = _color == i;
                  final ac = ActivityColors.light[i];
                  return Semantics(
                    label: 'Color ${i + 1}',
                    button: true,
                    selected: selected,
                    child: GestureDetector(
                      onTap: () => setState(() => _color = i),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: ac.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            width: selected ? 3 : 1,
                          ),
                        ),
                        child: selected
                            ? Icon(Icons.check, size: 20, color: ac.foreground)
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              _TaskLinkTile(
                taskId: _taskId,
                onPick: _pickTask,
                onClear: () => setState(() => _taskId = null),
              ),
              const SizedBox(height: AppSpacing.lg),
              SegmentedButton<_EditorMode>(
                segments: const [
                  ButtonSegment(
                    value: _EditorMode.single,
                    label: Text('Puntual'),
                    icon: Icon(Icons.event),
                  ),
                  ButtonSegment(
                    value: _EditorMode.recurring,
                    label: Text('Recurrente'),
                    icon: Icon(Icons.repeat),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_mode == _EditorMode.single) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha'),
                  subtitle: Text(
                    DateFormat('EEEE d MMMM y', 'es').format(_singleDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(
                    _singleDate,
                    (d) => setState(() => _singleDate = d),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Inicio'),
                        subtitle: Text(_singleStart.format(context)),
                        onTap: () => _pickTime(
                          _singleStart,
                          (t) => setState(() => _singleStart = t),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Fin'),
                        subtitle: Text(_singleEnd.format(context)),
                        onTap: () => _pickTime(
                          _singleEnd,
                          (t) => setState(() => _singleEnd = t),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Inicio'),
                        subtitle: Text(_recStart.format(context)),
                        onTap: () => _pickTime(
                          _recStart,
                          (t) => setState(() => _recStart = t),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Fin'),
                        subtitle: Text(_recEnd.format(context)),
                        onTap: () => _pickTime(
                          _recEnd,
                          (t) => setState(() => _recEnd = t),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Días de la semana',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: _weekdayLabels.entries.map((e) {
                    final selected = _weekdays.contains(e.key);
                    return FilterChip(
                      label: Text(e.value),
                      selected: selected,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _weekdays = {..._weekdays, e.key};
                        } else {
                          _weekdays = {..._weekdays}..remove(e.key);
                        }
                      }),
                    );
                  }).toList(),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha de inicio'),
                  subtitle: Text(
                    DateFormat('EEEE d MMMM y', 'es').format(_firstDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(
                    _firstDate,
                    (d) => setState(() => _firstDate = d),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Termina', style: Theme.of(context).textTheme.titleSmall),
                RadioGroup<_EndCondition>(
                  groupValue: _endCondition,
                  onChanged: (v) => setState(() => _endCondition = v!),
                  child: Column(
                    children: [
                      RadioListTile<_EndCondition>(
                        title: const Text('Nunca'),
                        value: _EndCondition.never,
                      ),
                      RadioListTile<_EndCondition>(
                        title: const Text('Hasta fecha'),
                        value: _EndCondition.until,
                      ),
                      if (_endCondition == _EndCondition.until)
                        ListTile(
                          title: Text(
                            DateFormat(
                              'EEEE d MMMM y',
                              'es',
                            ).format(_untilDate),
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _pickDate(
                            _untilDate,
                            (d) => setState(() => _untilDate = d),
                          ),
                        ),
                      RadioListTile<_EndCondition>(
                        title: const Text('Después de N veces'),
                        value: _EndCondition.count,
                      ),
                    ],
                  ),
                ),
                if (_endCondition == _EndCondition.count)
                  TextFormField(
                    controller: _countCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Número de veces',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1) return 'Debe ser >= 1';
                      return null;
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskLinkTile extends ConsumerWidget {
  const _TaskLinkTile({
    required this.taskId,
    required this.onPick,
    required this.onClear,
  });

  final String? taskId;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (taskId == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.link_off),
          title: const Text('Sin tarea vinculada'),
          subtitle: const Text(
            'Vincula esta actividad a una tarea del backlog',
          ),
          trailing: FilledButton.tonal(
            onPressed: onPick,
            child: const Text('Vincular'),
          ),
        ),
      );
    }
    final asyncTask = ref.watch(taskByIdProvider(taskId!));
    return asyncTask.when(
      loading: () =>
          const Card(child: ListTile(title: Text('Cargando tarea...'))),
      error: (_, _) => Card(
        child: ListTile(
          leading: const Icon(Icons.link),
          title: Text('Tarea $taskId'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
        ),
      ),
      data: (task) => Card(
        child: ListTile(
          leading: const Icon(Icons.link),
          title: Text(task?.title ?? 'Tarea $taskId'),
          subtitle: task != null ? Text(task.kind.name) : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(onPressed: onPick, child: const Text('Cambiar')),
              IconButton(icon: const Icon(Icons.close), onPressed: onClear),
            ],
          ),
        ),
      ),
    );
  }
}
