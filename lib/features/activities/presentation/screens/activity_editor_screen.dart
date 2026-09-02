import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/activity_colors.dart';
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
  Set<int> _weekdays = {
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  };
  DateTime _firstDate = DateTime.now();
  _EndCondition _endCondition = _EndCondition.never;
  DateTime _untilDate = DateTime.now().add(const Duration(days: 30));
  Set<DateTime> _excludedDates = {};
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFromQuery());
  }

  void _initFromQuery() {
    if (widget.activityId != null) return;
    final state = GoRouterState.of(context);
    final dateStr = state.uri.queryParameters['date'];
    final hourStr = state.uri.queryParameters['hour'];
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
  }

  void _populateFromActivity(Activity a) {
    _titleCtrl.text = a.title;
    _notesCtrl.text = a.notes ?? '';
    _color = a.color;
    _excludedDates = a.excludedDates;
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

    setState(() => _saving = true);
    final id = widget.activityId ?? const Uuid().v4();
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
      );
    }

    try {
      await ref.read(activitiesRepositoryProvider).save(activity);
      if (mounted) context.go('/');
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
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activityId != null;
    final asyncActivity = isEditing
        ? ref.watch(activityByIdProvider(widget.activityId!))
        : null;

    if (isEditing && asyncActivity != null) {
      return asyncActivity.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Cargando...')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Error: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar actividad' : 'Nueva actividad'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar',
              onPressed: _delete,
            ),
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
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(activityPalette.length, (i) {
                final selected = _color == i;
                return GestureDetector(
                  onTap: () => setState(() => _color = i),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: activityPalette[i],
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            )
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
              const SizedBox(height: 8),
              Text(
                'Días de la semana',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
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
              const SizedBox(height: 8),
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
                          DateFormat('EEEE d MMMM y', 'es').format(_untilDate),
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
    );
  }
}
