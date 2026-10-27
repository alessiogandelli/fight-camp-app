import 'package:fight_camp/health/health_import.dart';
import 'package:fight_camp/health/health_source.dart';
import 'package:fight_camp/models/types.dart';
import 'package:fight_camp/training/training.dart';
import 'package:flutter_test/flutter_test.dart';

AppData _data({
  List<SessionRecord> sessions = const [],
  List<HealthLink> links = const [],
}) => AppData(
  version: 9,
  techniques: const [],
  combinations: const [],
  workouts: const [],
  sessions: sessions,
  plans: const [],
  settings: const Settings(sound: true, vibration: true, prepSeconds: 3),
  healthLinks: links,
);

SessionRecord _session({
  required String id,
  required int start,
  required int duration,
  String? groupId,
  WorkoutType type = WorkoutType.heavyBag,
  String source = 'timer',
  int? rpe,
  int load = 0,
}) => SessionRecord(
  id: id,
  date: start + duration * 1000,
  type: type,
  source: source,
  name: 'SACCO',
  duration: duration,
  rpe: rpe,
  load: load,
  groupId: groupId,
);

String Function() _ids() {
  var n = 0;
  return () => 'new-${n++}';
}

void main() {
  const day = 1700000000000;
  const minute = 60 * 1000; // ms, for timestamps
  const minuteSec = 60; // seconds, for durations

  test('imports a workout with no app session as its own training', () {
    final plan = planHealthImport(
      data: _data(),
      batch: HealthBatch(
        workouts: const [
          HealthWorkout(
            externalId: 'w1',
            start: day,
            end: day + 30 * minute,
            activity: 'RUNNING',
            sourceName: 'Apple Watch',
            distanceKm: 6,
            energyKcal: 400,
          ),
        ],
        samples: [
          const HeartSample(0, 100),
          HeartSample(day, 120),
          HeartSample(day + 10 * minute, 160),
          HeartSample(day + 29 * minute, 150),
        ],
      ),
      lang: Lang.it,
      newId: _ids(),
    );

    expect(plan.newSessions, 1);
    expect(plan.attachedWorkouts, 0);
    final s = plan.sessions.single;
    expect(s.source, 'health');
    expect(s.type, WorkoutType.running);
    expect(s.duration, 30 * 60);
    expect(s.running?.distanceKm, 6);
    expect(s.running?.paceSecPerKm, (30 * 60 / 6).round());
    expect(s.groupId, isNotNull);
    expect(s.hrAvg, ((120 + 160 + 150) / 3).round());
    expect(s.hrMax, 160);

    final link = plan.links.single;
    expect(link.groupId, s.groupId);
    expect(link.avgHr, s.hrAvg);
    expect(plan.series.single.externalId, 'w1');
  });

  test(
    'attaches a workout to the session it covers instead of duplicating',
    () {
      final session = _session(id: 's1', start: day, duration: 20 * minuteSec);
      final plan = planHealthImport(
        data: _data(sessions: [session]),
        batch: HealthBatch(
          workouts: const [
            HealthWorkout(
              externalId: 'w1',
              start: day - 2 * minute,
              end: day + 40 * minute,
              activity: 'HIGH_INTENSITY_INTERVAL_TRAINING',
            ),
          ],
          samples: [
            HeartSample(day + minute, 130),
            HeartSample(day + 10 * minute, 165),
          ],
        ),
        lang: Lang.it,
        newId: _ids(),
      );

      expect(plan.newSessions, 0);
      expect(plan.attachedWorkouts, 1);
      expect(plan.sessions, hasLength(1));
      expect(plan.sessions.single.groupId, 's1');
      expect(plan.sessions.single.hrAvg, 148);
      expect(plan.sessions.single.hrMax, 165);
      expect(plan.links.single.groupId, 's1');
    },
  );

  test('merges back-to-back sessions covered by one workout', () {
    final a = _session(id: 'a', start: day, duration: 10 * minuteSec);
    final b = _session(
      id: 'b',
      start: day + 12 * minute,
      duration: 10 * minuteSec,
    );
    final plan = planHealthImport(
      data: _data(sessions: [a, b]),
      batch: HealthBatch(
        workouts: const [
          HealthWorkout(
            externalId: 'w1',
            start: day,
            end: day + 25 * minute,
            activity: 'MARTIAL_ARTS',
          ),
        ],
      ),
      lang: Lang.it,
      newId: _ids(),
    );

    expect(plan.attachedWorkouts, 1);
    expect(plan.sessions.map((s) => s.groupId).toSet(), hasLength(1));
    expect(trainingCount(plan.sessions), 1);
  });

  test('does not re-import the same workout', () {
    final plan = planHealthImport(
      data: _data(
        sessions: [
          _session(
            id: 's1',
            start: day,
            duration: 20 * minuteSec,
            groupId: 'g1',
            source: 'health',
          ),
        ],
        links: const [
          HealthLink(
            externalId: 'w1',
            groupId: 'g1',
            start: day,
            end: day + 20 * minute,
            activity: 'RUNNING',
          ),
        ],
      ),
      batch: HealthBatch(
        workouts: const [
          HealthWorkout(
            externalId: 'w1',
            start: day,
            end: day + 20 * minute,
            activity: 'RUNNING',
          ),
        ],
      ),
      lang: Lang.it,
      newId: _ids(),
    );

    expect(plan.skippedWorkouts, 1);
    expect(plan.newSessions, 0);
    expect(plan.attachedWorkouts, 0);
    expect(plan.sessions, hasLength(1));
  });

  test('skips the same run recorded by two different apps', () {
    final plan = planHealthImport(
      data: _data(),
      batch: HealthBatch(
        workouts: const [
          HealthWorkout(
            externalId: 'watch',
            start: day,
            end: day + 30 * minute,
            activity: 'RUNNING',
            sourceName: 'Apple Watch',
          ),
          HealthWorkout(
            externalId: 'nike',
            start: day + minute,
            end: day + 31 * minute,
            activity: 'RUNNING',
            sourceName: 'Nike Run Club',
          ),
        ],
      ),
      lang: Lang.it,
      newId: _ids(),
    );

    expect(plan.newSessions, 1);
    expect(plan.skippedWorkouts, 1);
    expect(plan.sessions, hasLength(1));
  });

  test('a short workout inside a long session still attaches to it', () {
    final session = _session(id: 's1', start: day, duration: 60 * minuteSec);
    final plan = planHealthImport(
      data: _data(sessions: [session]),
      batch: HealthBatch(
        workouts: const [
          HealthWorkout(
            externalId: 'w1',
            start: day + 20 * minute,
            end: day + 40 * minute,
            activity: 'TRADITIONAL_STRENGTH_TRAINING',
          ),
        ],
      ),
      lang: Lang.it,
      newId: _ids(),
    );
    expect(plan.attachedWorkouts, 1);
    expect(plan.sessions, hasLength(1));
  });

  test('a tiny edge overlap does not attach', () {
    final session = _session(id: 's1', start: day, duration: 60 * minuteSec);
    final plan = planHealthImport(
      data: _data(sessions: [session]),
      batch: HealthBatch(
        workouts: [
          HealthWorkout(
            externalId: 'w1',
            start: day + 59 * minute,
            end: day + 90 * minute,
            activity: 'WALKING',
          ),
        ],
      ),
      lang: Lang.it,
      newId: _ids(),
    );
    expect(plan.newSessions, 1);
    expect(plan.attachedWorkouts, 0);
  });

  test('long workouts that contain a short session still attach to it', () {
    final session = _session(id: 's1', start: day, duration: 3 * minuteSec);
    final plan = planHealthImport(
      data: _data(sessions: [session]),
      batch: HealthBatch(
        workouts: const [
          HealthWorkout(
            externalId: 'w1',
            start: day - 2 * minute,
            end: day + 90 * minute,
            activity: 'WALKING',
          ),
        ],
      ),
      lang: Lang.it,
      newId: _ids(),
    );
    expect(plan.attachedWorkouts, 1);
    expect(plan.sessions, hasLength(1));
  });

  test('imports Apple effort as RPE and load for a health-only workout', () {
    final plan = planHealthImport(
      data: _data(),
      batch: HealthBatch(
        workouts: [
          HealthWorkout(
            externalId: 'w1',
            start: day,
            end: day + 30 * minute,
            activity: 'RUNNING',
            effortScore: 7,
          ),
        ],
      ),
      lang: Lang.it,
      newId: _ids(),
    );
    expect(plan.sessions.single.rpe, 7);
    expect(plan.sessions.single.load, 210);
    expect(plan.links.single.effortScore, 7);
  });

  test('imports distance samples and never overrides a manual RPE', () {
    final session = _session(
      id: 's1',
      start: day,
      duration: 20 * minuteSec,
      groupId: 'g1',
      rpe: 9,
      load: 180,
    );
    final plan = planHealthImport(
      data: _data(sessions: [session]),
      batch: HealthBatch(
        workouts: [
          HealthWorkout(
            externalId: 'w1',
            start: day,
            end: day + 20 * minute,
            activity: 'RUNNING',
            effortScore: 5,
            distanceSamples: const [
              DistanceSample(day, day + 10 * minute, 1000),
            ],
          ),
        ],
      ),
      lang: Lang.it,
      newId: _ids(),
    );
    expect(plan.sessions.single.rpe, 9);
    expect(plan.sessions.single.load, 180);
    expect(plan.distanceSeries.single.externalId, 'w1');
    expect(plan.distanceSeries.single.samples.single.meters, 1000);
  });

  test('enriches an already imported workout with effort and distance', () {
    final plan = planHealthImport(
      data: _data(
        sessions: [
          _session(
            id: 's1',
            start: day,
            duration: 30 * minuteSec,
            groupId: 'g1',
            source: 'health',
          ),
        ],
        links: const [
          HealthLink(
            externalId: 'w1',
            groupId: 'g1',
            start: day,
            end: day + 30 * minute,
            activity: 'RUNNING',
          ),
        ],
      ),
      batch: HealthBatch(
        workouts: [
          HealthWorkout(
            externalId: 'w1',
            start: day,
            end: day + 30 * minute,
            activity: 'RUNNING',
            effortScore: 6,
            distanceSamples: const [
              DistanceSample(day, day + 10 * minute, 1000),
            ],
          ),
        ],
      ),
      lang: Lang.it,
      newId: _ids(),
    );
    expect(plan.skippedWorkouts, 1);
    expect(plan.enrichedWorkouts, 1);
    expect(plan.sessions.single.rpe, 6);
    expect(plan.sessions.single.load, 180);
    expect(plan.links.single.effortScore, 6);
    expect(plan.distanceSeries, hasLength(1));
  });
}
