const int kDragSnapStepMinutes = 15;
const int kDragMinRangeMinutes = 15;
const int kDayEndMinutes = 1439;

int minutesFromOffset(double dy, double hourHeight) {
  final minutes = (dy / hourHeight * 60).round();
  return minutes.clamp(0, kDayEndMinutes);
}

int snapMinutes(int minutes, {int step = kDragSnapStepMinutes}) {
  final snapped = (minutes / step).round() * step;
  return snapped.clamp(0, kDayEndMinutes);
}

(int, int) normalizeRange(int a, int b) {
  var lo = snapMinutes(a);
  var hi = snapMinutes(b);
  if (lo > hi) {
    final tmp = lo;
    lo = hi;
    hi = tmp;
  }
  if (hi - lo < kDragMinRangeMinutes) {
    hi = lo + kDragMinRangeMinutes;
    if (hi > kDayEndMinutes) {
      hi = kDayEndMinutes;
      lo = kDayEndMinutes - kDragMinRangeMinutes;
    }
  }
  return (lo, hi);
}
