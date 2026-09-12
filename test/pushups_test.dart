// Tests ported from src/tests/pushups.test.ts.
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/lib/pushups_detector.dart';

const bright = 200.0;
const dark = 40.0;

int run(
  List<double> lums, [
  DetectorParams params = defaultParams,
  double startNow = 0,
]) {
  var d = DetectorState.initial();
  var t = startNow;
  var counts = 0;
  for (final l in lums) {
    t += 33;
    final res = stepDetector(d, l, t, params);
    d = res.state;
    if (res.counted) counts += 1;
  }
  return counts;
}

List<double> brightN(int n) => List.filled(n, bright);
List<double> darkN(int n) => List.filled(n, dark);

void main() {
  group('stepDetector', () {
    test('counts one rep for a full down -> up cycle', () {
      final lums = [...brightN(30), ...darkN(20), ...brightN(30)];
      expect(run(lums), 1);
    });

    test('counts multiple reps for repeated cycles', () {
      final lums = [
        ...brightN(30),
        ...darkN(20),
        ...brightN(30),
        ...darkN(20),
        ...brightN(30),
      ];
      expect(run(lums), 2);
    });

    test('does not count without going dark', () {
      expect(run(brightN(60)), 0);
    });

    test('does not count when contrast is too low (no calibration)', () {
      final lums = [for (var i = 0; i < 60; i++) i.isEven ? 130.0 : 133.0];
      expect(run(lums), 0);
    });

    test('respects the cooldown between reps', () {
      final lums = [
        ...brightN(30),
        ...darkN(20),
        ...brightN(30),
        ...darkN(2),
        ...brightN(30),
      ];
      expect(run(lums), 1);
    });
  });

  group('paramsForSensitivity', () {
    test('lowers minDelta as sensitivity rises', () {
      expect(
        paramsForSensitivity(100).minDelta < paramsForSensitivity(0).minDelta,
        true,
      );
    });

    test('clamps sensitivity to 0..100', () {
      expect(
        paramsForSensitivity(-10).minDelta,
        paramsForSensitivity(0).minDelta,
      );
      expect(
        paramsForSensitivity(200).minDelta,
        paramsForSensitivity(100).minDelta,
      );
    });
  });
}
