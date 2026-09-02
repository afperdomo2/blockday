# Blockday

Calendario personal de bloques de tiempo para **Windows y Android**, hecho
con Flutter. Planifica actividades diarias (p. ej. "Buscar trabajo"
Lun–Vie 17:00–19:00) y eventos puntuales (p. ej. "Curso virtual" el próximo
jueves 08:00), con reglas de repetición flexibles.

- Producto: [`docs/PRODUCT.md`](docs/PRODUCT.md)
- Arquitectura: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- Roadmap: [`docs/TASKS.md`](docs/TASKS.md)
- Convenciones para agentes IA: [`AGENTS.md`](AGENTS.md)

## Desarrollo

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # codegen Drift
flutter analyze
flutter test
flutter run -d windows
```
