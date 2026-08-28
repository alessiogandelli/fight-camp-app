// Session helpers ported from src/lib/session.ts.
import '../engine/plan.dart';
import '../models/types.dart';
import 'format.dart';
import 'stretch.dart';
import '../l10n/app_localizations.dart';

/// Fixed stretching cadence: work seconds per exercise, rest seconds between
/// exercises (ADR 0003 — intervals are always the same within a workout).
const stretchWorkSeconds = 30;
const stretchRestSeconds = 10;

/// Rounds generated per endless batch; the engine appends more while running.
const endlessBatchRounds = 8;

/// Compiles a Workout (single uniform configuration) into the LiveConfig the
/// session engine consumes. Stretching workouts expand into one round per
/// exercise of the routine, each carrying its SVG illustration.
/// Workouts with rounds == 0 are endless: a first batch is emitted and the
/// engine keeps appending rounds of the same pattern until stopped.
LiveConfig configFromWorkout(
  Workout w,
  List<Combination> combos,
  List<Technique> techniques,
  int prepSeconds,
) {
  final exerciseRounds = <RoundBase>[];
  if (w.routineId != null) {
    final techByName = {for (final t in techniques) t.id: t};
    final routine = combos.where((c) => c.id == w.routineId).firstOrNull;
    final exerciseIds = routine?.techniqueIds ?? const <String>[];
    for (var i = 0; i < exerciseIds.length; i++) {
      final id = exerciseIds[i];
      exerciseRounds.add(
        RoundBase(
          label: techByName[id]?.name,
          duration: stretchWorkSeconds,
          restDuration: i < exerciseIds.length - 1 ? stretchRestSeconds : 0,
          type: RoundType.custom,
          image: stretchImageFor(id),
        ),
      );
    }
    return LiveConfig(
      name: w.name,
      type: WorkoutType.stretching,
      workoutId: w.id,
      prepSeconds: prepSeconds,
      rounds: exerciseRounds,
    );
  }

  final endless = w.rounds == 0;
  final count = endless ? endlessBatchRounds : w.rounds;
  final rounds = [
    for (var i = 0; i < count; i++)
      RoundBase(
        duration: w.workDuration,
        restDuration: endless || i < count - 1 ? w.restDuration : 0,
        type: w.hasCombos ? RoundType.combination : RoundType.free,
        combinationIds: w.combinationIds,
      ),
  ];
  return LiveConfig(
    name: w.name,
    type: w.type,
    workoutId: w.id,
    prepSeconds: prepSeconds,
    endless: endless,
    rounds: rounds,
  );
}

/// Compact one-line summary of a workout's shape, e.g. "4×3:00 · 1:00 RIPOSO · 5 COMBO".
String summarizeWorkout(Workout w, AppLocalizations l) {
  if (w.workDuration < 1) return l.sessionNoRounds;
  final parts = <String>[
    w.rounds == 0
        ? '∞ ×${fmtClock(w.workDuration)}'
        : (w.rounds > 1
              ? '${w.rounds}×${fmtClock(w.workDuration)}'
              : fmtClock(w.workDuration)),
    if (w.restDuration > 0) '${fmtClock(w.restDuration)} ${l.sessionRest}',
    if (w.hasCombos) l.workoutsCombosCount(w.combinationIds.length),
    if (w.routineId != null) l.workoutsRoutine,
  ];
  return parts.join(' · ');
}

class WorkoutTotals {
  final int work;
  final int rest;
  final int total;
  const WorkoutTotals(this.work, this.rest, this.total);
}

WorkoutTotals workoutTotals(Workout w) {
  if (w.rounds == 0) {
    // Endless: surface a single round's footprint; the session has no fixed total.
    return WorkoutTotals(
      w.workDuration,
      w.restDuration,
      w.workDuration + w.restDuration,
    );
  }
  final work = w.workDuration * w.rounds;
  final rest = w.restDuration * (w.rounds - 1).clamp(0, 1 << 30);
  return WorkoutTotals(work, rest, work + rest);
}

SessionSummary buildSummary(
  SessionPlan plan,
  Set<String> seenComboIds,
  List<Combination> combos,
  List<Technique> techniques,
  AppLocalizations l,
) {
  final comboById = {for (final c in combos) c.id: c};
  final techById = {for (final tt in techniques) tt.id: tt};
  final combosUsed = <NameRef>[];
  final usage = <String, UsageRef>{};
  final seenSlots = <String, List<String>>{};
  for (final seg in plan.segments) {
    for (final slot in seg.slots) {
      if (slot.comboId != null && !seenSlots.containsKey(slot.comboId)) {
        seenSlots[slot.comboId!] = slot.techniqueIds;
      }
    }
  }
  for (final id in seenComboIds) {
    final slotIds = seenSlots[id];
    final combo = comboById[id];
    combosUsed.add(NameRef(id, combo?.name ?? l.sessionDeletedCombo));
    final techIds = slotIds ?? combo?.techniqueIds ?? const <String>[];
    for (final tid in techIds) {
      final cur = usage[tid];
      final tech = techById[tid];
      final tname = tech != null ? tech.name : l.sessionUnknown;
      if (cur != null) {
        usage[tid] = UsageRef(tid, cur.name, cur.count + 1);
      } else {
        usage[tid] = UsageRef(tid, tname, 1);
      }
    }
  }
  return SessionSummary(
    totalRounds: plan.rounds,
    totalSeconds: plan.totalSeconds,
    workSeconds: plan.workSeconds,
    restSeconds: plan.restSeconds,
    combosUsed: combosUsed,
    techniqueUsage: usage.values.toList(),
  );
}
