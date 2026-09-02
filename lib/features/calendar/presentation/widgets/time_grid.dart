import 'package:flutter/material.dart';

import '../../../activities/domain/occurrence.dart';
import 'activity_block.dart';

class TimeGrid extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: SizedBox(
        height: totalHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: gutterWidth,
              child: Column(
                children: List.generate(24, (hour) {
                  return SizedBox(
                    height: hourHeight,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8, top: 2),
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
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
                  final totalMinutes = (localY / hourHeight * 60)
                      .clamp(0, 1439)
                      .toInt();
                  final hour = totalMinutes ~/ 60;
                  final minute = totalMinutes % 60;
                  onEmptyTap(hour, minute);
                },
                child: Stack(
                  children: [
                    Column(
                      children: List.generate(24, (hour) {
                        return Container(
                          height: hourHeight,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                                width: hour == 0 ? 0 : 0.5,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    ...occurrences.map((occ) {
                      final startMinutes =
                          occ.start.hour * 60 + occ.start.minute;
                      final endMinutes = occ.end.hour * 60 + occ.end.minute;
                      final top = startMinutes / 60 * hourHeight;
                      final height =
                          (endMinutes - startMinutes) / 60 * hourHeight;
                      return Positioned(
                        top: top + 1,
                        left: 4,
                        right: 8,
                        height: height.clamp(22, totalHeight),
                        child: ActivityBlock(
                          occurrence: occ,
                          onTap: () => onBlockTap(occ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
