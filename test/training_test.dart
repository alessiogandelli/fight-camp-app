import 'package:fight_camp/models/types.dart';
import 'package:fight_camp/training/training.dart';
import 'package:flutter_test/flutter_test.dart';

SessionRecord _session({
  required String id,
  required int start,
  required int duration,
  String? groupId,
  RunningExtra? running,
  WorkoutType type = WorkoutType.heavyBag,
}) => SessionRecord(
  id: id,
  date: start + duration * 1000,
  type: type,
  source: 'timer',
  name: 'SACCO',
  duration: duration,
  load: 10,
  groupId: groupId,
  running: running,
);

void main() {
  const minute = 60 * 1000; // ms, for timestamps
  const minuteSec = 60; // seconds, for durations
  const day = 1700000000000;

  test('sessions ten minutes apart share a group, twenty do not', () {
    var n = 0;
    String next() => 'g${n++}';
    final out = assignGroupIds([
      _session(id: 'a', start: day, duration: 10 * minuteSec),
      _session(id: 'b', start: day + 20 * minute, duration: 10 * minuteSec),
      _session(id: 'c', start: day + 60 * minute, duration: 10 * minuteSec),
    ], next);

    expect(out[0].groupId, 'g0');
    expect(out[1].groupId, 'g0');
    expect(out[2].groupId, 'g1');
  });

  test('assignGroupIds is idempotent', () {
    var n = 0;
    String next() => 'g${n++}';
    final first = assignGroupIds([
      _session(id: 'a', start: day, duration: 10 * minuteSec),
      _session(id: 'b', start: day + 12 * minute, duration: 10 * minuteSec),
    ], next);
    final second = assignGroupIds(first, next);
    expect(
      second.map((s) => s.groupId).toSet(),
      first.map((s) => s.groupId).toSet(),
    );
  });

  test('groupIdNear reuses the group of an overlapping session', () {
    final existing = [
      _session(id: 'a', start: day, duration: 10 * minuteSec, groupId: 'g1'),
    ];
    expect(groupIdNear(existing, day + 5 * minute, day + 6 * minute), 'g1');
    expect(groupIdNear(existing, day + 40 * minute, day + 41 * minute), isNull);
  });

  test('trainingsOf groups sessions and links, newest first', () {
    final sessions = [
      _session(id: 'a', start: day, duration: 10 * minuteSec, groupId: 'g1'),
      _session(
        id: 'b',
        start: day + 11 * minute,
        duration: 10 * minuteSec,
        groupId: 'g1',
      ),
      _session(
        id: 'c',
        start: day + 120 * minute,
        duration: 10 * minuteSec,
        groupId: 'g2',
      ),
    ];
    final links = [
      const HealthLink(
        externalId: 'w1',
        groupId: 'g1',
        start: day,
        end: day + 21 * minute,
        activity: 'MARTIAL_ARTS',
        avgHr: 150,
        maxHr: 180,
      ),
    ];
    final trainings = trainingsOf(sessions, links);

    expect(trainings.map((t) => t.id), ['g2', 'g1']);
    final g1 = trainings.last;
    expect(g1.sessions, hasLength(2));
    expect(g1.links, hasLength(1));
    expect(g1.durationSec, 20 * 60);
    expect(g1.load, 20);
    expect(g1.avgHr, 150);
    expect(g1.maxHr, 180);
    expect(trainingCount(sessions), 2);
  });

  test('distance and pace are the whole training, not the last run', () {
    final t = Training(
      id: 'g1',
      sessions: [
        _session(
          id: 'a',
          start: day,
          duration: 20 * minuteSec,
          groupId: 'g1',
          type: WorkoutType.running,
          running: const RunningExtra(distanceKm: 4, paceSecPerKm: 300),
        ),
        _session(
          id: 'b',
          start: day + 21 * minute,
          duration: 20 * minuteSec,
          groupId: 'g1',
          type: WorkoutType.running,
          running: const RunningExtra(distanceKm: 2, paceSecPerKm: 600),
        ),
      ],
    );
    expect(t.distanceKm, 6);
    // 2400s over 6km, not the average of 5:00 and 10:00.
    expect(t.paceSecPerKm, 400);
  });

  test('a Health link does not double the distance of its session', () {
    final t = Training(
      id: 'g1',
      sessions: [
        _session(
          id: 'a',
          start: day,
          duration: 20 * minuteSec,
          groupId: 'g1',
          type: WorkoutType.running,
          running: const RunningExtra(distanceKm: 5),
        ),
      ],
      links: const [
        HealthLink(
          externalId: 'w1',
          groupId: 'g1',
          start: day,
          end: day + 20 * minute,
          activity: 'RUNNING',
          distanceKm: 5,
        ),
      ],
    );
    expect(t.distanceKm, 5);
    expect(t.paceSecPerKm, 240);
  });

  test('no distance means no pace', () {
    final t = Training(
      id: 'g1',
      sessions: [
        _session(
          id: 'a',
          start: day,
          duration: 20 * minuteSec,
          groupId: 'g1',
          type: WorkoutType.running,
        ),
      ],
    );
    expect(t.distanceKm, isNull);
    expect(t.paceSecPerKm, isNull);
  });

  test('a session without a group is a training of its own', () {
    final trainings = trainingsOf([
      _session(id: 'a', start: day, duration: 10 * minuteSec),
      _session(id: 'b', start: day + minute, duration: 10 * minuteSec),
    ], const []);
    expect(trainings, hasLength(2));
  });
}
