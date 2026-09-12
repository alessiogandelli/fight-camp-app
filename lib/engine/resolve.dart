// Pure time resolution ported from src/engine/resolve.ts.
import 'plan.dart';

class ResolvedState {
  final bool done;
  final int segIndex;
  final Segment? segment;
  final int segElapsed;
  final int segRemaining;
  final int totalElapsed;

  const ResolvedState({
    required this.done,
    required this.segIndex,
    this.segment,
    required this.segElapsed,
    required this.segRemaining,
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
      return ResolvedState(
        done: false,
        segIndex: i,
        segment: s,
        segElapsed: segElapsed,
        segRemaining: segRemaining,
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
  }
  if (plan.totalSeconds > from && to >= plan.totalSeconds) events.add(DoneCue());
  return events;
}

enum PreviewKind { round, none }

class NextPreview {
  final PreviewKind kind;
  final Slot? slot;
  final int? round;
  const NextPreview(this.kind, {this.slot, this.round});
}

NextPreview nextWorkPreview(SessionPlan plan, int segIndex) {
  if (segIndex < 0 || segIndex >= plan.segments.length) {
    return const NextPreview(PreviewKind.none);
  }
  for (var i = segIndex + 1; i < plan.segments.length; i++) {
    final s = plan.segments[i];
    if (s.kind == SegmentKind.work) {
      return NextPreview(PreviewKind.round, round: s.round, slot: s.slot);
    }
  }
  return const NextPreview(PreviewKind.none);
}
