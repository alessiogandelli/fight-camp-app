// Colour language for Progress: one stable hue per training type, reused by
// the activity calendar, training-mix bars, filters and log accents.
import 'package:flutter/material.dart';

import '../models/types.dart';
import '../training/training.dart';

const Color kProgressRed = Color(0xFFFF5064);
const Color kProgressCyan = Color(0xFF35C2E8);
const Color kProgressPurple = Color(0xFF9B7BFF);
const Color kProgressAmber = Color(0xFFF5A524);
const Color kProgressGreen = Color(0xFF48C78E);
const Color kProgressTeal = Color(0xFF5FD3B3);
const Color kProgressYellow = Color(0xFFF2C94C);
const Color kProgressBlue = Color(0xFF5B8CFF);

Color progressTypeColor(WorkoutType type) => switch (type) {
  WorkoutType.heavyBag => kProgressRed,
  WorkoutType.muayThai => kProgressRed,
  WorkoutType.tabata => kProgressAmber,
  WorkoutType.intervals => kProgressYellow,
  WorkoutType.running => kProgressCyan,
  WorkoutType.strength => kProgressGreen,
  WorkoutType.conditioning => kProgressPurple,
  WorkoutType.aerobic => kProgressAmber,
  WorkoutType.stretching => kProgressTeal,
  WorkoutType.other => kProgressPurple,
};

/// Dominant colour for a training, used as the log card's left accent.
Color progressTrainingColor(Training training) {
  final durations = <WorkoutType, int>{};
  for (final session in training.sessions) {
    durations[session.type] = (durations[session.type] ?? 0) + session.duration;
  }
  for (final segment in training.segments) {
    final type = segment.type;
    if (segment.kind != TrainingSegmentKind.activity || type == null) continue;
    durations[type] = (durations[type] ?? 0) + segment.durationSec;
  }
  if (durations.isEmpty) return kProgressBlue;
  final ordered = durations.entries.toList()
    ..sort((a, b) {
      final byDuration = b.value.compareTo(a.value);
      if (byDuration != 0) return byDuration;
      return a.key.index.compareTo(b.key.index);
    });
  return progressTypeColor(ordered.first.key);
}

/// Hard-stop slices for a day circle containing more than one training type.
List<({Color color, int weight})> progressDaySlices(
  Map<WorkoutType, int> typeSeconds,
) {
  final rows = [
    for (final entry in typeSeconds.entries)
      if (entry.value > 0)
        (color: progressTypeColor(entry.key), weight: entry.value),
  ];
  rows.sort((a, b) {
    final byWeight = b.weight.compareTo(a.weight);
    if (byWeight != 0) return byWeight;
    return a.color.toARGB32().compareTo(b.color.toARGB32());
  });
  return rows;
}
