#!/usr/bin/env bash
# Compila con los datos de la compilación inyectados (commit, fecha y dirty).
#
#   ./scripts/build.sh linux            # release de Linux
#   ./scripts/build.sh linux-install    # release + scripts/install-linux.sh
#   ./scripts/build.sh windows          # release de Windows
#   ./scripts/build.sh apk              # APK release (Android)
#   ./scripts/build.sh run              # flutter run con los datos inyectados
#
# Sin este script la app muestra "No disponible" en commit y fecha; la versión
# siempre sale del pubspec (package_info_plus), así que nunca se desincroniza.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# En Linux el SDK suele no estar en el PATH del sistema. Se resuelve por PATH y,
# si no, por las ubicaciones típicas de una instalación manual.
resolve_flutter() {
  if command -v flutter >/dev/null 2>&1; then
    command -v flutter
    return
  fi
  local candidate
  for candidate in \
    "${FLUTTER_ROOT:-}/bin/flutter" \
    "$HOME/Documentos/flutter/bin/flutter" \
    "$HOME/flutter/bin/flutter" \
    "$HOME/snap/flutter/common/flutter/bin/flutter" \
    /opt/flutter/bin/flutter; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done
  return 1
}

FLUTTER="$(resolve_flutter || true)"
if [[ -z "$FLUTTER" ]]; then
  echo "✗ No se encontró el binario 'flutter'." >&2
  echo "  Agregá el SDK al PATH (export PATH=\"\$HOME/Documentos/flutter/bin:\$PATH\")" >&2
  echo "  o definí FLUTTER_ROOT apuntando a la raíz del SDK." >&2
  exit 1
fi

TARGET="${1:-linux}"
if [[ $# -gt 0 ]]; then
  shift
fi

COMMIT="$(git rev-parse --short HEAD 2>/dev/null || true)"
DIRTY="false"
if [[ -n "$(git status --porcelain 2>/dev/null || true)" ]]; then
  DIRTY="true"
fi
BUILD_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
VERSION="$(sed -n 's/^version: *//p' pubspec.yaml | head -1)"

DEFINES=(
  --dart-define=GIT_COMMIT="$COMMIT"
  --dart-define=BUILD_TIME="$BUILD_TIME"
  --dart-define=BUILD_DIRTY="$DIRTY"
)

info() { printf '  %s\n' "$*"; }

build_release() {
  local platform="$1"
  shift
  "$FLUTTER" build "$platform" --release "${DEFINES[@]}" "$@"
}

echo "→ Compilando ($TARGET)"
info "Versión   : ${VERSION:-desconocida} (pubspec.yaml)"
info "Commit    : ${COMMIT:-desconocido}"
info "Dirty     : $DIRTY"
info "Compilada : $BUILD_TIME"

case "$TARGET" in
  linux)
    build_release linux "$@"
    ;;
  linux-install)
    build_release linux "$@"
    "$REPO_ROOT/scripts/install-linux.sh"
    ;;
  windows)
    build_release windows "$@"
    ;;
  apk | android)
    build_release apk "$@"
    ;;
  run)
    "$FLUTTER" run "${DEFINES[@]}" "$@"
    ;;
  *)
    echo "Uso: $(basename "$0") {linux|linux-install|windows|apk|run} [args de flutter]" >&2
    exit 2
    ;;
esac
