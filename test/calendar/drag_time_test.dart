import 'package:blockday/features/calendar/domain/drag_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('minutesFromOffset', () {
    test('converts pixel offset to minutes at hourHeight 60', () {
      expect(minutesFromOffset(0, 60), 0);
      expect(minutesFromOffset(90, 60), 90);
      expect(minutesFromOffset(630, 60), 630);
      expect(minutesFromOffset(33, 60), 33);
    });

    test('converts pixel offset at hourHeight 48', () {
      expect(minutesFromOffset(120, 48), 150);
    });

    test('clamps to day bounds', () {
      expect(minutesFromOffset(-50, 60), 0);
      expect(minutesFromOffset(1500, 60), 1439);
    });
  });

  group('snapMinutes', () {
    test('snaps to nearest 15-minute step', () {
      expect(snapMinutes(0), 0);
      expect(snapMinutes(7), 0);
      expect(snapMinutes(8), 15);
      expect(snapMinutes(60), 60);
      expect(snapMinutes(67), 60);
      expect(snapMinutes(68), 75);
    });

    test('clamps to day bounds', () {
      expect(snapMinutes(-30), 0);
      expect(snapMinutes(1435), 1439);
      expect(snapMinutes(1439), 1439);
      expect(snapMinutes(1500), 1439);
    });

    test('supports custom step', () {
      expect(snapMinutes(45, step: 30), 60);
      expect(snapMinutes(20, step: 30), 30);
      expect(snapMinutes(10, step: 30), 0);
    });
  });

  group('normalizeRange', () {
    test('keeps a valid range', () {
      expect(normalizeRange(480, 600), (480, 600));
    });

    test('orders inverted drag', () {
      expect(normalizeRange(600, 480), (480, 600));
    });

    test('enforces minimum duration', () {
      expect(normalizeRange(600, 600), (600, 615));
      expect(normalizeRange(600, 605), (600, 615));
    });

    test('min duration near midnight shifts start back', () {
      expect(normalizeRange(1439, 1439), (1424, 1439));
    });

    test('snaps both edges', () {
      expect(normalizeRange(601, 691), (600, 690));
      expect(normalizeRange(691, 601), (600, 690));
    });
  });
}
