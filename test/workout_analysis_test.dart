import 'package:fight_camp/health/health_source.dart';
import 'package:fight_camp/health/hr_zones.dart';
import 'package:fight_camp/health/splits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const start = 1700000000000;
  const minute = 60 * 1000;

  test('distance intervals become complete km splits with pace', () {
    final splits = computeKmSplits(
      samples: const [
        DistanceSample(start, start + 5 * minute, 1000),
        DistanceSample(start + 5 * minute, start + 10 * minute, 1000),
      ],
      workoutStart: start,
      workoutEnd: start + 10 * minute,
    );
    expect(splits, hasLength(2));
    expect(splits.first.distanceKm, 1);
    expect(splits.first.durationSec, 300);
    expect(splits.first.paceSecPerKm, 300);
    expect(splits.first.isComplete, isTrue);
  });

  test('a trailing partial split is labelled as partial', () {
    final splits = computeKmSplits(
      samples: const [
        DistanceSample(start, start + 5 * minute, 1000),
        DistanceSample(start + 5 * minute, start + 8 * minute, 500),
      ],
      workoutStart: start,
      workoutEnd: start + 8 * minute,
    );
    expect(splits, hasLength(2));
    expect(splits.last.isComplete, isFalse);
    expect(splits.last.distanceKm, closeTo(0.5, 0.001));
  });

  test('splits average the HR samples inside each km', () {
    final splits = computeKmSplits(
      samples: const [DistanceSample(start, start + 10 * minute, 1000)],
      workoutStart: start,
      workoutEnd: start + 10 * minute,
      hrSamples: const [
        HeartSample(start + 1 * minute, 120),
        HeartSample(start + 2 * minute, 140),
      ],
    );
    expect(splits.single.avgHr, 130);
  });

  test('Karvonen zones use heart-rate reserve boundaries', () {
    final zones = computeKarvonenZones(
      samples: const [
        HeartSample(start, 120), // below 50%
        HeartSample(start + 10000, 130), // zone 1
        HeartSample(start + 20000, 140), // zone 2
        HeartSample(start + 30000, 160), // zone 4
        HeartSample(start + 40000, 180), // zone 5
      ],
      maxHr: 190,
      restingHr: 60,
    );
    expect(zones[0].minBpm, 125);
    expect(zones[0].seconds, 10);
    expect(zones[1].seconds, 10);
    expect(zones[2].seconds, 10);
    expect(zones[3].seconds, 0);
    expect(zones[4].seconds, 10);
  });

  test('zones are unavailable without valid Karvonen inputs', () {
    expect(
      computeKarvonenZones(
        samples: const [HeartSample(start, 150)],
        maxHr: 190,
        restingHr: 0,
      ),
      isEmpty,
    );
    expect(
      computeKarvonenZones(
        samples: const [HeartSample(start, 150)],
        maxHr: 60,
        restingHr: 60,
      ),
      isEmpty,
    );
    expect(
      maxObservedHr(const [
        HeartSample(start, 120),
        HeartSample(start + 1, 190),
      ]),
      190,
    );
  });
}
