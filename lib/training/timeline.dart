// The heart-rate timeline of one training: the sessions, the declared blocks
// (rests and timer-less exercises) and the imported Health workout, laid on the
// same clock so the chart can label every part of the effort.
//
// Pure: no IO, no widgets. See docs/adr/0007-allenamenti-e-import-da-salute.md.
import '../health/health_source.dart';
import '../models/types.dart';
import 'training.dart';

/// Where a piece of the timeline comes from.
enum TimelineKind { session, health, pause, activity }

class TimelineSegment {
  final int start;
  final int end;
  final TimelineKind kind;
  final WorkoutType? type;
  final String label;

  /// Set only for blocks declared by the user, so the UI can edit them.
  final String? segmentId;

  const TimelineSegment({
    required this.start,
    required this.end,
    required this.kind,
    this.type,
    required this.label,
    this.segmentId,
  });

  int get durationMs => end - start;
  bool get isDeclared => segmentId != null;
  bool get isPause => kind == TimelineKind.pause;
}

class TimelineGap {
  final int start;
  final int end;
  const TimelineGap(this.start, this.end);

  int get durationSec => ((end - start) / 1000).round();
}

/// Every piece of [training] in chronological order: app sessions, declared
/// blocks, and — only when there are no sessions at all — the Health workout.
List<TimelineSegment> trainingTimeline(Training training, Lang lang) {
  final out = <TimelineSegment>[
    for (final s in training.sessions)
      TimelineSegment(
        start: sessionStart(s),
        end: sessionEnd(s),
        kind: TimelineKind.session,
        type: s.type,
        label: s.name,
      ),
    for (final segment in training.segments)
      TimelineSegment(
        start: segment.start,
        end: segment.end,
        kind: segment.kind == TrainingSegmentKind.pause
            ? TimelineKind.pause
            : TimelineKind.activity,
        type: segment.type,
        label: segment.name,
        segmentId: segment.id,
      ),
  ];
  if (training.sessions.isEmpty) {
    for (final link in training.links) {
      final type = workoutTypeForActivity(link.activity);
      out.add(
        TimelineSegment(
          start: link.start,
          end: link.end,
          kind: TimelineKind.health,
          type: type,
          label: workoutTypeLabel(type, lang),
        ),
      );
    }
  }
  out.sort((a, b) => a.start.compareTo(b.start));
  return out;
}

/// The parts of [training] not covered by a session or a declared block: the
/// pieces the user can still declare as a rest or a timer-less exercise.
List<TimelineGap> timelineGaps(Training training, {int minGapMs = 30 * 1000}) {
  final busy = <({int start, int end})>[
    for (final s in training.sessions)
      (start: sessionStart(s), end: sessionEnd(s)),
    for (final segment in training.segments)
      (start: segment.start, end: segment.end),
    // An imported-only training is already one piece: no gaps to declare.
    if (training.sessions.isEmpty)
      for (final link in training.links) (start: link.start, end: link.end),
  ]..sort((a, b) => a.start.compareTo(b.start));

  final gaps = <TimelineGap>[];
  var cursor = training.start;
  for (final block in busy) {
    if (block.start - cursor >= minGapMs) {
      gaps.add(TimelineGap(cursor, block.start));
    }
    if (block.end > cursor) cursor = block.end;
  }
  if (training.end - cursor >= minGapMs) {
    gaps.add(TimelineGap(cursor, training.end));
  }
  return gaps;
}
