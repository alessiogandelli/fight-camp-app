// Stats helpers ported from src/lib/stats.ts.
import '../models/types.dart';
import 'format.dart';

int computeLoad(int durationSec, int? rpe) {
  if (rpe == null || rpe <= 0) return 0;
  return ((durationSec / 60) * rpe).round();
}

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime startOfWeek(DateTime d) {
  final x = startOfDay(d);
  final day = (x.weekday + 6) % 7; // Monday-based
  return x.subtract(Duration(days: day));
}

class Streaks {
  final int current;
  final int longest;
  const Streaks(this.current, this.longest);
}

Streaks streaks(List<SessionRecord> sessions) {
  final days = sessions
      .map((s) => dateKey(DateTime.fromMillisecondsSinceEpoch(s.date)))
      .toSet();
  var longest = 0;
  final sorted = days.toList()..sort();
  var run = 0;
  DateTime? prev;
  for (final k in sorted) {
    final parts = k.split('-').map(int.parse).toList();
    final d = DateTime(parts[0], parts[1], parts[2]);
    if (prev != null && d.difference(prev).inDays == 1) {
      run += 1;
    } else {
      run = 1;
    }
    if (run > longest) longest = run;
    prev = d;
  }
  var current = 0;
  final now = DateTime.now();
  var cursor = startOfDay(now);
  if (!days.contains(dateKey(cursor)))
    cursor = cursor.subtract(const Duration(days: 1));
  while (days.contains(dateKey(cursor))) {
    current += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return Streaks(current, longest);
}

double sessionsPerWeek(List<SessionRecord> sessions, [int windowWeeks = 4]) {
  final cutoff =
      DateTime.now().millisecondsSinceEpoch - windowWeeks * 7 * 86400000;
  final n = sessions.where((s) => s.date >= cutoff).length;
  return ((n / windowWeeks) * 10).round() / 10;
}

int weeklyStreak(List<SessionRecord> sessions) {
  final weeks = sessions
      .map(
        (s) =>
            dateKey(startOfWeek(DateTime.fromMillisecondsSinceEpoch(s.date))),
      )
      .toSet();
  var cursor = startOfWeek(DateTime.now());
  if (!weeks.contains(dateKey(cursor))) {
    cursor = cursor.subtract(const Duration(days: 7));
  }
  var count = 0;
  while (weeks.contains(dateKey(cursor))) {
    count += 1;
    cursor = cursor.subtract(const Duration(days: 7));
  }
  return count;
}

int sessionsThisWeek(List<SessionRecord> sessions) {
  final key = dateKey(startOfWeek(DateTime.now()));
  return sessions
      .where(
        (s) =>
            dateKey(startOfWeek(DateTime.fromMillisecondsSinceEpoch(s.date))) ==
            key,
      )
      .length;
}

class LoadBucket {
  final String label;
  final int load;
  final int sessions;
  final int minutes;
  final int rounds;
  const LoadBucket(
    this.label,
    this.load,
    this.sessions,
    this.minutes, [
    this.rounds = 0,
  ]);
}

int _roundsOf(List<SessionRecord> sessions) =>
    sessions.fold(0, (a, s) => a + (s.roundsCompleted ?? 0));

List<LoadBucket> weeklyBuckets(List<SessionRecord> sessions, [int weeks = 8]) {
  final out = <LoadBucket>[];
  final thisWeek = startOfWeek(DateTime.now());
  for (var i = weeks - 1; i >= 0; i--) {
    final start = thisWeek.subtract(Duration(days: i * 7));
    final end = start.add(const Duration(days: 7));
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;
    final inRange = sessions
        .where((s) => s.date >= startMs && s.date < endMs)
        .toList();
    out.add(
      LoadBucket(
        '${start.day}/${start.month}',
        inRange.fold(0, (a, s) => a + s.load),
        inRange.length,
        (inRange.fold(0, (a, s) => a + s.duration) / 60).round(),
        _roundsOf(inRange),
      ),
    );
  }
  return out;
}

const _itMonthsShort = [
  'gen',
  'feb',
  'mar',
  'apr',
  'mag',
  'giu',
  'lug',
  'ago',
  'set',
  'ott',
  'nov',
  'dic',
];

List<LoadBucket> monthlyBuckets(
  List<SessionRecord> sessions, {
  int months = 6,
  Lang lang = Lang.it,
}) {
  final out = <LoadBucket>[];
  final now = DateTime.now();
  for (var i = months - 1; i >= 0; i--) {
    var year = now.year;
    var month = now.month - i;
    while (month <= 0) {
      month += 12;
      year -= 1;
    }
    final start = DateTime(year, month, 1);
    var endMonth = month + 1;
    var endYear = year;
    if (endMonth > 12) {
      endMonth = 1;
      endYear += 1;
    }
    final end = DateTime(endYear, endMonth, 1);
    final inRange = sessions
        .where(
          (s) =>
              s.date >= start.millisecondsSinceEpoch &&
              s.date < end.millisecondsSinceEpoch,
        )
        .toList();
    final label = lang == Lang.it
        ? _itMonthsShort[start.month - 1]
        : const [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ][start.month - 1];
    out.add(
      LoadBucket(
        label,
        inRange.fold(0, (a, s) => a + s.load),
        inRange.length,
        (inRange.fold(0, (a, s) => a + s.duration) / 60).round(),
        _roundsOf(inRange),
      ),
    );
  }
  return out;
}

class VolumeStats {
  final int sessions;
  final int minutes;
  final int rounds;
  final int workSeconds;
  final int load;
  const VolumeStats(
    this.sessions,
    this.minutes,
    this.rounds,
    this.workSeconds,
    this.load,
  );
}

VolumeStats volumeStats(List<SessionRecord> sessions) => VolumeStats(
  sessions.length,
  (sessions.fold<int>(0, (a, s) => a + s.duration) / 60).round(),
  sessions.fold(0, (a, s) => a + (s.roundsCompleted ?? 0)),
  sessions.fold(0, (a, s) => a + (s.workDuration ?? 0)),
  sessions.fold(0, (a, s) => a + s.load),
);

List<SessionRecord> filterSince(List<SessionRecord> sessions, [int? days]) {
  if (days == null) return sessions;
  final cutoff = DateTime.now().millisecondsSinceEpoch - days * 86400000;
  return sessions.where((s) => s.date >= cutoff).toList();
}

List<NameCount> comboUsageStats(List<SessionRecord> sessions) {
  // Returns NameRef list where `name` is the label and count is carried separately.
  final counts = <String, ({String name, int count})>{};
  for (final s in sessions) {
    for (final c in s.combosUsed ?? const <NameRef>[]) {
      final cur = counts[c.id];
      if (cur != null) {
        counts[c.id] = (name: cur.name, count: cur.count + 1);
      } else {
        counts[c.id] = (name: c.name, count: 1);
      }
    }
  }
  final entries =
      counts.entries
          .map((e) => NameCount(e.key, e.value.name, e.value.count))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));
  return entries;
}

List<NameCount> techniqueUsageStats(List<SessionRecord> sessions) {
  final map = <String, int>{};
  final names = <String, String>{};
  for (final s in sessions) {
    for (final t in s.techniqueUsage ?? const <UsageRef>[]) {
      names[t.id] ??= t.name;
      map[t.id] = (map[t.id] ?? 0) + t.count;
    }
  }
  final entries =
      map.entries
          .map((e) => NameCount(e.key, names[e.key] ?? '', e.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));
  return entries;
}

class NameCount implements NameRef {
  @override
  final String id;
  @override
  final String name;
  final int count;
  const NameCount(this.id, this.name, this.count);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class BagStats {
  final int sessions;
  final int rounds;
  final int seconds;
  const BagStats(this.sessions, this.rounds, this.seconds);
}

BagStats bagStats(List<SessionRecord> sessions) {
  final bag = sessions.where((s) => s.type == WorkoutType.heavyBag).toList();
  return BagStats(
    bag.length,
    bag.fold(0, (a, s) => a + (s.roundsCompleted ?? 0)),
    bag.fold(0, (a, s) => a + (s.workDuration ?? s.duration)),
  );
}

/// The three training-oriented time windows shown on Progressi.
enum StatsRange { week, weeks4, all }

/// A half-open time window ([start] inclusive, [end] exclusive). A null bound
/// means "no bound" (beginning of time / now).
class StatsPeriod {
  final DateTime? start;
  final DateTime? end;
  const StatsPeriod(this.start, this.end);

  bool contains(int ms) {
    if (start != null && ms < start!.millisecondsSinceEpoch) return false;
    if (end != null && ms >= end!.millisecondsSinceEpoch) return false;
    return true;
  }
}

/// Window for [range]: the current calendar week, the 4 calendar weeks ending
/// today, or all of history.
StatsPeriod periodFor(StatsRange range, {DateTime? now}) {
  final n = now ?? DateTime.now();
  switch (range) {
    case StatsRange.week:
      return StatsPeriod(startOfWeek(n), null);
    case StatsRange.weeks4:
      return StatsPeriod(
        startOfWeek(n).subtract(const Duration(days: 21)),
        null,
      );
    case StatsRange.all:
      return const StatsPeriod(null, null);
  }
}

/// The window immediately before [range] (same length), or null for all-time.
StatsPeriod? previousPeriodFor(StatsRange range, {DateTime? now}) {
  final n = now ?? DateTime.now();
  switch (range) {
    case StatsRange.week:
      final thisWeek = startOfWeek(n);
      return StatsPeriod(thisWeek.subtract(const Duration(days: 7)), thisWeek);
    case StatsRange.weeks4:
      final start = startOfWeek(n).subtract(const Duration(days: 21));
      return StatsPeriod(start.subtract(const Duration(days: 28)), start);
    case StatsRange.all:
      return null;
  }
}

List<SessionRecord> sessionsInPeriod(
  List<SessionRecord> sessions,
  StatsPeriod period,
) => sessions.where((s) => period.contains(s.date)).toList();

/// Whole-percent change from [previous] to [current]. Null when there is no
/// baseline to compare against (previous is zero), so callers can hide
/// statistically meaningless deltas.
int? percentChange(num current, num previous) {
  if (previous <= 0) return null;
  return ((current - previous) / previous * 100).round();
}

/// Total number of combinations performed across [sessions].
int combosUsedCount(List<SessionRecord> sessions) =>
    sessions.fold(0, (a, s) => a + (s.combosUsed?.length ?? 0));

class PersonalRecords {
  final int maxRounds;
  final int longestSessionSeconds;
  final int totalCombos;
  final int longestStreak;

  const PersonalRecords({
    required this.maxRounds,
    required this.longestSessionSeconds,
    required this.totalCombos,
    required this.longestStreak,
  });

  bool get isEmpty =>
      maxRounds == 0 &&
      longestSessionSeconds == 0 &&
      totalCombos == 0 &&
      longestStreak == 0;
}

PersonalRecords personalRecords(List<SessionRecord> sessions) {
  var maxRounds = 0;
  var longest = 0;
  var combos = 0;
  for (final s in sessions) {
    final r = s.roundsCompleted ?? 0;
    if (r > maxRounds) maxRounds = r;
    if (s.duration > longest) longest = s.duration;
    combos += s.combosUsed?.length ?? 0;
  }
  return PersonalRecords(
    maxRounds: maxRounds,
    longestSessionSeconds: longest,
    totalCombos: combos,
    longestStreak: streaks(sessions).longest,
  );
}
