import 'package:blockday/features/settings/data/settings_store.dart';
import 'package:blockday/features/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('InMemorySettingsStore', () {
    test('load devuelve el valor inicial', () async {
      final store = InMemorySettingsStore(
        const AppSettings(use24HourFormat: false),
      );
      expect(await store.load(), const AppSettings(use24HourFormat: false));
    });

    test('save persiste el valor', () async {
      final store = InMemorySettingsStore();
      const updated = AppSettings(
        themePreference: ThemePreference.dark,
        weekStart: WeekStart.sunday,
        use24HourFormat: false,
      );
      await store.save(updated);
      expect(await store.load(), updated);
    });
  });

  group('SharedPrefsSettingsStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('sin preferencias guardadas devuelve defaults', () async {
      final store = SharedPrefsSettingsStore();
      expect(await store.load(), AppSettings.defaults);
    });

    test('round-trip save → load', () async {
      final store = SharedPrefsSettingsStore();
      const updated = AppSettings(
        themePreference: ThemePreference.light,
        weekStart: WeekStart.sunday,
        use24HourFormat: false,
      );
      await store.save(updated);
      expect(await store.load(), updated);
    });
  });
}
