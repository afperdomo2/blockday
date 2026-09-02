import 'package:blockday/features/activities/data/app_database.dart';
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
