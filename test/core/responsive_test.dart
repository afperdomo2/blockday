import 'package:blockday/core/responsive/app_breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBreakpoints.of', () {
    test('compact por debajo de 600', () {
      expect(AppBreakpoints.of(0), WindowSize.compact);
      expect(AppBreakpoints.of(375), WindowSize.compact);
      expect(AppBreakpoints.of(599.9), WindowSize.compact);
    });

    test('medium entre 600 y 1023', () {
      expect(AppBreakpoints.of(600), WindowSize.medium);
      expect(AppBreakpoints.of(768), WindowSize.medium);
      expect(AppBreakpoints.of(1023.9), WindowSize.medium);
    });

    test('expanded desde 1024', () {
      expect(AppBreakpoints.of(1024), WindowSize.expanded);
      expect(AppBreakpoints.of(1440), WindowSize.expanded);
      expect(AppBreakpoints.of(2560), WindowSize.expanded);
    });
  });
}
