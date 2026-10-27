// A training is what really happened in the gym: one or more app sessions
// performed back to back, plus the Apple Health workouts that covered them.
//
// The app records the pieces (a timer session for the warm-up, one for the bag,
// one for stretching); `Training` is the read-side aggregate Progressi and
// Storico show. See docs/adr/0007-allenamenti-e-import-da-salute.md.
import '../models/types.dart';

/// Sessions separated by less than this belong to the same training.
const groupGapMs = 15 * 60 * 1000;

/// [SessionRecord.date] is the moment the session was recorded — its end — and
/// [SessionRecord.duration] its length, so the start is derived.
int sessionEnd(SessionRecord s) => s.date;
int sessionStart(SessionRecord s) => s.date - s.duration * 1000;

/// The group a session belongs to. A session without an explicit group is a
/// group of its own, so old data keeps working without a migration step.
String groupIdOf(SessionRecord s) => s.groupId ?? s.id;

/// Group id for a session that starts at [start] and ends at [end], reusing the
/// group of any session within [groupGapMs]. Returns null when it starts a new
/// training.
String? groupIdNear(Iterable<SessionRecord> sessions, int start, int end) {
  for (final s in sessions) {
    // Overlapping or close enough (in either direction).
    if (start <= sessionEnd(s) + groupGapMs &&
        sessionStart(s) <= end + groupGapMs) {
      return s.groupId;
    }
  }
  return null;
}

/// Assigns a group id to every session that has none, clustering sessions whose
/// gap is at most [groupGapMs]. Deterministic and idempotent: safe to run on
/// every load and used by the storage v9 migration.
List<SessionRecord> assignGroupIds(
  List<SessionRecord> sessions,
  String Function() newId,
) {
  final sorted = [...sessions]..sort((a, b) => a.date.compareTo(b.date));
  final out = <SessionRecord>[];
  String? currentGroup;
  int? currentEnd;
  for (final s in sorted) {
    final close =
        currentGroup != null &&
        currentEnd != null &&
        sessionStart(s) <= currentEnd + groupGapMs;
    final group = s.groupId ?? (close ? currentGroup : newId());
    out.add(s.groupId == group ? s : _withGroup(s, group));
    if (!close || s.groupId != null) currentGroup = group;
    currentEnd = (close && currentEnd > sessionEnd(s))
        ? currentEnd
        : sessionEnd(s);
  }
  return out;
}

SessionRecord _withGroup(SessionRecord s, String groupId) =>
    s.copyWith(groupId: groupId);

/// One real-world training: the sessions plus the Health workouts covering it.
class Training {
  final String id;
  final List<SessionRecord> sessions;
  final List<HealthLink> links;

  const Training({
    required this.id,
    required this.sessions,
    this.links = const [],
  });

  bool get isEmpty => sessions.isEmpty && links.isEmpty;
  bool get hasHealth => links.isNotEmpty;
  bool get isImportedOnly =>
      sessions.isNotEmpty && sessions.every((s) => s.source == 'health');

  int get start {
    var v = sessions.isEmpty ? links.first.start : sessionStart(sessions.first);
    for (final s in sessions) {
      final start = sessionStart(s);
      if (start < v) v = start;
    }
    for (final l in links) {
      if (l.start < v) v = l.start;
    }
    return v;
  }

  int get end {
    var v = sessions.isEmpty ? links.first.end : sessionEnd(sessions.first);
    for (final s in sessions) {
      final e = sessionEnd(s);
      if (e > v) v = e;
    }
    for (final l in links) {
      if (l.end > v) v = l.end;
    }
    return v;
  }

  /// Sum of the app sessions' durations. Health workouts add no time: when they
  /// overlap a session they describe the same minutes, and when they don't they
  /// are imported as sessions themselves.
  int get durationSec => sessions.fold(0, (a, s) => a + s.duration);

  int get load => sessions.fold(0, (a, s) => a + s.load);

  WorkoutType get type =>
      sessions.isNotEmpty ? sessions.first.type : WorkoutType.other;

  String get name => sessions.isNotEmpty ? sessions.first.name : '';

  int? get avgHr {
    final perSession = _weightedHrAvg();
    if (perSession != null) return perSession;
    final withHr = links.where((l) => l.avgHr != null).toList();
    if (withHr.isEmpty) return null;
    final total = withHr.fold<int>(0, (a, l) => a + (l.end - l.start));
    if (total == 0) return withHr.first.avgHr;
    final sum = withHr.fold<int>(0, (a, l) => a + l.avgHr! * (l.end - l.start));
    return (sum / total).round();
  }

  int? get maxHr {
    int? v;
    for (final s in sessions) {
      if (s.hrMax != null && (v == null || s.hrMax! > v)) v = s.hrMax;
    }
    for (final l in links) {
      if (l.maxHr != null && (v == null || l.maxHr! > v)) v = l.maxHr;
    }
    return v;
  }

  int? get energyKcal {
    final values = links.where((l) => l.energyKcal != null).toList();
    if (values.isEmpty) return null;
    return values.fold<int>(0, (a, l) => a + l.energyKcal!);
  }

  Iterable<SessionRecord> get _runs =>
      sessions.where((s) => s.running?.distanceKm != null);

  /// Total distance of the runs in this training, or the Health workout's when
  /// no session carries one. Never both, to avoid counting twice.
  double? get distanceKm {
    final runs = _runs;
    if (runs.isNotEmpty) {
      return runs.fold<double>(0, (a, s) => a + s.running!.distanceKm!);
    }
    double? v;
    for (final l in links) {
      if (l.distanceKm != null && (v == null || l.distanceKm! > v)) {
        v = l.distanceKm;
      }
    }
    return v;
  }

  /// Average pace over the whole training (time / distance), not the average of
  /// the paces. Null when no run carries a distance.
  int? get paceSecPerKm {
    final runs = _runs.toList();
    if (runs.isEmpty) return null;
    final km = runs.fold<double>(0, (a, s) => a + s.running!.distanceKm!);
    if (km <= 0) return null;
    final sec = runs.fold<int>(0, (a, s) => a + s.duration);
    return (sec / km).round();
  }

  /// Average heart rate weighted by session duration, so a 3-minute warm-up
  /// does not weigh as much as a 30-minute bag round.
  int? _weightedHrAvg() {
    final withHr = sessions.where((s) => s.hrAvg != null).toList();
    if (withHr.isEmpty) return null;
    final total = withHr.fold<int>(0, (a, s) => a + s.duration);
    if (total == 0) return withHr.first.hrAvg;
    final sum = withHr.fold<int>(0, (a, s) => a + s.hrAvg! * s.duration);
    return (sum / total).round();
  }
}

/// Groups sessions and Health links into trainings, newest first.
List<Training> trainingsOf(
  List<SessionRecord> sessions,
  List<HealthLink> links,
) {
  final byGroup = <String, List<SessionRecord>>{};
  for (final s in sessions) {
    byGroup.putIfAbsent(groupIdOf(s), () => []).add(s);
  }
  final linksByGroup = <String, List<HealthLink>>{};
  for (final l in links) {
    linksByGroup.putIfAbsent(l.groupId, () => []).add(l);
  }
  final ids = {...byGroup.keys, ...linksByGroup.keys};
  final out = <Training>[];
  for (final id in ids) {
    final groupSessions = [...?byGroup[id]]
      ..sort((a, b) => a.date.compareTo(b.date));
    final groupLinks = [...?linksByGroup[id]];
    if (groupSessions.isEmpty && groupLinks.isEmpty) continue;
    out.add(Training(id: id, sessions: groupSessions, links: groupLinks));
  }
  out.sort((a, b) => b.start.compareTo(a.start));
  return out;
}

/// Number of distinct trainings represented by [sessions].
int trainingCount(Iterable<SessionRecord> sessions) =>
    sessions.map(groupIdOf).toSet().length;
