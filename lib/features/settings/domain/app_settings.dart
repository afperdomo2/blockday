enum ThemePreference { system, light, dark }

enum WeekStart { monday, sunday }

class AppSettings {
  const AppSettings({
    this.themePreference = ThemePreference.system,
    this.weekStart = WeekStart.monday,
    this.use24HourFormat = true,
  });

  static const AppSettings defaults = AppSettings();

  final ThemePreference themePreference;
  final WeekStart weekStart;
  final bool use24HourFormat;

  AppSettings copyWith({
    ThemePreference? themePreference,
    WeekStart? weekStart,
    bool? use24HourFormat,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      weekStart: weekStart ?? this.weekStart,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      themePreference == other.themePreference &&
      weekStart == other.weekStart &&
      use24HourFormat == other.use24HourFormat;

  @override
  int get hashCode => Object.hash(themePreference, weekStart, use24HourFormat);

  @override
  String toString() =>
      'AppSettings(theme:$themePreference, weekStart:$weekStart, 24h:$use24HourFormat)';
}

int weekStartWeekday(WeekStart weekStart) =>
    weekStart == WeekStart.monday ? DateTime.monday : DateTime.sunday;

DateTime startOfWeek(DateTime date, WeekStart weekStart) {
  final d = DateTime(date.year, date.month, date.day);
  final offset = (d.weekday - weekStartWeekday(weekStart) + 7) % 7;
  return DateTime(d.year, d.month, d.day - offset);
}
