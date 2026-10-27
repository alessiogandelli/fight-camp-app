// Per-kilometre splits derived from HealthKit distance samples. No raw GPS
// route is stored: this works for outdoor runs and treadmills alike.
import 'health_source.dart';

class KmSplit {
  final int index;
  final int startMs;
  final int endMs;
  final double distanceKm;
  final int durationSec;
  final int? avgHr;

  const KmSplit({
    required this.index,
    required this.startMs,
    required this.endMs,
    required this.distanceKm,
    required this.durationSec,
    required this.avgHr,
  });

  int get paceSecPerKm => (durationSec / distanceKm).round();
  bool get isComplete => distanceKm >= 0.999;
}

List<KmSplit> computeKmSplits({
  required List<DistanceSample> samples,
  required int workoutStart,
  required int workoutEnd,
  List<HeartSample> hrSamples = const [],
}) {
  final valid = <DistanceSample>[
    for (final sample in samples)
      if (sample.meters > 0 && sample.end > sample.start)
        DistanceSample(
          sample.start.clamp(workoutStart, workoutEnd).toInt(),
          sample.end.clamp(workoutStart, workoutEnd).toInt(),
          sample.meters,
        ),
  ]..removeWhere((s) => s.end <= s.start);
  valid.sort((a, b) => a.start.compareTo(b.start));
  if (valid.isEmpty) return const [];

  final totalMeters = valid.fold<double>(0, (sum, s) => sum + s.meters);
  if (totalMeters < 50) return const [];

  var splitStart = valid.first.start;
  var cumulative = 0.0;
  var nextBoundary = 1000.0;
  final out = <KmSplit>[];

  void addSplit(int start, int end, double distanceMeters) {
    if (end <= start || distanceMeters <= 0) return;
    final seconds = ((end - start) / 1000).round();
    if (seconds <= 0) return;
    final km = distanceMeters / 1000;
    out.add(
      KmSplit(
        index: out.length + 1,
        startMs: start,
        endMs: end,
        distanceKm: km,
        durationSec: seconds,
        avgHr: _averageHr(hrSamples, start, end),
      ),
    );
  }

  for (final sample in valid) {
    final durationMs = sample.end - sample.start;
    if (durationMs <= 0) continue;
    var startMeters = cumulative;
    final endMeters = cumulative + sample.meters;
    while (endMeters >= nextBoundary) {
      final fraction = (nextBoundary - startMeters) / sample.meters;
      final boundaryMs = sample.start + (fraction * durationMs).round();
      addSplit(splitStart, boundaryMs, 1000);
      splitStart = boundaryMs;
      nextBoundary += 1000;
      startMeters = nextBoundary - 1000;
    }
    cumulative = endMeters;
  }

  final partialMeters = totalMeters - (nextBoundary - 1000);
  if (partialMeters >= 50) {
    addSplit(splitStart, valid.last.end, partialMeters);
  }
  return out;
}

int? _averageHr(List<HeartSample> samples, int start, int end) {
  var sum = 0;
  var count = 0;
  for (final sample in samples) {
    if (sample.ms < start || sample.ms > end) continue;
    sum += sample.bpm;
    count++;
  }
  return count == 0 ? null : (sum / count).round();
}
