import 'package:blockday/app.dart';
import 'package:blockday/features/activities/data/app_database.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:blockday/features/settings/data/settings_store.dart';
import 'package:blockday/features/settings/domain/app_settings.dart';
import 'package:blockday/features/settings/presentation/screens/settings_screen.dart';
import 'package:blockday/features/settings/providers/settings_providers.dart';
import 'package:blockday/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  Future<InMemorySettingsStore> pumpSettings(
    WidgetTester tester, {
    AppSettings initial = AppSettings.defaults,
  }) async {
    final store = InMemorySettingsStore(initial);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsStoreProvider.overrideWithValue(store)],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('muestra las secciones de ajustes', (tester) async {
    await pumpSettings(tester);
    expect(find.text('Apariencia'), findsOneWidget);
    expect(find.text('Calendario'), findsOneWidget);
    expect(find.text('Formato de hora'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);
    expect(find.text('Lunes'), findsOneWidget);
    expect(find.text('24 h'), findsOneWidget);
  });

  testWidgets('cambiar tema persiste la preferencia', (tester) async {
    final store = await pumpSettings(tester);
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    expect(store.current.themePreference, ThemePreference.dark);
  });

  testWidgets('cambiar inicio de semana persiste la preferencia', (
    tester,
  ) async {
    final store = await pumpSettings(tester);
    await tester.tap(find.text('Domingo'));
    await tester.pumpAndSettle();
    expect(store.current.weekStart, WeekStart.sunday);
  });

  testWidgets('cambiar formato de hora persiste la preferencia', (
    tester,
  ) async {
    final store = await pumpSettings(tester);
    await tester.tap(find.text('12 h'));
    await tester.pumpAndSettle();
    expect(store.current.use24HourFormat, false);
  });

  testWidgets('la preferencia de tema se aplica a la app', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final store = InMemorySettingsStore(
      const AppSettings(themePreference: ThemePreference.dark),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          tasksStreamProvider.overrideWith((ref) => Stream.value([])),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
          settingsStoreProvider.overrideWithValue(store),
        ],
        child: const BlockdayApp(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Inicio').first);
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('la ruta /settings abre la pantalla de ajustes', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    appRouter.go('/');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          tasksStreamProvider.overrideWith((ref) => Stream.value([])),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
          settingsStoreProvider.overrideWithValue(InMemorySettingsStore()),
        ],
        child: const BlockdayApp(),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/settings');
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
