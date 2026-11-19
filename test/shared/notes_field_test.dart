import 'package:blockday/shared/widgets/markdown_note.dart';
import 'package:blockday/shared/widgets/notes_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester,
    TextEditingController ctrl,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: NotesField(controller: ctrl)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empieza en modo edición', (tester) async {
    await pumpField(tester, TextEditingController());
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byTooltip('Vista previa'), findsOneWidget);
    expect(find.byType(MarkdownBody), findsNothing);
  });

  testWidgets('la vista previa renderiza el markdown', (tester) async {
    final ctrl = TextEditingController(text: '# Título\n\nTexto con **marca**');
    addTearDown(ctrl.dispose);
    await pumpField(tester, ctrl);

    await tester.tap(find.byTooltip('Vista previa'));
    await tester.pumpAndSettle();

    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(find.text('Título'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('vista previa de notas vacías', (tester) async {
    await pumpField(tester, TextEditingController());
    await tester.tap(find.byTooltip('Vista previa'));
    await tester.pumpAndSettle();

    expect(find.text('Sin notas'), findsOneWidget);
  });

  testWidgets('volver a editar muestra el campo', (tester) async {
    final ctrl = TextEditingController(text: 'hola');
    addTearDown(ctrl.dispose);
    await pumpField(tester, ctrl);
    await tester.tap(find.byTooltip('Vista previa'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(MarkdownBody), findsNothing);
    expect(find.text('hola'), findsOneWidget);
  });

  testWidgets('MarkdownNote renderiza listas y títulos', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MarkdownNote(data: '## Subtítulo\n\n- uno\n- dos'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Subtítulo'), findsOneWidget);
    expect(find.text('uno'), findsOneWidget);
    expect(find.text('dos'), findsOneWidget);
  });
}
