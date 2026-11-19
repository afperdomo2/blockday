import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/utils/date_format.dart';
import '../domain/reminder_schedule.dart';

abstract class NotificationService {
  Future<void> init();

  Future<void> requestPermissions();

  Future<void> replaceAll(List<ReminderSchedule> reminders);
}

class LocalNotificationService implements NotificationService {
  static const String _channelId = 'blockday_reminders';
  static const String _channelName = 'Recordatorios';
  static const String _channelDescription =
      'Aviso antes de que empiece un bloque';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    try {
      tz_data.initializeTimeZones();
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        linux: LinuxInitializationSettings(defaultActionName: 'Abrir'),
        windows: WindowsInitializationSettings(
          appName: 'Blockday',
          appUserModelId: 'com.blockday.app',
          guid: '6f9619ff-8b86-4d01-b42b-2f73d6e0c6a3',
        ),
      );
      await _plugin.initialize(settings: settings);
    } catch (_) {}
  }

  @override
  Future<void> requestPermissions() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    } catch (_) {}
  }

  @override
  Future<void> replaceAll(List<ReminderSchedule> reminders) async {
    try {
      await _plugin.cancelAll();
      for (final reminder in reminders) {
        await _plugin.zonedSchedule(
          id: reminder.notificationId,
          title: reminder.title,
          body: 'Empieza a las ${formatHour(reminder.occurrenceStart)}',
          scheduledDate: tz.TZDateTime.from(reminder.fireAt, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
            ),
            linux: LinuxNotificationDetails(),
            windows: WindowsNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    } catch (_) {}
  }
}

class FakeNotificationService implements NotificationService {
  bool initialized = false;
  bool permissionsRequested = false;
  int replaceAllCalls = 0;
  List<ReminderSchedule> scheduled = const [];

  @override
  Future<void> init() async {
    initialized = true;
  }

  @override
  Future<void> requestPermissions() async {
    permissionsRequested = true;
  }

  @override
  Future<void> replaceAll(List<ReminderSchedule> reminders) async {
    replaceAllCalls++;
    scheduled = List.of(reminders);
  }
}
