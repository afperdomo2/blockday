import 'package:blockday/features/activities/data/app_database.dart'
    hide Activity, Task;
import 'package:blockday/features/activities/providers/activities_providers.dart';
import 'package:blockday/features/backup/data/backup_file_service.dart';
import 'package:blockday/features/backup/domain/backup_document.dart';
import 'package:blockday/features/backup/presentation/widgets/backup_section.dart';
import 'package:blockday/features/backup/providers/backup_providers.dart';
import 'package:blockday/features/backlog/data/repositories/tasks_repository.dart';
import 'package:blockday/features/backlog/domain/task.dart';
import 'package:blockday/features/notifications/data/notification_service.dart';
import 'package:blockday/features/notifications/providers/notifications_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late FakeBackupFileService files;
  late FakeNotificationService notifications;

  Future<void> pumpSection(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          backupFileServiceProvider.overrideWithValue(files),
          notificationServiceProvider.overrideWithValue(notifications),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: BackupSection())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    db = AppDatabase.memory();
    files = FakeBackupFileService();
    notifications = FakeNotificationService();
    addTearDown(db.close);
  });

  testWidgets('exportar escribe la copia en el archivo', (tester) async {
    await pumpSection(tester);
    await tester.tap(find.text('Exportar copia de seguridad'));
    await tester.pumpAndSettle();

    expect(files.lastSavedContent, isNotNull);
    expect(files.lastSavedName, startsWith('blockday-backup-'));
    final data = decodeBackup(files.lastSavedContent!);
    expect(data.tasks, isEmpty);
    expect(find.text('Copia exportada'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('importar reemplaza los datos tras confirmar', (tester) async {
    files.contentToPick = encodeBackup(
      BackupData(
        tasks: [
          Task(id: 't1', title: 'Importada', tags: ['x']),
        ],
      ),
    );
    await pumpSection(tester);
    await tester.tap(find.text('Importar copia de seguridad'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Importar'));
    await tester.pumpAndSettle();

    final tasks = await TasksRepository(db).getAll();
    expect(tasks.single.title, 'Importada');
    expect(find.text('Copia importada'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('cancelar la importación no toca los datos', (tester) async {
    files.contentToPick = encodeBackup(
      BackupData(
        tasks: [Task(id: 't1', title: 'Importada')],
      ),
    );
    await pumpSection(tester);
    await tester.tap(find.text('Importar copia de seguridad'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(await TasksRepository(db).getAll(), isEmpty);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('un archivo inválido muestra error', (tester) async {
    files.contentToPick = 'no es json';
    await pumpSection(tester);
    await tester.tap(find.text('Importar copia de seguridad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Importar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Archivo no válido'), findsOneWidget);
    expect(await TasksRepository(db).getAll(), isEmpty);
    await tester.pump(const Duration(seconds: 5));
  });
}
