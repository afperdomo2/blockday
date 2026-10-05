// ignore_for_file: unnecessary_non_null_assertion
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/activity_colors.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../activities/providers/activities_stream_provider.dart';

class WeekView extends ConsumerStatefulWidget {
  const WeekView({super.key, required this.selectedDate});

  final DateTime selectedDate;

  static const double hourHeight = 48;
  static const double gutterWidth = 48;
  static const double totalHeight = 24 * hourHeight;

  @override
  ConsumerState<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
  late final ScrollController _controller;
  late final DateTime? _now;
  late final double? _nowTop;
  late final int? _todayIndex;

  DateTime get monday {
    final d = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    return DateTime(d.year, d.month, d.day - (d.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final m = monday;
    final sunday = DateTime(m.year, m.month, m.day + 6);
    final normalizedNow = DateTime(now.year, now.month, now.day);
    if (!normalizedNow.isBefore(m) && !normalizedNow.isAfter(sunday)) {
      _now = now;
      _nowTop = (now.hour * 60 + now.minute) / 60 * WeekView.hourHeight;
      _todayIndex = normalizedNow.difference(m).inDays;
      final offset = (_nowTop! - 120).clamp(0.0, WeekView.totalHeight);
      _controller = ScrollController(initialScrollOffset: offset);
    } else {
      _now = null;
      _nowTop = null;
      _todayIndex = null;
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
    final occurrences = ref.watch(weekOccurrencesProvider(widget.selectedDate));
    final weekDays = List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _WeekHeader(weekDays: weekDays),
        Expanded(
          child: SingleChildScrollView(
            controller: _controller,
            child: SizedBox(
              height: WeekView.totalHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columnWidth = constraints.maxWidth.isFinite
                      ? (constraints.maxWidth - WeekView.gutterWidth) / 7
                      : 100.0;
                  return Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: WeekView.gutterWidth,
                            child: Column(
                              children: List.generate(24, (h) {
                                return SizedBox(
                                  height: WeekView.hourHeight,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 6,
                                        top: 2,
                                      ),
                                      child: Text(
                                        '${h.toString().padLeft(2, '0')}:00',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          ...weekDays.map((day) {
                            final dayOcc = occurrences
                                .where((o) => _isSameDay(o.date, day))
                                .toList();
                            final isToday = _isSameDay(day, DateTime.now());
                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? colorScheme.primaryContainer.withValues(
                                          alpha: 0.15,
                                        )
                                      : null,
                                  border: Border(
                                    left: BorderSide(
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: 0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapUp: (details) {
                                    final localY = details.localPosition.dy;
                                    final h = (localY / WeekView.hourHeight)
                                        .clamp(0, 23)
                                        .toInt();
                                    context.go(
                                      '/activity/new?date=${day.toIso8601String()}&hour=$h&from=/calendar',
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: List.generate(24, (h) {
                                          return Container(
                                            height: WeekView.hourHeight,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color: colorScheme
                                                      .outlineVariant
                                                      .withValues(alpha: 0.3),
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      ...dayOcc.map((occ) {
                                        final startMin =
                                            occ.start.hour * 60 +
                                            occ.start.minute;
                                        final endMin =
                                            occ.end.hour * 60 + occ.end.minute;
                                        final top =
                                            startMin / 60 * WeekView.hourHeight;
                                        final height =
                                            (endMin - startMin) /
                                            60 *
                                            WeekView.hourHeight;
                                        return Positioned(
                                          top: top + 1,
                                          left: 2,
                                          right: 2,
                                          height: height.clamp(
                                            18,
                                            WeekView.totalHeight,
                                          ),
                                          child: _WeekBlock(occurrence: occ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      if (_now != null &&
                          _nowTop != null &&
                          _todayIndex != null)
                        Positioned(
                          top: _nowTop!,
                          left:
                              WeekView.gutterWidth + _todayIndex! * columnWidth,
                          width: columnWidth,
                          height: 2,
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: colorScheme.primary,
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
          ),
        ),
      ],
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.weekDays});
  final List<DateTime> weekDays;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          const SizedBox(width: 48),
          ...weekDays.map((d) {
            final isToday = _isSameDay(d, now);
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isToday
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'es').format(d),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isToday
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    Text(
                      '${d.day}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: isToday ? FontWeight.bold : null,
                        color: isToday
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WeekBlock extends StatelessWidget {
  const _WeekBlock({required this.occurrence});
  final Occurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final bg = activityColor(occurrence.color);
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final isLinked = occurrence.isLinkedToTask;
    return GestureDetector(
      onTap: () =>
          context.go('/activity/${occurrence.activityId}?from=/calendar'),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                occurrence.title,
                style: TextStyle(
                  color: fg,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLinked) ...[
              const SizedBox(width: 2),
              Icon(Icons.link, size: 10, color: fg.withValues(alpha: 0.9)),
            ],
          ],
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
