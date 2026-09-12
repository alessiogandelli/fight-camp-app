// Session plan builder ported from src/engine/plan.ts.
import '../models/types.dart';

enum SlotKind { free, defense, conditioning, custom }

class Slot {
  final String? comboId;
  final String name;
  final List<String> techniqueIds;
  final bool free;
  final SlotKind? kind;
  final String? image;

  const Slot({
    this.comboId,
    required this.name,
    required this.techniqueIds,
    required this.free,
    this.kind,
    this.image,
  });
}

enum SegmentKind { prep, work, rest }

class Segment {
  final SegmentKind kind;
  final int duration;
  final int round;
  final int totalRounds;
  final String? label;
  final RoundType? roundType;
  final Slot? slot;

  const Segment({
    required this.kind,
    required this.duration,
    required this.round,
    required this.totalRounds,
    this.label,
    this.roundType,
    this.slot,
  });
}

class SessionPlan {
  final List<Segment> segments;
  final int totalSeconds;
  final int workSeconds;
  final int restSeconds;
  final int rounds;

  /// Endless plan (Workout.rounds == 0): [extendPlan] appends repetitions of
  /// the last rest+work pattern while the session runs.
  final bool endless;

  const SessionPlan({
    required this.segments,
    required this.totalSeconds,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    this.endless = false,
  });
}

Slot _comboToSlot(Combination c) => Slot(
  comboId: c.id,
  name: c.name,
  techniqueIds: c.techniqueIds.toList(),
  free: false,
);

Slot _fixedSlot(SlotKind kind, {String name = '', String? image}) => Slot(
  name: name,
  techniqueIds: const [],
  free: true,
  kind: kind,
  image: image,
);

SessionPlan buildPlan(
  LiveConfig cfg,
  List<Technique> techniques,
  List<Combination> combos,
) {
  final comboById = {for (final c in combos) c.id: c};
  final segments = <Segment>[];
  final rounds = cfg.rounds.where((r) => r.duration >= 1).toList();
  final totalRounds = rounds.length;

  if (cfg.prepSeconds > 0 && totalRounds > 0) {
    segments.add(
      Segment(
        kind: SegmentKind.prep,
        duration: cfg.prepSeconds,
        round: 0,
        totalRounds: totalRounds,
      ),
    );
  }

  for (var idx = 0; idx < rounds.length; idx++) {
    final r = rounds[idx];
    final duration = r.duration < 1 ? 1 : r.duration;
    final restDuration = r.restDuration < 0 ? 0 : r.restDuration;

    final Slot slot;
    switch (r.type) {
      case RoundType.free:
      case RoundType.defense:
      case RoundType.conditioning:
      case RoundType.custom:
        final SlotKind kind;
        switch (r.type) {
          case RoundType.free:
            kind = SlotKind.free;
          case RoundType.defense:
            kind = SlotKind.defense;
          case RoundType.conditioning:
            kind = SlotKind.conditioning;
          default:
            kind = SlotKind.custom;
        }
        slot = _fixedSlot(
          kind,
          name: r.type == RoundType.custom ? (r.label ?? '') : '',
          image: r.image,
        );
      case RoundType.combination:
        final resolved = r.combinationIds
            .map((id) => comboById[id])
            .whereType<Combination>()
            .map(_comboToSlot)
            .toList();
        final pool = resolved.isNotEmpty
            ? resolved
            : [_fixedSlot(SlotKind.free)];
        // One combination per work round, cycling through the selection at
        // each round boundary.
        slot = pool[idx % pool.length];
    }

    segments.add(
      Segment(
        kind: SegmentKind.work,
        duration: duration,
        round: idx + 1,
        totalRounds: totalRounds,
        label: r.type == RoundType.custom ? (r.label ?? '') : null,
        roundType: r.type,
        slot: slot,
      ),
    );

    if (restDuration > 0 && idx < totalRounds - 1) {
      segments.add(
        Segment(
          kind: SegmentKind.rest,
          duration: restDuration,
          round: idx + 1,
          totalRounds: totalRounds,
        ),
      );
    }
  }

  final workSeconds = segments
      .where((s) => s.kind == SegmentKind.work)
      .fold<int>(0, (a, s) => a + s.duration);
  final restSeconds = segments
      .where((s) => s.kind == SegmentKind.rest)
      .fold<int>(0, (a, s) => a + s.duration);
  final prepSeconds = segments
      .where((s) => s.kind == SegmentKind.prep)
      .fold<int>(0, (a, s) => a + s.duration);

  return SessionPlan(
    segments: segments,
    totalSeconds: workSeconds + restSeconds + prepSeconds,
    workSeconds: workSeconds,
    restSeconds: restSeconds,
    rounds: totalRounds,
    endless: cfg.endless,
  );
}

/// Appends one more rest+work repetition of the last round to an endless plan.
/// Time coordinates of existing segments are preserved, so the engine can
/// hot-swap the plan mid-session without moving the clock.
SessionPlan extendPlan(SessionPlan plan) {
  if (!plan.endless || plan.segments.isEmpty) return plan;
  final workIdx = plan.segments.lastIndexWhere(
    (s) => s.kind == SegmentKind.work,
  );
  if (workIdx < 0) return plan;
  final work = plan.segments[workIdx];
  final nextRound = work.round + 1;
  final segs = [...plan.segments];
  final restIdx = plan.segments.lastIndexWhere(
    (s) => s.kind == SegmentKind.rest,
  );
  if (restIdx >= 0) {
    final r = plan.segments[restIdx];
    segs.add(
      Segment(
        kind: SegmentKind.rest,
        duration: r.duration,
        round: work.round,
        totalRounds: work.totalRounds,
      ),
    );
  }
  segs.add(
    Segment(
      kind: SegmentKind.work,
      duration: work.duration,
      round: nextRound,
      totalRounds: nextRound,
      label: work.label,
      roundType: work.roundType,
      slot: work.slot,
    ),
  );
  final workSeconds = segs
      .where((s) => s.kind == SegmentKind.work)
      .fold<int>(0, (a, s) => a + s.duration);
  final restSeconds = segs
      .where((s) => s.kind == SegmentKind.rest)
      .fold<int>(0, (a, s) => a + s.duration);
  return SessionPlan(
    segments: segs,
    totalSeconds: workSeconds + restSeconds,
    workSeconds: workSeconds,
    restSeconds: restSeconds,
    rounds: nextRound,
    endless: true,
  );
}

int segmentStart(SessionPlan plan, int index) {
  var t = 0;
  for (var i = 0; i < index && i < plan.segments.length; i++) {
    t += plan.segments[i].duration;
  }
  return t;
}
