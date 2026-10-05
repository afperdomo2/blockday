import 'package:blockday/features/activities/data/app_database.dart'
    hide Activity;
import 'package:blockday/features/activities/domain/activity.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:blockday/features/calendar/presentation/widgets/activity_block.dart';
import 'package:blockday/features/calendar/presentation/widgets/days_header.dart';
import 'package:blockday/features/calendar/presentation/widgets/three_day_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  final selectedDate = DateTime(2025, 1, 6);

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              Scaffold(body: ThreeDayView(selectedDate: selectedDate)),
        ),
        GoRoute(
          path: '/activity/new',
          builder: (_, state) => Scaffold(body: Text('new ${state.uri}')),
        ),
        GoRoute(
          path: '/activity/:id',
          builder: (_, state) => Scaffold(body: Text('edit ${state.uri}')),
        ),
      ],
    );
  }

  testWidgets('renders 3 day headers and hour gutter', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          home: Scaffold(body: ThreeDayView(selectedDate: selectedDate)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DaysHeader), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('23:00'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('occurrences render in their day column', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final activities = [
      Activity(
        id: 'a1',
        title: 'Primer día',
        color: 0,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 6, 10, 0),
        singleEnd: DateTime(2025, 1, 6, 11, 0),
      ),
      Activity(
        id: 'a3',
        title: 'Tercer día',
        color: 1,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 8, 10, 0),
        singleEnd: DateTime(2025, 1, 8, 11, 0),
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith(
            (ref) => Stream.value(activities),
          ),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          home: Scaffold(body: ThreeDayView(selectedDate: selectedDate)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Primer día'), findsOneWidget);
    expect(find.text('Tercer día'), findsOneWidget);
    final rectFirst = tester.getRect(find.text('Primer día'));
    final rectThird = tester.getRect(find.text('Tercer día'));
    expect(rectFirst.left, lessThan(rectThird.left));
    expect(rectThird.top, moreOrLessEquals(rectFirst.top, epsilon: 2));
  });

  testWidgets('tap on empty area of third column opens editor with its date', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final router = buildRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    final viewRect = tester.getRect(find.byType(ThreeDayView));
    final gutterRect = tester.getRect(find.text('06:00'));
    await tester.tapAt(
      Offset(viewRect.left + viewRect.width * 0.9, gutterRect.top + 30),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('/activity/new'), findsOneWidget);
    expect(find.textContaining('date=2025-01-08'), findsOneWidget);
    expect(find.textContaining('hour=6'), findsOneWidget);
  });

  testWidgets(
    'long-press and drag in middle column creates range for that day',
    (tester) async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final router = buildRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
            sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      final viewRect = tester.getRect(find.byType(ThreeDayView));
      final gutterRect = tester.getRect(find.text('02:00'));
      final pressAt = Offset(
        viewRect.left + viewRect.width * 0.5,
        gutterRect.top + 30,
      );
      final gesture = await tester.startGesture(pressAt);
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveBy(const Offset(0, 120));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.textContaining('/activity/new'), findsOneWidget);
      expect(find.textContaining('date=2025-01-07'), findsOneWidget);
      expect(find.textContaining('start=150'), findsOneWidget);
      expect(find.textContaining('end=270'), findsOneWidget);
    },
  );

  testWidgets('drag on block handle in first column resizes via editor', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final activities = [
      Activity(
        id: 'a1',
        title: 'Bloque',
        color: 0,
        kind: ActivityKind.single,
        singleStart: DateTime(2025, 1, 6, 2, 0),
        singleEnd: DateTime(2025, 1, 6, 3, 0),
      ),
    ];
    final router = buildRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith(
            (ref) => Stream.value(activities),
          ),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    final blockRect = tester.getRect(find.byType(ActivityBlock));
    final handlePos = Offset(
      blockRect.center.dx,
      blockRect.bottom - ActivityBlock.resizeHandleHeight / 2,
    );
    final gesture = await tester.startGesture(handlePos);
    await gesture.moveBy(const Offset(0, 71));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.textContaining('/activity/a1'), findsOneWidget);
    expect(find.textContaining('start=120'), findsOneWidget);
    expect(find.textContaining('end=240'), findsOneWidget);
  });
}
