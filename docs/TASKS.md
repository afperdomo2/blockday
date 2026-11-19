# Blockday — Roadmap de tareas

Estado: `- [ ]` pendiente · `- [x]` hecho · `(en curso)` en progreso.
Un commit por hito; antes de cada commit: `flutter analyze` + `flutter test`
en verde (ver AGENTS.md).

## Hito 1 — Documentación y config

- [x] `AGENTS.md` con comandos, convenciones y gate de commit
- [x] `docs/PRODUCT.md` (alcance, historias, no-alcance)
- [x] `docs/ARCHITECTURE.md` (stack, modelo, motor de recurrencia, Drift)
- [x] `docs/TASKS.md` (este archivo)
- [x] Commitear `skills-lock.json`, fix `.gitignore` (`opencode.json` local)

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
- [x] Tags de tareas
- [ ] Markdown en notas (campo `notes` ya preparado, render deferido)
- [ ] Animaciones avanzadas según `apple-design` para Backlog (staggered list)

Notas de implementación (tags):
- Schema 3→4: columna `tasks.tags` (lista JSON serializada, nullable).
- Dominio: `Task.tags` (lista inmutable) + `normalizeTags()` (trim, descarta
  vacíos, dedupe case-insensitive conservando la primera forma) + `hasTag()`.
- UI: chips `InputChip` en `TaskEditorScreen` (añadir con Enter o botón +),
  chips `#tag` en `TaskTile`, fila de filtros por etiqueta en `BacklogScreen`
  (selección única, toggle) y la búsqueda del backlog también matchea tags.

## Hito 15 — Fix de navegación post-editor

- [x] Guardar/eliminar actividad vuelve al calendario (no a `/` vacío)
- [x] Decidir retorno: se adopta recordar origen vía query param `from`,
      con default `/calendar` (whitelist `/`, `/calendar`, `/backlog/**`)
- [x] Widget test del editor verificando la ruta de retorno
      (default, desde backlog y en modo edición)

## Hito 16 — Dashboard "Inicio"

- [x] Reemplazar `HomeScreen` vacío (`SizedBox.shrink`) por un dashboard real
- [x] Cabecera "Hoy" + fecha (`formatDayHeader`)
- [x] Bloques de hoy (`dayOccurrencesProvider(today)`)
- [x] Próximos (7 días siguientes vía `rangeOccurrencesProvider`, tope 8)
- [x] Tareas sin programar (captura rápida con botón "Nueva tarea")
- [x] Resumen semanal (X/Y sesiones): decisión → métrica semanal real
      (semanal = ocurrencias de la semana + sesiones completadas), no suma
      de `taskProgressProvider` (que es histórico). `taskProgressProvider`
      sí alimenta la sección de tareas vía `taskStatusProvider`
- [x] Botones rápidos: nueva actividad / nueva tarea
- [x] Widget tests (estado vacío y con datos)

Notas de implementación:
- `home_screen.dart` usa sólo providers; la agregación semanal vive en
  `home/providers/home_providers.dart` (`weeklyProgressProvider`).
- Los widget tests sobreescriben los streams (`activitiesStreamProvider`,
  `tasksStreamProvider`, `sessionsStreamProvider`) para evitar que los
  streams `.watch()` de Drift dejen un timer pendiente al desmontar
  `ProviderScope` (invariante `!timersPending` de `flutter_test`).
  `app_test` se actualizó igual por renderizar `HomeScreen`.

## Hito 17 — Solapamientos lado a lado

- [x] Lógica pura de layout: agrupar ocurrencias que se pisan + asignar
      columnas
- [x] Aplicar en `time_grid.dart` (día) y `week_view.dart`
- [x] Tests unitarios de layout (0, 2, 3+ solapes, encadenados, bordes)

Notas de implementación:
- `lib/features/activities/domain/overlap_layout.dart` expone
  `layoutOverlaps(List<Occurrence>) → List<LaidOutOccurrence>`
  (`occurrence`, `column`, `totalColumns`). Intervalos `[start, end)`: bordes
  exactos no solapan; clusters transitivos (encadenados A∩B∩C comparten grupo
  aunque A∩C no se pisen).
- `time_grid.dart` y `week_view.dart` solo consumen el layout (cálculo de
  geometría con `LayoutBuilder`, sin lógica de solapes duplicada).
- Vista semana con `totalColumns > 2` usa `_WeekBlock(compact: true)`: fuente
  9, padding 2 y sin icono de vínculo, para legibilidad en columna angosta.

## Hito 18 — Drag crear/redimensionar

- [x] Drag en hueco crea bloque; drag en bordes redimensiona
- [x] Feedback visual + precarga del editor con el rango arrastrado
- [x] Widget tests de los gestos críticos

Notas de implementación:
- `lib/features/calendar/domain/drag_time.dart`: lógica pura
  `minutesFromOffset()` (px→minutos clamp 0..1439), `snapMinutes()` (paso
  15 min, clamp) y `normalizeRange()` (ordena rango invertido, duración
  mínima 15 min, shift hacia atrás cerca de medianoche).
- Crear: **long-press + drag** en el hueco del `TimeGrid` (el tap simple
  sigue creando 1h; el long-press gana la arena de gestos contra el
  `SingleChildScrollView`, así el scroll nunca se bloquea). Long-press sin
  mover = bloque de 1h desde la hora presionada. Haptic `lightImpact` al
  iniciar/soltar.
- Redimensionar: handles invisibles de 24px (`ActivityBlock.resizeHandleHeight`)
  en bordes superior/inferior de bloques con altura ≥44px
  (`TimeGrid.minBlockHeightForHandles`). Los handles están DENTRO de
  `ActivityBlock` y reenvían `onTap`/`onLongPress` (preservan editar y
  toggle de sesión); el cuerpo del bloque absorbe long-presses con un
  `GestureDetector` no-op para que el drag-crear no arranque sobre bloques.
- Feedback: overlay translúcido con pastilla del rango
  (`formatHourRange`) — `primaryContainer` al crear, color de la actividad
  al redimensionar; `Semantics(label: 'Vista previa …')`.
- Conversión px→minutos vía `globalPosition` + `globalToLocal` sobre la
  pila de contenido (`GlobalKey`), porque `localPosition` de los handles es
  relativo al handle, no a la grid.
- Navegación: `onRangeSelected` → `/activity/new?date=…&start=…&end=…`;
  `onBlockResize` → `/activity/:id?start=…&end=…` (en recurrentes el
  editor precarga las horas de la regla — el usuario confirma).
- Editor: nuevos query params `start`/`end` (minutos del día 0..1440);
  tienen prioridad sobre `hour`. En modo edición se aplican tras
  `_populateFromActivity` vía `_pendingRange` (`_initFromQuery` ya no
  retorna temprano sin parsear el rango).
- Alcance: vista día únicamente; drag en vista semana queda pendiente.

## Hito 19 — Vista 3 días + fix texto semana

- [x] Vista "3 días" (fecha seleccionada + 2 días siguientes) con las
      mismas características que la vista día (tap hueco, long-press+drag
      crear, handles resize, toggle sesión, overlaps, previews)
- [x] Navegación prev/next de 3 en 3 días desde la fecha seleccionada
- [x] Fix: texto de bloques de semana vuelve a 10px (normal) / 9px
      (compacto) — el rediseño de tokens (hito tema) lo había subido a
      12px y cortaba títulos cortos con "…"
- [x] Tests: estado, vista (headers, columnas, gestos), pantalla
      (segmento + 360dp sin desbordes), tipografía de semana

Notas de implementación:
- Refactor: la lógica de columna con gestos vive en
  `time_grid_column.dart` (`TimeGridColumn` — stateful, posee create-drag,
  resize, previews, now-line). `TimeGrid` (día) quedó como envoltura
  (scroll + gutter + una columna + línea "ahora" a todo el ancho).
- `DaysHeader` (`days_header.dart`) extraído de la semana; lo comparten
  semana y 3 días.
- `three_day_view.dart`: header + un scroll + gutter + 3 columnas
  (`hourHeight: 60`, igual que día); ocurrencias vía
  `dayOccurrencesProvider(día)`; columna de hoy con tinte y now-line.
- Navegación: `CalendarView.threeDay` + `nextThreeDay()/previousThreeDay`
  (±3 días desde `selectedDate`; por defecto ancla en hoy).
- Selector de vistas: 4 segmentos. Adaptativo — con ancho ≥600dp muestra
  icono+label; por debajo solo iconos (con 4 labels+icons el
  `SegmentedButton` desborda a 360-412dp). `showSelectedIcon: false`.
- Fix semana: tokens `AppTypography.weekBlock` (10px w600) y
  `weekBlockCompact` (9px w600); compacto con padding horizontal 2
  (`AppSpacing.xxs`) y maxLines 3. Causa raíz: `39e6a76` migró el bloque
  de `fontSize: 10` fijo a `labelMedium` (12px) + Plus Jakarta Sans (más
  ancha), y "Estudiar AWS" ya no cabía en 2 líneas de columna angosta.
- Pendiente futuro: evaluar eliminar la vista día si la de 3 días
  resulta suficiente (decisión del usuario, no se elimina aún).

## Hito 20 — Pantalla de ajustes

- [x] Preferencias persistentes (inicio de semana, modo de tema, formato
      12/24h)
- [x] Decidir almacenamiento: `shared_preferences` vs tabla Drift
- [x] Ruta `/settings` + entrada desde el shell
- [x] Widget tests

Notas de implementación:
- Almacenamiento: **`shared_preferences`** (claves `settings.*`), detrás de la
  interfaz `SettingsStore` (`SharedPrefsSettingsStore` + `InMemorySettingsStore`
  para tests). Sin migración de schema.
- Dominio puro en `lib/features/settings/domain/app_settings.dart`
  (`AppSettings`, `ThemePreference`, `WeekStart`, `startOfWeek()`).
- `settingsProvider` (`AsyncNotifier`) + `currentSettingsProvider` (defaults si
  falla la carga). `BlockdayApp` aplica `themeMode` y un override de
  `MediaQuery.alwaysUse24HourFormat` (así el `showTimePicker` respeta el
  formato 12/24h — lo decide solo esa MediaQuery).
- Formato de hora en display: `formatHour/formatHourRange/formatTimeOfDay/
  formatHourLabel` con `use24Hour` (gutters, bloques, preview, home y horas del
  editor de actividad).
- Inicio de semana: `startOfWeek()` en `weekOccurrencesProvider`, `WeekView`
  (días de la semana), `MonthView` (celdas iniciales + rótulos) y
  `weeklyProgressProvider` del Inicio.
- UI: `SettingsScreen` (segmentados Tema / Inicio de semana / Reloj) + acción
  `SettingsAction` en las AppBars de Inicio, Calendario y Backlog.

## Hito 21 — Búsqueda global

- [x] Buscar actividades + tareas en una vista de resultados
- [x] Centralizar/reutilizar el buscador del backlog
- [x] Tests de filtrado

Notas de implementación:
- Matcher compartido y puro en `lib/features/search/domain/search_filter.dart`
  (`textMatches`, `taskMatchesQuery` — título/notas/tags —,
  `activityMatchesQuery`, `filterTasks`, `filterActivities`). El backlog y la
  búsqueda global lo usan los dos.
- `SearchScreen` en `/search` con secciones «Actividades» y «Tareas», estados
  vacíos, subtítulo con fecha/hora (próxima ocurrencia en recurrentes) y
  navegación al editor correspondiente (el `from=/search` se añadió a la
  whitelist de retorno del editor de actividad).
- Entradas: acción `SearchAction` en las AppBars de Inicio y Calendario (el
  Backlog conserva su búsqueda inline con el matcher compartido).

## Hito 22 — Backup export/import JSON

- [x] Serializar tasks, activities, exclusions y sessions a JSON
- [x] Exportar a archivo (file picker/sharing) + importar con validación
- [x] Tests round-trip export→import sin pérdida de datos

Notas de implementación:
- Formato JSON versionado (`app: "blockday"`, `version: 1`) con tasks (incluye
  tags), activities (incluye regla, exclusiones y recordatorio) y sessions.
  Fechas en epoch ms. Todo el codec es puro en
  `lib/features/backup/domain/backup_document.dart`
  (`encodeBackup`/`decodeBackup` + `BackupFormatException`).
- Validación de referencias al decodificar (taskIds/activityIds existentes);
  importar un archivo inválido no toca los datos (validación antes de la
  transacción).
- `BackupRepository` sobre Drift: `exportJson()` e `importReplaceAll()`
  (estrategia: **reemplazo total** dentro de una transacción).
- Archivos con `file_picker` (`saveFile` con diálogo nativo en Windows/Linux/
  Android SAF; `pickFiles` para importar). Sin dependencias extra.
- UI: sección «Datos» en Ajustes (exportar/importar) con diálogo de
  confirmación al importar. Tras importar se reprograman los recordatorios.

## Hito 23 — Notificaciones/recordatorios

- [x] Añadir `flutter_local_notifications` + `timezone`
- [x] Migración schema 2→3: campo recordatorio por actividad
      (o recordatorio global por defecto)
- [x] Programar/cancelar notificaciones al guardar/eliminar
- [x] Permisos Android + canal de notificaciones Windows
- [x] Tests de la lógica de programación (tiempo de disparo)

Notas de implementación:
- Dependencias: `flutter_local_notifications` 23 (soporta Android, Linux y
  Windows), `timezone` y `flutter_timezone` (zona horaria local).
- Schema 4→5 (la numeración real: 3 tags → 4): columna
  `activities.reminderMinutes` (minutos antes del inicio; null = sin
  recordatorio). La UI ofrece 5/10/15/30/60 min.
- Lógica pura en `lib/features/notifications/domain/reminder_schedule.dart`:
  `computeReminders()` (disparo = inicio − minutos; descarta pasados; respeta
  exclusiones y horizonte de 14 días) y `reminderNotificationId()` (hash
  estable de 31 bits por actividad+fecha).
- `NotificationService` (interfaz) con `LocalNotificationService` (plugin,
  `zonedSchedule` + `AndroidScheduleMode.exactAllowWhileIdle`, canal
  `blockday_reminders`, init de Windows/Linux) y `FakeNotificationService`
  para tests. Los errores de plugin se tragan (best-effort).
- `RemindersController.rescheduleAll()` reprograma todo (cancelAll + agenda las
  próximas 2 semanas) al guardar/eliminar actividad y al arrancar la app
  (`notificationsBootstrapProvider` en `BlockdayApp`). Si hay recordatorio se
  piden permisos Android (`requestNotificationsPermission` +
  `requestExactAlarmsPermission`).
- Android: permisos `RECEIVE_BOOT_COMPLETED` y `SCHEDULE_EXACT_ALARM` + receivers
  `ScheduledNotificationReceiver`/`ScheduledNotificationBootReceiver` en el
  manifest (sobreviven a kill/reboot).
- Nota Windows: sin MSIX `cancel` es no-op (limitación del plugin); la
  reprogramación acumula como mucho 2 semanas de avisos.

## Hito 24 — Linux, versionado y distribución

- [x] Plataforma Linux (`linux/`), título de ventana, icono y `.desktop`
- [x] `scripts/bump-build.sh` (versión única en `pubspec.yaml`)
- [x] `scripts/build.sh` (release con commit/fecha inyectados)
- [x] `scripts/build-deb.sh` (`.deb` en `dist/` con dependencias calculadas)
- [x] `scripts/install-linux.sh` (instalación local sin `sudo`, para pruebas)
- [x] `scripts/build-apk.sh` (APK de Android en `dist/`)
- [x] Diálogo «Acerca de» con versión, build, commit, fecha y plataforma
- [x] Documentación: README (desarrollo/distribución) y AGENTS.md

## Fase 3 (futuro, no programado)

- [ ] Sincronización en la nube / multi-dispositivo
- [ ] Invitados, ubicaciones, videollamadas
- [ ] Eventos de día completo / multi-día
- [ ] iOS / Web
