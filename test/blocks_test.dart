// Tests for the single-configuration workout compile step (ADR 0003),
// exercised at the buildPlan seam.
import 'package:flutter_test/flutter_test.dart';

import 'package:fight_camp/engine/plan.dart';
import 'package:fight_camp/lib/session.dart';
import 'package:fight_camp/lib/stretch.dart';
import 'package:fight_camp/models/types.dart';

Technique tech(String id, [TechniqueCategory category = TechniqueCategory.boxing]) =>
    Technique(id: id, name: id, shortName: id.toUpperCase(), category: category);

Combination combo(String id, List<String> ids) => Combination(
    id: id, name: id.toUpperCase(), techniqueIds: ids, favorite: false, createdAt: 0);

final TECHS = [
  tech('a'),
  tech('b'),
  tech('s1', TechniqueCategory.stretching),
  tech('s2', TechniqueCategory.stretching),
];
final COMBOS = [combo('c1', ['a', 'b']), combo('c2', ['b', 'a'])];
final ROUTINES = [combo('routine-1', ['s1', 's2'])];

Workout _workout({
  int work = 180,
  int rest = 60,
  int rounds = 3,
  List<String> combos = const [],
  String? routine,
}) =>
    Workout(
      id: 'w',
      name: 'W',
      workDuration: work,
      restDuration: rest,
      rounds: rounds,
      combinationIds: combos,
      routineId: routine,
      createdAt: 0,
    );

SessionPlan _plan(Workout w) => buildPlan(
      configFromWorkout(w, [...COMBOS, ...ROUTINES], TECHS, 0),
      TECHS,
      [...COMBOS, ...ROUTINES],
    );

void main() {
  group('configFromWorkout', () {
    test('bag workout expands into N rounds with rest between but not after the last', () {
      final cfg = configFromWorkout(_workout(work: 90, rest: 45, rounds: 3, combos: ['c1']), COMBOS, TECHS, 0);
      expect(cfg.type, WorkoutType.heavyBag);
      expect(cfg.rounds.length, 3);
      expect(cfg.rounds.map((r) => r.duration), [90, 90, 90]);
      expect(cfg.rounds.take(2).map((r) => r.restDuration), [45, 45]);
      expect(cfg.rounds.last.restDuration, 0);
    });

    test('bag workout with combos uses combination type', () {
      final cfg = configFromWorkout(_workout(work: 30, rest: 30, rounds: 2, combos: ['c1']), COMBOS, TECHS, 0);
      expect(cfg.rounds.every((r) => r.type == RoundType.combination), isTrue);
    });

    test('cycles one combo per round across the workout', () {
      final plan = _plan(_workout(work: 60, rest: 30, rounds: 3, combos: ['c1', 'c2']));
      final work = plan.segments.where((s) => s.kind == SegmentKind.work).toList();
      expect(work.map((s) => s.slot!.comboId), ['c1', 'c2', 'c1']);
    });

    test('sparring is a workout without combos and compiles to free rounds', () {
      final cfg = configFromWorkout(_workout(work: 180, rest: 60, rounds: 2), COMBOS, TECHS, 0);
      expect(cfg.rounds.every((r) => r.type == RoundType.free), isTrue);
    });

    test('stretching workout expands into one round per exercise with image and fixed cadence', () {
      final cfg = configFromWorkout(_workout(routine: 'routine-1'), [...COMBOS, ...ROUTINES], TECHS, 0);
      expect(cfg.type, WorkoutType.stretching);
      expect(cfg.rounds.length, 2);
      expect(cfg.rounds.map((r) => r.duration), [30, 30]);
      expect(cfg.rounds.map((r) => r.restDuration), [10, 0]);
      expect(cfg.rounds.map((r) => r.image), [stretchImageFor('s1'), stretchImageFor('s2')]);
      expect(cfg.rounds.map((r) => r.label), ['s1', 's2']);
    });
  });

  group('derived type', () {
    test('routine workout is stretching', () {
      expect(_workout(routine: 'routine-1').type, WorkoutType.stretching);
    });
    test('combos make it a bag workout', () {
      expect(_workout(combos: ['c1']).type, WorkoutType.heavyBag);
    });
    test('no rest and a single round is continuous', () {
      expect(_workout(work: 600, rest: 0, rounds: 1).type, WorkoutType.aerobic);
    });
    test('anything else is a circuit', () {
      expect(_workout(work: 20, rest: 10, rounds: 8).type, WorkoutType.intervals);
    });
  });

  group('workoutTotals', () {
    test('multiplies work by rounds and counts rest between rounds only', () {
      final t = workoutTotals(_workout(work: 30, rest: 10, rounds: 4));
      expect(t.work, 120);
      expect(t.rest, 30);
      expect(t.total, 150);
    });
  });

  group('stretching workout end-to-end at the buildPlan seam', () {
    test('produces a work/rest phase per exercise and resolves no combos', () {
      final plan = _plan(_workout(routine: 'routine-1'));
      expect(plan.rounds, 2);
      expect(plan.workSeconds, 60);
      expect(plan.restSeconds, 10);
      final work = plan.segments.where((s) => s.kind == SegmentKind.work).toList();
      expect(work.length, 2);
      expect(work[0].slot!.image, stretchImageFor('s1'));
    });
  });
}