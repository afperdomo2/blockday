# Blockday — Arquitectura

## Stack

| Área | Decisión | Motivo |
|---|---|---|
| UI | Flutter (Windows + Android) | Un solo código para ambos targets |
| Estado | `flutter_riverpod` | Testeable, sin `setState` global |
| Persistencia | `drift` (SQLite) | SQL real, queries por rango de fechas, DB en memoria para tests |
| Navegación | `go_router` | Rutas declarativas, deep-linking futuro |
| Fechas | `intl` (locale `es`) | Formato en español |
| Modelos | Dart inmutables a mano | Sin freezed/json_serializable (menos codegen) |

Drift genera `*.g.dart` con `build_runner`; ese codegen sí se usa (solo para
tablas/DAOs).

## Estructura de carpetas

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/          # ThemeData claro/oscuro, paleta de colores
│   └── utils/          # extensiones de DateTime, etc.
├── features/
│   ├── activities/
│   │   ├── domain/     # Activity, RecurrenceRule, motor de ocurrencias (puro)
│   │   ├── data/       # tablas Drift, DAO, repositorio
│   │   ├── presentation/  # editor de actividad, selector de repetición
│   │   └── providers/
│   ├── backlog/
│   │   ├── domain/     # Task, TaskKind, TaskStatus, TaskProgress
│   │   ├── data/       # mappers, TasksRepository, SessionsRepository
│   │   ├── presentation/  # BacklogScreen, TaskEditor, TaskTile
│   │   └── providers/  # tasks/sessions/progress providers
│   └── calendar/
│       ├── presentation/  # shell, vista día/semana/mes, time-grid
│       └── providers/     # fecha seleccionada, vista actual, ocurrencias por rango
├── shared/
│   └── widgets/        # widgets reutilizables
└── routes/
    ├── app_router.dart     # StatefulShellRoute (calendario/backlog)
    └── main_shell.dart     # NavigationBar
```

## Modelo de dominio

```
Task (backlog, inmutable)
├── id: String (uuid)
├── title: String
├── notes: String?               # texto plano, futuro markdown
├── kind: TaskKind               # task | learning | note | project
├── status: TaskStatus           # pending | scheduled | inProgress | completed
├── estimatedMinutes: int?       # estimación total en minutos
└── createdAt: DateTime

Activity (inmutable)
├── id: String (uuid)
├── title: String
├── notes: String?
├── color: int              # índice de la paleta
├── kind: ActivityKind      # single | recurring
├── singleStart/singleEnd: DateTime?   # solo si kind == single
├── rule: RecurrenceRule?              # solo si kind == recurring
│     ├── startTime/endTime: minutos desde medianoche (start < end, mismo día)
│     ├── weekdays: Set<DateTime.monday..sunday>
│     ├── firstDate: DateTime (solo fecha)
│     └── end: RecurrenceEnd  # never | until(date) | count(n)
├── excludedDates: Set<DateTime>  # ocurrencias saltadas (solo fecha)
└── taskId: String?               # FK opcional → tasks.id ON DELETE SET NULL

Occurrence { activityId, title, color, date, start, end, taskId? }
→ taskId se propaga desde Activity para badge y progreso

TaskProgress (derivado)
├── totalPlannedSessions, completedSessions, remainingSessions
├── totalPlannedMinutes, totalActualMinutes
├── linkedActivitiesCount, hasFutureOccurrence, completionRatio
└── isUnscheduled (linkedCount == 0)
```

Restricciones (validadas en dominio):
- `endTime > startTime` (sin eventos que crucen medianoche en v1).
- `weekdays` no vacío.
- `until >= firstDate`, `count >= 1`.

## Motor de recurrencia (núcleo)

Lógica pura en `lib/features/activities/domain/recurrence_engine.dart`:

```dart
List<Occurrence> expandOccurrences(Activity a, DateTime rangeStart, DateTime rangeEnd)
// Occurrence { activityId, date, start, end }
```

Algoritmo (recurrente semanal):
1. Inicio del barrido: `max(firstDate, rangeStart)`.
2. Fin del barrido: `rangeEnd`; si `end == until(d)`, acotar a `min(rangeEnd, d)`.
3. Para cada fecha del barrido: si su día de semana ∈ `weekdays` y no está en
   `excludedDates` → emitir ocurrencia con horas `startTime`/`endTime`.
4. Si `end == count(n)`: contar ocurrencias desde `firstDate` (aunque estén
   antes de `rangeStart`) y parar al llegar a N.

Casos borde que deben estar testeados: fin de mes, año bisiesto, cambio de
año, `until` en el límite, `count` pequeño, exclusiones, rango sin
intersección, zona horaria local (usar siempre `DateTime` local, nunca UTC,
para fechas de calendario).

## Persistencia (Drift)

```
tasks
├── id TEXT PK
├── title TEXT NOT NULL
├── notes TEXT
├── kind TEXT NOT NULL ('task'|'learning'|'note'|'project')
├── status TEXT NOT NULL ('pending'|'scheduled'|'inProgress'|'completed')
├── estimated_minutes INTEGER?
└── created_at INTEGER NOT NULL (epoch ms)

activities
├── id TEXT PK
├── title TEXT NOT NULL
├── notes TEXT
├── color INTEGER NOT NULL
├── kind TEXT NOT NULL ('single'|'recurring')
├── single_start INTEGER? (epoch ms)
├── single_end INTEGER?
├── weekdays INTEGER?        # bitmask Lun=1..Dom=7
├── first_date INTEGER?
├── start_minutes INTEGER?
├── end_minutes INTEGER?
├── end_type TEXT?           # 'never'|'until'|'count'
├── end_value INTEGER?       # epoch ms o N
└── task_id TEXT NULL REFERENCES tasks(id) ON DELETE SET NULL

activity_exclusions
├── activity_id TEXT FK → activities.id ON DELETE CASCADE
└── excluded_date INTEGER NOT NULL  # epoch ms normalizado a 00:00 local
    PK (activity_id, excluded_date)

activity_sessions
├── activity_id TEXT FK → activities.id ON DELETE CASCADE
├── date INTEGER NOT NULL  # epoch ms normalizado a 00:00 local
├── completed_at INTEGER?  # epoch ms, null = no completada
└── actual_minutes INTEGER?
    PK (activity_id, date)

Migración 1→2: create tasks + activity_sessions, addColumn activities.taskId, PRAGMA foreign_keys=ON.
SchemaVersion 2.
```

Repositorio (`ActivitiesRepository`): CRUD + query de activities +
exclusiones; la expansión de ocurrencias se hace en dominio, no en SQL.
Tests con `NativeDatabase.memory()` / executor en memoria.

## Estado (Riverpod)

- `appDatabaseProvider` → AppDatabase (singleton).
- `activitiesRepositoryProvider` → repositorio.
- `tasksRepositoryProvider` / `sessionsRepositoryProvider`
- `activitiesStreamProvider` → stream/lista de actividades.
- `tasksStreamProvider` / `taskByIdProvider` / `sessionsStreamProvider`
- `taskProgressProvider(taskId)` → TaskProgress derivado
- `calendarStateProvider` → `CalendarState{ selectedDate, view (día/semana/mes) }`.
- `occurrencesProvider(rangeStart, rangeEnd)` → ocurrencias expandidas para el
  rango visible (family provider).

## Navegación

- Shell `StatefulShellRoute.indexedStack` con `MainShell` (NavigationBar: Calendario / Backlog)
  - `/` → calendario (vistas día/semana/mes)
  - `/backlog` → BacklogScreen (captura rápida + filtros + secciones)
  - `/backlog/task/new` → nueva tarea
  - `/backlog/task/:id` → editar tarea
- `/activity/new?date=...&hour=...&taskId=...` → editor de actividad (prefill + vínculo)
- `/activity/:id` → editar actividad existente (con selector de tarea vinculada)

## Estrategia de tests

| Capa | Tipo | Herramienta |
|---|---|---|
| Recurrence engine, modelos, validación | Unitario puro | `flutter_test` |
| Repositorio / DAOs | Unitario con DB en memoria | drift `NativeDatabase.memory()` |
| Providers | Unitario | `ProviderContainer` |
| Pantallas críticas | Widget tests | `flutter_test` + `ProviderScope` |

## Decisiones clave (ADR resumidos)

1. **Expansión en Dart, no en SQL**: el cálculo de ocurrencias es complejo y
   debe ser testeable; SQLite solo almacena la regla.
2. **Actividades dentro del mismo día (v1)**: simplifica solapamientos y UI.
3. **IDs de texto (uuid)**: portables y seguros para FK.
4. **Sin i18n**: UI en español hardcodeado; se puede extraer después.
