// Tests ported from src/tests/engine.test.ts.
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/engine/plan.dart';
import 'package:fight_camp/engine/resolve.dart';
import 'package:fight_camp/lib/session.dart';
import 'package:fight_camp/models/types.dart';

Technique tech(String id) => Technique(
  id: id,
  name: id,
  shortName: id.toUpperCase(),
  category: TechniqueCategory.boxing,
);
final TECHS = [tech('a'), tech('b'), tech('c'), tech('d')];
Combination combo(String id, List<String> ids) => Combination(
  id: id,
  name: id.toUpperCase(),
  techniqueIds: ids,
  favorite: false,
  createdAt: 0,
);
final COMBOS = [
  combo('c1', ['a', 'b']),
  combo('c2', ['c', 'd']),
];

LiveConfig basicConfig(int prep) => LiveConfig(
  name: 'TEST',
  type: WorkoutType.heavyBag,
  prepSeconds: prep,
  rounds: [
    const RoundBase(
      duration: 20,
      restDuration: 10,
      type: RoundType.combination,
      combinationIds: ['c1'],
    ),
    const RoundBase(
      duration: 20,
      restDuration: 10,
      type: RoundType.combination,
      combinationIds: ['c2'],
    ),
  ],
);

void main() {
  group('buildPlan', () {
    test(
      'builds prep, work and rest segments and skips rest after the last round',
      () {
        final plan = buildPlan(basicConfig(5), TECHS, COMBOS);
        expect(plan.segments.map((s) => s.kind).toList(), [
          SegmentKind.prep,
          SegmentKind.work,
          SegmentKind.rest,
          SegmentKind.work,
        ]);
        expect(plan.totalSeconds, 5 + 20 + 10 + 20);
        expect(plan.workSeconds, 40);
        expect(plan.restSeconds, 10);
        expect(plan.rounds, 2);
      },
    );

    test('omits prep when prepSeconds is 0', () {
      final plan = buildPlan(basicConfig(0), TECHS, COMBOS);
      expect(plan.segments.first.kind, SegmentKind.work);
      expect(plan.totalSeconds, 50);
    });

    test('cycles one combination per work round', () {
      final cfg = LiveConfig(
        name: 'TEST',
        type: WorkoutType.heavyBag,
        prepSeconds: 0,
        rounds: [
          for (var i = 0; i < 3; i++)
            const RoundBase(
              duration: 60,
              restDuration: 30,
              type: RoundType.combination,
              combinationIds: ['c1', 'c2'],
            ),
        ],
      );
      final plan = buildPlan(cfg, TECHS, COMBOS);
      final work = plan.segments
          .where((s) => s.kind == SegmentKind.work)
          .toList();
      expect(work.length, 3);
      expect(work.map((s) => s.slot!.comboId), ['c1', 'c2', 'c1']);
    });

    test('falls back to FREE when combinations were deleted', () {
      final cfg = basicConfig(0);
      cfg.rounds[0] = cfg.rounds[0].copyWith(combinationIds: ['missing']);
      final plan = buildPlan(cfg, TECHS, COMBOS);
      expect(plan.segments[0].slot!.free, true);
    });

    test('keeps a single slot for a single-combination round', () {
      final plan = buildPlan(basicConfig(0), TECHS, COMBOS);
      expect(plan.segments[0].slot!.comboId, 'c1');
    });
  });

  group('resolvePlan', () {
    final plan = buildPlan(basicConfig(5), TECHS, COMBOS);

    test('resolves prep at t=0', () {
      final st = resolvePlan(plan, 0);
      expect(st.segment!.kind, SegmentKind.prep);
      expect(st.segRemaining, 5);
    });

    test('moves to work exactly at the boundary', () {
      final st = resolvePlan(plan, 5);
      expect(st.segment!.kind, SegmentKind.work);
      expect(st.segment!.round, 1);
      expect(st.segRemaining, 20);
    });

    test('resolves rest between rounds', () {
      final st = resolvePlan(plan, 27);
      expect(st.segment!.kind, SegmentKind.rest);
      expect(st.segRemaining, 8);
    });

    test('reports done at the end', () {
      final st = resolvePlan(plan, plan.totalSeconds);
      expect(st.done, true);
    });
  });

  group('eventsBetween', () {
    final plan = buildPlan(basicConfig(5), TECHS, COMBOS);

    test('fires segment events when crossing boundaries', () {
      final evs = eventsBetween(plan, 4.9, 5.1);
      expect(
        evs.any((e) => e is SegmentCue && e.kind == SegmentKind.work),
        true,
      );
    });

    test('fires warn at 10 seconds remaining', () {
      final evs = eventsBetween(plan, 14.9, 15.1);
      expect(evs.any((e) => e is WarnCue), true);
    });

    test('fires 3-2-1 counts before segment end', () {
      final evs = eventsBetween(plan, 21.5, 25);
      final counts = evs.whereType<CountCue>().map((e) => e.n).toList();
      expect(counts, [3, 2, 1]);
    });

    test('fires done at the end of the plan', () {
      final evs = eventsBetween(
        plan,
        plan.totalSeconds - 0.2,
        plan.totalSeconds + 0.1,
      );
      expect(evs.any((e) => e is DoneCue), true);
    });

    test('returns nothing when time does not advance', () {
      expect(eventsBetween(plan, 10, 10), isEmpty);
    });
  });

  group('endless plans', () {
    SessionPlan endlessPlan() => buildPlan(
      LiveConfig(
        name: 'SPARRING',
        type: WorkoutType.intervals,
        prepSeconds: 0,
        endless: true,
        rounds: [
          for (var i = 0; i < 8; i++)
            const RoundBase(
              duration: 90,
              restDuration: 60,
              type: RoundType.free,
            ),
        ],
      ),
      TECHS,
      COMBOS,
    );

    test('buildPlan marks the plan endless', () {
      expect(endlessPlan().endless, true);
      expect(buildPlan(basicConfig(0), TECHS, COMBOS).endless, false);
    });

    test('extendPlan appends a rest+work repetition preserving the clock', () {
      final p = endlessPlan();
      final totalBefore = p.totalSeconds;
      final lastWork = p.segments.last;
      final extended = extendPlan(p);
      expect(extended.totalSeconds, totalBefore + 60 + 90);
      expect(extended.segments.length, p.segments.length + 2);
      expect(
        extended.segments[extended.segments.length - 2].kind,
        SegmentKind.rest,
      );
      expect(extended.segments.last.kind, SegmentKind.work);
      expect(extended.segments.last.round, lastWork.round + 1);
      expect(extended.segments.last.totalRounds, lastWork.round + 1);
      // Existing time coordinates stay valid after the swap.
      expect(resolvePlan(extended, 100).segIndex, resolvePlan(p, 100).segIndex);
    });

    test('extendPlan chains across multiple extensions', () {
      var p = endlessPlan();
      final t0 = p.totalSeconds;
      for (var i = 0; i < 3; i++) {
        p = extendPlan(p);
      }
      expect(p.totalSeconds, t0 + 3 * (90 + 60));
      expect(p.rounds, 11);
    });

    test('extendPlan is a no-op for finite plans', () {
      final p = buildPlan(basicConfig(0), TECHS, COMBOS);
      expect(identical(extendPlan(p), p), true);
    });

    test('configFromWorkout expands rounds == 0 into an endless batch', () {
      final w = const Workout(
        id: 'workout-sparring',
        name: 'SPARRING',
        workDuration: 90,
        restDuration: 60,
        rounds: 0,
        createdAt: 0,
      );
      final cfg = configFromWorkout(w, COMBOS, TECHS, 3);
      expect(cfg.endless, true);
      expect(cfg.rounds.length, endlessBatchRounds);
      expect(cfg.rounds.first.duration, 90);
      expect(cfg.rounds.first.restDuration, 60);
    });
  });
}
