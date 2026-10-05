import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/date_format.dart';
import '../../../activities/providers/activities_stream_provider.dart';
import '../../providers/calendar_state.dart';
import '../widgets/month_view.dart';
import '../widgets/time_grid.dart';
import '../widgets/week_view.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarStateProvider);
    final selectedDate = calendarState.selectedDate;
    final view = calendarState.view;
    final occurrences = ref.watch(dayOccurrencesProvider(selectedDate));
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    final isToday = isSameDay(selectedDate, DateTime.now());

    void navigatePrev() {
      final notifier = ref.read(calendarStateProvider.notifier);
      if (view == CalendarView.day) {
        notifier.previousDay();
      } else if (view == CalendarView.week) {
        notifier.previousWeek();
      } else {
        notifier.previousMonth();
      }
    }

    void navigateNext() {
      final notifier = ref.read(calendarStateProvider.notifier);
      if (view == CalendarView.day) {
        notifier.nextDay();
      } else if (view == CalendarView.week) {
        notifier.nextWeek();
      } else {
        notifier.nextMonth();
      }
    }

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
            tooltip: 'Anterior',
            onPressed: navigatePrev,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Siguiente',
            onPressed: navigateNext,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SegmentedButton<CalendarView>(
              segments: const [
                ButtonSegment(
                  value: CalendarView.day,
                  label: Text('Día'),
                  icon: Icon(Icons.view_day),
                ),
                ButtonSegment(
                  value: CalendarView.week,
                  label: Text('Semana'),
                  icon: Icon(Icons.view_week),
                ),
                ButtonSegment(
                  value: CalendarView.month,
                  label: Text('Mes'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: {view},
              onSelectionChanged: (s) =>
                  ref.read(calendarStateProvider.notifier).setView(s.first),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.reduceMotion(context)
                  ? Duration.zero
                  : AppMotion.base,
              switchInCurve: AppMotion.enter,
              switchOutCurve: AppMotion.exit,
              child: activitiesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (_) {
                  if (view == CalendarView.week) {
                    return WeekView(
                      key: ValueKey('week-$selectedDate'),
                      selectedDate: selectedDate,
                    );
                  }
                  if (view == CalendarView.month) {
                    return MonthView(
                      key: ValueKey('month-$selectedDate'),
                      selectedDate: selectedDate,
                    );
                  }
                  if (occurrences.isEmpty) {
                    return Column(
                      key: ValueKey('day-empty-$selectedDate'),
                      children: [
                        _DateChip(date: selectedDate),
                        Expanded(
                          child: TimeGrid(
                            date: selectedDate,
                            occurrences: const [],
                            onEmptyTap: (h, m) => context.go(
                              '/activity/new?date=${selectedDate.toIso8601String()}&hour=$h&from=/calendar',
                            ),
                            onBlockTap: (occ) => context.go(
                              '/activity/${occ.activityId}?from=/calendar',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Sin actividades para este día',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    key: ValueKey('day-$selectedDate'),
                    children: [
                      _DateChip(date: selectedDate),
                      Expanded(
                        child: TimeGrid(
                          date: selectedDate,
                          occurrences: occurrences,
                          onEmptyTap: (h, m) => context.go(
                            '/activity/new?date=${selectedDate.toIso8601String()}&hour=$h&from=/calendar',
                          ),
                          onBlockTap: (occ) => context.go(
                            '/activity/${occ.activityId}?from=/calendar',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'calendar-fab',
        onPressed: () => context.go(
          '/activity/new?date=${selectedDate.toIso8601String()}&from=/calendar',
        ),
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
