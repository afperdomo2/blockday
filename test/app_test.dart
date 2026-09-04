import 'package:blockday/app.dart';
import 'package:blockday/features/activities/data/app_database.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/routes/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  setUp(() {
    appRouter.go('/');
  });

  testWidgets('shows home screen', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const BlockdayApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsWidgets);
  });

  testWidgets('shows calendar screen at /calendar', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const BlockdayApp(),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/calendar');
    await tester.pumpAndSettle();

    expect(find.text('Blockday'), findsOneWidget);
    expect(find.text('Sin actividades para este día'), findsOneWidget);
  });

  testWidgets('navigates to new activity editor', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const BlockdayApp(),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/activity/new');
    await tester.pumpAndSettle();

    expect(find.text('Nueva actividad'), findsOneWidget);
  });

  testWidgets('edit route opens editor in edit mode', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const BlockdayApp(),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/activity/abc-123');
    await tester.pumpAndSettle();

    expect(find.text('Editar actividad'), findsOneWidget);
  });
}
