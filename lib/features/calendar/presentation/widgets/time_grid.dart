import 'package:flutter/material.dart';

import '../../../../core/utils/date_format.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../activities/domain/overlap_layout.dart';
import 'activity_block.dart';

class TimeGrid extends StatefulWidget {
  const TimeGrid({
    super.key,
    required this.date,
    required this.occurrences,
    required this.onEmptyTap,
    required this.onBlockTap,
  });

  final DateTime date;
  final List<Occurrence> occurrences;
  final void Function(int hour, int minute) onEmptyTap;
  final void Function(Occurrence occurrence) onBlockTap;

  static const double hourHeight = 60;
  static const double gutterWidth = 56;
  static const double totalHeight = 24 * hourHeight;

  @override
  State<TimeGrid> createState() => _TimeGridState();
}

class _TimeGridState extends State<TimeGrid> {
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
                              '${hour.toString().padLeft(2, '0')}:00',
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) {
                      final localY = details.localPosition.dy;
                      final totalMinutes = (localY / TimeGrid.hourHeight * 60)
                          .clamp(0, 1439)
                          .toInt();
                      final hour = totalMinutes ~/ 60;
                      final minute = totalMinutes % 60;
                      widget.onEmptyTap(hour, minute);
                    },
                    child: Stack(
                      children: [
                        Column(
                          children: List.generate(24, (hour) {
                            return Container(
                              height: TimeGrid.hourHeight,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                    width: hour == 0 ? 0 : 0.5,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              const gutter = 12.0;
                              final available = (constraints.maxWidth - gutter)
                                  .clamp(0.0, double.infinity);
                              final laid = layoutOverlaps(widget.occurrences);
                              return Stack(
                                children: laid.map((item) {
                                  final occ = item.occurrence;
                                  final columnWidth =
                                      available / item.totalColumns;
                                  final startMinutes =
                                      occ.start.hour * 60 + occ.start.minute;
                                  final endMinutes =
                                      occ.end.hour * 60 + occ.end.minute;
                                  final top =
                                      startMinutes / 60 * TimeGrid.hourHeight;
                                  final height =
                                      (endMinutes - startMinutes) /
                                      60 *
                                      TimeGrid.hourHeight;
                                  return Positioned(
                                    top: top + 1,
                                    left: 4 + columnWidth * item.column,
                                    width: columnWidth - 3,
                                    height: height.clamp(
                                      22,
                                      TimeGrid.totalHeight,
                                    ),
                                    child: ActivityBlock(
                                      occurrence: occ,
                                      onTap: () => widget.onBlockTap(occ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_now != null && _nowTop != null)
              _buildNowIndicator(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildNowIndicator(ColorScheme scheme) {
    return Positioned(
      top: _nowTop!,
      left: 0,
      right: 0,
      height: 2,
      child: Row(
        children: [
          SizedBox(width: TimeGrid.gutterWidth - 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(child: Container(height: 2, color: scheme.primary)),
        ],
      ),
    );
  }
}
