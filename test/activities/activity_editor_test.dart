import 'package:blockday/features/activities/data/app_database.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:blockday/features/activities/presentation/screens/activity_editor_screen.dart';

GoRouter _buildRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/calendar',
        builder: (_, _) => const Scaffold(body: Text('calendar')),
      ),
      GoRoute(
        path: '/backlog',
        builder: (_, _) => const Scaffold(body: Text('backlog')),
      ),
      GoRoute(
        path: '/activity/new',
        builder: (_, _) => const ActivityEditorScreen(),
      ),
      GoRoute(
        path: '/activity/:id',
        builder: (_, state) =>
            ActivityEditorScreen(activityId: state.pathParameters['id']),
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
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('shows validation error when title empty', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _pumpEditor(tester, db, _buildRouter('/activity/new'));
    expect(find.text('Nueva actividad'), findsOneWidget);
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    expect(find.text('El título es obligatorio'), findsOneWidget);
  });

  testWidgets('saves and navigates to calendar by default', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _pumpEditor(tester, db, _buildRouter('/activity/new'));
    await tester.enterText(find.byType(TextFormField).first, 'Mi actividad');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('calendar'), findsOneWidget);
    final all = await db.select(db.activities).get();
    expect(all.length, 1);
    expect(all.first.title, 'Mi actividad');
  });

  testWidgets('save returns to origin via from param', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _pumpEditor(tester, db, _buildRouter('/activity/new?from=/backlog'));
    await tester.enterText(find.byType(TextFormField).first, 'Desde backlog');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('backlog'), findsOneWidget);
  });

  testWidgets('edit save returns to origin even in edit mode', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await db
        .into(db.activities)
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
    await _pumpEditor(
      tester,
      db,
      _buildRouter('/activity/edit-1?from=/backlog'),
    );
    expect(find.text('Editar actividad'), findsOneWidget);
    expect(find.text('Existente'), findsOneWidget);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('backlog'), findsOneWidget);
  });

  testWidgets('start/end params prefill single-mode range', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _pumpEditor(
      tester,
      db,
      _buildRouter(
        '/activity/new?date=2025-01-06T00:00:00.000&start=600&end=690',
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Arrastrada');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    final all = await db.select(db.activities).get();
    expect(all.length, 1);
    final start = DateTime.fromMillisecondsSinceEpoch(all.first.singleStart!);
    final end = DateTime.fromMillisecondsSinceEpoch(all.first.singleEnd!);
    expect(start, DateTime(2025, 1, 6, 10, 0));
    expect(end, DateTime(2025, 1, 6, 11, 30));
  });

  testWidgets('start/end params take precedence over hour param', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _pumpEditor(
      tester,
      db,
      _buildRouter(
        '/activity/new?date=2025-01-06T00:00:00.000&hour=8&start=600&end=690',
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Prioridad');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    final all = await db.select(db.activities).get();
    final start = DateTime.fromMillisecondsSinceEpoch(all.first.singleStart!);
    final end = DateTime.fromMillisecondsSinceEpoch(all.first.singleEnd!);
    expect(start, DateTime(2025, 1, 6, 10, 0));
    expect(end, DateTime(2025, 1, 6, 11, 30));
  });

  testWidgets('start/end params apply in edit mode after load', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await db
        .into(db.activities)
        .insert(
          ActivitiesCompanion.insert(
            id: 'resize-1',
            title: 'Existente',
            color: 2,
            kind: 'single',
            singleStart: Value(DateTime(2025, 1, 10, 8).millisecondsSinceEpoch),
            singleEnd: Value(DateTime(2025, 1, 10, 9).millisecondsSinceEpoch),
          ),
        );
    await _pumpEditor(
      tester,
      db,
      _buildRouter('/activity/resize-1?start=600&end=690&from=/calendar'),
    );
    expect(find.text('Editar actividad'), findsOneWidget);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('calendar'), findsOneWidget);
    final all = await db.select(db.activities).get();
    final start = DateTime.fromMillisecondsSinceEpoch(all.first.singleStart!);
    final end = DateTime.fromMillisecondsSinceEpoch(all.first.singleEnd!);
    expect(start, DateTime(2025, 1, 10, 10, 0));
    expect(end, DateTime(2025, 1, 10, 11, 30));
  });

  testWidgets('start/end params apply to recurring rule in edit mode', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await db
        .into(db.activities)
        .insert(
          ActivitiesCompanion.insert(
            id: 'rec-1',
            title: 'Recurrente',
            color: 1,
            kind: 'recurring',
            weekdays: Value(1),
            firstDate: Value(DateTime(2025, 1, 6).millisecondsSinceEpoch),
            startMinutes: Value(1020),
            endMinutes: Value(1140),
            endType: Value('never'),
          ),
        );
    await _pumpEditor(
      tester,
      db,
      _buildRouter('/activity/rec-1?start=480&end=600&from=/calendar'),
    );
    expect(find.text('Editar actividad'), findsOneWidget);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('calendar'), findsOneWidget);
    final all = await db.select(db.activities).get();
    expect(all.first.startMinutes, 480);
    expect(all.first.endMinutes, 600);
  });
}
