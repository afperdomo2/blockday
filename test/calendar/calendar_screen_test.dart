import 'package:blockday/features/activities/data/app_database.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:blockday/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:blockday/features/calendar/presentation/widgets/three_day_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/calendar',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
      GoRoute(
        path: '/calendar',
        builder: (_, _) => const Scaffold(body: CalendarScreen()),
      ),
      GoRoute(
        path: '/activity/new',
        builder: (_, _) => const Scaffold(body: Text('new')),
      ),
      GoRoute(
        path: '/activity/:id',
        builder: (_, _) => const Scaffold(body: Text('edit')),
      ),
      GoRoute(
        path: '/backlog',
        builder: (_, _) => const Scaffold(body: Text('backlog')),
      ),
    ],
  );
}

Widget _wrap(AppDatabase db, GoRouter router) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
      sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('wide screen shows labeled segment and switches to 3-day view', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final router = _buildRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_wrap(db, router));
    await tester.pumpAndSettle();
    expect(find.text('3 días'), findsOneWidget);
    await tester.tap(find.text('3 días'));
    await tester.pumpAndSettle();
    expect(find.byType(ThreeDayView), findsOneWidget);
  });

  testWidgets(
    'narrow screen (360dp) fits four view segments without overflow',
    (tester) async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final router = _buildRouter();
      addTearDown(router.dispose);
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_wrap(db, router));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.view_column), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.view_column));
      await tester.pumpAndSettle();
      expect(find.byType(ThreeDayView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
