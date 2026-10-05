# Blockday — Roadmap de tareas

Estado: `- [ ]` pendiente · `- [x]` hecho · `(en curso)` en progreso.
Un commit por hito; antes de cada commit: `flutter analyze` + `flutter test`
en verde (ver AGENTS.md).

## Hito 1 — Documentación y config

- [x] `AGENTS.md` con comandos, convenciones y gate de commit
- [x] `docs/PRODUCT.md` (alcance, historias, no-alcance)
- [x] `docs/ARCHITECTURE.md` (stack, modelo, motor de recurrencia, Drift)
- [x] `docs/TASKS.md` (este archivo)
- [x] Commitear `opencode.json`, `skills-lock.json`, fix `.gitignore`

## Hito 2 — Foundation

- [x] Dependencias: `flutter_riverpod`, `drift`, `go_router`, `intl`, `uuid`
      (dev: `drift_dev`, `build_runner`)
- [x] Estructura feature-first (`core/`, `features/`, `shared/`, `routes/`)
- [x] Tema claro/oscuro + paleta de colores de actividades
- [x] Shell de app con `ProviderScope`, `MaterialApp.router`, go_router
- [x] Widget test del shell

## Hito 3 — Dominio (motor de recurrencia)

- [x] Modelos: `Activity`, `RecurrenceRule`, `RecurrenceEnd`, `Occurrence`
- [x] Validaciones de dominio (horas, weekdays, límites)
- [x] `expandOccurrences()` con barrido semanal + count/until/exclusiones
- [x] Tests unitarios exhaustivos (bordes de mes, bisiesto, hasta-fecha,
      N veces, exclusiones, rango vacío)

## Hito 4 — Persistencia (Drift)

- [x] Tablas `activities` y `activity_exclusions` + DAOs
- [x] `ActivitiesRepository` (CRUD + exclusiones + mapeo dominio↔fila)
- [x] Tests con base de datos en memoria

## Hito 5 — Vista día

- [x] `CalendarState` (fecha seleccionada, vista) + providers
- [x] Time-grid del día (00–24h) con bloques de actividades
- [x] Render de ocurrencias por rango (provider family)
- [x] Navegación entre días (botones + swipe)
- [x] Tap en bloque → abrir editor; tap en hueco → nueva actividad

## Hito 6 — CRUD de actividades

- [x] Pantalla editor (nueva/editar): título, notas, color
- [x] Modo puntual: fecha + hora inicio/fin
- [x] Modo recurrente: días de semana + condición de fin
      (sin fin / hasta fecha / N veces)
- [x] Eliminar actividad; excluir una ocurrencia concreta
- [x] Widget tests del formulario

## Hito 7 — Vistas semana y mes

- [x] Vista semana (7 columnas con time-grid)
- [x] Vista mes (grid tipo Google Calendar con puntos/resumen)
- [x] Selector de vista (segmented) sincronizado con providers

## Hito 8 — Pulido

- [x] Animaciones y gestos según skill `apple-design`
      (springs, materiales, feedback)
- [x] Materiales translúcidos en barras/sheets
- [x] Dark mode pulido
- [x] Vacíos de UI (empty states) y errores de formulario

## Hito 9 — Backlog: dominio y persistencia Task

- [x] Modelos `Task`, `TaskKind` (task|learning|note|project), `TaskStatus` (pending|scheduled|inProgress|completed), `TaskProgress`
- [x] Validaciones de dominio (título, estimación >0)
- [x] Tablas Drift `tasks` + `activity_sessions`, columna `activities.task_id` (FK `ON DELETE SET NULL`)
- [x] Migración schemaVersion 1→2 con `MigrationStrategy` (create tasks/sessions + addColumn taskId)
- [x] Mappers `task_mapper.dart` + repos `TasksRepository`, `SessionsRepository`
- [x] `Activity.taskId` y `Occurrence.taskId` + mappers actualizados

## Hito 10 — Providers y progreso

- [x] `tasksStreamProvider`, `taskByIdProvider`, `sessionsStreamProvider`, `taskProgressProvider`, `isTaskScheduledProvider`
- [x] `TaskProgress` (sesiones planeadas vs completadas, horas planificadas vs reales)

## Hito 11 — Backlog UI + Shell con bottom nav

- [x] `MainShell` con `NavigationBar` (Calendario / Backlog) vía `StatefulShellRoute.indexedStack`
- [x] `BacklogScreen`: captura rápida (inbox), resumen semanal, filtros (Todas/Sin programar/Programadas/En progreso/Hechas), secciones agrupadas
- [x] `TaskTile` con badge de vínculo, progreso `3 de 8`, horas y `LinearProgressIndicator`
- [x] `TaskEditorScreen` (crear/editar: título, notas texto plano -markdown futuro-, tipo, estado, estimación horas, sección de bloques vinculados)

## Hito 12 — Flujo Programar en calendario

- [x] Desde tarea → `Programar` abre `/activity/new?taskId=…` prellenado (título/notas) y vinculado
- [x] Editor de actividad con `_TaskLinkTile` (vincular/cambiar/sin vincular tarea)
- [x] Badge `Icons.link` en `ActivityBlock` (día) y `_WeekBlock` (semana) cuando `occurrence.isLinkedToTask`

## Hito 13 — Sesiones completadas y progreso

- [x] `SessionsRepository` (mark/unmark/toggle/isCompleted) sobre `activity_sessions`
- [x] Long-press en `ActivityBlock` hace toggle de sesión completada (con `actualMinutes`)
- [x] `taskProgressProvider` agrega sesiones completadas y horas reales

## Hito 14 — Pulido

- [x] Resumen semanal en Backlog (`Total: X/Y sesiones`)
- [x] Empty states y filtros en Backlog
- [x] Corrección de `time_grid_test.dart` para `ProviderScope` + `sessionsStreamProvider`
- [ ] Tags de tareas (deferido)
- [ ] Markdown en notas (campo `notes` ya preparado, render deferido)
- [ ] Animaciones avanzadas según `apple-design` para Backlog (staggered list)

## Hito 15 — Fix de navegación post-editor

- [x] Guardar/eliminar actividad vuelve al calendario (no a `/` vacío)
- [x] Decidir retorno: se adopta recordar origen vía query param `from`,
      con default `/calendar` (whitelist `/`, `/calendar`, `/backlog/**`)
- [x] Widget test del editor verificando la ruta de retorno
      (default, desde backlog y en modo edición)

## Hito 16 — Dashboard "Inicio"

- [ ] Reemplazar `HomeScreen` vacío (`SizedBox.shrink`) por un dashboard real
- [ ] Cabecera "Hoy" + fecha
- [ ] Bloques de hoy (`dayOccurrencesProvider(today)`)
- [ ] Próximos (N días siguientes)
- [ ] Tareas sin programar (captura rápida)
- [ ] Resumen semanal (X/Y sesiones) reutilizando `taskProgressProvider`
- [ ] Botones rápidos: nueva actividad / nueva tarea
- [ ] Widget tests (estado vacío y con datos)

## Hito 17 — Solapamientos lado a lado

- [ ] Lógica pura de layout: agrupar ocurrencias que se pisan + asignar
      columnas
- [ ] Aplicar en `time_grid.dart` (día) y `week_view.dart`
- [ ] Tests unitarios de layout (0, 2, 3+ solapes, encadenados, bordes)

## Hito 18 — Drag crear/redimensionar

- [ ] Drag en hueco crea bloque; drag en bordes redimensiona
- [ ] Feedback visual + precarga del editor con el rango arrastrado
- [ ] Widget tests de los gestos críticos

## Hito 19 — Pantalla de ajustes

- [ ] Preferencias persistentes (inicio de semana, modo de tema, formato
      12/24h)
- [ ] Decidir almacenamiento: `shared_preferences` vs tabla Drift
- [ ] Ruta `/settings` + entrada desde el shell
- [ ] Widget tests

## Hito 20 — Búsqueda global

- [ ] Buscar actividades + tareas en una vista de resultados
- [ ] Centralizar/reutilizar el buscador del backlog
- [ ] Tests de filtrado

## Hito 21 — Backup export/import JSON

- [ ] Serializar tasks, activities, exclusions y sessions a JSON
- [ ] Exportar a archivo (file picker/sharing) + importar con validación
- [ ] Tests round-trip export→import sin pérdida de datos

## Hito 22 — Notificaciones/recordatorios

- [ ] Añadir `flutter_local_notifications` + `timezone`
- [ ] Migración schema 2→3: campo recordatorio por actividad
      (o recordatorio global por defecto)
- [ ] Programar/cancelar notificaciones al guardar/eliminar
- [ ] Permisos Android + canal de notificaciones Windows
- [ ] Tests de la lógica de programación (tiempo de disparo)

## Fase 3 (futuro, no programado)

- [ ] Sincronización en la nube / multi-dispositivo
- [ ] Invitados, ubicaciones, videollamadas
- [ ] Eventos de día completo / multi-día
- [ ] iOS / Web
