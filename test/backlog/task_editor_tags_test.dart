import 'package:blockday/features/activities/data/app_database.dart' hide Task;
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/backlog/data/repositories/tasks_repository.dart';
import 'package:blockday/features/backlog/domain/task.dart';
import 'package:blockday/features/backlog/presentation/screens/task_editor_screen.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter _buildRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/backlog',
        builder: (_, _) => const Scaffold(body: Text('backlog')),
      ),
      GoRoute(
        path: '/backlog/task/new',
        builder: (_, _) => const TaskEditorScreen(),
      ),
      GoRoute(
        path: '/backlog/task/:id',
        builder: (_, state) =>
            TaskEditorScreen(taskId: state.pathParameters['id']),
      ),
    ],
  );
}

Future<void> _pumpEditor(
  WidgetTester tester,
  AppDatabase db,
  GoRouter router,
) async {
  addTearDown(router.dispose);
  tester.view.physicalSize = const Size(900, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
        tasksStreamProvider.overrideWith((ref) => Stream.value([])),
        sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
    addTearDown(db.close);
  });

  testWidgets('añadir etiqueta muestra un chip', (tester) async {
    await _pumpEditor(tester, db, _buildRouter('/backlog/task/new'));

    await tester.enterText(find.byType(TextField).last, 'estudio');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('estudio'), findsOneWidget);
    expect(find.byType(InputChip), findsOneWidget);
  });

  testWidgets('guardar persiste las etiquetas', (tester) async {
    final router = _buildRouter('/backlog/task/new');
    await _pumpEditor(tester, db, router);

    await tester.enterText(find.byType(TextFormField).first, 'Estudiar AWS');
    await tester.enterText(find.byType(TextField).last, 'estudio');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final tasks = await TasksRepository(db).getAll();
    expect(tasks.single.tags, ['estudio']);
  });

  testWidgets('el chip elimina la etiqueta antes de guardar', (tester) async {
    await _pumpEditor(tester, db, _buildRouter('/backlog/task/new'));

    final tagField = find.byType(TextField).last;
    await tester.enterText(tagField, 'casa');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(tagField, 'salud');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(InputChip), findsNWidgets(2));

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(InputChip, 'casa'),
        matching: find.byType(Icon),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'casa'), findsNothing);
    expect(find.widgetWithText(InputChip, 'salud'), findsOneWidget);
  });

  testWidgets('editar carga las etiquetas existentes', (tester) async {
    await TasksRepository(db)
        .save(Task(id: 't1', title: 'Tarea', tags: ['viaje']));
    await _pumpEditor(tester, db, _buildRouter('/backlog/task/t1'));

    expect(find.widgetWithText(InputChip, 'viaje'), findsOneWidget);
  });
}
