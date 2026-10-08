// Guards for the THAI club-programme seed (v8): referential integrity of the
// new combos/circuits/workouts and the conditioning type derivation.
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/lib/conditioning.dart';
import 'package:fight_camp/models/seed.dart';
import 'package:fight_camp/models/types.dart';

void main() {
  final techIds = seedTechniques.map((t) => t.id).toSet();

  test('seed technique ids are unique', () {
    expect(techIds.length, seedTechniques.length);
  });

  test('every combo/circuit references only existing techniques', () {
    final all = [
      ...seedCombinations,
      ...seedStretchRoutines,
      ...seedCombosThai,
      ...seedConditioningCircuits,
    ];
    for (final c in all) {
      for (final id in c.techniqueIds) {
        expect(
          techIds.contains(id),
          isTrue,
          reason: '${c.id} references missing technique $id',
        );
      }
    }
  });

  test('seed combination ids are unique', () {
    final ids = [
      ...seedCombinations,
      ...seedStretchRoutines,
      ...seedCombosThai,
      ...seedConditioningCircuits,
    ].map((c) => c.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('reps are aligned with techniqueIds in every circuit', () {
    for (final c in seedConditioningCircuits) {
      expect(
        c.reps.length <= c.techniqueIds.length,
        isTrue,
        reason: '${c.id} has more reps than techniques',
      );
    }
  });

  test('conditioning circuits contain only conditioning techniques', () {
    final byId = {for (final t in seedTechniques) t.id: t};
    for (final c in seedConditioningCircuits) {
      for (final id in c.techniqueIds) {
        expect(
          byId[id]?.category,
          TechniqueCategory.conditioning,
          reason: '${c.id} has non-conditioning technique $id',
        );
      }
    }
  });

  test('seed workout ids are unique and combo refs exist', () {
    final all = [...seedWorkouts, seedStretchingWorkout, ...seedThaiWorkouts];
    final ids = all.map((w) => w.id).toSet();
    expect(ids.length, all.length);
    final comboIds = {
      ...seedCombinations.map((c) => c.id),
      ...seedStretchRoutines.map((c) => c.id),
      ...seedCombosThai.map((c) => c.id),
      ...seedConditioningCircuits.map((c) => c.id),
    };
    for (final w in all) {
      for (final cid in w.combinationIds) {
        expect(comboIds.contains(cid), isTrue, reason: '${w.id} -> $cid');
      }
    }
  });

  test('a conditioning circuit makes the workout conditioning', () {
    final w = seedThaiWorkouts.firstWhere(
      (w) => w.id == 'workout-thai-wb-cardio-a',
    );
    expect(
      deriveWorkoutType(w, seedConditioningCircuits, seedTechniques),
      WorkoutType.conditioning,
    );
  });

  test('a boxing combo workout stays heavy bag', () {
    final w = seedWorkouts.firstWhere((w) => w.id == 'workout-combinations');
    expect(
      deriveWorkoutType(w, [
        ...seedCombinations,
        ...seedCombosThai,
      ], seedTechniques),
      WorkoutType.heavyBag,
    );
  });

  test('Combination with reps survives a JSON round-trip', () {
    final c = seedConditioningCircuits.first;
    final decoded = Combination.fromJson(c.toJson());
    expect(decoded.techniqueIds, c.techniqueIds);
    expect(decoded.reps, c.reps);
  });

  test('plain combos serialise without a reps key', () {
    expect(seedCombosThai.first.toJson().containsKey('reps'), isFalse);
  });

  test('every conditioning exercise has an illustration', () {
    final conditioning = seedTechniques
        .where((t) => t.category == TechniqueCategory.conditioning)
        .toList();
    expect(conditioning, isNotEmpty);
    for (final t in conditioning) {
      expect(
        conditioningImageFor(t.id),
        isNotNull,
        reason: '${t.id} has no illustration',
      );
    }
  });

  test('every circuit is exposed as a workout in Allenati', () {
    final referenced = {for (final w in seedThaiWorkouts) ...w.combinationIds};
    for (final c in seedConditioningCircuits) {
      expect(
        referenced.contains(c.id),
        isTrue,
        reason: 'circuit ${c.id} has no workout',
      );
    }
  });

  test('every conditioning workout references only conditioning circuits', () {
    final byId = {for (final c in seedConditioningCircuits) c.id: c};
    for (final w in seedThaiWorkouts) {
      final circuits = w.combinationIds.where(byId.containsKey).toList();
      if (circuits.isEmpty) continue;
      for (final cid in circuits) {
        expect(byId.containsKey(cid), isTrue, reason: '${w.id} -> $cid');
      }
      expect(
        deriveWorkoutType(w, seedConditioningCircuits, seedTechniques),
        WorkoutType.conditioning,
      );
    }
  });
}
