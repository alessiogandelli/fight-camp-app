// Read-side calculations for the redesigned Progress page.
//
// Everything here works on [Training] groups, the unit the user actually
// recognises: warm-up + bag + stretching is one workout, not three. Widgets
// receive these values instead of reinterpreting sessions and Health links on
// their own.
import '../models/types.dart';
import '../training/training.dart';
import 'format.dart';
import 'stats.dart';

class ProgressSummary {
  final int workouts;
  final int durationSec;
  final int activeDays;

  const ProgressSummary({
    required this.workouts,
    required this.durationSec,
    required this.activeDays,
  });

  int get minutes => (durationSec / 60).round();
}

/// One navigable dashboard window. Current windows are open-ended; past
/// windows have explicit start/end bounds.
class ProgressPeriod {
  final StatsRange range;
  final int offset;
  final StatsPeriod current;
  final StatsPeriod? previous;
  final DateTime? start;
  final DateTime? end;
  final int weeks;
  final bool isCurrent;

  const ProgressPeriod({
    required this.range,
    required this.offset,
    required this.current,
    required this.previous,
    required this.start,
    required this.end,
    required this.weeks,
    required this.isCurrent,
  });
}

ProgressPeriod progressPeriodFor(
  StatsRange range, {
  int offset = 0,
  DateTime? now,
}) {
  final n = now ?? DateTime.now();
  final thisWeek = startOfWeek(n);
  switch (range) {
    case StatsRange.week:
      final start = _shiftDate(thisWeek, -offset * 7);
      final end = offset == 0 ? null : _shiftDate(start, 7);
      return ProgressPeriod(
        range: range,
        offset: offset,
        current: StatsPeriod(start, end),
        previous: StatsPeriod(_shiftDate(start, -7), start),
        start: start,
        end: end,
        weeks: 1,
        isCurrent: offset == 0,
      );
    case StatsRange.weeks4:
      final start = _shiftDate(thisWeek, -(21 + offset * 28));
      final end = offset == 0 ? null : _shiftDate(start, 28);
      return ProgressPeriod(
        range: range,
        offset: offset,
        current: StatsPeriod(start, end),
        previous: StatsPeriod(_shiftDate(start, -28), start),
        start: start,
        end: end,
        weeks: 4,
        isCurrent: offset == 0,
      );
    case StatsRange.all:
      return const ProgressPeriod(
        range: StatsRange.all,
        offset: 0,
        current: StatsPeriod(null, null),
        previous: null,
        start: null,
        end: null,
        weeks: 0,
        isCurrent: true,
      );
  }
}

/// How many blocks of [range] can be navigated before reaching the first
/// recorded training.
int maxProgressOffset(
  StatsRange range,
  Iterable<Training> trainings, {
  DateTime? now,
}) {
  if (range == StatsRange.all) return 0;
  if (trainings.isEmpty) return 0;
  final n = now ?? DateTime.now();
  final earliest = trainings
      .map((t) => t.start)
      .reduce((a, b) => a < b ? a : b);
  final currentStart = _shiftDate(
    startOfWeek(n),
    range == StatsRange.weeks4 ? -21 : 0,
  );
  final earliestWeek = startOfWeek(
    DateTime.fromMillisecondsSinceEpoch(earliest),
  );
  final weeks = _calendarDaysBetween(currentStart, earliestWeek) ~/ 7;
  if (weeks <= 0) return 0;
  return range == StatsRange.weeks4 ? weeks ~/ 4 : weeks;
}

int weeksSpannedBy(ProgressPeriod period, Iterable<Training> trainings) {
  if (period.weeks > 0) return period.weeks;
  if (trainings.isEmpty) return 1;
  final earliest = trainings
      .map((t) => t.start)
      .reduce((a, b) => a < b ? a : b);
  final start = startOfWeek(DateTime.fromMillisecondsSinceEpoch(earliest));
  final end = startOfWeek(DateTime.now());
  return (_calendarDaysBetween(end, start) ~/ 7 + 1).clamp(1, 520);
}

class PeriodGoalStats {
  final double averageActiveDays;
  final int weeksOnGoal;
  final int weeks;
  final int goal;

  const PeriodGoalStats({
    required this.averageActiveDays,
    required this.weeksOnGoal,
    required this.weeks,
    required this.goal,
  });
}

PeriodGoalStats periodGoalStats(
  Iterable<Training> trainings,
  ProgressPeriod period, {
  int goal = 4,
  DateTime? now,
}) {
  final weeks = weeksSpannedBy(period, trainings);
  final start = period.start;
  if (start == null) {
    final earliest = trainings.isEmpty
        ? (now ?? DateTime.now())
        : DateTime.fromMillisecondsSinceEpoch(
            trainings.map((t) => t.start).reduce((a, b) => a < b ? a : b),
          );
    return _goalStatsInWindow(trainings, startOfWeek(earliest), weeks, goal);
  }
  return _goalStatsInWindow(trainings, start, weeks, goal);
}

PeriodGoalStats _goalStatsInWindow(
  Iterable<Training> trainings,
  DateTime start,
  int weeks,
  int goal,
) {
  final daysByWeek = <int, Set<String>>{};
  for (final training in trainings) {
    final date = DateTime.fromMillisecondsSinceEpoch(training.start);
    final diff = _calendarDaysBetween(startOfWeek(date), startOfWeek(start));
    final week = diff ~/ 7;
    if (week < 0 || week >= weeks) continue;
    daysByWeek.putIfAbsent(week, () => {}).add(_dayKey(training.start));
  }
  var totalDays = 0;
  var weeksOnGoal = 0;
  for (var i = 0; i < weeks; i++) {
    final days = daysByWeek[i]?.length ?? 0;
    totalDays += days;
    if (days >= goal) weeksOnGoal++;
  }
  return PeriodGoalStats(
    averageActiveDays: weeks == 0 ? 0 : totalDays / weeks,
    weeksOnGoal: weeksOnGoal,
    weeks: weeks,
    goal: goal,
  );
}

class PeriodLoadStats {
  final int total;
  final int measuredSessions;
  final int totalSessions;
  final double weeklyAverage;

  const PeriodLoadStats({
    required this.total,
    required this.measuredSessions,
    required this.totalSessions,
    required this.weeklyAverage,
  });

  double get coverage =>
      totalSessions == 0 ? 0 : measuredSessions / totalSessions;
  bool get hasEnoughData =>
      measuredSessions > 0 && (totalSessions <= 1 || coverage >= 0.5);
}

PeriodLoadStats periodLoadStats(
  Iterable<Training> trainings, {
  required int weeks,
}) {
  var total = 0;
  var measured = 0;
  var sessions = 0;
  for (final training in trainings) {
    for (final session in training.sessions) {
      sessions++;
      if (session.load > 0) {
        measured++;
        total += session.load;
      }
    }
  }
  final normalizedWeeks = weeks <= 0 ? 1 : weeks;
  return PeriodLoadStats(
    total: total,
    measuredSessions: measured,
    totalSessions: sessions,
    weeklyAverage: total / normalizedWeeks,
  );
}

/// Trainings whose start falls inside [period]. A training belongs to the
/// period it started in, even when a long session crosses midnight.
List<Training> trainingsInPeriod(
  Iterable<Training> trainings,
  StatsPeriod period,
) => trainings.where((t) => period.contains(t.start)).toList();

ProgressSummary summarizeProgress(Iterable<Training> trainings) {
  var durationSec = 0;
  final days = <String>{};
  var count = 0;
  for (final training in trainings) {
    count++;
    durationSec += training.durationSec;
    days.add(_dayKey(training.start));
  }
  return ProgressSummary(
    workouts: count,
    durationSec: durationSec,
    activeDays: days.length,
  );
}

class ProgressDay {
  final DateTime date;
  final int durationSec;
  final int workouts;
  final Map<WorkoutType, int> typeSeconds;

  const ProgressDay({
    required this.date,
    required this.durationSec,
    required this.workouts,
    required this.typeSeconds,
  });

  int get minutes => (durationSec / 60).round();
}

/// Calendar-day totals for the activity grid, keyed by local date.
Map<String, ProgressDay> progressDaysByKey(Iterable<Training> trainings) {
  final out = <String, ProgressDay>{};
  for (final training in trainings) {
    final date = DateTime.fromMillisecondsSinceEpoch(training.start);
    final day = DateTime(date.year, date.month, date.day);
    final key = _dayKey(training.start);
    final current = out[key];
    final types = {...?current?.typeSeconds};
    for (final session in training.sessions) {
      types[session.type] = (types[session.type] ?? 0) + session.duration;
    }
    out[key] = ProgressDay(
      date: day,
      durationSec: (current?.durationSec ?? 0) + training.durationSec,
      workouts: (current?.workouts ?? 0) + 1,
      typeSeconds: types,
    );
  }
  return out;
}

/// Trainings that started on [dateKey], newest first.
List<Training> trainingsOnDay(Iterable<Training> trainings, String dateKey) =>
    trainings.where((t) => _dayKey(t.start) == dateKey).toList()
      ..sort((a, b) => b.start.compareTo(a.start));

class TrainingMixRow {
  final WorkoutType type;
  final int sessionCount;
  final int durationSec;
  final int rounds;
  final double? distanceKm;

  const TrainingMixRow({
    required this.type,
    required this.sessionCount,
    required this.durationSec,
    required this.rounds,
    required this.distanceKm,
  });

  int get minutes => (durationSec / 60).round();
}

/// Time spent per session type. A mixed training contributes each of its
/// member sessions to the matching row, so warm-up, bag and stretching remain
/// visible instead of being collapsed under the first session's type.
///
/// Running distance comes from [Training.distanceKm] once per training, which
/// also covers distances that only exist on a Health link and avoids counting
/// an app session and its linked Health workout twice.
List<TrainingMixRow> trainingMix(Iterable<Training> trainings) {
  final sessions = <WorkoutType, int>{};
  final durations = <WorkoutType, int>{};
  final rounds = <WorkoutType, int>{};
  final distances = <WorkoutType, double>{};

  for (final training in trainings) {
    for (final session in training.sessions) {
      sessions[session.type] = (sessions[session.type] ?? 0) + 1;
      durations[session.type] =
          (durations[session.type] ?? 0) + session.duration;
      rounds[session.type] =
          (rounds[session.type] ?? 0) + (session.roundsCompleted ?? 0);
    }
    final hasRunning = training.sessions.any(
      (s) => s.type == WorkoutType.running,
    );
    final distance = training.distanceKm;
    if (hasRunning && distance != null) {
      distances[WorkoutType.running] =
          (distances[WorkoutType.running] ?? 0) + distance;
    }
  }

  final rows = [
    for (final type in sessions.keys)
      TrainingMixRow(
        type: type,
        sessionCount: sessions[type]!,
        durationSec: durations[type] ?? 0,
        rounds: rounds[type] ?? 0,
        distanceKm: distances[type],
      ),
  ];
  rows.sort((a, b) {
    final byDuration = b.durationSec.compareTo(a.durationSec);
    if (byDuration != 0) return byDuration;
    final byCount = b.sessionCount.compareTo(a.sessionCount);
    if (byCount != 0) return byCount;
    return a.type.index.compareTo(b.type.index);
  });
  return rows;
}

enum TrainingSourceFilter { all, app, health }

/// Combined Log filters: period AND search AND type AND source.
List<Training> filterTrainings(
  Iterable<Training> trainings, {
  String query = '',
  Set<WorkoutType> types = const {},
  TrainingSourceFilter source = TrainingSourceFilter.all,
  String? dayKey,
}) {
  final q = query.trim().toLowerCase();
  return trainings.where((training) {
    if (dayKey != null && _dayKey(training.start) != dayKey) return false;
    if (types.isNotEmpty &&
        !training.sessions.any((s) => types.contains(s.type))) {
      return false;
    }
    if (source == TrainingSourceFilter.app &&
        !training.sessions.any(_isAppSession)) {
      return false;
    }
    if (source == TrainingSourceFilter.health && !training.hasHealth) {
      return false;
    }
    if (q.isEmpty) return true;
    return trainingMatchesQuery(training, q);
  }).toList();
}

int totalLoad(Iterable<Training> trainings) =>
    trainings.fold(0, (sum, training) => sum + training.load);

List<SessionRecord> uncategorizedSessions(Iterable<Training> trainings) => [
  for (final training in trainings)
    for (final session in training.sessions)
      if (session.type == WorkoutType.other) session,
];

bool trainingMatchesQuery(Training training, String lowerCaseQuery) {
  final haystack = <String>[
    training.name,
    for (final s in training.sessions) ...[
      s.name,
      s.notes ?? '',
      for (final c in s.combosUsed ?? const <NameRef>[]) c.name,
      for (final e in s.strength ?? const <StrengthEntry>[]) e.exercise,
    ],
  ];
  return haystack.any((value) => value.toLowerCase().contains(lowerCaseQuery));
}

bool _isAppSession(SessionRecord session) =>
    session.source == 'timer' || session.source == 'manual';

String _dayKey(int timestamp) =>
    dateKey(DateTime.fromMillisecondsSinceEpoch(timestamp));

DateTime _shiftDate(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

int _calendarDaysBetween(DateTime later, DateTime earlier) => DateTime.utc(
  later.year,
  later.month,
  later.day,
).difference(DateTime.utc(earlier.year, earlier.month, earlier.day)).inDays;
