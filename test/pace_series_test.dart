import 'package:fight_camp/health/health_source.dart';
import 'package:fight_camp/health/pace_series.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('steady 100 m every 20 s reads as a 200 s/km pace', () {
    final samples = [
      for (var i = 0; i < 12; i++)
        DistanceSample(i * 20000, (i + 1) * 20000, 100),
    ];

    final pace = computePaceSeries(
      samples: samples,
      start: 0,
      end: 240000,
      windowMs: 60000,
      stepMs: 15000,
    );

    expect(pace, isNotEmpty);
    for (final point in pace) {
      expect(point.secPerKm, inInclusiveRange(195, 205));
    }
  });

  test('no distance samples means no pace line', () {
    expect(
      computePaceSeries(samples: const [], start: 0, end: 600000),
      isEmpty,
    );
  });

  test('standing still is skipped instead of showing an infinite pace', () {
    final samples = [
      DistanceSample(0, 60000, 200),
      // Two minutes without moving.
      DistanceSample(180000, 240000, 200),
    ];

    final pace = computePaceSeries(
      samples: samples,
      start: 0,
      end: 240000,
      windowMs: 60000,
      stepMs: 15000,
    );

    expect(pace, isNotEmpty);
    expect(pace.every((p) => p.secPerKm <= 1500), isTrue);
  });
}
