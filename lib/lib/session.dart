// Session helpers ported from src/lib/session.ts.
import '../engine/blocks.dart';
import '../engine/plan.dart';
import '../models/types.dart';
import 'format.dart';
import '../l10n/app_localizations.dart';

LiveConfig configFromWorkout(Workout w, int prepSeconds) => LiveConfig(
      name: w.name,
      type: w.type,
      workoutId: w.id,
      prepSeconds: prepSeconds,
      rounds: blockRounds(w),
    );

/// Compact one-line summary of a workout's shape, e.g. "10 × 0:30 · 1:00 riposo".
String summarizeWorkout(Workout w, AppLocalizations l) {
  if (w.blocks.isEmpty) return l.sessionNoRounds;
  final parts = <String>[];
  for (final b in w.blocks) {
    switch (b.type) {
      case BlockType.round || BlockType.circuit:
        parts.add(b.rounds > 1 ? '${b.rounds}×${fmtClock(b.duration)}' : fmtClock(b.duration));
      case BlockType.aerobic || BlockType.stretching || BlockType.free:
        parts.add(fmtClock(b.duration));
    }
  }
  final totals = workoutTotals(w);
  return totals.rest > 0 ? '${parts.join(' + ')} · ${fmtClock(totals.rest)} ${l.sessionRest}' : parts.join(' + ');
}

class WorkoutTotals {
  final int work;
  final int rest;
  final int total;
  const WorkoutTotals(this.work, this.rest, this.total);
}

WorkoutTotals workoutTotals(Workout w) {
  var work = 0;
  var rest = 0;
  for (final b in w.blocks) {
    if (b.type == BlockType.round || b.type == BlockType.circuit) {
      work += b.duration * b.rounds;
      rest += b.restDuration * (b.rounds - 1).clamp(0, 1 << 30);
    } else {
      work += b.duration;
    }
  }
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
