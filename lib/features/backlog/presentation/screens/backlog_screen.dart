import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/constrained_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/settings_action.dart';
import '../../../../shared/widgets/staggered_entrance.dart';
import '../../../search/domain/search_filter.dart';
import '../../domain/task.dart';
import '../../providers/tasks_providers.dart';
import '../widgets/task_tile.dart';

class BacklogScreen extends ConsumerStatefulWidget {
  const BacklogScreen({super.key});

  @override
  ConsumerState<BacklogScreen> createState() => _BacklogScreenState();
}

class _BacklogScreenState extends ConsumerState<BacklogScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _searchQuery = '';
  bool _searching = false;
  String _statusFilter = 'all';
  String? _tagFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _searching = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _searchFocus.requestFocus(),
    );
  }

  void _stopSearch() {
    setState(() {
      _searching = false;
      _searchQuery = '';
      _searchCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                decoration: const InputDecoration(
                  hintText: 'Buscar tareas...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                onSubmitted: (_) {},
              )
            : const Text('Backlog'),
        centerTitle: false,
        actions: [
          if (_searching)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cerrar búsqueda',
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Buscar',
              onPressed: _startSearch,
            ),
          const SettingsAction(),
        ],
      ),
      body: ConstrainedContent(
        maxWidth: AppContentWidth.list,
        child: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Column(
                children: [
                  _buildStatusFilter(context),
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: Text(
                          'Sin tareas aún.\nCrea una con el botón + y luego prográmala en el calendario.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final filtered = _applyFilter(tasks);

            return Column(
              children: [
                _buildStatusFilter(context),
                _buildTagFilter(tasks),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'Sin tareas'
                                  : 'Sin resultados para "$_searchQuery"',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 80),
                          children: [
                            StaggeredEntrance(
                              child: Column(
                                children: [
                                  if (_statusFilter == 'all' &&
                                      _searchQuery.isEmpty)
                                    ..._buildAllSections(filtered)
                                  else
                                    _Section(
                                      title: _sectionTitleForFilter(),
                                      count: filtered.length,
                                      tasks: filtered,
                                      emptyText: 'Sin tareas',
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'backlog-fab',
        onPressed: () => context.go('/backlog/task/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }

  List<Widget> _buildAllSections(List<Task> filtered) {
    final byStatus = <TaskStatus, List<Task>>{
      TaskStatus.pending: [],
      TaskStatus.scheduled: [],
      TaskStatus.inProgress: [],
      TaskStatus.completed: [],
    };
    for (final t in filtered) {
      final s = ref.read(taskStatusProvider(t.id));
      byStatus[s]!.add(t);
    }

    var base = 0;
    Widget section(String title, List<Task> tasks, String emptyText) {
      final widget = _Section(
        title: title,
        count: tasks.length,
        tasks: tasks,
        emptyText: emptyText,
        staggerBase: base,
      );
      base += tasks.isEmpty ? 2 : tasks.length + 1;
      return widget;
    }

    return [
      section(
        'Sin programar',
        byStatus[TaskStatus.pending]!,
        'Nada sin programar',
      ),
      section(
        'Programadas',
        byStatus[TaskStatus.scheduled]!,
        'Nada programado',
      ),
      section(
        'En progreso',
        byStatus[TaskStatus.inProgress]!,
        'Nada en progreso',
      ),
      section('Hechas', byStatus[TaskStatus.completed]!, 'Nada hecho aún'),
    ];
  }

  String _sectionTitleForFilter() {
    switch (_statusFilter) {
      case 'pending':
        return 'Sin programar';
      case 'scheduled':
        return 'Programadas';
      case 'inProgress':
        return 'En progreso';
      case 'completed':
        return 'Hechas';
      default:
        if (_searchQuery.isNotEmpty) return 'Resultados';
        return 'Tareas';
    }
  }

  Widget _buildStatusFilter(BuildContext context) {
    const filters = [
      ('all', 'Todas'),
      ('pending', 'Sin programar'),
      ('scheduled', 'Programadas'),
      ('inProgress', 'En progreso'),
      ('completed', 'Hechas'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: filters.map((f) {
          final selected = _statusFilter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(f.$2),
              selected: selected,
              onSelected: (_) => setState(() => _statusFilter = f.$1),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTagFilter(List<Task> tasks) {
    final tags = <String>{};
    for (final t in tasks) {
      tags.addAll(t.tags);
    }
    if (tags.isEmpty) return const SizedBox.shrink();
    final sorted = tags.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: sorted.map((tag) {
          final selected = _tagFilter == tag;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text('#$tag'),
              selected: selected,
              onSelected: (v) => setState(() => _tagFilter = v ? tag : null),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Task> _applyFilter(List<Task> tasks) {
    var result = tasks;

    if (_searchQuery.isNotEmpty) {
      result = result.where((t) => taskMatchesQuery(t, _searchQuery)).toList();
    }

    if (_tagFilter != null) {
      result = result.where((t) => t.hasTag(_tagFilter!)).toList();
    }

    switch (_statusFilter) {
      case 'pending':
        result = result
            .where(
              (t) => ref.read(taskStatusProvider(t.id)) == TaskStatus.pending,
            )
            .toList();
        break;
      case 'scheduled':
        result = result
            .where(
              (t) => ref.read(taskStatusProvider(t.id)) == TaskStatus.scheduled,
            )
            .toList();
        break;
      case 'inProgress':
        result = result
            .where(
              (t) =>
                  ref.read(taskStatusProvider(t.id)) == TaskStatus.inProgress,
            )
            .toList();
        break;
      case 'completed':
        result = result
            .where(
              (t) => ref.read(taskStatusProvider(t.id)) == TaskStatus.completed,
            )
            .toList();
        break;
      default:
        break;
    }

    return result;
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.count,
    required this.tasks,
    required this.emptyText,
    this.staggerBase = 0,
  });

  final String title;
  final int count;
  final List<Task> tasks;
  final String emptyText;
  final int staggerBase;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredItem(
          index: staggerBase,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: SectionHeader(title: title, count: count),
          ),
        ),
        if (tasks.isEmpty)
          StaggeredItem(
            index: staggerBase + 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                emptyText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...tasks.asMap().entries.map(
            (entry) => StaggeredItem(
              index: staggerBase + 1 + entry.key,
              child: TaskTile(
                task: entry.value,
                onTap: () =>
                    GoRouter.of(context).go('/backlog/task/${entry.value.id}'),
              ),
            ),
          ),
      ],
    );
  }
}
