// Karvonen heart-rate zones, computed from the stored HR series. We ask the
// user for max/resting HR instead of inventing a 220-age estimate.
import 'health_source.dart';

class HrZone {
  final int index;
  final int minBpm;
  final int maxBpm;
  final int seconds;

  const HrZone({
    required this.index,
    required this.minBpm,
    required this.maxBpm,
    required this.seconds,
  });
}

List<HrZone> computeKarvonenZones({
  required List<HeartSample> samples,
  required int maxHr,
  required int restingHr,
}) {
  if (samples.isEmpty || maxHr <= restingHr || restingHr <= 0) return const [];
  final reserve = maxHr - restingHr;
  final bounds = [
    restingHr + (reserve * 0.5).round(),
    restingHr + (reserve * 0.6).round(),
    restingHr + (reserve * 0.7).round(),
    restingHr + (reserve * 0.8).round(),
    restingHr + (reserve * 0.9).round(),
  ];
  final seconds = List<int>.filled(5, 0);
  final sorted = [...samples]..sort((a, b) => a.ms.compareTo(b.ms));

  for (var i = 0; i < sorted.length; i++) {
    final sample = sorted[i];
    final gap = i + 1 < sorted.length ? sorted[i + 1].ms - sample.ms : 10000;
    final weightMs = gap.clamp(1000, 30000);
    if (sample.bpm < bounds[0]) continue;
    var zone = 4;
    for (var z = 0; z < 4; z++) {
      if (sample.bpm < bounds[z + 1]) {
        zone = z;
        break;
      }
    }
    seconds[zone] += (weightMs / 1000).round();
  }

  return [
    for (var i = 0; i < 5; i++)
      HrZone(
        index: i + 1,
        minBpm: i == 0 ? bounds[0] : bounds[i],
        maxBpm: i == 4 ? maxHr : bounds[i + 1] - 1,
        seconds: seconds[i],
      ),
  ];
}

int? maxObservedHr(List<HeartSample> samples) {
  int? max;
  for (final sample in samples) {
    if (max == null || sample.bpm > max) max = sample.bpm;
  }
  return max;
}
