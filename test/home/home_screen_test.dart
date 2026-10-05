import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/backlog/domain/task.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:blockday/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('renders empty state dashboard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          tasksStreamProvider.overrideWith((ref) => Stream.value([])),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Resumen semanal'), findsOneWidget);
    expect(find.text('Sin sesiones programadas esta semana'), findsOneWidget);
    expect(find.text('Sin actividades hoy'), findsOneWidget);
    expect(find.text('Sin eventos en los próximos días'), findsOneWidget);
    expect(find.text('Nada pendiente. Todo está programado.'), findsOneWidget);
  });

  testWidgets('shows today activity, pending task and week summary', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activity = Activity(
      id: 'a1',
      title: 'Bloque de prueba',
      color: 0,
      kind: ActivityKind.single,
      singleStart: today.add(const Duration(hours: 17)),
      singleEnd: today.add(const Duration(hours: 19)),
    );
    final task = Task(id: 't1', title: 'Tarea pendiente');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activitiesStreamProvider.overrideWith(
            (ref) => Stream.value([activity]),
          ),
          tasksStreamProvider.overrideWith((ref) => Stream.value([task])),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bloque de prueba'), findsWidgets);
    expect(find.text('Tarea pendiente'), findsOneWidget);
    expect(find.text('0 de 1 sesiones completadas'), findsOneWidget);
  });
}
