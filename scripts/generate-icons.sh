#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "❌ Error en ${BASH_SOURCE[0]} línea $LINENO" >&2' ERR

# Genera los iconos de las plataformas de Blockday a partir de los másters
# de `brand/`.
#
#   brand/icon.svg      → tile redondeado (Linux, Windows, launcher legacy Android)
#   brand/mark.svg      → glifo suelto (foreground del adaptive icon de Android)
#   brand/mark-mono.svg → glifo monocromo (icono temático de Android 13+)
#
# Salidas:
#   linux/blockday.png                                        (192px, hicolor)
#   android/app/src/main/res/mipmap-*/ic_launcher.png            (legacy)
#   android/app/src/main/res/mipmap-*/ic_launcher_foreground.png (adaptive)
#   android/app/src/main/res/mipmap-*/ic_launcher_monochrome.png (temático)
#   android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
#   android/app/src/main/res/values/ic_launcher_background.xml
#   windows/runner/resources/app_icon.ico
#
# Requiere Google Chrome/Chromium (render de SVG) y Python 3 + Pillow
# (downscale LANCZOS, ICO y normalización). Los resultados se commitean:
# este script es de uso manual, no corre en CI ni en los git hooks.
# No editar los PNG/ICO generados a mano: la fuente única es `brand/`.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BRAND_DIR="$ROOT_DIR/brand"
ANDROID_RES="$ROOT_DIR/android/app/src/main/res"
WIN_RES="$ROOT_DIR/windows/runner/resources"
LINUX_ICON="$ROOT_DIR/linux/blockday.png"

BRAND_BG="#0F172A"

die() {
  echo "❌ $*" >&2
  exit 1
}

find_chrome() {
  local bin
  for bin in \
    google-chrome \
    google-chrome-stable \
    chromium \
    chromium-browser \
    "/c/Program Files/Google/Chrome/Application/chrome.exe" \
    "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"; do
    if command -v "$bin" >/dev/null 2>&1; then
      command -v "$bin"
      return 0
    fi
  done
  return 1
}

find_python() {
  local bin
  for bin in python3 python; do
    if command -v "$bin" >/dev/null 2>&1; then
      command -v "$bin"
      return 0
    fi
  done
  return 1
}

[[ -f "$BRAND_DIR/icon.svg" ]] || die "No existe $BRAND_DIR/icon.svg"
[[ -f "$BRAND_DIR/mark.svg" ]] || die "No existe $BRAND_DIR/mark.svg"
[[ -f "$BRAND_DIR/mark-mono.svg" ]] || die "No existe $BRAND_DIR/mark-mono.svg"

CHROME_BIN="$(find_chrome)" \
  || die "No encontré Chrome/Chromium. Instalalo o generá los PNG con rsvg-convert/ImageMagick."

PYTHON_BIN="$(find_python)" || die "Falta python3/python."
"$PYTHON_BIN" -c 'import PIL' 2>/dev/null || die "Falta Pillow: python3 -m pip install pillow"

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

ICON_SVG="$(cat "$BRAND_DIR/icon.svg")"
MARK_SVG="$(cat "$BRAND_DIR/mark.svg")"
MONO_SVG="$(cat "$BRAND_DIR/mark-mono.svg")"

# Renderiza un SVG a PNG cuadrado con Chrome headless.
#
#   render <modo> <px> <salida>
#
# Modos:
#   tile  tile redondeado, esquinas transparentes
#   safe  glifo con margen para la zona segura del adaptive icon de Android
#   mono  igual que safe, en blanco para el icono temático de Android
render() {
  local mode="$1"
  local size="$2"
  local out="$3"
  local svg bg scale color

  case "$mode" in
    tile)
      svg="$ICON_SVG"
      bg="transparent"
      scale="1"
      color="#0F172A"
      ;;
    safe)
      svg="$MARK_SVG"
      bg="transparent"
      # Zona segura Android: el glifo debe caber en el círculo de 66dp
      # sobre el lienzo de 108dp.
      scale="0.8"
      color="#0F172A"
      ;;
    mono)
      svg="$MONO_SVG"
      bg="transparent"
      scale="0.8"
      color="#FFFFFF"
      ;;
    *)
      die "Modo de render desconocido: $mode"
      ;;
  esac

  local html="$TMP_DIR/render-${mode}-${size}.html"
  cat >"$html" <<HTML
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<style>
html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background: ${bg}; }
.wrap { position: fixed; inset: 0; display: grid; place-items: center; color: ${color}; }
svg { width: 100%; height: 100%; display: block; transform: scale(${scale}); transform-origin: center; }
</style>
</head>
<body>
<div class="wrap">${svg}</div>
</body>
</html>
HTML

  "$CHROME_BIN" \
    --headless \
    --disable-gpu \
    --disable-dev-shm-usage \
    --hide-scrollbars \
    --force-device-scale-factor=1 \
    --default-background-color=00000000 \
    --window-size="${size},${size}" \
    --screenshot="$out" \
    "file://$html" >/dev/null 2>&1 \
    || die "Chrome falló al renderizar $mode a ${size}px"

  [[ -s "$out" ]] || die "Chrome no generó la imagen $out"
}

echo "🎨 Renderizando iconos desde brand/…"

# Un solo render maestro por modo; los tamaños finales salen por downscale
# LANCZOS con Pillow (más nítido que renderizar cada tamaño por separado).
render tile 1024 "$TMP_DIR/master-tile.png"
render safe 1024 "$TMP_DIR/master-safe.png"
render mono 1024 "$TMP_DIR/master-mono.png"

# Genera los assets de plataforma y normaliza los PNG (quita metadatos de
# Chrome para que el script sea idempotente).
"$PYTHON_BIN" - "$TMP_DIR" "$ANDROID_RES" "$WIN_RES" "$LINUX_ICON" <<'PY'
import sys
from pathlib import Path

from PIL import Image

tmp, android, win, linux_icon = (Path(p) for p in sys.argv[1:5])

masters = {}
for name in ("tile", "safe", "mono"):
    with Image.open(tmp / f"master-{name}.png") as img:
        img.load()
        masters[name] = img.copy().convert("RGBA")


def scaled(master, size):
    return masters[master].resize((size, size), Image.LANCZOS)


def save(img, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGBA").save(path, format="PNG", optimize=True)


# --- Linux ----------------------------------------------------------------
# Tamaño fijado por build-deb.sh / install-linux.sh (hicolor/192x192).
save(scaled("tile", 192), linux_icon)

# --- Android --------------------------------------------------------------
# Launcher legacy (tile) y adaptive icon (foreground con zona segura sobre
# lienzo de 108dp + monochrome para iconos temáticos de Android 13+).
density_dirs = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
for density, launcher_px in density_dirs.items():
    save(scaled("tile", launcher_px), android / f"mipmap-{density}/ic_launcher.png")
    fg_px = launcher_px * 108 // 48  # lienzo 108dp * densidad
    save(scaled("safe", fg_px), android / f"mipmap-{density}/ic_launcher_foreground.png")
    save(scaled("mono", fg_px), android / f"mipmap-{density}/ic_launcher_monochrome.png")

# --- Windows --------------------------------------------------------------
win.mkdir(parents=True, exist_ok=True)
scaled("tile", 256).save(
    win / "app_icon.ico",
    format="ICO",
    sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
)

# Normaliza los PNG de salida para que dos corridas sean idénticas.
for path in [*android.glob("mipmap-*/ic_launcher*.png"), linux_icon]:
    with Image.open(path) as img:
        img.load()
        normalized = img.copy()
    normalized.save(path, format="PNG", optimize=True)
PY

mkdir -p "$ANDROID_RES/mipmap-anydpi-v26"
cat >"$ANDROID_RES/mipmap-anydpi-v26/ic_launcher.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<!-- Generado por scripts/generate-icons.sh — no editar a mano. -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />
</adaptive-icon>
XML

cat >"$ANDROID_RES/values/ic_launcher_background.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<!-- Generado por scripts/generate-icons.sh — no editar a mano. -->
<resources>
    <color name="ic_launcher_background">$BRAND_BG</color>
</resources>
XML

echo "✅ Linux   → linux/blockday.png"
echo "✅ Android → android/app/src/main/res/{mipmap-*,mipmap-anydpi-v26,values}/"
echo "✅ Windows → windows/runner/resources/app_icon.ico"
