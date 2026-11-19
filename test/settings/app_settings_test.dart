import 'package:blockday/features/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettings', () {
    test('defaults', () {
      const s = AppSettings();
      expect(s.themePreference, ThemePreference.system);
      expect(s.weekStart, WeekStart.monday);
      expect(s.use24HourFormat, true);
    });

    test('copyWith reemplaza solo lo indicado', () {
      const s = AppSettings();
      final updated = s.copyWith(themePreference: ThemePreference.dark);
      expect(updated.themePreference, ThemePreference.dark);
      expect(updated.weekStart, WeekStart.monday);
      expect(updated.use24HourFormat, true);
    });

    test('igualdad por valor', () {
      expect(
        const AppSettings(themePreference: ThemePreference.light),
        const AppSettings(themePreference: ThemePreference.light),
      );
      expect(
        const AppSettings(),
        isNot(const AppSettings(use24HourFormat: false)),
      );
    });
  });

  group('startOfWeek', () {
    test('lunes: domingo cae en la semana anterior', () {
      final sunday = DateTime(2026, 11, 15);
      expect(startOfWeek(sunday, WeekStart.monday), DateTime(2026, 11, 9));
    });

    test('lunes: el propio lunes no se mueve', () {
      final monday = DateTime(2026, 11, 9);
      expect(startOfWeek(monday, WeekStart.monday), monday);
    });

    test('domingo: el propio domingo no se mueve', () {
      final sunday = DateTime(2026, 11, 15);
      expect(startOfWeek(sunday, WeekStart.sunday), sunday);
    });

    test('domingo: lunes cae el domingo anterior', () {
      final monday = DateTime(2026, 11, 9);
      expect(startOfWeek(monday, WeekStart.sunday), DateTime(2026, 11, 8));
    });

    test('mantiene la hora en 00:00', () {
      final d = DateTime(2026, 11, 18, 15, 30);
      final start = startOfWeek(d, WeekStart.monday);
      expect(start.hour, 0);
      expect(start.minute, 0);
    });
  });
}
