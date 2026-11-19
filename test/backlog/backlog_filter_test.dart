import 'package:blockday/features/activities/providers/activities_stream_provider.dart';
import 'package:blockday/features/backlog/domain/task.dart';
import 'package:blockday/features/backlog/presentation/screens/backlog_screen.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tasks = [
    Task(id: 't1', title: 'Estudiar AWS', tags: ['estudio', 'certificación']),
    Task(id: 't2', title: 'Comprar regalo', tags: ['personal']),
    Task(id: 't3', title: 'Sin etiquetas'),
  ];

  Future<void> pumpBacklog(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksStreamProvider.overrideWith((ref) => Stream.value(tasks)),
          activitiesStreamProvider.overrideWith((ref) => Stream.value([])),
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(home: BacklogScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra un chip por cada etiqueta usada', (tester) async {
    await pumpBacklog(tester);
    expect(find.widgetWithText(FilterChip, '#estudio'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '#certificación'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '#personal'), findsOneWidget);
    expect(find.text('Estudiar AWS'), findsOneWidget);
    expect(find.text('Comprar regalo'), findsOneWidget);
    expect(find.text('Sin etiquetas'), findsOneWidget);
  });

  testWidgets('seleccionar una etiqueta filtra las tareas', (tester) async {
    await pumpBacklog(tester);
    await tester.tap(find.widgetWithText(FilterChip, '#personal'));
    await tester.pumpAndSettle();

    expect(find.text('Comprar regalo'), findsOneWidget);
    expect(find.text('Estudiar AWS'), findsNothing);
    expect(find.text('Sin etiquetas'), findsNothing);
  });

  testWidgets('deseleccionar la etiqueta restaura la lista', (tester) async {
    await pumpBacklog(tester);
    await tester.tap(find.widgetWithText(FilterChip, '#personal'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, '#personal'));
    await tester.pumpAndSettle();

    expect(find.text('Estudiar AWS'), findsOneWidget);
    expect(find.text('Comprar regalo'), findsOneWidget);
    expect(find.text('Sin etiquetas'), findsOneWidget);
  });

  testWidgets('la búsqueda encuentra tareas por etiqueta', (tester) async {
    await pumpBacklog(tester);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'certificación');
    await tester.pumpAndSettle();

    expect(find.text('Estudiar AWS'), findsOneWidget);
    expect(find.text('Comprar regalo'), findsNothing);
    expect(find.text('Sin etiquetas'), findsNothing);
  });
}
