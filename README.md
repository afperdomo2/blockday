# Blockday

Calendario personal de bloques de tiempo para **Windows, Android y Linux**,
hecho con Flutter. Planifica actividades diarias (p. ej. "Buscar trabajo"
Lun–Vie 17:00–19:00) y eventos puntuales (p. ej. "Curso virtual" el próximo
jueves 08:00), con reglas de repetición flexibles.

- Producto: [`docs/PRODUCT.md`](docs/PRODUCT.md)
- Arquitectura: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- Sistema de diseño: [`docs/DESIGN_SYSTEM.md`](docs/DESIGN_SYSTEM.md)
- Roadmap: [`docs/TASKS.md`](docs/TASKS.md)
- Convenciones para agentes IA: [`AGENTS.md`](AGENTS.md)

## Requisitos

- Flutter (ver `pubspec.yaml` → `environment.sdk`) con soporte de escritorio.
- En Linux, además, el toolchain de escritorio:

  ```bash
  sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev
  ```

- Para generar el `.deb`: `dpkg` (aporta `dpkg-deb`).

> Si `flutter` no está en el `PATH` (habitual cuando el SDK se instaló a mano
> en `~/Documentos/flutter`), agregalo a tu shell:
>
> ```bash
> export PATH="$HOME/Documentos/flutter/bin:$PATH"
> ```
>
> Los scripts de `scripts/` también lo resuelven solos desde esa ubicación, así
> que funcionan sin tocar el `PATH`.

## Desarrollo

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # codegen Drift
flutter analyze
flutter test
```

Ejecutar en cada plataforma:

```bash
flutter run -d linux          # Linux (pruebas locales)
flutter run -d windows        # Windows
flutter run -d <device>       # Android (flutter devices para listar)

./scripts/build.sh run        # igual, pero inyectando commit y fecha de build
```

## Compilación y distribución

### Versionamiento

La versión vive en `pubspec.yaml` con el formato de Flutter
`x.y.z+número de build` (ej: `0.1.0+2`):

- **`x.y.z`** → versión visible para el usuario. Se cambia con los flags del
  script cuando hay cambios importantes.
- **`+N`** → número de build (`versionCode` en Android). Se incrementa en cada
  release.

```sh
# Subir el número de build (0.1.0+2 -> 0.1.0+3)
./scripts/bump-build.sh

# Cambios visibles para el usuario (reinician el número de build en 1)
./scripts/bump-build.sh --patch   # 0.1.0+3 -> 0.1.1+1
./scripts/bump-build.sh --minor   # 0.1.1+1 -> 0.2.0+1
./scripts/bump-build.sh --major   # 0.2.0+1 -> 1.0.0+1
```

La versión se propaga sola a cada plataforma: Android la usa como
`versionName`/`versionCode` y en escritorio Flutter escribe un `version.json`
dentro del bundle. La app la muestra en el diálogo **"Acerca de"** (ícono ⓘ en
la barra superior de Inicio), junto al commit, la fecha de compilación, la
plataforma y el canal.

Los scripts de release (`build-deb.sh` / `build-apk.sh`) invocan el bump
automáticamente antes de compilar. Si querés publicar el `.deb` y el APK con
**el mismo** número de build, compilá el segundo con `--no-bump`. El bump
modifica `pubspec.yaml`: commiteá el cambio junto al release (opcionalmente con
un tag `git tag v0.1.0`).

El commit y la fecha solo aparecen si compilaste con `./scripts/build.sh`
(los inyecta con `--dart-define`). Con `flutter build` directo la app muestra
"No disponible" en esos dos campos; la versión nunca se desincroniza porque
sale del paquete instalado.

### 🐧 Linux — `.deb`

**Requisitos:** toolchain de escritorio (ver Requisitos) y `dpkg`.

```sh
# Compilar y empaquetar (incrementa el número de build, compila y genera el .deb)
./scripts/build-deb.sh

# Variante: empaquetar sin cambiar la versión
./scripts/build-deb.sh --no-bump
```

El paquete queda en `dist/blockday_<versión>_<arquitectura>.deb`.

```sh
# Instalar (apt resuelve las dependencias de runtime)
sudo apt install ./dist/blockday_*_*.deb

# Desinstalar
sudo apt remove blockday
```

El paquete instala el binario y sus librerías en `/opt/blockday/`, un symlink en
`/usr/bin/blockday`, el acceso del menú de aplicaciones
(`/usr/share/applications/blockday.desktop`) y el icono en
`/usr/share/icons/hicolor/192x192/apps/blockday.png`. Las dependencias del
`control` se calculan automáticamente con `readelf` + `dpkg -S` sobre las
librerías que enlaza el bundle, por lo que reflejan la distro donde se compila.

### 🐧 Linux — instalación local (para pruebas rápidas)

Instala en el perfil del usuario, sin `sudo` ni paquete:

```sh
./scripts/build.sh linux-install   # compila y luego instala

# o por separado
./scripts/build.sh linux
./scripts/install-linux.sh

./scripts/install-linux.sh --uninstall
```

Destinos: `~/.local/opt/blockday/`, `~/.local/bin/blockday`,
`~/.local/share/applications/blockday.desktop` e icono en
`~/.local/share/icons/hicolor/`. Si `~/.local/bin` no está en tu `PATH`, el
script te indica cómo agregarlo.

### 🤖 Android — APK

**Requisitos:** Android SDK configurado (`flutter doctor`).

```sh
./scripts/build-apk.sh              # sube el número de build y compila
./scripts/build-apk.sh --no-bump    # compila con la versión actual
```

El instalador queda en `dist/blockday-<versión>-android.apk`.

```sh
adb install dist/blockday-*-android.apk
```

También se puede copiar el APK al teléfono y abrirlo desde el gestor de archivos
(habilitando la instalación de "orígenes desconocidos").

> **Firma:** la release se firma con las llaves de debug (ver
> `android/app/build.gradle.kts`), lo que alcanza para instalar manualmente.
> Para publicar en Google Play hace falta un keystore propio.

### 🪟 Windows

```sh
./scripts/build.sh windows
```

El ejecutable y sus DLL quedan en `build/windows/x64/runner/Release/`; se
distribuye copiando esa carpeta completa.

---

## 🧩 MCP de Dart en OpenCode (opcional)

El **Model Context Protocol (MCP)** permite que un agente de IA (por ejemplo
[OpenCode](https://opencode.ai)) use el SDK de Flutter/Dart como herramienta. El
servidor oficial es `dart mcp-server` e incluye análisis estático/LSP
(`analyze_files`), `dart fix`, `dart format`, `pub`, búsqueda en paquetes
(`read_package_uris`, `rip_grep_packages`) y control de la app en ejecución
(`dtd`, `hot_reload`, `hot_restart`, `get_runtime_errors`).

El cliente lo configura con el archivo **`opencode.json`** en la raíz del
proyecto. Ese archivo está en **`.gitignore`** (no se versiona) porque contiene
rutas absolutas que cambian según el sistema operativo y la máquina de cada
desarrollador. Créalo en tu copia local:

```bash
# Linux / macOS
touch opencode.json    # luego pega el bloque de tu SO con tu editor

# Windows (PowerShell)
ni opencode.json
```

### Requisito previo

El subcomando `mcp-server` viene incluido en el SDK de Dart:

```bash
dart mcp-server --version
```

Si el comando no existe, actualiza Flutter (`flutter upgrade`).

Además el proyecto necesita sus dependencias resueltas (`flutter pub get`);
sin `.dart_tool/package_config.json` el servidor reporta errores falsos del
tipo `Target of URI doesn't exist: 'package:flutter/material.dart'`.

### Windows

En Windows el instalador de Flutter agrega `dart` al `PATH`, por lo que basta
con el nombre del comando:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "dart-mcp-server": {
      "type": "local",
      "command": [
        "dart",
        "mcp-server"
      ],
      "enabled": true
    }
  }
}
```

Comprueba que el binario sea visible desde cualquier terminal:

```cmd
where dart
```

Si no devuelve nada, agrega `C:\ruta\a\flutter\bin` al `PATH` del usuario y
reinicia la terminal (y OpenCode).

### Linux / Ubuntu

En Linux el SDK instalado manualmente (ej. `~/Documentos/flutter`) **no** suele
estar en el `PATH` del sistema, y OpenCode no lee tu `.bashrc`, así que `"dart"`
a secas falla con `NotFound: ChildProcess.spawn (dart mcp-server)`. Hay que usar
la **ruta absoluta** al binario del SDK:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "dart-mcp-server": {
      "type": "local",
      "command": [
        "/ruta/a/tu/flutter/bin/dart",
        "mcp-server"
      ],
      "enabled": true
    }
  }
}
```

Para averiguar tu ruta, si `dart` sí está en el `PATH`:

```bash
command -v dart          # /home/tu-usuario/flutter/bin/dart
```

Si no aparece nada (caso habitual en Ubuntu), busca el SDK:

```bash
find ~ -maxdepth 4 -type f -path "*/flutter/bin/dart"
```

> ✅ Con la ruta absoluta **no** hace falta definir `FLUTTER_ROOT` ni
> `DART_ROOT`: el servidor deduce la raíz de Flutter subiendo desde el SDK de
> Dart.

### Verificar la conexión

1. Reinicia OpenCode (los servidores MCP se levantan al iniciar).
2. Lista el estado:

   ```bash
   opencode mcp list
   # ✓ dart-mcp-server  connected
   ```

3. En los logs (`~/.local/share/opencode/log/opencode.log` en Linux) debe
   aparecer:

   ```
   message="mcp connected" server=dart-mcp-server tools=14
   ```

**Diagnóstico rápido**

| Síntoma | Causa / solución |
|---------|------------------|
| `NotFound: ChildProcess.spawn (dart mcp-server)` | El binario no se encontró → usa ruta absoluta (Linux) o corrige el `PATH` (Windows) |
| `Target of URI doesn't exist: 'package:flutter/...'` | Falta `flutter pub get` (no hay `.dart_tool/`) |
| `✓ ... pending` en `opencode mcp list` | El servidor aún está arrancando (~1-2 s); vuelve a listar |
| El agente no ve las herramientas | La sesión abierta conserva la config anterior → reinicia OpenCode |
