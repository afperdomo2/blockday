import 'package:blockday/features/activities/data/app_database.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:blockday/features/activities/presentation/screens/activity_editor_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('shows validation error when title empty', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final router = GoRouter(
      initialLocation: '/activity/new',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/activity/new',
          builder: (_, _) => const ActivityEditorScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nueva actividad'), findsOneWidget);
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    expect(find.text('El título es obligatorio'), findsOneWidget);
  });

  testWidgets('saves single activity and navigates home', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final router = GoRouter(
      initialLocation: '/activity/new',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/activity/new',
          builder: (_, _) => const ActivityEditorScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Mi actividad');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    final all = await db.select(db.activities).get();
    expect(all.length, 1);
    expect(all.first.title, 'Mi actividad');
  });

  testWidgets('shows edit mode with existing activity', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final repo = db;
    await repo
        .into(repo.activities)
        .insert(
          ActivitiesCompanion.insert(
            id: 'edit-1',
            title: 'Existente',
            color: 2,
            kind: 'single',
            singleStart: Value(DateTime(2025, 1, 10, 8).millisecondsSinceEpoch),
            singleEnd: Value(DateTime(2025, 1, 10, 9).millisecondsSinceEpoch),
          ),
        );
    final router = GoRouter(
      initialLocation: '/activity/edit-1',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/activity/:id',
          builder: (_, state) =>
              ActivityEditorScreen(activityId: state.pathParameters['id']),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Editar actividad'), findsOneWidget);
    expect(find.text('Existente'), findsOneWidget);
  });
}
