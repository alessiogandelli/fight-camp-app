// Session plan builder ported from src/engine/plan.ts.
import '../lib/random.dart';
import '../models/types.dart';

enum SlotKind { free, defense, conditioning, custom, random }

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
  final List<Slot> slots;
  final int slotInterval;

  const Segment({
    required this.kind,
    required this.duration,
    required this.round,
    required this.totalRounds,
    this.label,
    this.roundType,
    required this.slots,
    required this.slotInterval,
  });
}

class SessionPlan {
  final List<Segment> segments;
  final int totalSeconds;
  final int workSeconds;
  final int restSeconds;
  final int rounds;

  const SessionPlan({
    required this.segments,
    required this.totalSeconds,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
  });
}

int _clamp(int v, int min, int max) => v < min ? min : (v > max ? max : v);

Slot _comboToSlot(Combination c) => Slot(
      comboId: c.id,
      name: c.name,
      techniqueIds: c.techniqueIds.toList(),
      free: false,
    );

Slot _fixedSlot(SlotKind kind, {String name = '', String? image}) =>
    Slot(name: name, techniqueIds: const [], free: true, kind: kind, image: image);

SessionPlan buildPlan(LiveConfig cfg, List<Technique> techniques, List<Combination> combos) {
  final comboById = {for (final c in combos) c.id: c};
  final segments = <Segment>[];
  final rounds = cfg.rounds.where((r) => r.duration >= 1).toList();
  final totalRounds = rounds.length;

  if (cfg.prepSeconds > 0 && totalRounds > 0) {
    segments.add(Segment(
      kind: SegmentKind.prep,
      duration: cfg.prepSeconds,
      round: 0,
      totalRounds: totalRounds,
      slots: const [],
      slotInterval: cfg.prepSeconds,
    ));
  }

  for (var idx = 0; idx < rounds.length; idx++) {
    final r = rounds[idx];
    final duration = r.duration < 1 ? 1 : r.duration;
    final restDuration = r.restDuration < 0 ? 0 : r.restDuration;
    var slots = <Slot>[];
    var slotInterval = duration;

    if (r.type == RoundType.free ||
        r.type == RoundType.defense ||
        r.type == RoundType.conditioning ||
        r.type == RoundType.custom) {
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
      slots = [_fixedSlot(kind, name: r.type == RoundType.custom ? (r.label ?? '') : '', image: r.image)];
    } else if (r.type == RoundType.random) {
      final rc = r.randomConfig;
      if (rc != null) {
        final interval = _clamp(r.rotationInterval != 0 ? r.rotationInterval : duration, 5, duration);
        final needed = (duration / interval).ceil().clamp(1, 1 << 30);
        final gen = generateCombos(rc, techniques, rc.count > needed ? rc.count : needed);
        var generated = gen
            .map((g) => Slot(name: g.name, techniqueIds: g.techniqueIds, free: false, kind: SlotKind.random))
            .toList();
        final n = (duration / interval).ceil().clamp(1, 1 << 30);
        slots = [for (var i = 0; i < n; i++) generated[i % generated.length]];
        slotInterval = interval;
      } else {
        slots = [_fixedSlot(SlotKind.free)];
      }
    } else {
      final resolved = r.combinationIds
          .map((id) => comboById[id])
          .whereType<Combination>()
          .map(_comboToSlot)
          .toList();
      final pool = resolved.isNotEmpty ? resolved : [_fixedSlot(SlotKind.free)];
      final singleCombo = pool.length == 1;
      final interval = _clamp(r.rotationInterval != 0 ? r.rotationInterval : duration, 5, duration);
      final n = singleCombo ? 1 : (duration / interval).ceil().clamp(1, 1 << 30);
      slotInterval = singleCombo ? duration : interval;
      if (r.rotationOrder == RotationOrder.random && pool.length > 1) {
        final seq = <int>[];
        var lastIdx = -1;
        for (var i = 0; i < n; i++) {
          final options = [for (var pi = 0; pi < pool.length; pi++) if (pi != lastIdx) pi];
          final chosen = options.isEmpty ? 0 : options[defaultRngInt(options.length)];
          seq.add(chosen);
          lastIdx = chosen;
        }
        slots = [for (final pi in seq) pool[pi]];
      } else {
        final offset = r.type == RoundType.sequence ? idx : 0;
        slots = [for (var i = 0; i < n; i++) pool[(i + offset) % pool.length]];
      }
    }

    segments.add(Segment(
      kind: SegmentKind.work,
      duration: duration,
      round: idx + 1,
      totalRounds: totalRounds,
      label: r.type == RoundType.custom ? (r.label ?? '') : null,
      roundType: r.type,
      slots: slots,
      slotInterval: slotInterval,
    ));

    if (restDuration > 0 && idx < totalRounds - 1) {
      segments.add(Segment(
        kind: SegmentKind.rest,
        duration: restDuration,
        round: idx + 1,
        totalRounds: totalRounds,
        slots: const [],
        slotInterval: restDuration,
      ));
    }
  }

  final workSeconds =
      segments.where((s) => s.kind == SegmentKind.work).fold<int>(0, (a, s) => a + s.duration);
  final restSeconds =
      segments.where((s) => s.kind == SegmentKind.rest).fold<int>(0, (a, s) => a + s.duration);
  final prepSeconds =
      segments.where((s) => s.kind == SegmentKind.prep).fold<int>(0, (a, s) => a + s.duration);

  return SessionPlan(
    segments: segments,
    totalSeconds: workSeconds + restSeconds + prepSeconds,
    workSeconds: workSeconds,
    restSeconds: restSeconds,
    rounds: totalRounds,
  );
}

int segmentStart(SessionPlan plan, int index) {
  var t = 0;
  for (var i = 0; i < index && i < plan.segments.length; i++) {
    t += plan.segments[i].duration;
  }
  return t;
}

// Small helper used by rotationOrder=random in buildPlan.
int defaultRngInt(int maxExclusive) {
  return (defaultRandom.nextDouble() * maxExclusive).floor();
}
