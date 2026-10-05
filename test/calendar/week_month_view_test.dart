import 'package:blockday/features/activities/data/app_database.dart';
import 'package:blockday/features/activities/domain/occurrence.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/calendar/presentation/widgets/month_view.dart';
import 'package:blockday/features/calendar/presentation/widgets/week_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('week view renders 7 day headers', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          home: Scaffold(body: WeekView(selectedDate: DateTime(2025, 1, 6))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('6'), findsWidgets);
    expect(find.text('00:00'), findsOneWidget);
  });

  testWidgets('week view renders overlapping blocks side by side', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final date = DateTime(2025, 1, 6);
    final a = Occurrence(
      activityId: 'a1',
      title: 'Solape A',
      color: 0,
      date: date,
      start: DateTime(2025, 1, 6, 8, 0),
      end: DateTime(2025, 1, 6, 10, 0),
    );
    final b = Occurrence(
      activityId: 'a2',
      title: 'Solape B',
      color: 1,
      date: date,
      start: DateTime(2025, 1, 6, 9, 0),
      end: DateTime(2025, 1, 6, 11, 0),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          weekOccurrencesProvider.overrideWith((ref, arg) => [a, b]),
        ],
        child: MaterialApp(
          home: Scaffold(body: WeekView(selectedDate: date)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Solape A'), findsOneWidget);
    expect(find.text('Solape B'), findsOneWidget);
    final rectA = tester.getRect(find.text('Solape A'));
    final rectB = tester.getRect(find.text('Solape B'));
    expect(rectA.right, lessThanOrEqualTo(rectB.left));
  });

  testWidgets('week block uses 10px token so short titles fit two lines', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final date = DateTime(2025, 1, 6);
    final a = Occurrence(
      activityId: 'a1',
      title: 'Estudiar AWS',
      color: 0,
      date: date,
      start: DateTime(2025, 1, 6, 17, 0),
      end: DateTime(2025, 1, 6, 19, 0),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          weekOccurrencesProvider.overrideWith((ref, arg) => [a]),
        ],
        child: MaterialApp(
          home: Scaffold(body: WeekView(selectedDate: date)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && w.data == 'Estudiar AWS' && w.style?.fontSize == 10,
      ),
      findsOneWidget,
    );
  });

  testWidgets('compact week blocks use 9px token when columns overlap', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final date = DateTime(2025, 1, 6);
    Occurrence occ(String id, String title) => Occurrence(
      activityId: id,
      title: title,
      color: 0,
      date: date,
      start: DateTime(2025, 1, 6, 8, 0),
      end: DateTime(2025, 1, 6, 11, 0),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          weekOccurrencesProvider.overrideWith(
            (ref, arg) => [
              occ('a1', 'Solape A'),
              occ('a2', 'Solape B'),
              occ('a3', 'Solape C'),
            ],
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: WeekView(selectedDate: date)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final title in ['Solape A', 'Solape B', 'Solape C']) {
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && w.data == title && w.style?.fontSize == 9,
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('month view renders month grid', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          home: Scaffold(body: MonthView(selectedDate: DateTime(2025, 1, 15))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('L'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
  });
}
