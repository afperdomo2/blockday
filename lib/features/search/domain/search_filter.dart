import '../../activities/domain/activity.dart';
import '../../backlog/domain/task.dart';

String normalizeQuery(String query) => query.trim().toLowerCase();

bool textMatches(String? text, String query) {
  final q = normalizeQuery(query);
  if (q.isEmpty) return true;
  return text != null && text.toLowerCase().contains(q);
}

bool taskMatchesQuery(Task task, String query) {
  final q = normalizeQuery(query);
  if (q.isEmpty) return true;
  return textMatches(task.title, q) ||
      textMatches(task.notes, q) ||
      task.tags.any((tag) => textMatches(tag, q));
}

bool activityMatchesQuery(Activity activity, String query) {
  final q = normalizeQuery(query);
  if (q.isEmpty) return true;
  return textMatches(activity.title, q) || textMatches(activity.notes, q);
}

List<Task> filterTasks(List<Task> tasks, String query) =>
    tasks.where((t) => taskMatchesQuery(t, query)).toList();

List<Activity> filterActivities(List<Activity> activities, String query) =>
    activities.where((a) => activityMatchesQuery(a, query)).toList();
