import 'package:blockday/app.dart';
import 'package:blockday/features/activities/data/app_database.dart';
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _pumpApp(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final db = AppDatabase.memory();
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
        tasksStreamProvider.overrideWith((ref) => Stream.value([])),
        sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: const BlockdayApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('en móvil usa NavigationBar abajo', (tester) async {
    await _pumpApp(tester, const Size(400, 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('en tablet usa NavigationRail lateral', (tester) async {
    await _pumpApp(tester, const Size(800, 1000));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('en escritorio usa NavigationRail con etiquetas', (tester) async {
    await _pumpApp(tester, const Size(1400, 900));

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.labelType, NavigationRailLabelType.all);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('el contenido se acota y centra en pantallas anchas', (
    tester,
  ) async {
    await _pumpApp(tester, const Size(1600, 1000));

    final listWidth = tester.getSize(find.byType(ListView).first).width;
    expect(listWidth, lessThanOrEqualTo(720));
  });
}
