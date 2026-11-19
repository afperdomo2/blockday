import 'package:blockday/core/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  group('formatHour', () {
    test('24h', () {
      expect(
        formatHour(DateTime(2026, 11, 18, 9, 5), use24Hour: true),
        '09:05',
      );
    });

    test('12h', () {
      expect(
        formatHour(DateTime(2026, 11, 18, 13, 5), use24Hour: false),
        contains('1:05'),
      );
    });
  });

  group('formatHourLabel', () {
    test('24h', () {
      expect(formatHourLabel(0), '00:00');
      expect(formatHourLabel(9), '09:00');
      expect(formatHourLabel(23), '23:00');
    });

    test('12h', () {
      expect(formatHourLabel(0, use24Hour: false), '12 a. m.');
      expect(formatHourLabel(9, use24Hour: false), '9 a. m.');
      expect(formatHourLabel(12, use24Hour: false), '12 p. m.');
      expect(formatHourLabel(23, use24Hour: false), '11 p. m.');
    });
  });

  group('formatTimeOfDay', () {
    test('24h', () {
      expect(formatTimeOfDay(const TimeOfDay(hour: 17, minute: 30)), '17:30');
    });

    test('12h', () {
      expect(
        formatTimeOfDay(
          const TimeOfDay(hour: 17, minute: 30),
          use24Hour: false,
        ),
        contains('5:30'),
      );
    });
  });
}
