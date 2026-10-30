// Pace over time, derived from the stored distance intervals. The heart-rate
// chart draws it on a second, inverted axis; no GPS route is stored.
import 'health_source.dart';

class PacePoint {
  final int ms;

  /// Seconds per kilometre over the window ending at [ms].
  final int secPerKm;

  const PacePoint(this.ms, this.secPerKm);
}

/// Rolling pace from [DistanceSample]s, sampled every [stepMs] over a
/// [windowMs] window. Windows with too little distance (standing still) are
/// skipped, so the line only shows while actually moving.
List<PacePoint> computePaceSeries({
  required List<DistanceSample> samples,
  required int start,
  required int end,
  int windowMs = 60 * 1000,
  int stepMs = 15 * 1000,
  double minKm = 0.03,
}) {
  if (samples.isEmpty || end <= start || windowMs <= 0) return const [];
  final valid = <DistanceSample>[
    for (final sample in samples)
      if (sample.meters > 0 && sample.end > sample.start)
        DistanceSample(
          sample.start.clamp(start, end).toInt(),
          sample.end.clamp(start, end).toInt(),
          sample.meters,
        ),
  ]..removeWhere((sample) => sample.end <= sample.start);
  if (valid.isEmpty) return const [];
  valid.sort((a, b) => a.start.compareTo(b.start));

  // Cumulative distance curve: hold the value between intervals.
  final times = <int>[];
  final meters = <double>[];
  var cumulative = 0.0;
  for (final sample in valid) {
    times.add(sample.start);
    meters.add(cumulative);
    cumulative += sample.meters;
    times.add(sample.end);
    meters.add(cumulative);
  }

  final out = <PacePoint>[];
  for (var t = start + windowMs; t <= end; t += stepMs) {
    final before = _cumulativeAt(times, meters, t - windowMs);
    final now = _cumulativeAt(times, meters, t);
    final km = (now - before) / 1000;
    if (km < minKm) continue;
    final secPerKm = ((windowMs / 1000) / km).round().clamp(120, 1500);
    out.add(PacePoint(t, secPerKm));
  }
  return out;
}

double _cumulativeAt(List<int> times, List<double> meters, int t) {
  if (t <= times.first) return meters.first;
  if (t >= times.last) return meters.last;
  var lo = 0;
  var hi = times.length - 1;
  while (lo < hi) {
    final mid = (lo + hi + 1) >> 1;
    if (times[mid] <= t) {
      lo = mid;
    } else {
      hi = mid - 1;
    }
  }
  final t0 = times[lo];
  final m0 = meters[lo];
  if (lo + 1 >= times.length) return m0;
  final t1 = times[lo + 1];
  final m1 = meters[lo + 1];
  if (t1 <= t0) return m0;
  final fraction = (t - t0) / (t1 - t0);
  return m0 + (m1 - m0) * fraction;
}
