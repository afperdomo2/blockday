import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/activity.dart';
import '../domain/occurrence.dart';
import '../domain/recurrence_engine.dart';
import 'activities_providers.dart';

final activitiesStreamProvider = StreamProvider<List<Activity>>((ref) {
  return ref.watch(activitiesRepositoryProvider).watchAll();
});

final dayOccurrencesProvider = Provider.family<List<Occurrence>, DateTime>((
  ref,
  date,
) {
  final asyncActivities = ref.watch(activitiesStreamProvider);
  final activities = asyncActivities.asData?.value;
  if (activities == null) return const [];
  final normalized = DateTime(date.year, date.month, date.day);
  return expandAll(activities, normalized, normalized);
});

final rangeOccurrencesProvider =
    Provider.family<List<Occurrence>, ({DateTime start, DateTime end})>((
      ref,
      range,
    ) {
      final asyncActivities = ref.watch(activitiesStreamProvider);
      final activities = asyncActivities.asData?.value;
      if (activities == null) return const [];
      return expandAll(activities, range.start, range.end);
    });

final weekOccurrencesProvider = Provider.family<List<Occurrence>, DateTime>((
  ref,
  date,
) {
  final normalized = DateTime(date.year, date.month, date.day);
  final weekday = normalized.weekday;
  final monday = DateTime(
    normalized.year,
    normalized.month,
    normalized.day - (weekday - 1),
  );
  final sunday = DateTime(monday.year, monday.month, monday.day + 6);
  final asyncActivities = ref.watch(activitiesStreamProvider);
  final activities = asyncActivities.asData?.value;
  if (activities == null) return const [];
  return expandAll(activities, monday, sunday);
});
