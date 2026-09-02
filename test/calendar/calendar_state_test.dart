import 'package:blockday/features/calendar/providers/calendar_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarStateNotifier', () {
    test('initial state is today', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(calendarStateProvider);
      final now = DateTime.now();
      expect(state.selectedDate.year, now.year);
      expect(state.selectedDate.month, now.month);
      expect(state.selectedDate.day, now.day);
      expect(state.view, CalendarView.day);
    });

    test('goTo updates date normalized', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(calendarStateProvider.notifier);
      notifier.goTo(DateTime(2025, 1, 15, 23, 59));
      expect(
        container.read(calendarStateProvider).selectedDate,
        DateTime(2025, 1, 15),
      );
    });

    test('nextDay and previousDay', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(calendarStateProvider.notifier);
      notifier.goTo(DateTime(2025, 1, 15));
      notifier.nextDay();
      expect(
        container.read(calendarStateProvider).selectedDate,
        DateTime(2025, 1, 16),
      );
      notifier.previousDay();
      notifier.previousDay();
      expect(
        container.read(calendarStateProvider).selectedDate,
        DateTime(2025, 1, 14),
      );
    });

    test('today resets to now', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(calendarStateProvider.notifier);
      notifier.goTo(DateTime(2000, 1, 1));
      notifier.today();
      final now = DateTime.now();
      expect(
        container.read(calendarStateProvider).selectedDate,
        DateTime(now.year, now.month, now.day),
      );
    });

    test('setView updates view', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(calendarStateProvider.notifier);
      notifier.setView(CalendarView.week);
      expect(container.read(calendarStateProvider).view, CalendarView.week);
      notifier.setView(CalendarView.month);
      expect(container.read(calendarStateProvider).view, CalendarView.month);
    });

    test('month boundary navigation', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(calendarStateProvider.notifier);
      notifier.goTo(DateTime(2025, 1, 31));
      notifier.nextDay();
      expect(
        container.read(calendarStateProvider).selectedDate,
        DateTime(2025, 2, 1),
      );
      notifier.goTo(DateTime(2025, 3, 1));
      notifier.previousDay();
      expect(
        container.read(calendarStateProvider).selectedDate,
        DateTime(2025, 2, 28),
      );
    });

    test('leap year navigation', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(calendarStateProvider.notifier);
      notifier.goTo(DateTime(2024, 2, 28));
      notifier.nextDay();
      expect(
        container.read(calendarStateProvider).selectedDate,
        DateTime(2024, 2, 29),
      );
      notifier.nextDay();
      expect(
        container.read(calendarStateProvider).selectedDate,
        DateTime(2024, 3, 1),
      );
    });
  });
}
