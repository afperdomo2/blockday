import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CalendarView { day, week, month }

class CalendarState {
  const CalendarState({
    required this.selectedDate,
    this.view = CalendarView.day,
  });

  final DateTime selectedDate;
  final CalendarView view;

  CalendarState copyWith({DateTime? selectedDate, CalendarView? view}) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      view: view ?? this.view,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CalendarState &&
      selectedDate.year == other.selectedDate.year &&
      selectedDate.month == other.selectedDate.month &&
      selectedDate.day == other.selectedDate.day &&
      view == other.view;

  @override
  int get hashCode => Object.hash(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    view,
  );
}

class CalendarStateNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final now = DateTime.now();
    return CalendarState(selectedDate: DateTime(now.year, now.month, now.day));
  }

  void goTo(DateTime date) {
    state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
    );
  }

  void nextDay() {
    final d = state.selectedDate;
    goTo(DateTime(d.year, d.month, d.day + 1));
  }

  void previousDay() {
    final d = state.selectedDate;
    goTo(DateTime(d.year, d.month, d.day - 1));
  }

  void today() {
    final now = DateTime.now();
    goTo(DateTime(now.year, now.month, now.day));
  }

  void setView(CalendarView view) {
    state = state.copyWith(view: view);
  }
}

final calendarStateProvider =
    NotifierProvider<CalendarStateNotifier, CalendarState>(
      CalendarStateNotifier.new,
    );
