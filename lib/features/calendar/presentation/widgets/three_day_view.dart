import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_format.dart';
import '../../../activities/providers/activities_stream_provider.dart';
import '../../../settings/providers/settings_providers.dart';
import 'days_header.dart';
import 'time_grid_column.dart';

class ThreeDayView extends ConsumerStatefulWidget {
  const ThreeDayView({super.key, required this.selectedDate});

  final DateTime selectedDate;

  static const double hourHeight = 60;
  static const double gutterWidth = 48;

  @override
  ConsumerState<ThreeDayView> createState() => _ThreeDayViewState();
}

class _ThreeDayViewState extends ConsumerState<ThreeDayView> {
  late final ScrollController _controller;
  double? _nowTop;

  DateTime _dayAt(int index) {
    final d = widget.selectedDate;
    return DateTime(d.year, d.month, d.day + index);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final first = _dayAt(0);
    final last = _dayAt(2);
    final normalizedNow = DateTime(now.year, now.month, now.day);
    if (!normalizedNow.isBefore(first) && !normalizedNow.isAfter(last)) {
      _nowTop = (now.hour * 60 + now.minute) / 60 * ThreeDayView.hourHeight;
      final offset = (_nowTop! - 120).clamp(0.0, 24 * ThreeDayView.hourHeight);
      _controller = ScrollController(initialScrollOffset: offset);
    } else {
      _controller = ScrollController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(3, _dayAt);
    final occsByDay = days
        .map((d) => ref.watch(dayOccurrencesProvider(d)))
        .toList();
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    return Column(
      children: [
        DaysHeader(days: days),
        Expanded(
          child: SingleChildScrollView(
            controller: _controller,
            child: SizedBox(
              height: 24 * ThreeDayView.hourHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ThreeDayView.gutterWidth,
                    child: Column(
                      children: List.generate(24, (h) {
                        return SizedBox(
                          height: ThreeDayView.hourHeight,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6, top: 2),
                              child: Text(
                                formatHourLabel(
                                  h,
                                  use24Hour: ref
                                      .watch(currentSettingsProvider)
                                      .use24HourFormat,
                                ),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  for (var i = 0; i < days.length; i++)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSameDay(days[i], now)
                              ? colorScheme.primaryContainer.withValues(
                                  alpha: 0.15,
                                )
                              : null,
                          border: Border(
                            left: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: TimeGridColumn(
                          date: days[i],
                          occurrences: occsByDay[i],
                          hourHeight: ThreeDayView.hourHeight,
                          showNowLine: isSameDay(days[i], now),
                          onEmptyTap: (h, m) => context.go(
                            '/activity/new?date=${days[i].toIso8601String()}&hour=$h&from=/calendar',
                          ),
                          onRangeSelected: (date, startMin, endMin) => context.go(
                            '/activity/new?date=${date.toIso8601String()}&start=$startMin&end=$endMin&from=/calendar',
                          ),
                          onBlockTap: (occ) => context.go(
                            '/activity/${occ.activityId}?from=/calendar',
                          ),
                          onBlockResize: (occ, startMin, endMin) => context.go(
                            '/activity/${occ.activityId}?start=$startMin&end=$endMin&from=/calendar',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
