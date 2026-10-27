// Pure read-side rules behind the redesigned Progress page.
import 'package:fight_camp/lib/format.dart';
import 'package:fight_camp/lib/progress_stats.dart';
import 'package:fight_camp/lib/stats.dart';
import 'package:fight_camp/models/types.dart';
import 'package:fight_camp/training/training.dart';
import 'package:flutter_test/flutter_test.dart';

SessionRecord _session({
  required String id,
  required int start,
  required int duration,
  required String group,
  WorkoutType type = WorkoutType.heavyBag,
  String source = 'timer',
  String? name,
  int? rounds,
  RunningExtra? running,
  List<NameRef>? combos,
  List<StrengthEntry>? strength,
  String? notes,
  int load = 0,
}) => SessionRecord(
  id: id,
  date: start + duration * 1000,
  type: type,
  source: source,
  name: name ?? id,
  duration: duration,
  roundsCompleted: rounds,
  load: load,
  running: running,
  combosUsed: combos,
  strength: strength,
  notes: notes,
  groupId: group,
);

void main() {
  final base = DateTime(2026, 10, 26, 9).millisecondsSinceEpoch; // Monday
  const minute = 60 * 1000;

  final warmup = _session(
    id: 'warmup',
    start: base,
    duration: 10 * 60,
    group: 'g1',
    type: WorkoutType.conditioning,
    name: 'WARM UP',
  );
  final bag = _session(
    id: 'bag',
    start: base + 12 * minute,
    duration: 30 * 60,
    group: 'g1',
    rounds: 5,
    name: 'BAG',
    load: 240,
    combos: const [NameRef('c1', 'JAB CROSS')],
  );
  final stretch = _session(
    id: 'stretch',
    start: base + 47 * minute,
    duration: 10 * 60,
    group: 'g1',
    type: WorkoutType.stretching,
    name: 'STRETCH',
  );
  final run = _session(
    id: 'run',
    start: base + 48 * 60 * minute,
    duration: 30 * 60,
    group: 'g2',
    type: WorkoutType.running,
    source: 'health',
    name: 'CORSA',
    running: const RunningExtra(distanceKm: 5, paceSecPerKm: 360),
  );
  final runLink = HealthLink(
    externalId: 'h1',
    groupId: 'g2',
    start: run.date - run.duration * 1000,
    end: run.date,
    activity: 'RUNNING',
    sourceName: 'Watch',
    distanceKm: 5,
  );
  final linked = _session(
    id: 'linked',
    start: base + 72 * 60 * minute,
    duration: 20 * 60,
    group: 'g3',
    type: WorkoutType.running,
    name: 'RUN LINKED',
  );
  final linkedHealth = HealthLink(
    externalId: 'h2',
    groupId: 'g3',
    start: linked.date - linked.duration * 1000,
    end: linked.date,
    activity: 'RUNNING',
    sourceName: 'Watch',
    distanceKm: 4,
  );

  final trainings = trainingsOf(
    [warmup, bag, stretch, run, linked],
    [runLink, linkedHealth],
  );

  test('period membership uses training start', () {
    final period = StatsPeriod(DateTime(2026, 10, 26), DateTime(2026, 10, 27));
    expect(trainingsInPeriod(trainings, period), hasLength(1));
  });

  test('nearby sessions count as one workout but sum their time', () {
    final one = trainingsInPeriod(
      trainings,
      StatsPeriod(DateTime(2026, 10, 26), DateTime(2026, 10, 27)),
    ).single;
    final summary = summarizeProgress([one]);
    expect(summary.workouts, 1);
    expect(summary.durationSec, 50 * 60);
    expect(summary.activeDays, 1);
  });

  test('mix attributes each session to its real type', () {
    final one = trainings.firstWhere((t) => t.id == 'g1');
    final rows = trainingMix([one]);
    expect(rows.map((r) => r.type).toSet(), {
      WorkoutType.conditioning,
      WorkoutType.heavyBag,
      WorkoutType.stretching,
    });
    expect(rows.firstWhere((r) => r.type == WorkoutType.heavyBag).rounds, 5);
  });

  test('Health link does not duplicate duration in a linked training', () {
    final linkedTraining = trainings.firstWhere((t) => t.id == 'g3');
    final summary = summarizeProgress([linkedTraining]);
    expect(summary.durationSec, 20 * 60);
    expect(summary.workouts, 1);
    expect(linkedTraining.distanceKm, 4);
  });

  test('imported run distance is visible in the running mix row', () {
    final runTraining = trainings.firstWhere((t) => t.id == 'g2');
    final row = trainingMix([runTraining]).single;
    expect(row.type, WorkoutType.running);
    expect(row.distanceKm, 5);
  });

  test('active days are unique days, not session count', () {
    final summary = summarizeProgress(trainings);
    expect(summary.workouts, 3);
    expect(summary.activeDays, 3);
  });

  test('type filter matches any member of a mixed training', () {
    final result = filterTrainings(trainings, types: {WorkoutType.stretching});
    expect(result.map((t) => t.id), ['g1']);
  });

  test('source filter distinguishes app, Health and mixed trainings', () {
    expect(
      filterTrainings(
        trainings,
        source: TrainingSourceFilter.health,
      ).map((t) => t.id).toSet(),
      {'g2', 'g3'},
    );
    expect(
      filterTrainings(
        trainings,
        source: TrainingSourceFilter.app,
      ).map((t) => t.id).toSet(),
      {'g1', 'g3'},
    );
  });

  test('search covers names, notes, combos and strength exercises', () {
    final notes = _session(
      id: 'notes',
      start: base + 90 * 60 * minute,
      duration: 10 * 60,
      group: 'g4',
      notes: 'shoulder felt great',
      name: 'SESSION',
    );
    final strength = _session(
      id: 'strength',
      start: base + 91 * 60 * minute,
      duration: 10 * 60,
      group: 'g5',
      type: WorkoutType.strength,
      name: 'LIFT',
      strength: const [
        StrengthEntry(exercise: 'bench press', sets: 3, reps: 8),
      ],
    );
    final all = trainingsOf([notes, strength], const []);
    expect(filterTrainings(all, query: 'shoulder'), hasLength(1));
    expect(filterTrainings(all, query: 'bench'), hasLength(1));
    expect(filterTrainings(trainings, query: 'jab cross'), hasLength(1));
  });

  test('day filter keeps only trainings that started on that day', () {
    final day = dateKey(DateTime.fromMillisecondsSinceEpoch(base));
    expect(filterTrainings(trainings, dayKey: day).map((t) => t.id), ['g1']);
  });

  test('calendar days retain the per-type split used by the heatmap', () {
    final one = trainings.firstWhere((t) => t.id == 'g1');
    final day = progressDaysByKey([one]).values.single;
    expect(day.workouts, 1);
    expect(day.typeSeconds[WorkoutType.heavyBag], 30 * 60);
    expect(day.typeSeconds[WorkoutType.conditioning], 10 * 60);
    expect(day.typeSeconds[WorkoutType.stretching], 10 * 60);
  });

  test('uncategorized and load helpers work on trainings', () {
    final unknown = _session(
      id: 'unknown',
      start: base + 92 * 60 * minute,
      duration: 15 * 60,
      group: 'g6',
      type: WorkoutType.other,
      name: 'UNKNOWN',
    );
    final all = trainingsOf([unknown], const []);
    expect(uncategorizedSessions(all), hasLength(1));
    expect(totalLoad([trainings.firstWhere((t) => t.id == 'g1')]), 240);
  });

  test('week and 4-week periods can move back by whole blocks', () {
    final now = DateTime(2026, 10, 28, 12);
    final week = progressPeriodFor(StatsRange.week, offset: 1, now: now);
    expect(week.start, DateTime(2026, 10, 19));
    expect(week.end, DateTime(2026, 10, 26));
    expect(week.isCurrent, isFalse);

    final block = progressPeriodFor(StatsRange.weeks4, offset: 1, now: now);
    expect(block.start, DateTime(2026, 9, 7));
    expect(block.end, DateTime(2026, 10, 5));
    expect(block.previous!.start, DateTime(2026, 8, 10));

    final current = progressPeriodFor(StatsRange.weeks4, now: now);
    expect(current.start, DateTime(2026, 10, 5));
    expect(current.end, isNull);
    expect(current.isCurrent, isTrue);
  });

  test('historical navigation stops at the first recorded block', () {
    final now = DateTime(2026, 10, 28, 12);
    final old = _session(
      id: 'old',
      start: DateTime(2026, 9, 1).millisecondsSinceEpoch,
      duration: 10 * 60,
      group: 'old',
    );
    final list = trainingsOf([old], const []);
    expect(maxProgressOffset(StatsRange.week, list, now: now), 8);
    expect(maxProgressOffset(StatsRange.weeks4, list, now: now), 1);
    expect(maxProgressOffset(StatsRange.all, list, now: now), 0);
  });

  test('goal stats normalise active days by weeks and count goal hits', () {
    final now = DateTime(2026, 10, 28, 12);
    final sessions = <SessionRecord>[];
    var id = 0;
    void add(DateTime date) {
      sessions.add(
        _session(
          id: 'd${id++}',
          start: date.millisecondsSinceEpoch,
          duration: 10 * 60,
          group: 'd${id}',
        ),
      );
    }

    for (final day in [6, 7, 8, 9]) {
      add(DateTime(2026, 10, day, 9)); // week 1: 4 days
    }
    add(DateTime(2026, 10, 13, 9)); // week 2: 2 days
    add(DateTime(2026, 10, 14, 9));
    for (final day in [20, 21, 22, 23]) {
      add(DateTime(2026, 10, day, 9)); // week 3: 4 days
    }
    for (final day in [27, 28]) {
      add(DateTime(2026, 10, day, 9)); // week 4: 2 days
    }
    final all = trainingsOf(sessions, const []);
    final period = progressPeriodFor(StatsRange.weeks4, now: now);
    final stats = periodGoalStats(all, period, now: now);
    expect(stats.weeks, 4);
    expect(stats.averageActiveDays, 3);
    expect(stats.weeksOnGoal, 2);
  });

  test('load stats report total, weekly average and measurement coverage', () {
    final sessions = [
      _session(
        id: 'l1',
        start: base,
        duration: 60 * 60,
        group: 'l1',
        load: 360,
      ),
      _session(
        id: 'l2',
        start: base + 30 * 60 * 1000,
        duration: 30 * 60,
        group: 'l2',
      ),
    ];
    final stats = periodLoadStats(trainingsOf(sessions, const []), weeks: 4);
    expect(stats.total, 360);
    expect(stats.weeklyAverage, 90);
    expect(stats.measuredSessions, 1);
    expect(stats.totalSessions, 2);
    expect(stats.coverage, 0.5);
    expect(stats.hasEnoughData, isTrue);
  });
}
