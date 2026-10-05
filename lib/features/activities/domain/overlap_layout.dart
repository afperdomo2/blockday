import 'occurrence.dart';

class LaidOutOccurrence {
  const LaidOutOccurrence({
    required this.occurrence,
    required this.column,
    required this.totalColumns,
  });

  final Occurrence occurrence;
  final int column;
  final int totalColumns;

  @override
  bool operator ==(Object other) =>
      other is LaidOutOccurrence &&
      occurrence == other.occurrence &&
      column == other.column &&
      totalColumns == other.totalColumns;

  @override
  int get hashCode => Object.hash(occurrence, column, totalColumns);

  @override
  String toString() => 'LaidOutOccurrence($occurrence $column/$totalColumns)';
}

int _startMinutes(Occurrence o) => o.start.hour * 60 + o.start.minute;

int _endMinutes(Occurrence o) => o.end.hour * 60 + o.end.minute;

/// Agrupa ocurrencias que se pisan (transitivamente) y les asigna columnas
/// paralelas para render lado a lado.
///
/// Los intervalos son [start, end): dos bloques que se tocan en un borde
/// exacto (9-10 y 10-11) no se consideran solapados.
List<LaidOutOccurrence> layoutOverlaps(List<Occurrence> occurrences) {
  if (occurrences.isEmpty) return const [];

  final sorted = [...occurrences]
    ..sort((a, b) {
      final byStart = _startMinutes(a).compareTo(_startMinutes(b));
      if (byStart != 0) return byStart;
      return _endMinutes(b).compareTo(_endMinutes(a));
    });

  final result = <LaidOutOccurrence>[];
  var cluster = <Occurrence>[];
  var clusterEnd = 0;

  void flush() {
    if (cluster.isEmpty) return;
    final columnEnds = <int, int>{};
    for (final occ in cluster) {
      final start = _startMinutes(occ);
      final end = _endMinutes(occ);
      var column = 0;
      while (true) {
        final busyUntil = columnEnds[column];
        if (busyUntil == null || busyUntil <= start) {
          columnEnds[column] = end;
          result.add(
            LaidOutOccurrence(
              occurrence: occ,
              column: column,
              totalColumns: columnEnds.length,
            ),
          );
          break;
        }
        column++;
      }
    }
    final total = columnEnds.length;
    for (var i = result.length - cluster.length; i < result.length; i++) {
      final item = result[i];
      result[i] = LaidOutOccurrence(
        occurrence: item.occurrence,
        column: item.column,
        totalColumns: total,
      );
    }
    cluster = [];
  }

  for (final occ in sorted) {
    if (cluster.isNotEmpty && _startMinutes(occ) >= clusterEnd) {
      flush();
      clusterEnd = 0;
    }
    cluster.add(occ);
    clusterEnd = clusterEnd > _endMinutes(occ) ? clusterEnd : _endMinutes(occ);
  }
  flush();

  return result;
}
