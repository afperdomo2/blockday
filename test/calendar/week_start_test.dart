import 'package:blockday/features/activities/data/app_database.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/calendar/presentation/widgets/month_view.dart';
import 'package:blockday/features/calendar/presentation/widgets/week_view.dart';
import 'package:blockday/features/settings/data/settings_store.dart';
import 'package:blockday/features/settings/domain/app_settings.dart';
import 'package:blockday/features/settings/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  Future<void> pumpWithSettings(
    WidgetTester tester, {
    required AppSettings settings,
    required Widget child,
  }) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          settingsStoreProvider.overrideWithValue(
            InMemorySettingsStore(settings),
          ),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('semana con inicio en lunes muestra lun..dom', (tester) async {
    await pumpWithSettings(
      tester,
      settings: AppSettings.defaults,
      child: WeekView(selectedDate: DateTime(2025, 1, 6)),
    );
    expect(find.text('6'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('semana con inicio en domingo muestra dom..sáb', (tester) async {
    await pumpWithSettings(
      tester,
      settings: const AppSettings(weekStart: WeekStart.sunday),
      child: WeekView(selectedDate: DateTime(2025, 1, 6)),
    );
    expect(find.text('5'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('12'), findsNothing);
  });

  testWidgets('mes con inicio en domingo rotula la primera columna con D', (
    tester,
  ) async {
    await pumpWithSettings(
      tester,
      settings: const AppSettings(weekStart: WeekStart.sunday),
      child: MonthView(selectedDate: DateTime(2025, 1, 15)),
    );
    final labels = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();
    final firstWeekdayLabel = labels.firstWhere(
      (l) => const ['L', 'M', 'X', 'J', 'V', 'S', 'D'].contains(l),
    );
    expect(firstWeekdayLabel, 'D');
  });
}
