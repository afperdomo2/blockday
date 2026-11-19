# AGENTS.md — Blockday

## Proyecto

Blockday es una app de calendario personal para **Windows, Android y Linux**,
tipo Google Calendar, para planificar bloques de tiempo y actividades:

- Bloques recurrentes (p. ej. "Buscar trabajo" Lun–Vie 17:00–19:00).
- Eventos puntuales futuros (p. ej. "Curso virtual" el próximo jueves 08:00).
- Reglas de repetición flexibles (p. ej. "todos los martes y jueves durante
  un mes").

Detalles de producto: `docs/PRODUCT.md`
Arquitectura y modelo de datos: `docs/ARCHITECTURE.md`
Roadmap de trabajo: `docs/TASKS.md`

## Stack

- Flutter / Dart (ver `pubspec.yaml`). Targets: **Windows, Android y Linux**
  (Linux se usa además para desarrollo y pruebas fuera de Windows).
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
flutter run -d linux                                   # ejecutar en Linux (dev/pruebas)
flutter run -d windows                                 # ejecutar en Windows
flutter run -d <device-android>                        # ejecutar en Android
flutter test --coverage && dart pub global activate coverage  # cobertura (opcional)
```

Si `flutter` no está en el `PATH` (caso habitual en Linux con SDK manual):
`export PATH="$HOME/Documentos/flutter/bin:$PATH"`. Los scripts de `scripts/`
lo resuelven solos desde `~/Documentos/flutter`, `~/flutter`, snap, `/opt` o
`FLUTTER_ROOT`.

### Versionado y releases (scripts)

```bash
./scripts/bump-build.sh [--patch|--minor|--major]  # sube versión en pubspec.yaml
./scripts/build.sh linux|linux-install|windows|apk|run
./scripts/build-deb.sh [--no-bump]                 # .deb en dist/
./scripts/build-apk.sh [--no-bump]                 # APK en dist/
./scripts/install-linux.sh [--uninstall]           # instala en ~/.local
```

- La versión vive **solo** en `pubspec.yaml` (`x.y.z+N`). No duplicarla en
  constantes de Dart (`package_info_plus` la lee del paquete instalado).
- `build.sh` inyecta `GIT_COMMIT`, `BUILD_TIME` y `BUILD_DIRTY` con
  `--dart-define`; el diálogo "Acerca de" los muestra.
- Los scripts de release hacen bump automático; usá `--no-bump` para publicar
  dos artefactos con el mismo número de build.
- El bump deja el cambio en el working tree: se commitea junto al release.


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
  tipografía, motion) y leer `docs/DESIGN_SYSTEM.md` antes de tocar
  cualquier pantalla/componente. Nada de hex/spacing/radius/fontSize crudos en
  widgets; respetar `MediaQuery.disableAnimations` (reduced motion) y targets
  táctiles >= 48dp.
- **Responsive (mobile-first)**: el layout cómodo es el de teléfono; en pantallas
  grandes se adapta, no se estira. Usar `context.windowSize` / `context.isCompact`
  (`lib/core/responsive/app_breakpoints.dart`) y acotar el contenido con
  `ConstrainedContent` + `AppContentWidth` (`lib/core/responsive/constrained_content.dart`).
  Nunca comparar anchos con números mágicos (`maxWidth >= 600`).
  Ver `docs/DESIGN_SYSTEM.md` → «Responsive y adaptativo».

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
| UI/UX, sistema de diseño, accesibilidad, motion | `ui-ux-pro-max` (ver `docs/DESIGN_SYSTEM.md`) |
| Animaciones y motion en Flutter | `flutter-animations` |
| Arquitectura por capas de la app | `flutter-apply-architecture-best-practices` |
| Layout responsive/adaptativo | `flutter-build-responsive-layout` |
| Bugs de layout (overflow, constraints sin límite) | `flutter-fix-layout-issues` |
| Navegación con go_router / rutas declarativas | `flutter-setup-declarative-routing` |
| Widget tests de pantallas y componentes | `flutter-add-widget-test` |
| Drift, SQLite, migraciones y CRUD local | `flutter-drift` |
| Tests unitarios de dominio (recurrencia, modelos) | `dart-add-unit-test` |
| Análisis estático y fixes de lint | `dart-run-static-analysis` |
| Estilo y buenas prácticas de Dart | `dart-best-practices` |

- Riverpod: el proyecto usa `flutter_riverpod` 3 con providers manuales
  (`Notifier` / `NotifierProvider`), **sin codegen** (`riverpod_generator`).
  Para la API exacta, consultar context7 antes de escribir providers nuevos.
- Si una skill no aparece en `.agents/skills/`, restaurarlas con
  `npx skills experimental_install`.

## Documentación de librerías

Para cualquier duda de API de una librería (flutter_riverpod, drift,
go_router, intl, etc.) usar el MCP de **context7**:
primero `resolve-library-id`, luego `query-docs` con una pregunta concreta.
No confiar en memoria: las APIs cambian.

## Archivos de IA y locales

- `AGENTS.md` — instrucciones para agentes (versionado, es el punto de entrada).
- `skills-lock.json` — versionado; fija las skills instaladas por el CLI de
  skills (fuente y hash). Se actualiza con el CLI, no a mano.
- `.agents/skills/` — gitignored; materializadas localmente por el CLI de
  skills a partir de `skills-lock.json` (no se versionan).
- `opencode.json` — **local, gitignored** (no se versiona: contiene rutas
  absolutas por SO). Habilita el MCP server `dart-mcp-server` (análisis/LSP,
  hot reload, pub). En Linux/Ubuntu usa ruta absoluta al SDK porque `dart` no
  está en `PATH`; en Windows basta `dart`. Plantillas para copiar/pegar en
  `README.md` → «MCP de Dart en OpenCode».
- `.vscode/` — gitignored.
- `docs/` — fuente de verdad de producto, arquitectura, diseño y roadmap
  (ver índice más abajo). No hay carpeta `context/`: lo que necesita un agente
  está aquí y enlazado desde `AGENTS.md`.
- Nunca commitear rutas absolutas de una máquina concreta.

## Plataformas y despliegue

| Plataforma | Ejecutar / probar | Distribuir |
|---|---|---|
| Linux (dev y pruebas) | `flutter run -d linux` o `./scripts/build.sh run` | `./scripts/build-deb.sh` → `dist/blockday_<versión>_<arch>.deb`; instalación sin `sudo` con `./scripts/install-linux.sh` |
| Windows | `flutter run -d windows` | `./scripts/build.sh windows` → `build/windows/x64/runner/Release/` |
| Android | `flutter run -d <device>` | `./scripts/build-apk.sh` → `dist/blockday-<versión>-android.apk` |

- Detalle completo (requisitos, rutas de instalación, firma, desinstalación) en
  `README.md` → «Compilación y distribución».
- **Responsive**: `NavigationBar` en compact (`< 600`), `NavigationRail` en
  tablet/escritorio; el contenido se centra con `ConstrainedContent`. La ventana
  de Linux abre en 480×900 y se adapta al redimensionar (breakpoints 600 / 1024).
- En Linux el `.deb` instala en `/opt/blockday/` + `/usr/bin/blockday`; la
  instalación local en `~/.local/opt/blockday/` + `~/.local/bin/blockday`.
- El icono de Linux es `linux/blockday.png` y la entrada de menú
  `linux/blockday.desktop` (con marcador `@EXEC@` que reemplazan los scripts).
- `dist/` y `build/` están en `.gitignore`: nunca commitear artefactos.

## Documentación (índice)

| Archivo | Contenido |
|---|---|
| `docs/PRODUCT.md` | Alcance, historias de usuario, no-alcance |
| `docs/ARCHITECTURE.md` | Stack, modelo de datos, motor de recurrencia, Drift |
| `docs/DESIGN_SYSTEM.md` | Tokens, tipografía, espaciado, componentes, reglas de UI |
| `docs/TASKS.md` | Roadmap por hitos |
| `README.md` | Requisitos, desarrollo, versionado, compilación y distribución |

`docs/` es la fuente de verdad detallada; `AGENTS.md` resume lo que un agente
necesita para trabajar. Si cambiás algo estructural (modelos, providers,
features, scripts, plataformas), actualizá ambos.

## Estructura de carpetas

Ver `docs/ARCHITECTURE.md` — estructura feature-first:
`lib/core/`, `lib/features/{calendar,activities}/`, `lib/shared/`,
`lib/routes/`. Cada feature con `domain/`, `data/`, `presentation/`,
`providers/`.
