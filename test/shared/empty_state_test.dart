import 'package:blockday/shared/widgets/date_hero.dart';
import 'package:blockday/shared/widgets/empty_state.dart';
import 'package:blockday/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('EmptyState renders icon, title and subtitle', (tester) async {
    await tester.pumpWidget(
      wrap(
        const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Sin tareas',
          subtitle: 'Crea una cuando quieras',
        ),
      ),
    );
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.text('Sin tareas'), findsOneWidget);
    expect(find.text('Crea una cuando quieras'), findsOneWidget);
  });

  testWidgets('EmptyState renders its action', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      wrap(
        EmptyState(
          icon: Icons.event_busy_outlined,
          title: 'Vacío',
          action: TextButton(
            onPressed: () => pressed = true,
            child: const Text('Crear'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
  });

  testWidgets('EmptyHint renders icon and text', (tester) async {
    await tester.pumpWidget(
      wrap(const EmptyHint(icon: Icons.event_available_outlined, text: 'Nada')),
    );
    expect(find.byIcon(Icons.event_available_outlined), findsOneWidget);
    expect(find.text('Nada'), findsOneWidget);
  });

  testWidgets('DateHero renders day, caption, label and trailing', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        DateHero(
          date: DateTime(2026, 11, 18),
          label: 'Hoy',
          caption: 'martes, 18 de noviembre',
          trailing: const Icon(Icons.insights),
        ),
      ),
    );
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('martes, 18 de noviembre'), findsOneWidget);
    expect(find.byIcon(Icons.insights), findsOneWidget);
  });

  testWidgets('SectionHeader renders count badge and action', (tester) async {
    var actionPressed = false;
    await tester.pumpWidget(
      wrap(
        SectionHeader(
          title: 'Programado hoy',
          count: 3,
          action: IconButton(
            onPressed: () => actionPressed = true,
            icon: const Icon(Icons.filter_list),
          ),
        ),
      ),
    );
    expect(find.text('Programado hoy'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    expect(actionPressed, isTrue);
  });
}
