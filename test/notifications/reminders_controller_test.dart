import 'package:blockday/features/activities/data/app_database.dart'
    hide Activity;
import 'package:blockday/features/activities/data/repositories/activities_repository.dart';
import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/activities/domain/recurrence_end.dart';
import 'package:blockday/features/activities/domain/recurrence_rule.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/notifications/data/notification_service.dart';
import 'package:blockday/features/notifications/domain/reminder_schedule.dart';
import 'package:blockday/features/notifications/providers/notifications_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late FakeNotificationService fake;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.memory();
    fake = FakeNotificationService();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);
  });

  Future<void> saveActivity(Activity activity) {
    return ActivitiesRepository(db).save(activity);
  }

  test('agenda recordatorios de las actividades que los tienen', () async {
    final start = DateTime.now().add(const Duration(days: 1));
    final occurrenceDay = DateTime(start.year, start.month, start.day);
    await saveActivity(
      Activity(
        id: 'a1',
        title: 'Curso',
        color: 0,
        kind: ActivityKind.single,
        singleStart: DateTime(
          occurrenceDay.year,
          occurrenceDay.month,
          occurrenceDay.day,
          10,
          0,
        ),
        singleEnd: DateTime(
          occurrenceDay.year,
          occurrenceDay.month,
          occurrenceDay.day,
          12,
          0,
        ),
        reminderMinutes: 15,
      ),
    );

    await container.read(remindersControllerProvider).rescheduleAll();

    expect(fake.replaceAllCalls, 1);
    expect(fake.scheduled, hasLength(1));
    expect(fake.scheduled.single.activityId, 'a1');
    expect(
      fake.scheduled.single.notificationId,
      reminderNotificationId('a1', occurrenceDay),
    );
    expect(
      fake.scheduled.single.fireAt,
      DateTime(
        occurrenceDay.year,
        occurrenceDay.month,
        occurrenceDay.day,
        9,
        45,
      ),
    );
  });

  test('las actividades sin recordatorio no se agendan', () async {
    await saveActivity(
      Activity(
        id: 'a2',
        title: 'Sin recordatorio',
        color: 0,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 9 * 60,
          endMinutes: 10 * 60,
          weekdays: {DateTime.monday},
          firstDate: DateTime.now().subtract(const Duration(days: 7)),
          end: const RecurrenceNever(),
        ),
      ),
    );

    await container.read(remindersControllerProvider).rescheduleAll();

    expect(fake.replaceAllCalls, 1);
    expect(fake.scheduled, isEmpty);
  });

  test('requestPermissions delega en el servicio', () async {
    await container.read(remindersControllerProvider).requestPermissions();
    expect(fake.permissionsRequested, true);
  });

  test('bootstrap inicializa el servicio y programa', () async {
    await container.read(notificationsBootstrapProvider.future);
    expect(fake.initialized, true);
    expect(fake.replaceAllCalls, 1);
  });
}
