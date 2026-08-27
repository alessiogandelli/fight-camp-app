// Tests for the blocks model compile step (ADR 0002), exercised at the
// buildPlan seam.
import 'package:flutter_test/flutter_test.dart';

import 'package:fight_camp/engine/blocks.dart';
import 'package:fight_camp/engine/plan.dart';
import 'package:fight_camp/lib/session.dart';
import 'package:fight_camp/models/types.dart';

Technique tech(String id) =>
    Technique(id: id, name: id, shortName: id.toUpperCase(), category: TechniqueCategory.boxing);
Technique stretchTech(String id) =>
    Technique(id: id, name: id, shortName: id.toUpperCase(), category: TechniqueCategory.stretching);

final TECHS = [tech('a'), tech('b'), tech('c'), tech('d')];
Combination combo(String id, List<String> ids) => Combination(
    id: id, name: id.toUpperCase(), techniqueIds: ids, favorite: false, createdAt: 0);
final COMBOS = [combo('c1', ['a', 'b'])];
final ROUTINES = [
  combo('routine-1', ['s1', 's2']),
];
final STRETCH_TECHS = [stretchTech('s1'), stretchTech('s2')];

Workout _workout(List<WorkoutBlock> blocks) => Workout(
      id: 'w',
      name: 'W',
      type: WorkoutType.other,
      blocks: blocks,
      createdAt: 0,
    );

SessionPlan _plan(Workout w) => buildPlan(
      configFromWorkout(w, 0),
      [...TECHS, ...STRETCH_TECHS],
      [...COMBOS, ...ROUTINES],
    );

void main() {
  group('blockRounds', () {
    test('expands a round block into N rounds with rest between but not after the last', () {
      final w = _workout([
        WorkoutBlock(id: 'b1', type: BlockType.round, rounds: 3, duration: 90, restDuration: 45),
      ]);
      final rounds = blockRounds(w);
      expect(rounds.length, 3);
      expect(rounds.map((r) => r.duration), [90, 90, 90]);
      expect(rounds.take(2).map((r) => r.restDuration), [45, 45]);
      expect(rounds.last.restDuration, 0);
    });

    test('round block with combos uses combination type', () {
      final w = _workout([
        WorkoutBlock(id: 'b1', type: BlockType.round, rounds: 2, duration: 30, combinationIds: ['c1']),
      ]);
      expect(blockRounds(w).every((r) => r.type == RoundType.combination), isTrue);
    });

    test('sparring is a round without combos and compiles to free rounds', () {
      final w = _workout([
        WorkoutBlock(id: 'b1', type: BlockType.round, rounds: 2, duration: 180, restDuration: 60),
      ]);
      expect(blockRounds(w).every((r) => r.type == RoundType.free), isTrue);
    });

    test('continuous blocks become a single round each', () {
      final w = _workout([
        WorkoutBlock(id: 'a', type: BlockType.aerobic, duration: 600),
        WorkoutBlock(id: 's', type: BlockType.stretching, duration: 300),
        WorkoutBlock(id: 'f', type: BlockType.free, duration: 120),
      ]);
      final rounds = blockRounds(w);
      expect(rounds.length, 3);
      expect(rounds.map((r) => r.duration), [600, 300, 120]);
    });
  });

  group('workoutTotals with blocks', () {
    test('multiplies series and counts rest between them only', () {
      final w = _workout([
        WorkoutBlock(id: 'b1', type: BlockType.round, rounds: 10, duration: 30, restDuration: 0),
        WorkoutBlock(id: 'b2', type: BlockType.round, rounds: 3, duration: 90, restDuration: 45),
      ]);
      final t = workoutTotals(w);
      expect(t.work, 10 * 30 + 3 * 90);
      expect(t.rest, 2 * 45);
    });
  });

  group('canonical example end-to-end at the buildPlan seam', () {
    // "10×30" senza pausa → 3×1'30"+45" → tabata → sparring → stretching"
    final canonical = _workout([
      const WorkoutBlock(id: 'b1', type: BlockType.round, rounds: 10, duration: 30, restDuration: 0,
          combinationIds: ['c1']),
      const WorkoutBlock(id: 'b2', type: BlockType.round, rounds: 3, duration: 90, restDuration: 45),
      const WorkoutBlock(id: 'b3', type: BlockType.circuit, rounds: 8, duration: 20, restDuration: 10),
      const WorkoutBlock(id: 'b4', type: BlockType.round, rounds: 3, duration: 120, restDuration: 60),
      const WorkoutBlock(id: 'b5', type: BlockType.stretching, duration: 600, combinationIds: ['routine-1']),
    ]);

    test('produces the expected phase sequence', () {
      final plan = _plan(canonical);
      // 10 + 3 + 8 + 3 rounds + 1 stretching = 25 work segments; rest after
      // every round except within b1 (no pause), after the last round of each
      // block, and before the stretching round.
      expect(plan.rounds, 25);
      expect(plan.workSeconds,
          10 * 30 + 3 * 90 + 8 * 20 + 3 * 120 + 600);
      // rest: b2 contributes 2*45, b3 7*10, b4 2*60; no rest inside b1 or before stretching
      expect(plan.restSeconds, 2 * 45 + 7 * 10 + 2 * 60);
    });

    test('stretching block resolves its routine techniques', () {
      final plan = _plan(canonical);
      final stretchSeg = plan.segments.last;
      expect(stretchSeg.slots.first.comboId, 'routine-1');
      expect(stretchSeg.slots.first.techniqueIds, ['s1', 's2']);
    });
  });
}
