import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../activities/providers/activities_providers.dart';
import '../data/notification_service.dart';
import '../domain/reminder_schedule.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationService();
});

class RemindersController {
  RemindersController(this._ref);

  final Ref _ref;

  Future<void> rescheduleAll() async {
    final service = _ref.read(notificationServiceProvider);
    final activities = await _ref.read(activitiesRepositoryProvider).getAll();
    final now = DateTime.now();
    final horizonEnd = now.add(const Duration(days: reminderHorizonDays));
    final reminders = <ReminderSchedule>[];
    for (final activity in activities) {
      final minutes = activity.reminderMinutes;
      if (minutes == null) continue;
      reminders.addAll(
        computeReminders(
          activity: activity,
          reminderMinutesBefore: minutes,
          now: now,
          horizonEnd: horizonEnd,
        ),
      );
    }
    await service.replaceAll(reminders);
  }

  Future<void> requestPermissions() {
    return _ref.read(notificationServiceProvider).requestPermissions();
  }
}

final remindersControllerProvider = Provider<RemindersController>((ref) {
  return RemindersController(ref);
});

final notificationsBootstrapProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  await service.init();
  await ref.watch(remindersControllerProvider).rescheduleAll();
});
