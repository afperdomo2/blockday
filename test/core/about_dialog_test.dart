import 'package:blockday/core/build_info/build_info.dart';
import 'package:blockday/core/build_info/build_info_provider.dart';
import 'package:blockday/shared/widgets/about_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final info = BuildInfo(
    version: '0.1.0',
    buildNumber: '4',
    commit: '3d8890b',
    buildDate: DateTime(2026, 11, 18, 14, 5),
    dirty: true,
    platform: 'Linux x64',
    channel: 'release',
  );

  Future<void> pumpDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [buildInfoProvider.overrideWith((ref) async => info)],
        child: MaterialApp(home: const Scaffold(body: BlockdayAboutDialog())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra versión, commit, fecha, plataforma y canal', (
    tester,
  ) async {
    await pumpDialog(tester);

    expect(find.text('Blockday'), findsOneWidget);
    expect(find.text('v0.1.0 (4)'), findsOneWidget);
    expect(find.text('3d8890b *'), findsOneWidget);
    expect(find.text('18 nov 2026 · 14:05'), findsOneWidget);
    expect(find.text('Linux x64'), findsOneWidget);
    expect(find.text('release'), findsOneWidget);
  });

  testWidgets('se cierra con el botón Cerrar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [buildInfoProvider.overrideWith((ref) async => info)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showBlockdayAboutDialog(context),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.byType(BlockdayAboutDialog), findsOneWidget);

    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.byType(BlockdayAboutDialog), findsNothing);
  });
}
