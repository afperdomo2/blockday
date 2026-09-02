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

- [ ] Pantalla editor (nueva/editar): título, notas, color
- [ ] Modo puntual: fecha + hora inicio/fin
- [ ] Modo recurrente: días de semana + condición de fin
      (sin fin / hasta fecha / N veces)
- [ ] Eliminar actividad; excluir una ocurrencia concreta
- [ ] Widget tests del formulario

## Hito 7 — Vistas semana y mes

- [ ] Vista semana (7 columnas con time-grid)
- [ ] Vista mes (grid tipo Google Calendar con puntos/resumen)
- [ ] Selector de vista (segmented) sincronizado con providers

## Hito 8 — Pulido

- [ ] Animaciones y gestos según skill `apple-design`
      (springs, materiales, feedback)
- [ ] Materiales translúcidos en barras/sheets
- [ ] Dark mode pulido
- [ ] Vacíos de UI (empty states) y errores de formulario

## Fase 2 (fuera de v1)

- [ ] Recordatorios con `flutter_local_notifications` (timezone, permisos
      Android, canal de notificaciones Windows)
- [ ] Búsqueda de actividades
- [ ] Exportar/importar datos
