import 'package:blockday/shared/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('renders center child and animates to value', (tester) async {
    await tester.pumpWidget(
      wrap(const ProgressRing(value: 0.5, size: 64, child: Text('50%'))),
    );
    expect(find.text('50%'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('clamps out-of-range values', (tester) async {
    await tester.pumpWidget(
      wrap(const ProgressRing(value: 1.5, child: Text('x'))),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('clamps negative values', (tester) async {
    await tester.pumpWidget(
      wrap(const ProgressRing(value: -0.5, child: Text('y'))),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
