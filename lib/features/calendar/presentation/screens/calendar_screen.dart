import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_format.dart';
import '../../../activities/providers/activities_stream_provider.dart';
import '../../providers/calendar_state.dart';
import '../widgets/time_grid.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarStateProvider);
    final selectedDate = calendarState.selectedDate;
    final occurrences = ref.watch(dayOccurrencesProvider(selectedDate));
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    final isToday = _isSameDay(selectedDate, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockday'),
        centerTitle: false,
        actions: [
          if (!isToday)
            TextButton(
              onPressed: () => ref.read(calendarStateProvider.notifier).today(),
              child: const Text('Hoy'),
            ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Día anterior',
            onPressed: () =>
                ref.read(calendarStateProvider.notifier).previousDay(),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Día siguiente',
            onPressed: () => ref.read(calendarStateProvider.notifier).nextDay(),
          ),
        ],
      ),
      body: activitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (_) {
          if (occurrences.isEmpty) {
            return Column(
              children: [
                _DateChip(date: selectedDate),
                Expanded(
                  child: TimeGrid(
                    date: selectedDate,
                    occurrences: const [],
                    onEmptyTap: (h, m) => context.go(
                      '/activity/new?date=${selectedDate.toIso8601String()}&hour=$h',
                    ),
                    onBlockTap: (occ) =>
                        context.go('/activity/${occ.activityId}'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Sin actividades para este día',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              _DateChip(date: selectedDate),
              Expanded(
                child: TimeGrid(
                  date: selectedDate,
                  occurrences: occurrences,
                  onEmptyTap: (h, m) => context.go(
                    '/activity/new?date=${selectedDate.toIso8601String()}&hour=$h',
                  ),
                  onBlockTap: (occ) =>
                      context.go('/activity/${occ.activityId}'),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.go('/activity/new?date=${selectedDate.toIso8601String()}'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        formatDayHeader(date),
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
