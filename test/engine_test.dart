// Tests ported from src/tests/engine.test.ts.
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/engine/plan.dart';
import 'package:fight_camp/engine/resolve.dart';
import 'package:fight_camp/models/types.dart';

Technique tech(String id) => Technique(id: id, name: id, shortName: id.toUpperCase(), category: TechniqueCategory.boxing);
final TECHS = [tech('a'), tech('b'), tech('c'), tech('d')];
Combination combo(String id, List<String> ids) =>
    Combination(id: id, name: id.toUpperCase(), techniqueIds: ids, favorite: false, createdAt: 0);
final COMBOS = [combo('c1', ['a', 'b']), combo('c2', ['c', 'd'])];

LiveConfig basicConfig(int prep) => LiveConfig(
      name: 'TEST',
      type: WorkoutType.heavyBag,
      prepSeconds: prep,
      rounds: [
        const RoundBase(duration: 20, restDuration: 10, type: RoundType.combination, combinationIds: ['c1'], rotationInterval: 20),
        const RoundBase(duration: 20, restDuration: 10, type: RoundType.combination, combinationIds: ['c2'], rotationInterval: 20),
      ],
    );

void main() {
  group('buildPlan', () {
    test('builds prep, work and rest segments and skips rest after the last round', () {
      final plan = buildPlan(basicConfig(5), TECHS, COMBOS);
      expect(plan.segments.map((s) => s.kind).toList(), [SegmentKind.prep, SegmentKind.work, SegmentKind.rest, SegmentKind.work]);
      expect(plan.totalSeconds, 5 + 20 + 10 + 20);
      expect(plan.workSeconds, 40);
      expect(plan.restSeconds, 10);
      expect(plan.rounds, 2);
    });

    test('omits prep when prepSeconds is 0', () {
      final plan = buildPlan(basicConfig(0), TECHS, COMBOS);
      expect(plan.segments.first.kind, SegmentKind.work);
      expect(plan.totalSeconds, 50);
    });

    test('builds rotation slots for sequence rounds', () {
      final cfg = basicConfig(0);
      cfg.rounds.clear();
      cfg.rounds.add(const RoundBase(duration: 60, restDuration: 0, type: RoundType.sequence, combinationIds: ['c1', 'c2'], rotationInterval: 30));
      final plan = buildPlan(cfg, TECHS, COMBOS);
      final seg = plan.segments[0];
      expect(seg.slots.length, 2);
      expect(seg.slots[0].comboId, 'c1');
      expect(seg.slots[1].comboId, 'c2');
      expect(seg.slotInterval, 30);
    });

    test('falls back to FREE when combinations were deleted', () {
      final cfg = basicConfig(0);
      cfg.rounds[0] = cfg.rounds[0].copyWith(combinationIds: ['missing']);
      final plan = buildPlan(cfg, TECHS, COMBOS);
      expect(plan.segments[0].slots[0].free, true);
    });

    test('keeps a single slot for a single-combination round', () {
      final plan = buildPlan(basicConfig(0), TECHS, COMBOS);
      expect(plan.segments[0].slots.length, 1);
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

    test('resolves slot index inside a rotating round', () {
      final cfg = basicConfig(0);
      cfg.rounds.clear();
      cfg.rounds.add(const RoundBase(duration: 60, restDuration: 0, type: RoundType.sequence, combinationIds: ['c1', 'c2'], rotationInterval: 30));
      final p = buildPlan(cfg, TECHS, COMBOS);
      expect(resolvePlan(p, 10).slotIndex, 0);
      expect(resolvePlan(p, 31).slotIndex, 1);
      expect(resolvePlan(p, 59).slotIndex, 1);
    });
  });

  group('eventsBetween', () {
    final plan = buildPlan(basicConfig(5), TECHS, COMBOS);

    SessionPlan rotatingPlan() {
      final cfg = basicConfig(0);
      cfg.rounds.clear();
      cfg.rounds.add(const RoundBase(duration: 60, restDuration: 0, type: RoundType.sequence, combinationIds: ['c1', 'c2'], rotationInterval: 30));
      return buildPlan(cfg, TECHS, COMBOS);
    }

    test('fires segment events when crossing boundaries', () {
      final evs = eventsBetween(plan, 4.9, 5.1);
      expect(evs.any((e) => e is SegmentCue && e.kind == SegmentKind.work), true);
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
      final evs = eventsBetween(plan, plan.totalSeconds - 0.2, plan.totalSeconds + 0.1);
      expect(evs.any((e) => e is DoneCue), true);
    });

    test('fires slot change events in rotating rounds', () {
      final p = rotatingPlan();
      final evs = eventsBetween(p, 29.9, 30.1);
      expect(evs.any((e) => e is SlotCue), true);
    });

    test('returns nothing when time does not advance', () {
      expect(eventsBetween(plan, 10, 10), isEmpty);
    });
  });
}
