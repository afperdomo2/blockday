import 'package:intl/intl.dart';

String formatDayHeader(DateTime date) {
  final fmt = DateFormat("EEEE d 'de' MMMM", 'es');
  final text = fmt.format(date);
  return text[0].toUpperCase() + text.substring(1);
}

String formatHourRange(DateTime start, DateTime end) {
  final f = DateFormat('HH:mm', 'es');
  return '${f.format(start)} – ${f.format(end)}';
}

String formatHour(DateTime date) {
  return DateFormat('HH:mm', 'es').format(date);
}

String formatDayShort(DateTime date) {
  final f = DateFormat('EEE d MMM', 'es');
  final text = f.format(date);
  return text[0].toUpperCase() + text.substring(1);
}
