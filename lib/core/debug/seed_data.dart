import 'dart:math';

import 'package:drift/drift.dart';

import '../../features/activities/data/app_database.dart' hide Activity, Task;
import '../../features/activities/data/repositories/activities_repository.dart';
import '../../features/activities/domain/activity.dart';
import '../../features/activities/domain/recurrence_end.dart';
import '../../features/activities/domain/recurrence_rule.dart';
import '../../features/backlog/data/repositories/tasks_repository.dart';
import '../../features/backlog/domain/task.dart';

const int seedTaskCount = 10;
const int seedActivityCount = 31;
const int seedExclusionCount = 3;

Future<void> seedDebugDataIfEmpty(AppDatabase db) async {
  final tasks = await db.select(db.tasks).get();
  if (tasks.isNotEmpty) return;
  final activities = await db.select(db.activities).get();
  if (activities.isNotEmpty) return;
  await seedDebugData(db);
}

Future<void> seedDebugData(AppDatabase db) async {
  final today = _today();
  final tasks = _buildTasks(today);
  final activities = _buildActivities(today);
  final tasksRepository = TasksRepository(db);
  for (final task in tasks) {
    await tasksRepository.save(task);
  }
  final activitiesRepository = ActivitiesRepository(db);
  for (final activity in activities) {
    await activitiesRepository.save(activity);
  }
  await _seedSessions(db, activities, today);
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _day(DateTime from, int offset) =>
    DateTime(from.year, from.month, from.day + offset);

DateTime _at(DateTime date, int hour, int minute) =>
    DateTime(date.year, date.month, date.day, hour, minute);

DateTime _nextWeekday(DateTime from, int weekday) {
  final offset = (weekday - from.weekday + 7) % 7;
  return _day(from, offset == 0 ? 7 : offset);
}

List<Task> _buildTasks(DateTime today) {
  return [
    Task(
      id: 'seed-task-portfolio',
      title: 'Preparar portfolio de diseño',
      notes: 'Reunir cinco casos de estudio y publicarlos online.',
      kind: TaskKind.project,
      estimatedMinutes: 600,
      createdAt: _day(today, -20),
    ),
    Task(
      id: 'seed-task-flutter',
      title: 'Curso de Flutter avanzado',
      notes: 'Módulos de animaciones, rendimiento y testing.',
      kind: TaskKind.learning,
      estimatedMinutes: 900,
      createdAt: _day(today, -15),
    ),
    Task(
      id: 'seed-task-cv',
      title: 'Actualizar CV y LinkedIn',
      kind: TaskKind.task,
      estimatedMinutes: 120,
      createdAt: _day(today, -25),
      completedAt: _at(_day(today, -18), 18, 30),
    ),
    Task(
      id: 'seed-task-book',
      title: 'Leer Clean Architecture',
      kind: TaskKind.learning,
      estimatedMinutes: 480,
      createdAt: _day(today, -30),
    ),
    Task(
      id: 'seed-task-finanzas',
      title: 'Organizar finanzas del mes',
      kind: TaskKind.task,
      estimatedMinutes: 90,
      createdAt: _day(today, -10),
      completedAt: _at(_day(today, -8), 21, 0),
    ),
    Task(
      id: 'seed-task-ideas',
      title: 'Ideas de producto',
      notes: 'Lista abierta de ideas y oportunidades.',
      kind: TaskKind.note,
      createdAt: _day(today, -5),
    ),
    Task(
      id: 'seed-task-habitos',
      title: 'App personal de hábitos',
      kind: TaskKind.project,
      estimatedMinutes: 1200,
      createdAt: _day(today, -40),
    ),
    Task(
      id: 'seed-task-entrevistas',
      title: 'Practicar entrevistas técnicas',
      notes: 'Ejercicios de algoritmos y simulacros de entrevista.',
      kind: TaskKind.task,
      estimatedMinutes: 300,
      createdAt: _day(today, -12),
    ),
    Task(
      id: 'seed-task-docs',
      title: 'Renovar documentación del proyecto',
      kind: TaskKind.task,
      estimatedMinutes: 180,
      createdAt: _day(today, -7),
    ),
    Task(
      id: 'seed-task-sqlite',
      title: 'Aprender SQLite a fondo',
      kind: TaskKind.learning,
      estimatedMinutes: 240,
      createdAt: _day(today, -3),
    ),
  ];
}

List<Activity> _buildActivities(DateTime today) {
  return [..._buildMainActivities(today), ..._buildStressActivities(today)];
}

List<Activity> _buildMainActivities(DateTime today) {
  final nextThursday = _nextWeekday(today, DateTime.thursday);
  final nextMonday = _nextWeekday(today, DateTime.monday);
  return [
    Activity(
      id: 'seed-act-buscar-trabajo',
      title: 'Buscar trabajo',
      notes: 'Envío de postulaciones, networking y seguimiento.',
      color: 1,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 17 * 60,
        endMinutes: 19 * 60,
        weekdays: const {
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        },
        firstDate: _day(today, -28),
        end: const RecurrenceNever(),
      ),
      excludedDates: {nextMonday, _day(nextMonday, 4)},
      taskId: 'seed-task-entrevistas',
    ),
    Activity(
      id: 'seed-act-gym',
      title: 'Gym',
      notes: 'Rutina de fuerza y cardio.',
      color: 3,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 7 * 60,
        endMinutes: 8 * 60 + 15,
        weekdays: const {
          DateTime.tuesday,
          DateTime.thursday,
          DateTime.saturday,
        },
        firstDate: _day(today, -42),
        end: const RecurrenceNever(),
      ),
    ),
    Activity(
      id: 'seed-act-curso-flutter',
      title: 'Curso de Flutter',
      notes: 'Clases en vivo del curso avanzado.',
      color: 2,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 19 * 60 + 30,
        endMinutes: 21 * 60,
        weekdays: const {DateTime.monday, DateTime.wednesday},
        firstDate: _day(today, -21),
        end: RecurrenceUntil(_day(today, 45)),
      ),
      taskId: 'seed-task-flutter',
    ),
    Activity(
      id: 'seed-act-reunion-equipo',
      title: 'Reunión de equipo',
      notes: 'Sync de avances y bloqueos.',
      color: 4,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 10 * 60,
        endMinutes: 11 * 60 + 30,
        weekdays: const {DateTime.tuesday, DateTime.thursday},
        firstDate: _day(today, -35),
        end: const RecurrenceNever(),
      ),
      excludedDates: {_nextWeekday(today, DateTime.tuesday)},
    ),
    Activity(
      id: 'seed-act-pair-programming',
      title: 'Pair programming',
      notes: 'Sesión de programación en pareja con el equipo.',
      color: 5,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 10 * 60 + 30,
        endMinutes: 12 * 60,
        weekdays: const {DateTime.tuesday, DateTime.thursday},
        firstDate: _day(today, -35),
        end: const RecurrenceNever(),
      ),
    ),
    Activity(
      id: 'seed-act-revision-prs',
      title: 'Revisión de PRs',
      color: 6,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 10 * 60,
        endMinutes: 11 * 60,
        weekdays: const {DateTime.tuesday},
        firstDate: _day(today, -35),
        end: const RecurrenceNever(),
      ),
      taskId: 'seed-task-docs',
    ),
    Activity(
      id: 'seed-act-llamada-cliente',
      title: 'Llamada con cliente',
      notes: 'Seguimiento semanal del proyecto.',
      color: 7,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 11 * 60,
        endMinutes: 12 * 60 + 30,
        weekdays: const {DateTime.thursday},
        firstDate: _day(today, -35),
        end: const RecurrenceNever(),
      ),
    ),
    Activity(
      id: 'seed-act-almuerzo',
      title: 'Almuerzo',
      color: 8,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 13 * 60,
        endMinutes: 14 * 60,
        weekdays: const {
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        },
        firstDate: _day(today, -60),
        end: const RecurrenceNever(),
      ),
    ),
    Activity(
      id: 'seed-act-foco',
      title: 'Sesión de foco',
      notes: 'Trabajo profundo sin reuniones para la app de hábitos.',
      color: 0,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 9 * 60,
        endMinutes: 10 * 60 + 30,
        weekdays: const {DateTime.monday, DateTime.wednesday, DateTime.friday},
        firstDate: _day(today, -14),
        end: const RecurrenceCount(5),
      ),
      taskId: 'seed-task-habitos',
    ),
    Activity(
      id: 'seed-act-estiramientos',
      title: 'Estiramientos',
      notes: 'Rutina corta de movilidad.',
      color: 9,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 18 * 60,
        endMinutes: 18 * 60 + 30,
        weekdays: const {DateTime.sunday},
        firstDate: _day(today, -7),
        end: RecurrenceUntil(_day(today, 10)),
      ),
    ),
    Activity(
      id: 'seed-act-plan-mensual',
      title: 'Planificación mensual',
      notes: 'Cierre del mes y armado del plan del próximo.',
      color: 10,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 16 * 60,
        endMinutes: 17 * 60,
        weekdays: const {DateTime.monday, DateTime.wednesday, DateTime.friday},
        firstDate: DateTime(today.year, today.month + 1, 0),
        end: const RecurrenceNever(),
      ),
    ),
    Activity(
      id: 'seed-act-inversiones',
      title: 'Revisión de inversiones',
      notes: 'Seguimiento trimestral de la cartera.',
      color: 4,
      kind: ActivityKind.recurring,
      rule: RecurrenceRule(
        startMinutes: 11 * 60,
        endMinutes: 12 * 60,
        weekdays: const {DateTime.monday},
        firstDate: DateTime(2024, 2, 29),
        end: const RecurrenceNever(),
      ),
      taskId: 'seed-task-finanzas',
    ),
    Activity(
      id: 'seed-act-curso-react',
      title: 'Curso virtual de React',
      notes: 'Clase en vivo con la comunidad.',
      color: 2,
      kind: ActivityKind.single,
      singleStart: _at(nextThursday, 8, 0),
      singleEnd: _at(nextThursday, 10, 0),
    ),
    Activity(
      id: 'seed-act-entrevista-acme',
      title: 'Entrevista con Acme Corp',
      notes: 'Entrevista técnica con el equipo de plataforma.',
      color: 1,
      kind: ActivityKind.single,
      singleStart: _at(_day(today, 1), 11, 0),
      singleEnd: _at(_day(today, 1), 11, 45),
      taskId: 'seed-task-entrevistas',
    ),
    Activity(
      id: 'seed-act-medico',
      title: 'Consulta médica',
      color: 9,
      kind: ActivityKind.single,
      singleStart: _at(_day(today, 5), 16, 0),
      singleEnd: _at(_day(today, 5), 16, 30),
    ),
    Activity(
      id: 'seed-act-cumple',
      title: 'Cumpleaños de Sofía',
      notes: 'Cena en casa de Sofía.',
      color: 6,
      kind: ActivityKind.single,
      singleStart: _at(_day(today, 3), 20, 0),
      singleEnd: _at(_day(today, 3), 23, 0),
    ),
    Activity(
      id: 'seed-act-entrevista-globant',
      title: 'Entrevista inicial con Globant',
      color: 1,
      kind: ActivityKind.single,
      singleStart: _at(_day(today, -4), 10, 0),
      singleEnd: _at(_day(today, -4), 10, 30),
      taskId: 'seed-task-entrevistas',
    ),
    Activity(
      id: 'seed-act-taller-cv',
      title: 'Taller de CV',
      notes: 'Workshop para pulir el CV y el perfil profesional.',
      color: 5,
      kind: ActivityKind.single,
      singleStart: _at(_day(today, -11), 17, 0),
      singleEnd: _at(_day(today, -11), 19, 0),
      taskId: 'seed-task-cv',
    ),
    Activity(
      id: 'seed-act-defensa',
      title: 'Defensa del proyecto',
      color: 0,
      kind: ActivityKind.single,
      singleStart: _at(_day(today, 12), 9, 0),
      singleEnd: _at(_day(today, 12), 10, 30),
      taskId: 'seed-task-habitos',
    ),
  ];
}

const List<String> _stressTitles = [
  'Redacción de informes',
  'Depuración de bugs',
  'Diseño de pantallas',
  'Refactorización',
  'Documentación técnica',
  'Investigación de mercado',
  'Análisis de métricas',
  'Prototipado',
  'Revisión de código',
  'Planificación de sprints',
  'Soporte a usuarios',
  'Migración de datos',
];

List<Activity> _buildStressActivities(DateTime today) {
  return [
    for (var i = 0; i < _stressTitles.length; i++)
      Activity(
        id: 'seed-act-stress-${i + 1}',
        title: _stressTitles[i],
        notes: 'Bloque de trabajo del tablero de mantenimiento.',
        color: i % 11,
        kind: ActivityKind.recurring,
        rule: RecurrenceRule(
          startMinutes: 8 * 60 + (i * 37) % 480,
          endMinutes: 8 * 60 + (i * 37) % 480 + 90,
          weekdays: {(i % 5) + 1, ((i + 2) % 5) + 1},
          firstDate: _day(today, -60),
          end: i.isEven ? const RecurrenceNever() : RecurrenceCount(24 + i),
        ),
      ),
  ];
}

Future<void> _seedSessions(
  AppDatabase db,
  List<Activity> activities,
  DateTime today,
) async {
  const targets = {
    'seed-act-buscar-trabajo',
    'seed-act-gym',
    'seed-act-curso-flutter',
    'seed-act-reunion-equipo',
    'seed-act-entrevista-globant',
    'seed-act-taller-cv',
  };
  final random = Random(42);
  for (final activity in activities.where((a) => targets.contains(a.id))) {
    final occurrences = activity.occurrencesInRange(
      _day(today, -28),
      _day(today, -1),
    );
    for (final occurrence in occurrences) {
      final plannedMinutes = occurrence.end
          .difference(occurrence.start)
          .inMinutes;
      final completed = random.nextDouble() < 0.75;
      final actualMinutes = completed
          ? max(15, plannedMinutes + random.nextInt(31) - 15)
          : null;
      await db
          .into(db.activitySessions)
          .insertOnConflictUpdate(
            ActivitySessionsCompanion.insert(
              activityId: activity.id,
              date: occurrence.date.millisecondsSinceEpoch,
              completedAt: completed
                  ? Value(occurrence.end.millisecondsSinceEpoch)
                  : const Value.absent(),
              actualMinutes: actualMinutes == null
                  ? const Value.absent()
                  : Value(actualMinutes),
            ),
          );
    }
  }
}
