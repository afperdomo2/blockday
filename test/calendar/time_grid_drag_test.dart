import 'package:blockday/features/activities/domain/occurrence.dart';
import 'package:blockday/features/backlog/providers/tasks_providers.dart';
import 'package:blockday/features/calendar/presentation/widgets/activity_block.dart';
import 'package:blockday/features/calendar/presentation/widgets/time_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  final date = DateTime(2025, 1, 6);

  Widget buildGrid({
    List<Occurrence> occurrences = const [],
    void Function(int, int)? onEmptyTap,
    void Function(Occurrence)? onBlockTap,
    void Function(DateTime, int, int)? onRangeSelected,
    void Function(Occurrence, int, int)? onBlockResize,
  }) {
    return ProviderScope(
      overrides: [
        sessionsStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TimeGrid(
            date: date,
            occurrences: occurrences,
            onEmptyTap: onEmptyTap ?? (_, _) {},
            onBlockTap: onBlockTap ?? (_) {},
            onRangeSelected: onRangeSelected ?? (_, _, _) {},
            onBlockResize: onBlockResize ?? (_, _, _) {},
          ),
        ),
      ),
    );
  }

  Occurrence occurrence2to3() {
    return Occurrence(
      activityId: 'a1',
      title: 'Bloque',
      color: 0,
      date: date,
      start: DateTime(2025, 1, 6, 2, 0),
      end: DateTime(2025, 1, 6, 3, 0),
    );
  }

  testWidgets('long-press and drag on empty grid creates snapped range', (
    tester,
  ) async {
    DateTime? selDate;
    int? selStart;
    int? selEnd;
    await tester.pumpWidget(
      buildGrid(
        onRangeSelected: (d, s, e) {
          selDate = d;
          selStart = s;
          selEnd = e;
        },
      ),
    );
    await tester.pumpAndSettle();
    final topLeft = tester.getTopLeft(find.byType(TimeGrid));
    final pressAt = Offset(
      topLeft.dx + TimeGrid.gutterWidth + 40,
      topLeft.dy + 2 * TimeGrid.hourHeight + 30,
    );
    final gesture = await tester.startGesture(pressAt);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(0, 120));
    await tester.pump();
    expect(find.text('02:30 – 04:30'), findsOneWidget);
    await gesture.up();
    await tester.pump();
    expect(selDate, date);
    expect(selStart, 150);
    expect(selEnd, 270);
  });

  testWidgets('long-press without movement creates a one-hour block', (
    tester,
  ) async {
    int? selStart;
    int? selEnd;
    await tester.pumpWidget(
      buildGrid(
        onRangeSelected: (_, s, e) {
          selStart = s;
          selEnd = e;
        },
      ),
    );
    await tester.pumpAndSettle();
    final topLeft = tester.getTopLeft(find.byType(TimeGrid));
    final pressAt = Offset(
      topLeft.dx + TimeGrid.gutterWidth + 40,
      topLeft.dy + 150,
    );
    final gesture = await tester.startGesture(pressAt);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pump();
    expect(selStart, 150);
    expect(selEnd, 210);
  });

  testWidgets('tap on empty grid still opens at tapped time', (tester) async {
    int? hour;
    int? minute;
    await tester.pumpWidget(
      buildGrid(
        onEmptyTap: (h, m) {
          hour = h;
          minute = m;
        },
      ),
    );
    await tester.pumpAndSettle();
    final topLeft = tester.getTopLeft(find.byType(TimeGrid));
    await tester.tapAt(
      Offset(topLeft.dx + TimeGrid.gutterWidth + 40, topLeft.dy + 150),
    );
    await tester.pump();
    expect(hour, 2);
    expect(minute, 30);
  });

  testWidgets('tap on block still opens the editor', (tester) async {
    String? tappedId;
    await tester.pumpWidget(
      buildGrid(
        occurrences: [occurrence2to3()],
        onBlockTap: (o) {
          tappedId = o.activityId;
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bloque'));
    await tester.pump();
    expect(tappedId, 'a1');
  });

  testWidgets('long-press on block body does not start create drag', (
    tester,
  ) async {
    var rangeCalls = 0;
    var tapCalls = 0;
    await tester.pumpWidget(
      buildGrid(
        occurrences: [occurrence2to3()],
        onRangeSelected: (_, _, _) => rangeCalls++,
        onBlockTap: (_) => tapCalls++,
      ),
    );
    await tester.pumpAndSettle();
    final blockRect = tester.getRect(find.byType(ActivityBlock));
    final gesture = await tester.startGesture(blockRect.center);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pump();
    expect(rangeCalls, 0);
    expect(tapCalls, 0);
  });

  testWidgets('drag on bottom handle resizes the block', (tester) async {
    Occurrence? resizedOcc;
    int? resizedStart;
    int? resizedEnd;
    await tester.pumpWidget(
      buildGrid(
        occurrences: [occurrence2to3()],
        onBlockResize: (o, s, e) {
          resizedOcc = o;
          resizedStart = s;
          resizedEnd = e;
        },
      ),
    );
    await tester.pumpAndSettle();
    final blockRect = tester.getRect(find.byType(ActivityBlock));
    final handlePos = Offset(
      blockRect.center.dx,
      blockRect.bottom - ActivityBlock.resizeHandleHeight / 2,
    );
    final gesture = await tester.startGesture(handlePos);
    await gesture.moveBy(const Offset(0, 71));
    await tester.pump();
    expect(find.text('02:00 – 04:00'), findsOneWidget);
    await gesture.up();
    await tester.pump();
    expect(resizedOcc?.activityId, 'a1');
    expect(resizedStart, 120);
    expect(resizedEnd, 240);
  });

  testWidgets('drag on top handle resizes the start', (tester) async {
    Occurrence? resizedOcc;
    int? resizedStart;
    int? resizedEnd;
    await tester.pumpWidget(
      buildGrid(
        occurrences: [occurrence2to3()],
        onBlockResize: (o, s, e) {
          resizedOcc = o;
          resizedStart = s;
          resizedEnd = e;
        },
      ),
    );
    await tester.pumpAndSettle();
    final blockRect = tester.getRect(find.byType(ActivityBlock));
    final handlePos = Offset(
      blockRect.center.dx,
      blockRect.top + ActivityBlock.resizeHandleHeight / 2,
    );
    final gesture = await tester.startGesture(handlePos);
    await gesture.moveBy(const Offset(0, -71));
    await tester.pump();
    expect(find.text('01:00 – 03:00'), findsOneWidget);
    await gesture.up();
    await tester.pump();
    expect(resizedOcc?.activityId, 'a1');
    expect(resizedStart, 60);
    expect(resizedEnd, 180);
  });
}
