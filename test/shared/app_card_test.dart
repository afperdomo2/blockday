import 'package:blockday/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('renders its child', (tester) async {
    await tester.pumpWidget(wrap(const AppCard(child: Text('contenido'))));
    expect(find.text('contenido'), findsOneWidget);
  });

  testWidgets('invokes onTap when interactive', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(AppCard(onTap: () => taps++, child: const Text('tappable'))),
    );
    await tester.tap(find.text('tappable'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('does not crash without onTap', (tester) async {
    await tester.pumpWidget(wrap(const AppCard(child: Text('estático'))));
    await tester.tap(find.text('estático'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('estático'), findsOneWidget);
  });

  testWidgets('applies custom padding and margin', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AppCard(
          padding: EdgeInsets.all(4),
          margin: EdgeInsets.all(8),
          child: Text('con métricas'),
        ),
      ),
    );
    expect(find.text('con métricas'), findsOneWidget);
  });
}
