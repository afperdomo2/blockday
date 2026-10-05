import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../activities/providers/activities_stream_provider.dart';
import '../../backlog/providers/tasks_providers.dart';

typedef WeeklyProgress = ({int completed, int planned});

final weeklyProgressProvider = Provider.family<WeeklyProgress, DateTime>((
  ref,
  today,
) {
  final planned = ref.watch(weekOccurrencesProvider(today)).length;
  final sessions = ref.watch(sessionsStreamProvider).asData?.value ?? const [];

  final monday = DateTime(
    today.year,
    today.month,
    today.day - (today.weekday - 1),
  );
  final sunday = monday.add(const Duration(days: 6));

  var completed = 0;
  for (final s in sessions) {
    if (s.completedAt == null) continue;
    final d = DateTime.fromMillisecondsSinceEpoch(s.date);
    if (!d.isBefore(monday) && !d.isAfter(sunday)) completed++;
  }
  return (completed: completed, planned: planned);
});
