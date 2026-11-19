import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

abstract class SettingsStore {
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);
}

class SharedPrefsSettingsStore implements SettingsStore {
  static const String _themeKey = 'settings.themePreference';
  static const String _weekStartKey = 'settings.weekStart';
  static const String _hourFormatKey = 'settings.use24HourFormat';

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      themePreference:
          ThemePreference.values.asNameMap()[prefs.getString(_themeKey)] ??
          ThemePreference.system,
      weekStart:
          WeekStart.values.asNameMap()[prefs.getString(_weekStartKey)] ??
          WeekStart.monday,
      use24HourFormat: prefs.getBool(_hourFormatKey) ?? true,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, settings.themePreference.name);
    await prefs.setString(_weekStartKey, settings.weekStart.name);
    await prefs.setBool(_hourFormatKey, settings.use24HourFormat);
  }
}

class InMemorySettingsStore implements SettingsStore {
  InMemorySettingsStore([AppSettings? initial])
    : _settings = initial ?? AppSettings.defaults;

  AppSettings _settings;

  AppSettings get current => _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }
}
