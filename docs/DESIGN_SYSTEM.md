# Blockday — Sistema de diseño

> Fuente de verdad de la UI. Vive en `docs/` junto al resto de la documentación.
> Si alguna pantalla necesita reglas propias, van en `docs/pages/<pantalla>.md`
> y **sobrescriben** este archivo.

---

**Project:** Blockday
**Generated:** 2026-10-05 16:37:01
**Rediseño v2 (profundidad sutil):** 2026-11-18
**Category:** Calendar & Scheduling App
**Estilo:** Soft UI Evolution + Dimensional Layering + Micro-interactions

## Dirección visual (v2)

La v1 era *Flat Design* ("no shadows") y la app se leía como plana y genérica.
La dirección actual es **profundidad sutil**:

- **Capas con significado**: cada superficie se separa del fondo con sombras
  suaves en dos capas (contacto + ambiente) y bordes tenues, nunca más de
  3 niveles de elevación visibles a la vez.
- **Color con identidad**: cobalto profundo propio (no el azul genérico de
  plantilla), tinta navy para títulos, esmeralda cálido para progreso y
  superficies de papel cálido (`#F7F6F2`). Gradients de marca solo en momentos
  clave (botón primario, marca, progreso).
- **Microinteracciones**: feedback inmediato (80–150ms), press scale sin
  shift de layout, animaciones de entrada escalonadas, checks animados,
  contadores y anillos de progreso animados. Todo gateado por
  `AppMotion.reduceMotion`.

Anti-patrones: neumorfismo extremo, glassmorphism pesado, gradientes en todo,
sombras duras, un solo duration para todas las transiciones.

---

## Color Palette

### Marca y semántica (light)

| Role | Hex | Token Dart |
|------|-----|------------|
| Primary (cobalto) | `#2E3EC9` | `AppColors.primary` |
| On Primary | `#FFFFFF` | `AppColors.onPrimary` |
| Primary Container | `#E3E6FB` | `AppColors.primaryContainer` |
| On Primary Container | `#1B2560` | `AppColors.onPrimaryContainer` |
| Secondary | `#5B64B8` | `AppColors.secondary` |
| Secondary Container | `#E7E8FA` | `AppColors.secondaryContainer` |
| Accent / Success (esmeralda) | `#0E9C6E` | `AppColors.accent` / `AppColors.success` |
| Accent Container | `#D4F0E3` | `AppColors.accentContainer` |
| Destructive | `#C4402E` | `AppColors.destructive` |
| Background (papel cálido) | `#F7F6F2` | `AppColors.backgroundLight` |
| Foreground (ink) | `#23263B` | `AppColors.foreground` |
| Heading (navy) | `#1B2560` | `AppColors.heading` |
| Card | `#FFFFFF` | `AppColors.cardLight` |
| Muted | `#EDEBE6` | `AppColors.mutedLight` |
| Muted Foreground | `#5C6072` | `AppColors.mutedForeground` |
| Border | `#E2DFD7` | `AppColors.borderLight` |

### Dark

| Role | Hex | Token Dart |
|------|-----|------------|
| Primary | `#AEB8FF` | `AppColors.primaryDark` |
| On Primary | `#161F55` | `AppColors.onPrimaryDark` |
| Primary Container | `#2D3891` | `AppColors.primaryContainerDark` |
| Accent | `#4BD3A2` | `AppColors.accentDark` |
| Background | `#12141F` | `AppColors.backgroundDark` |
| Card | `#181B28` | `AppColors.cardDark` |
| Foreground | `#E7E8F2` | `AppColors.foregroundDark` |
| Muted Foreground | `#A4A8BE` | `AppColors.mutedForegroundDark` |
| Muted | `#2F3346` | `AppColors.mutedDark` |
| Border | `#343850` | `AppColors.borderDark` |
| Destructive | `#F1917F` | `AppColors.destructiveDark` |

> Los tonos completos viven en `buildAppColorScheme()` (`app_colors.dart`),
> que construye el `ColorScheme` **explícito** (sin `fromSeed`) para ambos
> brillos. Contraste de texto normal ≥ 4.5:1 verificado por rol.

### Paleta funcional de actividades

11 categorías con foreground contrastado (≥ 4.5:1), en `activity_colors.dart`:
cobalto `#2E3EC9`, océano `#1F6FB2`, teal `#0E7C86`, violeta `#6B4BC4`,
rosa `#B0356E`, carmín `#BE3A2B`, óxido `#B05A14`, oro `#E3B23C` (fg negra),
bosque `#2C7A4B`, teal profundo `#146B5E`, pizarra `#495877`.
Dark usa variantes más claras con fg negra.

**Regla de bloques**: los bloques de actividad NO se pintan a color pleno.
Se renderizan como **tinte suave** (color al 12–22%) + **barra de acento** de
3px a color pleno + borde al 50%. El color pleno se reserva para dots
(mes), barras de acento y badges.

---

## Marca / Icono

**Concepto:** página de calendario blanca con dos argollas azules y tres
bloques de tiempo (primario, acento claro y verde de éxito) sobre un tile
slate `#0F172A` con esquinas de 112px en un lienzo de 512px y un trazo interior
sutil `#94A3B8` al 20%.

**Fuentes (SVG maestros, `brand/`):**

| Archivo | Contenido | Uso |
|---|---|---|
| `brand/icon.svg` | tile completo con colores | Linux, Windows, launcher legacy de Android |
| `brand/mark.svg` | glifo suelto con colores | foreground del adaptive icon de Android |
| `brand/mark-mono.svg` | glifo monocromo (`currentColor`) con los bloques como huecos | icono temático de Android 13+ |

**En la app:** el glifo se dibuja como widget (`shared/widgets/brand_mark.dart`,
tile con gradiente primario→secundario) en el AppBar de Inicio y Calendario.

**Generación:** `scripts/generate-icons.sh` rasteriza los SVG con Chrome
headless y deriva todos los PNG/ICO (no editar los generados a mano).

---

## Typography

- **Font:** Plus Jakarta Sans (bundled como TTF en `assets/fonts/`, offline).
- **Mood:** friendly, modern, saas, clean, approachable, professional.
- **Weights:** Light 300, Regular 400, Medium 500, SemiBold 600, Bold 700
  (más `w800` sintético para display).

| Rol | Uso | Notas |
|---|---|---|
| `displayLarge` (56, w800, -2 tracking) | `DateHero`: número de día grande | alto 1.0 |
| `headlineSmall/Medium` | títulos de pantalla | w700, tracking negativo |
| `titleLarge` | AppBar titles | w700, color heading |
| `titleMedium/Small` | títulos de sección y tarjeta | w600 |
| `bodyMedium/Small` | texto corrido | alto 1.5 / 1.4 |
| `labelLarge` | botones | w600 |
| `labelSmall` | chips, badges, horas | w600, tracking +0.4 |
| `AppTypography.weekBlock` (10) / `weekBlockCompact` (9) | bloques en vista semana | **no cambiar**: los tests fijan el tamaño |

Los títulos (display/headline/title) usan `AppColors.heading` (navy) en light;
el resto usa `onSurface`.

---

## Spacing Variables

| Token | Valor | Uso |
|-------|-------|-----|
| `AppSpacing.xxs` | 2 | micro gaps |
| `AppSpacing.xs` | 4 | gaps apretados |
| `AppSpacing.sm` | 8 | gaps de icono |
| `AppSpacing.md` | 12 | padding inline |
| `AppSpacing.lg` | 16 | padding estándar |
| `AppSpacing.xl` | 20 | gaps de botones |
| `AppSpacing.xxl` | 24 | padding de sección |
| `AppSpacing.xxxl` | 32 | gaps grandes |
| `AppSpacing.jumbo` | 48 | márgenes de sección |

## Radius

`AppRadius.sm` 6 · `md` 8 · `lg` 12 (cards) · `xl` 16 (dialogs, FAB) ·
`pill` 999. Getters `smAll/mdAll/lgAll/xlAll/pillAll`.

## Shadow Depths (`app_shadows.dart`)

Sombras en dos capas (tinta `#1B2350` en light, negro en dark con +60% blur).

| Token | Uso |
|-------|-----|
| `AppShadows.card(brightness)` | Cards en reposo |
| `AppShadows.pressed(brightness)` | Cards presionadas (más compacta) |
| `AppShadows.floating(brightness)` | menús, barras flotantes, FAB |
| `AppShadows.brand(color, brightness)` | glow tintado del CTA primario |

## Icon Sizes (`app_icon_size.dart`)

`sm` 16 · `md` 20 · `lg` 24 · `xl` 32. Nada de tamaños arbitrarios.

## Motion (`app_motion.dart`)

| Token | Valor |
|-------|-------|
| `fast` | 150ms (estados, press) |
| `base` | 200ms (transiciones cortas) |
| `slow` | 300ms (entradas, progreso) |
| `enter` | `easeOutCubic` (entra desacelerando) |
| `exit` | `easeInCubic` (sale acelerando, ~60–70% del enter) |
| `spring` | `easeOutBack` (checks, elementos que "asientan") |
| `pressScale` | 0.98 (escala visual presionada, sin shift de layout) |

**Reduced motion:** `AppMotion.reduceMotion(context)` gatea toda animación
no esencial (incluye haptics).

---

## Componentes de negocio (shared/widgets)

| Widget | Rol |
|---|---|
| `AppCard` | card con sombra en capas, borde tenue, press scale + ink ripple |
| `DateHero` | fecha grande (día + caption + badge "Hoy" + trailing) |
| `ProgressRing` | anillo de progreso animado con gradiente primario→acento |
| `AppProgressBar` | barra animada con gradiente de marca |
| `AnimatedCheckButton` | check circular animado + haptic al completar |
| `EmptyState` / `EmptyHint` | empty states con icono en badge + copy + acción |
| `SectionHeader` | título de sección + count pill + acción trailing |
| `BrandMark` | glifo de marca (tile con gradiente + painter) |
| `StaggeredEntrance/StaggeredItem` | entradas escalonadas de listas |
| `ActivityBlock` | bloque de calendario: tinte + barra de acento + completado |
| `NowLine` | indicador de hora actual (línea con fade + dot con anillo) |

**Reglas de componente:**
- Ningún widget usa hex/spacing/radius/fontSize crudos: solo tokens.
- Toda superficie interactiva da feedback en <150ms sin shift de layout.
- Touch targets ≥ 48dp (botones `minimumSize` 48×48 en el tema).
- Los estados completados usan esmeralda + check + strikethrough, nunca solo
  color (el color nunca es el único indicador).

---

## Pre-Delivery Checklist

- [ ] Sin emojis como iconos (usar `Icons` / SVG)
- [ ] Iconos con `AppIconSize`, familia consistente
- [ ] Feedback pressed en todo elemento tappable (<150ms, sin shift de layout)
- [ ] Contraste ≥ 4.5:1 en light **y** dark (revisar por separado)
- [ ] Focus visible para teclado
- [ ] `AppMotion.reduceMotion` respetado
- [ ] Responsive: 375px / 768px / 1024px / 1440px, sin overflow horizontal
- [ ] Contenido no queda detrás de barras fijas
- [ ] Tests de widget para componentes nuevos

---

## Flutter Implementation Map (Blockday)

| Design role | Material 3 slot / token |
|---|---|
| Primary `#2E3EC9` | `ColorScheme.primary` (explícito, no `fromSeed`) |
| Secondary `#5B64B8` | `ColorScheme.secondary` |
| Accent/success `#0E9C6E` | `ColorScheme.tertiary` / `AppColors.success` |
| Background `#F7F6F2` | `ColorScheme.surface` |
| Heading `#1B2560` | `textTheme.display/headline/title` (light) |
| Card `#FFFFFF` | `ColorScheme.surfaceContainerLow` + `AppCard` |
| Muted `#EDEBE6` | `ColorScheme.surfaceContainerHighest` |
| Border `#E2DFD7` | `ColorScheme.outlineVariant` |
| Destructive `#C4402E` | `ColorScheme.error` |

Token files (`lib/core/theme/`):

- `app_colors.dart` — semántica de color light + dark y `buildAppColorScheme`.
- `app_shadows.dart` — elevaciones suaves en capas (card/pressed/floating/brand).
- `app_spacing.dart` — escala 4/8dp.
- `app_radius.dart` — radios de esquina.
- `app_icon_size.dart` — tamaños de icono.
- `app_typography.dart` — roles tipográficos sobre Plus Jakarta Sans.
- `app_motion.dart` — durations/curves + `pressScale` + `reduceMotion`.
- `app_theme.dart` — `ThemeData` light/dark a partir de los tokens.
- `activity_colors.dart` — paleta funcional de categorías (contrast-checked).

---

## Responsive y adaptativo (Blockday)

La app es **mobile-first**: el layout cómodo es el de teléfono y en pantallas
grandes se adapta, nunca se estira. La lógica vive en `lib/core/responsive/`.

### Window size classes

| Clase | Ancho | Casos típicos | Navegación |
|---|---|---|---|
| `compact` | `< 600` | teléfono, ventana de escritorio angosta | `NavigationBar` inferior |
| `medium` | `600 – 1023` | tablet vertical, ventana mediana | `NavigationRail` (sin etiquetas) |
| `expanded` | `≥ 1024` | tablet horizontal, escritorio | `NavigationRail` (con etiquetas) |

```dart
if (context.isCompact) { /* layout de teléfono */ }
switch (context.windowSize) { ... }
```

> Los cortes viven en `AppBreakpoints.medium` (600) y `AppBreakpoints.expanded`
> (1024). **No usar números mágicos** (`maxWidth >= 600`) en pantallas.

### Ancho máximo de contenido

En lugar de estirar el contenido, se centra con `ConstrainedContent`:

```dart
body: ConstrainedContent(
  maxWidth: AppContentWidth.list,
  child: ListView(...),
),
```

| Token | Ancho | Uso |
|---|---|---|
| `AppContentWidth.form` | 560 | editores (actividad, tarea) |
| `AppContentWidth.day` | 560 | calendario, vista día |
| `AppContentWidth.list` | 720 | Inicio, Backlog, barra de herramientas del calendario |
| `AppContentWidth.threeDay` | 760 | calendario, vista 3 días |
| `AppContentWidth.calendar` | 1100 | calendario, semana y mes |

### Escritorio (Linux / Windows)

- La ventana de Linux abre en **480×900** (proporción de teléfono), así el
  primer vistazo es el layout móvil.
- Al **redimensionar** la ventana el layout cambia en vivo: al pasar de 600 px
  aparece el rail lateral y, desde 1024 px, sus etiquetas; el contenido se
  centra y deja de estirarse.
- No duplicar pantallas por plataforma: adaptar con breakpoints y tokens.
