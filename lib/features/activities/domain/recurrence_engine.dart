import 'activity.dart';
import 'occurrence.dart';

List<Occurrence> expandOccurrences(
  Activity activity,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  return activity.occurrencesInRange(rangeStart, rangeEnd);
}

List<Occurrence> expandAll(
  Iterable<Activity> activities,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final result = <Occurrence>[];
  for (final a in activities) {
    result.addAll(a.occurrencesInRange(rangeStart, rangeEnd));
  }
  result.sort((a, b) => a.start.compareTo(b.start));
  return result;
}
