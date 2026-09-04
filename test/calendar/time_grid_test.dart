import 'package:blockday/features/activities/domain/occurrence.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:blockday/features/calendar/presentation/widgets/time_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('renders hour labels and activity blocks', (tester) async {
    final occurrences = [
      Occurrence(
        activityId: 'a1',
        title: 'Buscar trabajo',
        color: 0,
        date: DateTime(2025, 1, 6),
        start: DateTime(2025, 1, 6, 17, 0),
        end: DateTime(2025, 1, 6, 19, 0),
      ),
      Occurrence(
        activityId: 'a2',
        title: 'Estudiar',
        color: 1,
        date: DateTime(2025, 1, 6),
        start: DateTime(2025, 1, 6, 19, 30),
        end: DateTime(2025, 1, 6, 21, 0),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: TimeGrid(
              date: DateTime(2025, 1, 6),
              occurrences: occurrences,
              onEmptyTap: (_, _) {},
              onBlockTap: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('12:00'), findsOneWidget);
    expect(find.text('23:00'), findsOneWidget);
    expect(find.text('Buscar trabajo'), findsOneWidget);
    expect(find.text('Estudiar'), findsOneWidget);
  });

  testWidgets('empty grid shows no blocks', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: TimeGrid(
              date: DateTime(2025, 1, 6),
              occurrences: const [],
              onEmptyTap: (_, _) {},
              onBlockTap: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(find.text('Buscar trabajo'), findsNothing);
    expect(find.text('00:00'), findsOneWidget);
  });

  testWidgets('tap on block triggers onBlockTap', (tester) async {
    var tappedId = '';
    final occ = Occurrence(
      activityId: 'a1',
      title: 'Bloque',
      color: 0,
      date: DateTime(2025, 1, 6),
      start: DateTime(2025, 1, 6, 2, 0),
      end: DateTime(2025, 1, 6, 3, 0),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: TimeGrid(
              date: DateTime(2025, 1, 6),
              occurrences: [occ],
              onEmptyTap: (_, _) {},
              onBlockTap: (o) => tappedId = o.activityId,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Bloque'));
    await tester.pump();
    expect(tappedId, 'a1');
  });
}
