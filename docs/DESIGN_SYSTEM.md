# Blockday — Sistema de diseño

> Fuente de verdad de la UI. Vive en `docs/` junto al resto de la documentación
> (antes estaba en `design-system/blockday/MASTER.md`).
> Si alguna pantalla necesita reglas propias, van en `docs/pages/<pantalla>.md`
> y **sobrescriben** este archivo.

---

**Project:** Blockday
**Generated:** 2026-10-05 16:37:01
**Moved to docs/:** 2026-11-18
**Category:** Calendar & Scheduling App
**Design Dials:** Variance 4/10 (Balanced / Modern) | Density 7/10 (Standard)

---

## Global Rules

### Color Palette

| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#2563EB` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#3B82F6` | `--color-secondary` |
| On Secondary | `#000000` | `--color-on-secondary` |
| Accent/CTA | `#059669` | `--color-accent` |
| On Accent/CTA | `#000000` | `--color-on-accent` |
| Background | `#F8FAFC` | `--color-background` |
| Foreground | `#0F172A` | `--color-foreground` |
| Card | `#FFFFFF` | `--color-card` |
| Card Foreground | `#0F172A` | `--color-card-foreground` |
| Muted | `#F1F5FD` | `--color-muted` |
| Muted Foreground | `#475569` | `--color-muted-foreground` |
| Border | `#E4ECFC` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| On Destructive | `#FFFFFF` | `--color-on-destructive` |
| Ring | `#2563EB` | `--color-ring` |

**Color Notes:** Calendar blue + event green

### Typography

- **Heading Font:** Plus Jakarta Sans
- **Body Font:** Plus Jakarta Sans
- **Mood:** friendly, modern, saas, clean, approachable, professional
- **Weights bundled (offline, as assets):** Light 300, Regular 400, Medium 500, SemiBold 600, Bold 700
- **Font Family name in code:** `PlusJakartaSans`
- **Assets:** `assets/fonts/PlusJakartaSans-{Light,Regular,Medium,SemiBold,Bold}.ttf` (license: `assets/fonts/OFL.txt`)

> This app is 100% offline: fonts are bundled as TTF assets declared in `pubspec.yaml`, never fetched at runtime.

### Spacing Variables

*Density: 7/10 — Standard*

| Token | Value | Usage |
|-------|-------|-------|
| `--space-xs` | `4px` / `0.25rem` | Tight gaps |
| `--space-sm` | `8px` / `0.5rem` | Icon gaps, inline spacing |
| `--space-md` | `16px` / `1rem` | Standard padding |
| `--space-lg` | `24px` / `1.5rem` | Section padding |
| `--space-xl` | `32px` / `2rem` | Large gaps |
| `--space-2xl` | `48px` / `3rem` | Section margins |
| `--space-3xl` | `64px` / `4rem` | Hero padding |

### Shadow Depths

| Level | Value | Usage |
|-------|-------|-------|
| `--shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Subtle lift |
| `--shadow-md` | `0 4px 6px rgba(0,0,0,0.1)` | Cards, buttons |
| `--shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | Modals, dropdowns |
| `--shadow-xl` | `0 20px 25px rgba(0,0,0,0.15)` | Hero images, featured cards |

---

## Component Specs

### Buttons

```css
/* Primary Button */
.btn-primary {
  background: #059669;
  color: #000000;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  transition: all 200ms ease;
  cursor: pointer;
}

.btn-primary:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

/* Secondary Button */
.btn-secondary {
  background: transparent;
  color: #2563EB;
  border: 2px solid #2563EB;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  transition: all 200ms ease;
  cursor: pointer;
}
```

### Cards

```css
.card {
  background: #F8FAFC;
  border-radius: 12px;
  padding: 24px;
  box-shadow: var(--shadow-md);
  transition: all 200ms ease;
  cursor: pointer;
}

.card:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}
```

### Inputs

```css
.input {
  padding: 12px 16px;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  font-size: 16px;
  transition: border-color 200ms ease;
}

.input:focus {
  border-color: #2563EB;
  outline: none;
  box-shadow: 0 0 0 3px #2563EB20;
}
```

### Modals

```css
.modal-overlay {
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
}

.modal {
  background: white;
  border-radius: 16px;
  padding: 32px;
  box-shadow: var(--shadow-xl);
  max-width: 500px;
  width: 90%;
}
```

---

## Style Guidelines

**Style:** Flat Design

**Keywords:** 2D, minimalist, bold colors, no shadows, clean lines, simple shapes, typography-focused, modern, icon-heavy

**Best For:** Web apps, mobile apps, cross-platform, startup MVPs, user-friendly, SaaS, dashboards, corporate

**Key Effects:** No gradients/shadows, simple hover (color/opacity shift), fast loading, clean transitions (150-200ms ease), minimal icons

### Page Pattern

**Pattern Name:** Product Demo + Features

- **Conversion Strategy:** Use an interactive demo only when it explains value better than static media. Provide captions, transcript, visible play/pause controls, and a non-video fallback; do not autoplay under reduced motion. Pause media when offscreen or hidden and keep the final product state available as static content.
- **CTA Placement:** Video center + CTA right/bottom
- **Section Order:** Hero > Product video/mockup (center) > Feature breakdown per section > Comparison (optional) > CTA

---

## Anti-Patterns (Do NOT Use)

- ❌ Complex shadows
- ❌ 3D effects

### Additional Forbidden Patterns

- ❌ **Emojis as icons** — Use SVG icons (Heroicons, Lucide, Simple Icons)
- ❌ **Missing cursor:pointer** — All clickable elements must have cursor:pointer
- ❌ **Layout-shifting hovers** — Avoid scale transforms that shift layout
- ❌ **Low contrast text** — Maintain 4.5:1 minimum contrast ratio
- ❌ **Instant state changes** — Always use transitions (150-300ms)
- ❌ **Invisible focus states** — Focus states must be visible for a11y

---

## Pre-Delivery Checklist

Before delivering any UI code, verify:

- [ ] No emojis used as icons (use SVG instead)
- [ ] All icons from consistent icon set (Heroicons/Lucide)
- [ ] `cursor-pointer` on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard navigation
- [ ] `prefers-reduced-motion` respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px
- [ ] No content hidden behind fixed navbars
- [ ] No horizontal scroll on mobile

---

## Flutter Implementation Map (Blockday)

The web/CSS specs above are the design intent. In Flutter, apply them through the
semantic tokens in `lib/core/theme/` — never hardcode hex/spacing/radius in widgets.

| Design role | Material 3 slot / token |
|---|---|
| Primary `#2563EB` | `ColorScheme.primary` (seed) |
| Secondary `#3B82F6` | `ColorScheme.secondary` (seed harmonic) |
| Accent/event green `#059669` | `ColorScheme.tertiary` / `AppColors.success` |
| Background `#F8FAFC` | `ColorScheme.surface` (scaffold) |
| Foreground `#0F172A` | `ColorScheme.onSurface` |
| Card `#FFFFFF` | `ColorScheme.surfaceContainerLow` / Card theme |
| Muted `#F1F5FD` | `ColorScheme.surfaceContainerHighest` |
| Border `#E4ECFC` | `ColorScheme.outlineVariant` |
| Destructive `#DC2626` | `ColorScheme.error` |

Token files:

- `app_colors.dart` — semantic color tokens (light + dark).
- `app_spacing.dart` — 4/8dp scale (`xxs..4xl`).
- `app_radius.dart` — corner radii (`sm..pill`).
- `app_typography.dart` — type roles on Plus Jakarta Sans.
- `app_motion.dart` — shared durations/curves (enter ~200ms, exit ~60–70%).
- `app_theme.dart` — builds `ThemeData` (light/dark) from the above.
- `activity_colors.dart` — functional activity palette (contrast-checked, dark variant).

Rules: use tokens only, `const` where possible, respect `MediaQuery.disableAnimations`,
keep touch targets ≥48dp, and run the `flutter`/`ui-ux-pro-max` pre-delivery checklist
before committing UI changes.

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
