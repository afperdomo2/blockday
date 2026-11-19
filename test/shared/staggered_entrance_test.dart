import 'package:blockday/shared/widgets/staggered_entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder staggerFades() => find.descendant(
  of: find.byType(StaggeredItem),
  matching: find.byType(FadeTransition),
);

void main() {
  Widget wrap({required Widget child, bool disableAnimations = false}) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: child,
        ),
      ),
    );
  }

  testWidgets('los items entran con fade + slide hasta completar', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        child: StaggeredEntrance(
          child: Column(children: [StaggeredItem(index: 0, child: Text('a'))]),
        ),
      ),
    );

    final fadeIn = tester.widget<FadeTransition>(staggerFades());
    expect(fadeIn.opacity.value, lessThan(0.01));

    await tester.pumpAndSettle();

    final fadeOut = tester.widget<FadeTransition>(staggerFades());
    expect(fadeOut.opacity.value, 1.0);
  });

  testWidgets('el stagger empieza antes en los primeros items', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: StaggeredEntrance(
          child: Column(
            children: [
              for (var i = 0; i < 12; i++)
                StaggeredItem(index: i, child: Text('item $i')),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    final opacities = tester
        .widgetList<FadeTransition>(staggerFades())
        .map((f) => f.opacity.value)
        .toList();

    expect(opacities.first, greaterThan(opacities.last));
    expect(opacities.last, lessThan(0.2));
  });

  testWidgets('con animaciones deshabilitadas no hay transiciones', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        disableAnimations: true,
        child: StaggeredEntrance(
          child: Column(
            children: [StaggeredItem(index: 0, child: Text('sin animar'))],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(staggerFades(), findsNothing);
    expect(find.text('sin animar'), findsOneWidget);
  });

  testWidgets('StaggeredItem sin StaggeredEntrance muestra el hijo', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(child: StaggeredItem(index: 3, child: Text('suelto'))),
    );
    await tester.pumpAndSettle();

    expect(staggerFades(), findsNothing);
    expect(find.text('suelto'), findsOneWidget);
  });
}
