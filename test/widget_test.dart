import 'package:flutter_test/flutter_test.dart';

import 'package:fight_camp/engine/plan.dart';
import 'package:fight_camp/models/types.dart';

void main() {
  test('buildPlan creates prep + work + rest segments', () {
    final cfg = LiveConfig(
      name: 'TEST',
      type: WorkoutType.heavyBag,
      prepSeconds: 10,
      rounds: const [
        RoundBase(duration: 180, restDuration: 60, type: RoundType.combination, combinationIds: ['combo-01']),
        RoundBase(duration: 180, restDuration: 0, type: RoundType.free),
      ],
    );
    final plan = buildPlan(cfg, [], []);
    expect(plan.segments.length, 4); // prep, work, rest, work
    expect(plan.totalSeconds, 10 + 180 + 60 + 180);
    expect(plan.rounds, 2);
  });
}
