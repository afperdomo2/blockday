import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_store.dart';
import '../domain/app_settings.dart';

final settingsStoreProvider = Provider<SettingsStore>((ref) {
  return SharedPrefsSettingsStore();
});

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    try {
      return await ref.watch(settingsStoreProvider).load();
    } catch (_) {
      return AppSettings.defaults;
    }
  }

  Future<void> _update(AppSettings Function(AppSettings) change) async {
    final updated = change(state.value ?? AppSettings.defaults);
    state = AsyncData(updated);
    try {
      await ref.read(settingsStoreProvider).save(updated);
    } catch (_) {}
  }

  Future<void> setThemePreference(ThemePreference value) {
    return _update((s) => s.copyWith(themePreference: value));
  }

  Future<void> setWeekStart(WeekStart value) {
    return _update((s) => s.copyWith(weekStart: value));
  }

  Future<void> setUse24HourFormat(bool value) {
    return _update((s) => s.copyWith(use24HourFormat: value));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

final currentSettingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(settingsProvider).value ?? AppSettings.defaults;
});
