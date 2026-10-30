import 'package:fight_camp/models/types.dart';
import 'package:fight_camp/training/timeline.dart';
import 'package:fight_camp/training/training.dart';
import 'package:flutter_test/flutter_test.dart';

const _minute = 60 * 1000;
const _base = 1700000000000;

SessionRecord _session({
  required String id,
  required int start,
  required int minutes,
  WorkoutType type = WorkoutType.heavyBag,
  String name = 'SACCO',
  String? groupId = 'g1',
}) => SessionRecord(
  id: id,
  date: start + minutes * _minute,
  type: type,
  source: 'timer',
  name: name,
  duration: minutes * 60,
  load: 0,
  groupId: groupId,
);

TrainingSegment _segment({
  required String id,
  required int start,
  required int minutes,
  TrainingSegmentKind kind = TrainingSegmentKind.pause,
  String name = 'Pausa',
  WorkoutType? type,
}) => TrainingSegment(
  id: id,
  groupId: 'g1',
  start: start,
  end: start + minutes * _minute,
  kind: kind,
  name: name,
  type: type,
);

void main() {
  test('timeline keeps sessions and declared blocks in order', () {
    final training = Training(
      id: 'g1',
      sessions: [
        _session(
          id: 'warm',
          start: _base,
          minutes: 10,
          type: WorkoutType.aerobic,
          name: 'RISCALDAMENTO',
        ),
        _session(id: 'bag', start: _base + 15 * _minute, minutes: 20),
      ],
      segments: [_segment(id: 's1', start: _base + 10 * _minute, minutes: 5)],
    );

    final timeline = trainingTimeline(training, Lang.it);

    expect(timeline.map((s) => s.label), ['RISCALDAMENTO', 'Pausa', 'SACCO']);
    expect(timeline[1].kind, TimelineKind.pause);
    expect(timeline[1].isDeclared, isTrue);
    expect(timeline[1].durationMs, 5 * _minute);
  });

  test('gaps are the uncovered time between and around sessions', () {
    final training = Training(
      id: 'g1',
      sessions: [
        _session(id: 'a', start: _base, minutes: 10),
        _session(id: 'b', start: _base + 25 * _minute, minutes: 20),
      ],
    );

    final gaps = timelineGaps(training);

    expect(gaps, hasLength(1));
    expect(gaps.first.start, _base + 10 * _minute);
    expect(gaps.first.end, _base + 25 * _minute);
  });

  test('declaring a gap removes it from the gaps', () {
    final training = Training(
      id: 'g1',
      sessions: [
        _session(id: 'a', start: _base, minutes: 10),
        _session(id: 'b', start: _base + 25 * _minute, minutes: 20),
      ],
      segments: [_segment(id: 's1', start: _base + 10 * _minute, minutes: 15)],
    );

    expect(timelineGaps(training), isEmpty);
  });

  test('a health-only training is one piece and has no gaps to declare', () {
    final training = Training(
      id: 'h1',
      sessions: const [],
      links: [
        HealthLink(
          externalId: 'x',
          groupId: 'h1',
          start: _base,
          end: _base + 30 * _minute,
          activity: 'RUNNING',
          hasSeries: true,
        ),
      ],
    );

    final timeline = trainingTimeline(training, Lang.it);
    expect(timeline, hasLength(1));
    expect(timeline.single.kind, TimelineKind.health);
    expect(timeline.single.label, 'Corsa');
    expect(timelineGaps(training), isEmpty);
  });

  test('duration counts sessions and declared blocks, rests included', () {
    final training = Training(
      id: 'g1',
      sessions: [
        _session(id: 'a', start: _base, minutes: 10),
        _session(id: 'b', start: _base + 25 * _minute, minutes: 20),
      ],
      segments: [_segment(id: 's1', start: _base + 10 * _minute, minutes: 15)],
    );

    expect(training.durationSec, 45 * 60);
  });

  test('small holes are not offered as declarable gaps', () {
    final training = Training(
      id: 'g1',
      sessions: [
        _session(id: 'a', start: _base, minutes: 10),
        _session(id: 'b', start: _base + 10 * _minute + 5000, minutes: 20),
      ],
    );

    expect(timelineGaps(training), isEmpty);
  });

  test('trainingsOf attaches declared blocks to their training', () {
    final trainings = trainingsOf(
      [_session(id: 'a', start: _base, minutes: 10)],
      const [],
      segments: [_segment(id: 's1', start: _base + 10 * _minute, minutes: 5)],
    );

    expect(trainings.single.segments, hasLength(1));
    expect(trainings.single.durationSec, 15 * 60);
  });
}
