// ignore_for_file: unnecessary_non_null_assertion
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/activity_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../activities/domain/overlap_layout.dart';
import '../../../activities/providers/activities_stream_provider.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/providers/settings_providers.dart';
import 'days_header.dart';
import 'now_line.dart';

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

  DateTime get _weekStart => startOfWeek(
    widget.selectedDate,
    ref.read(currentSettingsProvider).weekStart,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final m = _weekStart;
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
    ref.watch(currentSettingsProvider);
    final occurrences = ref.watch(weekOccurrencesProvider(widget.selectedDate));
    final weekStart = _weekStart;
    final weekDays = List.generate(
      7,
      (i) => DateTime(weekStart.year, weekStart.month, weekStart.day + i),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        DaysHeader(days: weekDays),
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
                                        formatHourLabel(
                                          h,
                                          use24Hour: ref
                                              .watch(currentSettingsProvider)
                                              .use24HourFormat,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
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
                                .where((o) => isSameDay(o.date, day))
                                .toList();
                            final isToday = isSameDay(day, DateTime.now());
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
                                      Positioned.fill(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            const gutter = 4.0;
                                            final available =
                                                (constraints.maxWidth - gutter)
                                                    .clamp(
                                                      0.0,
                                                      double.infinity,
                                                    );
                                            final laid = layoutOverlaps(dayOcc);
                                            return Stack(
                                              children: laid.map((item) {
                                                final occ = item.occurrence;
                                                final columnWidth =
                                                    available /
                                                    item.totalColumns;
                                                final startMin =
                                                    occ.start.hour * 60 +
                                                    occ.start.minute;
                                                final endMin =
                                                    occ.end.hour * 60 +
                                                    occ.end.minute;
                                                final top =
                                                    startMin /
                                                    60 *
                                                    WeekView.hourHeight;
                                                final height =
                                                    (endMin - startMin) /
                                                    60 *
                                                    WeekView.hourHeight;
                                                return Positioned(
                                                  top: top + 1,
                                                  left:
                                                      2 +
                                                      columnWidth * item.column,
                                                  width: columnWidth - 2,
                                                  height: height.clamp(
                                                    18,
                                                    WeekView.totalHeight,
                                                  ),
                                                  child: _WeekBlock(
                                                    occurrence: occ,
                                                    compact:
                                                        item.totalColumns > 2,
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
                            );
                          }),
                        ],
                      ),
                      if (_now != null &&
                          _nowTop != null &&
                          _todayIndex != null)
                        Positioned(
                          top: _nowTop! - 3,
                          left:
                              WeekView.gutterWidth + _todayIndex! * columnWidth,
                          width: columnWidth,
                          height: 8,
                          child: const NowLine(),
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

class _WeekBlock extends StatelessWidget {
  const _WeekBlock({required this.occurrence, this.compact = false});
  final Occurrence occurrence;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = ActivityColors.of(
      occurrence.color,
      Theme.of(context).brightness,
    ).background;
    final isLinked = occurrence.isLinkedToTask;
    return GestureDetector(
      onTap: () =>
          context.go('/activity/${occurrence.activityId}?from=/calendar'),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.22),
              accent.withValues(alpha: 0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: accent.withValues(alpha: 0.5)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.xxs : AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                occurrence.title,
                style:
                    (compact
                            ? AppTypography.weekBlockCompact
                            : AppTypography.weekBlock)
                        .copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                maxLines: compact ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLinked && !compact) ...[
              const SizedBox(width: AppSpacing.xxs),
              Icon(
                Icons.link,
                size: 10,
                color: cs.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
