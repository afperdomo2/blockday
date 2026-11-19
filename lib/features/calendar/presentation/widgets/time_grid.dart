import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_format.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../settings/providers/settings_providers.dart';
import 'now_line.dart';
import 'time_grid_column.dart';

class TimeGrid extends ConsumerStatefulWidget {
  const TimeGrid({
    super.key,
    required this.date,
    required this.occurrences,
    required this.onEmptyTap,
    required this.onBlockTap,
    required this.onRangeSelected,
    required this.onBlockResize,
  });

  final DateTime date;
  final List<Occurrence> occurrences;
  final void Function(int hour, int minute) onEmptyTap;
  final void Function(Occurrence occurrence) onBlockTap;
  final void Function(DateTime date, int startMinutes, int endMinutes)
  onRangeSelected;
  final void Function(Occurrence occurrence, int startMinutes, int endMinutes)
  onBlockResize;

  static const double hourHeight = 60;
  static const double gutterWidth = 56;
  static const double totalHeight = 24 * hourHeight;

  @override
  ConsumerState<TimeGrid> createState() => _TimeGridState();
}

class _TimeGridState extends ConsumerState<TimeGrid> {
  late final ScrollController _controller;
  late final DateTime? _now;
  late final double? _nowTop;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (isSameDay(widget.date, now)) {
      _now = now;
      _nowTop = (now.hour * 60 + now.minute) / 60 * TimeGrid.hourHeight;
      final offset = (_nowTop! - 120).clamp(0.0, TimeGrid.totalHeight);
      _controller = ScrollController(initialScrollOffset: offset);
    } else {
      _now = null;
      _nowTop = null;
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
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      controller: _controller,
      child: SizedBox(
        height: TimeGrid.totalHeight,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: TimeGrid.gutterWidth,
                  child: Column(
                    children: List.generate(24, (hour) {
                      return SizedBox(
                        height: TimeGrid.hourHeight,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8, top: 2),
                            child: Text(
                              formatHourLabel(
                                hour,
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
                Expanded(
                  child: TimeGridColumn(
                    date: widget.date,
                    occurrences: widget.occurrences,
                    hourHeight: TimeGrid.hourHeight,
                    onEmptyTap: widget.onEmptyTap,
                    onBlockTap: widget.onBlockTap,
                    onRangeSelected: widget.onRangeSelected,
                    onBlockResize: widget.onBlockResize,
                  ),
                ),
              ],
            ),
            if (_now != null && _nowTop != null)
              Positioned(
                top: _nowTop - 3,
                left: 0,
                right: 0,
                height: 8,
                child: NowLine(leadingWidth: TimeGrid.gutterWidth - 10),
              ),
          ],
        ),
      ),
    );
  }
}
