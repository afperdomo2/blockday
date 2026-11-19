import 'package:blockday/features/activities/data/app_database.dart'
    hide Activity;
import 'package:blockday/features/activities/data/repositories/activities_repository.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/activities/presentation/screens/activity_editor_screen.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:blockday/features/notifications/data/notification_service.dart';
import 'package:blockday/features/notifications/providers/notifications_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('el editor guarda el recordatorio y repregunta permisos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final db = AppDatabase.memory();
    addTearDown(db.close);
    final fake = FakeNotificationService();
    final router = GoRouter(
      initialLocation: '/activity/new',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(
          path: '/activity/new',
          builder: (_, _) => const ActivityEditorScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          tasksStreamProvider.overrideWith((ref) => Stream.value([])),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
          notificationServiceProvider.overrideWithValue(fake),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'Con recordatorio',
    );
    await tester.tap(find.text('Sin recordatorio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 minutos antes').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final activities = await ActivitiesRepository(db).getAll();
    expect(activities.single.reminderMinutes, 15);
    expect(fake.permissionsRequested, true);
    expect(fake.replaceAllCalls, 1);
  });
}
