import 'package:blockday/core/theme/app_colors.dart';
import 'package:blockday/shared/widgets/animated_check_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('tapping toggles and reports the new value', (tester) async {
    final values = <bool>[];
    await tester.pumpWidget(
      wrap(
        AnimatedCheckButton(
          checked: false,
          tooltip: 'Marcar hecha',
          onChanged: values.add,
        ),
      ),
    );
    await tester.tap(find.byType(AnimatedCheckButton));
    await tester.pumpAndSettle();
    expect(values, [true]);
  });

  testWidgets('shows a check icon only when checked', (tester) async {
    await tester.pumpWidget(
      wrap(
        AnimatedCheckButton(
          checked: true,
          checkedColor: AppColors.success,
          onChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.pumpWidget(
      wrap(AnimatedCheckButton(checked: false, onChanged: (_) {})),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('exposes checked state semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        AnimatedCheckButton(
          checked: true,
          tooltip: 'Reabrir',
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.bySemanticsLabel('Reabrir'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Reabrir')),
      isSemantics(isChecked: true, isButton: true),
    );
    handle.dispose();
  });
}
