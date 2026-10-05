import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/activity_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../activities/domain/overlap_layout.dart';
import '../../domain/drag_time.dart';
import 'activity_block.dart';

class TimeGrid extends StatefulWidget {
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
  static const double minBlockHeightForHandles = 44;

  @override
  State<TimeGrid> createState() => _TimeGridState();
}

class _CreateDrag {
  _CreateDrag(this.anchorMinutes, this.currentMinutes);

  int anchorMinutes;
  int currentMinutes;
}

class _ResizeDrag {
  _ResizeDrag(
    this.occurrence,
    this.isTop,
    this.anchorMinutes,
    this.currentMinutes,
  );

  final Occurrence occurrence;
  final bool isTop;
  int anchorMinutes;
  int currentMinutes;
}

class _TimeGridState extends State<TimeGrid> {
  final GlobalKey _contentKey = GlobalKey();
  late final ScrollController _controller;
  late final DateTime? _now;
  late final double? _nowTop;
  _CreateDrag? _createDrag;
  _ResizeDrag? _resizeDrag;

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

  int _minutesAt(Offset globalPosition) {
    final box = _contentKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return 0;
    final local = box.globalToLocal(globalPosition);
    return minutesFromOffset(local.dy, TimeGrid.hourHeight);
  }

  void _onCreateDragStart(LongPressStartDetails details) {
    HapticFeedback.lightImpact();
    final minutes = _minutesAt(details.globalPosition);
    setState(() => _createDrag = _CreateDrag(minutes, minutes));
  }

  void _onCreateDragUpdate(LongPressMoveUpdateDetails details) {
    final drag = _createDrag;
    if (drag == null) return;
    drag.currentMinutes = _minutesAt(details.globalPosition);
    setState(() {});
  }

  void _onCreateDragEnd(LongPressEndDetails details) {
    final drag = _createDrag;
    if (drag == null) return;
    HapticFeedback.lightImpact();
    final moved = drag.currentMinutes != drag.anchorMinutes;
    setState(() => _createDrag = null);
    if (!moved) {
      final start = snapMinutes(drag.anchorMinutes);
      final end = (start + 60).clamp(0, kDayEndMinutes);
      widget.onRangeSelected(widget.date, start, end > start ? end : start);
      return;
    }
    final (start, end) = normalizeRange(
      drag.anchorMinutes,
      drag.currentMinutes,
    );
    widget.onRangeSelected(widget.date, start, end);
  }

  void _onCreateDragCancel() {
    if (_createDrag != null) setState(() => _createDrag = null);
  }

  void _onResizeDragStart(
    DragStartDetails details,
    Occurrence occurrence,
    bool isTop,
  ) {
    HapticFeedback.lightImpact();
    final minutes = _minutesAt(details.globalPosition);
    setState(
      () => _resizeDrag = _ResizeDrag(occurrence, isTop, minutes, minutes),
    );
  }

  void _onResizeDragUpdate(DragUpdateDetails details) {
    final drag = _resizeDrag;
    if (drag == null) return;
    drag.currentMinutes = _minutesAt(details.globalPosition);
    setState(() {});
  }

  void _onResizeDragEnd(DragEndDetails details) {
    final drag = _resizeDrag;
    if (drag == null) return;
    HapticFeedback.lightImpact();
    final (start, end) = _resizeRange(drag);
    setState(() => _resizeDrag = null);
    widget.onBlockResize(drag.occurrence, start, end);
  }

  (int, int) _resizeRange(_ResizeDrag drag) {
    final occ = drag.occurrence;
    final occStart = occ.start.hour * 60 + occ.start.minute;
    final occEnd = occ.end.hour * 60 + occ.end.minute;
    return drag.isTop
        ? normalizeRange(drag.currentMinutes, occEnd)
        : normalizeRange(occStart, drag.currentMinutes);
  }

  (int, int)? get _createPreview {
    final drag = _createDrag;
    if (drag == null) return null;
    return normalizeRange(drag.anchorMinutes, drag.currentMinutes);
  }

  (int, int)? get _resizePreview {
    final drag = _resizeDrag;
    if (drag == null) return null;
    return _resizeRange(drag);
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
                    onLongPressStart: _onCreateDragStart,
                    onLongPressMoveUpdate: _onCreateDragUpdate,
                    onLongPressEnd: _onCreateDragEnd,
                    onLongPressCancel: _onCreateDragCancel,
                    child: Stack(
                      key: _contentKey,
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
                                children: [
                                  ...laid.map((item) {
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
                                      child: _buildBlock(occ, height),
                                    );
                                  }),
                                  ..._buildPreviews(colorScheme),
                                ],
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

  Widget _buildBlock(Occurrence occ, double blockHeight) {
    return ActivityBlock(
      occurrence: occ,
      showResizeHandles: blockHeight >= TimeGrid.minBlockHeightForHandles,
      onTap: () => widget.onBlockTap(occ),
      onResizeStart: (details, isTop) =>
          _onResizeDragStart(details, occ, isTop),
      onResizeUpdate: _onResizeDragUpdate,
      onResizeEnd: _onResizeDragEnd,
    );
  }

  List<Widget> _buildPreviews(ColorScheme colorScheme) {
    final create = _createPreview;
    final resize = _resizePreview;
    final resizeDrag = _resizeDrag;
    return [
      if (create != null)
        _buildPreview(
          startMinutes: create.$1,
          endMinutes: create.$2,
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
        ),
      if (resize != null && resizeDrag != null)
        _buildPreview(
          startMinutes: resize.$1,
          endMinutes: resize.$2,
          background: ActivityColors.of(
            resizeDrag.occurrence.color,
            Theme.of(context).brightness,
          ).background.withValues(alpha: 0.55),
          foreground: ActivityColors.of(
            resizeDrag.occurrence.color,
            Theme.of(context).brightness,
          ).foreground,
        ),
    ];
  }

  Widget _buildPreview({
    required int startMinutes,
    required int endMinutes,
    required Color background,
    required Color foreground,
  }) {
    final top = startMinutes / 60 * TimeGrid.hourHeight;
    final height = (endMinutes - startMinutes) / 60 * TimeGrid.hourHeight;
    final date = widget.date;
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      startMinutes ~/ 60,
      startMinutes % 60,
    );
    final end = DateTime(
      date.year,
      date.month,
      date.day,
      endMinutes ~/ 60,
      endMinutes % 60,
    );
    final label = formatHourRange(start, end);
    return Positioned(
      top: top + 1,
      left: 4,
      right: 4,
      height: height.clamp(22, TimeGrid.totalHeight),
      child: Semantics(
        label: 'Vista previa $label',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
              ),
            ),
          ),
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
