import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDayHeader(DateTime date) {
  final fmt = DateFormat("EEEE d 'de' MMMM", 'es');
  final text = fmt.format(date);
  return text[0].toUpperCase() + text.substring(1);
}

String formatHourRange(DateTime start, DateTime end, {bool use24Hour = true}) {
  return '${formatHour(start, use24Hour: use24Hour)} – ${formatHour(end, use24Hour: use24Hour)}';
}

String formatHour(DateTime date, {bool use24Hour = true}) {
  final pattern = use24Hour ? 'HH:mm' : 'h:mm a';
  return DateFormat(pattern, 'es').format(date);
}

String formatTimeOfDay(TimeOfDay time, {bool use24Hour = true}) {
  return formatHour(
    DateTime(2000, 1, 1, time.hour, time.minute),
    use24Hour: use24Hour,
  );
}

String formatHourLabel(int hour, {bool use24Hour = true}) {
  if (use24Hour) return '${hour.toString().padLeft(2, '0')}:00';
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  return '$h12 ${hour < 12 ? 'a. m.' : 'p. m.'}';
}

String formatDayShort(DateTime date) {
  final f = DateFormat('EEE d MMM', 'es');
  final text = f.format(date);
  return text[0].toUpperCase() + text.substring(1);
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
