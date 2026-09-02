import 'package:blockday/app.dart';
import 'package:blockday/routes/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    appRouter.go('/');
  });

  testWidgets('shows calendar home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BlockdayApp()));
    await tester.pumpAndSettle();

    expect(find.text('Blockday'), findsOneWidget);
    expect(find.text('Vista de día — próximamente'), findsOneWidget);
  });

  testWidgets('navigates to new activity editor', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BlockdayApp()));
    await tester.pumpAndSettle();

    appRouter.go('/activity/new');
    await tester.pumpAndSettle();

    expect(find.text('Nueva actividad'), findsOneWidget);
  });

  testWidgets('edit route opens editor in edit mode', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BlockdayApp()));
    await tester.pumpAndSettle();

    appRouter.go('/activity/abc-123');
    await tester.pumpAndSettle();

    expect(find.text('Editar actividad'), findsOneWidget);
  });
}
