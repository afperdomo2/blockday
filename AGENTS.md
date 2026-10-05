# AGENTS.md — Blockday

## Proyecto

Blockday es una app de calendario personal para **Windows y Android**, tipo
Google Calendar, para planificar bloques de tiempo y actividades:

- Bloques recurrentes (p. ej. "Buscar trabajo" Lun–Vie 17:00–19:00).
- Eventos puntuales futuros (p. ej. "Curso virtual" el próximo jueves 08:00).
- Reglas de repetición flexibles (p. ej. "todos los martes y jueves durante
  un mes").

Detalles de producto: `docs/PRODUCT.md`
Arquitectura y modelo de datos: `docs/ARCHITECTURE.md`
Roadmap de trabajo: `docs/TASKS.md`

## Stack

- Flutter / Dart (ver `pubspec.yaml`). Targets: Windows + Android.
- Estado: **Riverpod** (`flutter_riverpod`).
- Persistencia local offline: **Drift** (SQLite). Requiere `build_runner`.
- Navegación: **go_router**.
- Fechas/formato: **intl** (locale `es`).
- UI en **español** (strings hardcodeados, sin i18n por ahora).
- Código (identificadores, nombres de archivo) en **inglés**.

## Comandos

```bash
flutter pub get                                        # dependencias
flutter analyze                                        # lint (debe dar 0 issues)
dart format lib test                                   # formatear
flutter test                                           # tests unitarios/widget
flutter test --coverage                                # tests con cobertura
flutter test test/domain/recurrence_engine_test.dart   # un solo archivo
dart run build_runner build --delete-conflicting-outputs  # codegen de Drift
dart run build_runner watch --delete-conflicting-outputs  # codegen en modo watch
flutter run -d windows                                 # ejecutar en Windows
flutter run -d <device-android>                        # ejecutar en Android
flutter test --coverage && dart pub global activate coverage  # cobertura (opcional)
```

## Gate antes de cada commit (obligatorio)

1. `dart run build_runner build --delete-conflicting-outputs` si cambiaron
   tablas/DAOs de Drift.
2. `flutter analyze` → 0 issues.
3. `dart format lib test` → sin cambios pendientes.
4. `flutter test` → todo verde.
5. Recién entonces: `git add -A && git commit`.

## Convenciones de commit

- Conventional Commits, mensaje en inglés:
  `feat: ...`, `fix: ...`, `docs: ...`, `test: ...`, `refactor: ...`,
  `chore: ...`, `style: ...`
- Un commit por hito o cambio grande (ver `docs/TASKS.md`).
- Todo commit de funcionalidad incluye sus tests.
- Nunca commitear secretos, builds (`build/`) ni archivos generados
  (`*.g.dart` sí se commitea: es codegen de Drift necesario para CI).

## Reglas de código

- Sin comentarios en el código salvo que se pidan explícitamente.
- Constructores `const` siempre que sea posible.
- Modelos de dominio inmutables, escritos a mano (sin freezed/json_serializable).
- No usar `setState` para estado global: siempre Riverpod
  (`ConsumerWidget`/`ref.watch`).
- El código pesado de fechas/recurrencia va en lógica pura de dominio
  (`lib/features/activities/domain/`), nunca dentro de widgets.
- Strings de UI en español; resto del código en inglés.
- Seguir `analysis_options.yaml` (flutter_lints).
- UI: usar **tokens de diseño** de `lib/core/theme/` (colores, spacing, radius,
  tipografía, motion) y leer `design-system/blockday/MASTER.md` antes de tocar
  cualquier pantalla/componente. Nada de hex/spacing/radius/fontSize crudos en
  widgets; respetar `MediaQuery.disableAnimations` (reduced motion) y targets
  táctiles >= 48dp.

## Tests

- Toda lógica de dominio nueva (recurrencia, modelos, repositorio) nace con
  tests unitarios en `test/`.
- Casos borde obligatorios en recurrencia: fin de mes, año bisiesto,
  condición "hasta fecha", condición "N veces", fechas excluidas.
- Repositorio de Drift se testa con base de datos en memoria.
- Flujos críticos de UI llevan widget tests.

## Skills (carpeta `.agents/skills/`)

| Tarea | Skill |
|---|---|
| UI/UX, sistema de diseño, accesibilidad, motion | `ui-ux-pro-max` (ver `design-system/blockday/MASTER.md`) |
| Implementar animaciones en Flutter | `flutter-animations` |
| Arquitectura, Riverpod, GoRouter, widgets, rendimiento | `flutter-expert` (ver `references/`) |
| Estilo y buenas prácticas de Dart | `dart-best-practices` |

## Documentación de librerías

Para cualquier duda de API de una librería (flutter_riverpod, drift,
go_router, intl, etc.) usar el MCP de **context7**:
primero `resolve-library-id`, luego `query-docs` con una pregunta concreta.
No confiar en memoria: las APIs cambian.

## Estructura de carpetas

Ver `docs/ARCHITECTURE.md` — estructura feature-first:
`lib/core/`, `lib/features/{calendar,activities}/`, `lib/shared/`,
`lib/routes/`. Cada feature con `domain/`, `data/`, `presentation/`,
`providers/`.
