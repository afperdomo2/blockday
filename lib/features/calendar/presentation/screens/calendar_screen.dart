import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/responsive/constrained_content.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../shared/widgets/search_action.dart';
import '../../../../shared/widgets/settings_action.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../activities/providers/activities_stream_provider.dart';
import '../../providers/calendar_state.dart';
import '../widgets/month_view.dart';
import '../widgets/three_day_view.dart';
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
      } else if (view == CalendarView.threeDay) {
        notifier.previousThreeDay();
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
      } else if (view == CalendarView.threeDay) {
        notifier.nextThreeDay();
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
          const SearchAction(),
          const SettingsAction(),
        ],
      ),
      body: Column(
        children: [
          ConstrainedContent(
            maxWidth: AppContentWidth.list,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = !context.isCompact;
                  return SegmentedButton<CalendarView>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: CalendarView.day,
                        label: wide ? const Text('Día') : null,
                        icon: const Icon(Icons.view_day),
                      ),
                      ButtonSegment(
                        value: CalendarView.threeDay,
                        label: wide ? const Text('3 días') : null,
                        icon: const Icon(Icons.view_column),
                      ),
                      ButtonSegment(
                        value: CalendarView.week,
                        label: wide ? const Text('Semana') : null,
                        icon: const Icon(Icons.view_week),
                      ),
                      ButtonSegment(
                        value: CalendarView.month,
                        label: wide ? const Text('Mes') : null,
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ],
                    selected: {view},
                    onSelectionChanged: (s) => ref
                        .read(calendarStateProvider.notifier)
                        .setView(s.first),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ConstrainedContent(
              maxWidth: switch (view) {
                CalendarView.day => AppContentWidth.day,
                CalendarView.threeDay => AppContentWidth.threeDay,
                CalendarView.week ||
                CalendarView.month => AppContentWidth.calendar,
              },
              child: AnimatedSwitcher(
                duration: AppMotion.reduceMotion(context)
                    ? Duration.zero
                    : AppMotion.base,
                switchInCurve: AppMotion.enter,
                switchOutCurve: AppMotion.exit,
                child: activitiesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (_) {
                    if (view == CalendarView.threeDay) {
                      return ThreeDayView(
                        key: ValueKey('threeDay-$selectedDate'),
                        selectedDate: selectedDate,
                      );
                    }
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
                    return _buildDayGrid(context, selectedDate, occurrences);
                  },
                ),
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

  Widget _buildDayGrid(
    BuildContext context,
    DateTime selectedDate,
    List<Occurrence> occurrences,
  ) {
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
            onRangeSelected: (date, startMin, endMin) => context.go(
              '/activity/new?date=${date.toIso8601String()}&start=$startMin&end=$endMin&from=/calendar',
            ),
            onBlockTap: (occ) =>
                context.go('/activity/${occ.activityId}?from=/calendar'),
            onBlockResize: (occ, startMin, endMin) => context.go(
              '/activity/${occ.activityId}?start=$startMin&end=$endMin&from=/calendar',
            ),
          ),
        ),
        if (occurrences.isEmpty)
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
