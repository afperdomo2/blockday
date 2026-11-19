import 'package:blockday/features/activities/data/app_database.dart'
    hide Activity, Task;
import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/backlog/domain/task.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:blockday/features/search/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  final start = DateTime.now().add(const Duration(days: 1));
  final activities = [
    Activity(
      id: 'a1',
      title: 'Curso virtual',
      color: 0,
      kind: ActivityKind.single,
      singleStart: start,
      singleEnd: start.add(const Duration(hours: 2)),
    ),
    Activity(
      id: 'a2',
      title: 'Gimnasio',
      color: 1,
      kind: ActivityKind.single,
      singleStart: start,
      singleEnd: start.add(const Duration(hours: 1)),
    ),
  ];
  final tasks = [
    Task(id: 't1', title: 'Repasar curso', tags: ['estudio']),
    Task(id: 't2', title: 'Comprar regalo'),
  ];

  Future<void> pumpSearch(WidgetTester tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith(
            (ref) => Stream.value(activities),
          ),
          tasksStreamProvider.overrideWith((ref) => Stream.value(tasks)),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(home: SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sin query muestra el hint de búsqueda', (tester) async {
    await pumpSearch(tester);
    expect(
      find.text('Escribe para buscar en tus actividades y tareas'),
      findsOneWidget,
    );
  });

  testWidgets('busca en actividades y tareas a la vez', (tester) async {
    await pumpSearch(tester);
    await tester.enterText(find.byType(TextField), 'curso');
    await tester.pumpAndSettle();

    expect(find.text('Actividades'), findsOneWidget);
    expect(find.text('Tareas'), findsOneWidget);
    expect(find.text('Curso virtual'), findsOneWidget);
    expect(find.text('Repasar curso'), findsOneWidget);
    expect(find.text('Gimnasio'), findsNothing);
    expect(find.text('Comprar regalo'), findsNothing);
  });

  testWidgets('la búsqueda también encuentra por etiqueta', (tester) async {
    await pumpSearch(tester);
    await tester.enterText(find.byType(TextField), 'estudio');
    await tester.pumpAndSettle();

    expect(find.text('Repasar curso'), findsOneWidget);
    expect(find.text('Curso virtual'), findsNothing);
  });

  testWidgets('sin coincidencias muestra el estado vacío', (tester) async {
    await pumpSearch(tester);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('Sin resultados para "zzz"'), findsOneWidget);
  });
}
