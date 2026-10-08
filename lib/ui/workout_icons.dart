// Maps a Workout to a category glyph for the browse cards.
//
// The model stays Flutter-free, so this lives in the UI layer. Known seeded
// workouts are recognised by name (duplicates keep their name), everything else
// falls back to the derived WorkoutType.
import 'package:flutter/material.dart';

import '../models/types.dart';

IconData workoutIconFor(Workout w, {WorkoutType? type}) {
  final t = type ?? w.type;
  if (w.routineId != null || t == WorkoutType.stretching) {
    return Icons.self_improvement_rounded;
  }
  final name = w.name.toUpperCase();
  if (name.contains('CORDA') || name.contains('ROPE')) {
    return Icons.sports_gymnastics_rounded;
  }
  if (name.contains('RISCALDAMENTO') || name.contains('WARM')) {
    return Icons.local_fire_department_rounded;
  }
  if (t == WorkoutType.conditioning ||
      name.contains('CIRCUITO') ||
      name.contains('CIRCUIT')) {
    return Icons.loop_rounded;
  }
  if (name.contains('SPARRING')) {
    return Icons.sports_mma_rounded;
  }
  return workoutTypeIcon(t);
}

IconData workoutTypeIcon(WorkoutType type) => switch (type) {
  WorkoutType.heavyBag => Icons.sports_mma_rounded,
  WorkoutType.muayThai => Icons.sports_martial_arts_rounded,
  WorkoutType.tabata => Icons.timer_rounded,
  WorkoutType.intervals => Icons.repeat_rounded,
  WorkoutType.running => Icons.directions_run_rounded,
  WorkoutType.strength => Icons.fitness_center_rounded,
  WorkoutType.conditioning => Icons.bolt_rounded,
  WorkoutType.aerobic => Icons.directions_run_rounded,
  WorkoutType.stretching => Icons.self_improvement_rounded,
  WorkoutType.other => Icons.timer_outlined,
};

/// Glyph for a saved combination in the Library.
const comboCardIcon = Icons.sports_mma_rounded;
