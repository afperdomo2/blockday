# Blockday — Producto

## Visión

Una app de calendario personal, simple y rápida, para planificar el día en
bloques de tiempo: qué hago, cuándo y con qué frecuencia. Funciona 100%
offline en Windows, Android y Linux. Inspirada en la experiencia de Google Calendar
pero centrada en bloques de actividades personales (estudio, trabajo,
hábitos).

## Usuario objetivo

Una persona que organiza su rutina diaria y quiere verla de un vistazo:
bloques recurrentes (rutinas) + eventos puntuales (citas, cursos).

## Historias de usuario (v1)

1. Como usuario, quiero crear una actividad puntual ("Curso virtual" el
   próximo jueves 08:00–10:00) para verla en mi calendario.
2. Como usuario, quiero crear una actividad recurrente ("Buscar trabajo"
   Lun–Vie 17:00–19:00) para no repetirla cada día.
3. Como usuario, quiero definir la repetición por días de la semana y una
   condición de fin: sin fin, hasta una fecha, o N veces.
4. Como usuario, quiero vistas de día, semana y mes para navegar el tiempo.
5. Como usuario, quiero editar o eliminar una actividad (y opcionalmente solo
   una ocurrencia concreta).
6. Como usuario, quiero asignar un color a cada actividad para distinguirlas.
7. Como usuario, quiero que mis datos persistan entre sesiones (SQLite local).

## Alcance v1

- CRUD de actividades puntuales y recurrentes.
- Motor de expansión de ocurrencias por rango de fechas.
- Vistas: día (rejilla horaria), semana, mes.
- Paleta de colores por actividad.
- Exclusiones de ocurrencias individuales (saltarse un día concreto).
- Modo claro/oscuro.

## No-alcance (por ahora)

- Recordatorios/notificaciones push (fase 2).
- Sincronización en la nube / multi-dispositivo.
- Invitados, ubicaciones, videollamadas.
- Eventos de día completo multi-día (v1: la actividad empieza y termina el
  mismo día).
- iOS/Web.

## Experiencia objetivo

- Abrir la app → vista día de hoy con los bloques ya colocados.
- Crear actividad en ≤ 3 toques/clics: título, hora, días de repetición.
- Navegación por gestos (swipe entre días/semanas) y botones de navegación.
- UI fluida: springs, feedback inmediato y tokens de diseño definidos en
  `docs/DESIGN_SYSTEM.md` (ver skill `ui-ux-pro-max`).

## Métricas de éxito (v1)

- Toda la lógica de recurrencia cubierta por tests unitarios.
- `flutter analyze` sin issues.
- Crear/editar/eliminar una actividad sin pérdida de datos.
