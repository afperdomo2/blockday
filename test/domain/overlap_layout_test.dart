import 'package:blockday/features/activities/domain/occurrence.dart';
import 'package:blockday/features/activities/domain/overlap_layout.dart';
import 'package:flutter_test/flutter_test.dart';

Occurrence occ({
  required String id,
  required int startHour,
  required int startMinute,
  required int endHour,
  required int endMinute,
}) {
  final date = DateTime(2025, 1, 6);
  return Occurrence(
    activityId: id,
    title: id,
    color: 0,
    date: date,
    start: DateTime(date.year, date.month, date.day, startHour, startMinute),
    end: DateTime(date.year, date.month, date.day, endHour, endMinute),
  );
}

void main() {
  test('empty list returns empty', () {
    expect(layoutOverlaps(const []), isEmpty);
  });

  test('single occurrence occupies full width', () {
    final result = layoutOverlaps([
      occ(id: 'a', startHour: 9, startMinute: 0, endHour: 10, endMinute: 0),
    ]);
    expect(result, hasLength(1));
    expect(result.single.column, 0);
    expect(result.single.totalColumns, 1);
  });

  test('two overlapping occurrences get two columns', () {
    final result = layoutOverlaps([
      occ(id: 'a', startHour: 9, startMinute: 0, endHour: 11, endMinute: 0),
      occ(id: 'b', startHour: 10, startMinute: 0, endHour: 12, endMinute: 0),
    ]);
    expect(result, hasLength(2));
    expect(result[0].column, 0);
    expect(result[0].totalColumns, 2);
    expect(result[1].column, 1);
    expect(result[1].totalColumns, 2);
  });

  test('three simultaneous occurrences get three columns', () {
    final result = layoutOverlaps([
      occ(id: 'a', startHour: 9, startMinute: 0, endHour: 12, endMinute: 0),
      occ(id: 'b', startHour: 9, startMinute: 0, endHour: 12, endMinute: 0),
      occ(id: 'c', startHour: 9, startMinute: 0, endHour: 12, endMinute: 0),
    ]);
    expect(result, hasLength(3));
    expect(result.map((e) => e.column).toList(), [0, 1, 2]);
    expect(result.every((e) => e.totalColumns == 3), isTrue);
  });

  test('chained overlaps share one cluster of two columns', () {
    final result = layoutOverlaps([
      occ(id: 'a', startHour: 9, startMinute: 0, endHour: 11, endMinute: 0),
      occ(id: 'b', startHour: 10, startMinute: 0, endHour: 12, endMinute: 0),
      occ(id: 'c', startHour: 11, startMinute: 0, endHour: 13, endMinute: 0),
    ]);
    expect(result, hasLength(3));
    expect(result.every((e) => e.totalColumns == 2), isTrue);
    expect(result[0].column, 0);
    expect(result[1].column, 1);
    expect(result[2].column, 0);
  });

  test('touching edges do not overlap', () {
    final result = layoutOverlaps([
      occ(id: 'a', startHour: 9, startMinute: 0, endHour: 10, endMinute: 0),
      occ(id: 'b', startHour: 10, startMinute: 0, endHour: 11, endMinute: 0),
    ]);
    expect(result, hasLength(2));
    expect(result.every((e) => e.totalColumns == 1), isTrue);
    expect(result.every((e) => e.column == 0), isTrue);
  });

  test('same start with different end gets separate columns', () {
    final result = layoutOverlaps([
      occ(id: 'a', startHour: 9, startMinute: 0, endHour: 12, endMinute: 0),
      occ(id: 'b', startHour: 9, startMinute: 0, endHour: 10, endMinute: 0),
    ]);
    expect(result[0].column, 0);
    expect(result[1].column, 1);
    expect(result[0].totalColumns, 2);
  });

  test('contained occurrence gets its own column', () {
    final result = layoutOverlaps([
      occ(id: 'outer', startHour: 8, startMinute: 0, endHour: 18, endMinute: 0),
      occ(
        id: 'inner',
        startHour: 10,
        startMinute: 0,
        endHour: 11,
        endMinute: 0,
      ),
    ]);
    expect(result, hasLength(2));
    expect(result[0].column, 0);
    expect(result[1].column, 1);
    expect(result.every((e) => e.totalColumns == 2), isTrue);
  });

  test('input order does not change the layout', () {
    final a = occ(
      id: 'a',
      startHour: 9,
      startMinute: 0,
      endHour: 11,
      endMinute: 0,
    );
    final b = occ(
      id: 'b',
      startHour: 9,
      startMinute: 30,
      endHour: 10,
      endMinute: 30,
    );
    final c = occ(
      id: 'c',
      startHour: 12,
      startMinute: 0,
      endHour: 13,
      endMinute: 0,
    );

    final forward = layoutOverlaps([a, b, c]);
    final reversed = layoutOverlaps([c, b, a]);

    expect(
      forward.map((e) => e.occurrence.activityId).toList(),
      reversed.map((e) => e.occurrence.activityId).toList(),
    );
    expect(
      forward.map((e) => e.column).toList(),
      reversed.map((e) => e.column).toList(),
    );
    expect(
      forward.map((e) => e.totalColumns).toList(),
      reversed.map((e) => e.totalColumns).toList(),
    );
  });

  test('separate clusters reset column count', () {
    final result = layoutOverlaps([
      occ(id: 'a', startHour: 9, startMinute: 0, endHour: 11, endMinute: 0),
      occ(id: 'b', startHour: 10, startMinute: 0, endHour: 12, endMinute: 0),
      occ(id: 'c', startHour: 15, startMinute: 0, endHour: 16, endMinute: 0),
    ]);
    expect(result, hasLength(3));
    expect(result[0].totalColumns, 2);
    expect(result[1].totalColumns, 2);
    expect(result[2].column, 0);
    expect(result[2].totalColumns, 1);
  });

  test('null duration or zero-length occurrence keeps single column', () {
    final result = layoutOverlaps([
      occ(id: 'a', startHour: 9, startMinute: 0, endHour: 10, endMinute: 0),
      occ(id: 'b', startHour: 10, startMinute: 0, endHour: 11, endMinute: 0),
      occ(id: 'c', startHour: 11, startMinute: 0, endHour: 12, endMinute: 0),
    ]);
    expect(result.every((e) => e.totalColumns == 1), isTrue);
    expect(result.every((e) => e.column == 0), isTrue);
  });
}
