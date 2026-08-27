// Pure time resolution ported from src/engine/resolve.ts.
import 'plan.dart';

class ResolvedState {
  final bool done;
  final int segIndex;
  final Segment? segment;
  final int segElapsed;
  final int segRemaining;
  final int slotIndex;
  final int slotRemaining;
  final int totalElapsed;

  const ResolvedState({
    required this.done,
    required this.segIndex,
    this.segment,
    required this.segElapsed,
    required this.segRemaining,
    required this.slotIndex,
    required this.slotRemaining,
    required this.totalElapsed,
  });
}

ResolvedState resolvePlan(SessionPlan plan, num t) {
  final time = t < 0 ? 0 : t;
  var acc = 0;
  for (var i = 0; i < plan.segments.length; i++) {
    final s = plan.segments[i];
    if (time < acc + s.duration) {
      final segElapsed = (time - acc).floor();
      final segRemaining = s.duration - segElapsed;
      var slotIndex = 0;
      var slotRemaining = segRemaining;
      if (s.kind == SegmentKind.work && s.slots.isNotEmpty) {
        final iv = s.slotInterval < 1 ? 1 : s.slotInterval;
        slotIndex = (segElapsed / iv).floor();
        if (slotIndex > s.slots.length - 1) slotIndex = s.slots.length - 1;
        final slotEndA = acc + (slotIndex + 1) * iv;
        final slotEndB = acc + s.duration;
        final slotEnd = slotEndA < slotEndB ? slotEndA : slotEndB;
        slotRemaining = (slotEnd - time).round();
      }
      return ResolvedState(
        done: false,
        segIndex: i,
        segment: s,
        segElapsed: segElapsed,
        segRemaining: segRemaining,
        slotIndex: slotIndex,
        slotRemaining: slotRemaining < 0 ? 0 : slotRemaining,
        totalElapsed: time.toInt(),
      );
    }
    acc += s.duration;
  }
  final has = plan.segments.isNotEmpty;
  final last = has ? plan.segments.last : null;
  return ResolvedState(
    done: true,
    segIndex: has ? plan.segments.length - 1 : 0,
    segment: last,
    segElapsed: last?.duration ?? 0,
    segRemaining: 0,
    slotIndex: last != null && last.slots.isNotEmpty ? last.slots.length - 1 : 0,
    slotRemaining: 0,
    totalElapsed: time.toInt(),
  );
}

sealed class CueEvent {}

class SegmentCue extends CueEvent {
  final SegmentKind kind;
  final int round;
  final int index;
  SegmentCue(this.kind, this.round, this.index);
}

class SlotCue extends CueEvent {
  final int index;
  SlotCue(this.index);
}

class WarnCue extends CueEvent {}

class CountCue extends CueEvent {
  final int n;
  CountCue(this.n);
}

class DoneCue extends CueEvent {}

List<CueEvent> eventsBetween(SessionPlan plan, num from, num to) {
  if (to <= from) return [];
  final events = <CueEvent>[];
  var acc = 0;
  for (var i = 0; i < plan.segments.length; i++) {
    final s = plan.segments[i];
    final start = acc;
    final end = acc + s.duration;
    acc = end;
    if (end <= from) continue;
    if (start >= to) break;
    if (start > from) events.add(SegmentCue(s.kind, s.round, i));
    if (s.duration >= 10) {
      final warnT = end - 10;
      if (warnT > from && warnT <= to) events.add(WarnCue());
    }
    for (final n in const [3, 2, 1]) {
      final ct = end - n;
      if (ct > from && ct <= to && ct >= start) events.add(CountCue(n));
    }
    if (s.kind == SegmentKind.work && s.slots.length > 1) {
      final iv = s.slotInterval < 1 ? 1 : s.slotInterval;
      for (var k = 1; k < s.slots.length; k++) {
        final st = start + k * iv;
        if (st >= end) break;
        if (st > from && st <= to) events.add(SlotCue(k));
      }
    }
  }
  if (plan.totalSeconds > from && to >= plan.totalSeconds) events.add(DoneCue());
  return events;
}

enum PreviewKind { slot, round, none }

class NextPreview {
  final PreviewKind kind;
  final Slot? slot;
  final int? round;
  const NextPreview(this.kind, {this.slot, this.round});
}

NextPreview nextSlotPreview(SessionPlan plan, int segIndex, int slotIndex) {
  if (segIndex < 0 || segIndex >= plan.segments.length) return const NextPreview(PreviewKind.none);
  final seg = plan.segments[segIndex];
  if (seg.kind == SegmentKind.work && seg.slots.length > 1 && slotIndex < seg.slots.length - 1) {
    return NextPreview(PreviewKind.slot, slot: seg.slots[slotIndex + 1]);
  }
  for (var i = segIndex + 1; i < plan.segments.length; i++) {
    final s = plan.segments[i];
    if (s.kind == SegmentKind.work) {
      return NextPreview(PreviewKind.round, round: s.round, slot: s.slots.isEmpty ? null : s.slots.first);
    }
  }
  return const NextPreview(PreviewKind.none);
}
