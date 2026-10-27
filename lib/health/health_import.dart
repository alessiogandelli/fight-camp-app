// Turns a health batch into sessions, training groups and Health links.
//
// Pure: no IO, no platform calls. The caller persists the heart-rate series and
// applies the returned lists to the store. See
// docs/adr/0007-allenamenti-e-import-da-salute.md.
import '../models/types.dart';
import '../lib/stats.dart';
import '../training/training.dart';
import 'health_source.dart';

/// A heart-rate series to persist for one Health workout.
class HealthSeriesWrite {
  final String externalId;
  final List<HeartSample> samples;
  const HealthSeriesWrite(this.externalId, this.samples);
}

/// Distance intervals to persist for one workout, used for km splits.
class HealthDistanceWrite {
  final String externalId;
  final List<DistanceSample> samples;
  const HealthDistanceWrite(this.externalId, this.samples);
}

class HealthImportPlan {
  /// Full replacement lists, ready to be stored.
  final List<SessionRecord> sessions;
  final List<HealthLink> links;
  final List<HealthSeriesWrite> series;
  final List<HealthDistanceWrite> distanceSeries;

  /// Workouts that became a new training (no app session to attach to).
  final int newSessions;

  /// Workouts attached to a training that already existed.
  final int attachedWorkouts;

  /// Already imported, or recorded twice by different apps.
  final int skippedWorkouts;

  /// Existing workouts that gained effort/distance data during this pass.
  final int enrichedWorkouts;

  const HealthImportPlan({
    required this.sessions,
    required this.links,
    required this.series,
    this.distanceSeries = const [],
    this.newSessions = 0,
    this.attachedWorkouts = 0,
    this.skippedWorkouts = 0,
    this.enrichedWorkouts = 0,
  });

  bool get hasChanges =>
      newSessions > 0 ||
      attachedWorkouts > 0 ||
      enrichedWorkouts > 0 ||
      distanceSeries.isNotEmpty;
}

/// Two records describe the same effort when they start close together and
/// overlap for at least half of the shorter one — the same run written by the
/// Watch and by a third-party app.
const _duplicateStartWindowMs = 10 * 60 * 1000;

HealthImportPlan planHealthImport({
  required AppData data,
  required HealthBatch batch,
  required Lang lang,
  required String Function() newId,
}) {
  final sessions = [...data.sessions];
  final links = [...data.healthLinks];
  final series = <HealthSeriesWrite>[];
  final distanceSeries = <HealthDistanceWrite>[];

  var newSessions = 0;
  var attached = 0;
  var skipped = 0;
  var enriched = 0;

  final workouts = [...batch.workouts]
    ..sort((a, b) => a.start.compareTo(b.start));

  for (final w in workouts) {
    final existingIndex = links.indexWhere((l) => l.externalId == w.externalId);
    if (existingIndex >= 0) {
      final existing = links[existingIndex];
      final gainedEffort =
          w.effortScore != null && existing.effortScore != w.effortScore;
      final gainedDistance = w.distanceSamples.isNotEmpty;
      if (gainedEffort || gainedDistance) {
        enriched++;
        if (gainedEffort) {
          links[existingIndex] = existing.copyWith(effortScore: w.effortScore);
          _applyEffortToGroup(sessions, existing.groupId, w, w.effortScore!);
        }
        if (gainedDistance) {
          distanceSeries.add(
            HealthDistanceWrite(w.externalId, w.distanceSamples),
          );
        }
      }
      skipped++;
      continue;
    }
    if (_isDuplicate(w, links)) {
      skipped++;
      continue;
    }

    final workoutMs = w.end - w.start;
    final candidates = sessions.where((s) {
      final sessionMs = s.duration * 1000;
      final overlap = _overlap(w.start, w.end, sessionStart(s), sessionEnd(s));
      final shorter = sessionMs < workoutMs ? sessionMs : workoutMs;
      // At least half of the shorter of the two, and never less than two
      // minutes: a Watch workout started before the timer still counts, and a
      // stray overlap at the edge does not.
      return overlap >= 2 * 60 * 1000 && overlap * 2 >= shorter;
    }).toList();

    final hr = _hrWindow(batch.samples, w.start, w.end);
    final link = HealthLink(
      externalId: w.externalId,
      groupId: '',
      start: w.start,
      end: w.end,
      activity: w.activity,
      sourceName: w.sourceName,
      distanceKm: w.distanceKm,
      energyKcal: w.energyKcal,
      avgHr: hr?.avg,
      maxHr: hr?.max,
      effortScore: w.effortScore,
      hasSeries: _hasSamples(batch.samples, w.start, w.end),
    );
    if (link.hasSeries) {
      series.add(
        HealthSeriesWrite(
          w.externalId,
          _samplesIn(batch.samples, w.start, w.end),
        ),
      );
    }
    if (w.distanceSamples.isNotEmpty) {
      distanceSeries.add(HealthDistanceWrite(w.externalId, w.distanceSamples));
    }

    if (candidates.isEmpty) {
      final type = workoutTypeForActivity(w.activity);
      final duration = w.durationSec;
      final group = newId();
      sessions.add(
        SessionRecord(
          id: newId(),
          // `date` is the recording moment: the workout's end.
          date: w.end,
          type: type,
          source: 'health',
          name: workoutTypeLabel(type, lang).toUpperCase(),
          duration: duration,
          rpe: w.effortScore,
          load: w.effortScore == null
              ? 0
              : computeLoad(duration, w.effortScore),
          running: type == WorkoutType.running && w.distanceKm != null
              ? RunningExtra(
                  distanceKm: w.distanceKm,
                  paceSecPerKm: (duration / w.distanceKm!).round(),
                )
              : null,
          groupId: group,
          hrAvg: hr?.avg,
          hrMax: hr?.max,
        ),
      );
      links.add(link.copyWith(groupId: group));
      newSessions++;
      continue;
    }

    // Attach to the group of the earliest session and merge the others: the
    // workout proves they were one training.
    candidates.sort((a, b) => a.date.compareTo(b.date));
    final groups = <String>{};
    for (final s in candidates) {
      groups.add(groupIdOf(s));
    }
    final target = groupIdOf(candidates.first);
    for (var i = 0; i < sessions.length; i++) {
      final s = sessions[i];
      if (!groups.contains(groupIdOf(s))) continue;
      final inWindow =
          _overlap(w.start, w.end, sessionStart(s), sessionEnd(s)) > 0;
      final sessionHr = inWindow
          ? _hrWindow(batch.samples, sessionStart(s), sessionEnd(s))
          : null;
      sessions[i] = _withGroupHrEffort(
        s,
        target,
        sessionHr?.avg ?? s.hrAvg,
        sessionHr?.max ?? s.hrMax,
        w.effortScore,
      );
    }
    for (var i = 0; i < links.length; i++) {
      final l = links[i];
      if (groups.contains(l.groupId) && l.groupId != target) {
        links[i] = l.copyWith(groupId: target);
      }
    }
    links.add(link.copyWith(groupId: target));
    attached++;
  }

  return HealthImportPlan(
    sessions: sessions,
    links: links,
    series: series,
    distanceSeries: distanceSeries,
    newSessions: newSessions,
    attachedWorkouts: attached,
    skippedWorkouts: skipped,
    enrichedWorkouts: enriched,
  );
}

bool _isDuplicate(HealthWorkout w, List<HealthLink> links) {
  for (final l in links) {
    if (l.externalId == w.externalId) return true;
    final sameStart = (l.start - w.start).abs() <= _duplicateStartWindowMs;
    if (!sameStart) continue;
    final shorter = (l.end - l.start) < (w.end - w.start)
        ? (l.end - l.start)
        : (w.end - w.start);
    if (shorter > 0 &&
        _overlap(l.start, l.end, w.start, w.end) >= shorter ~/ 2) {
      return true;
    }
  }
  return false;
}

int _overlap(int aStart, int aEnd, int bStart, int bEnd) {
  final start = aStart > bStart ? aStart : bStart;
  final end = aEnd < bEnd ? aEnd : bEnd;
  return end - start;
}

List<HeartSample> _samplesIn(List<HeartSample> samples, int start, int end) => [
  for (final s in samples)
    if (s.ms >= start && s.ms <= end) s,
];

bool _hasSamples(List<HeartSample> samples, int start, int end) =>
    samples.any((s) => s.ms >= start && s.ms <= end);

({int avg, int max})? _hrWindow(List<HeartSample> samples, int start, int end) {
  var sum = 0;
  var count = 0;
  var max = 0;
  for (final s in samples) {
    if (s.ms < start || s.ms > end) continue;
    sum += s.bpm;
    count++;
    if (s.bpm > max) max = s.bpm;
  }
  if (count == 0) return null;
  return (avg: (sum / count).round(), max: max);
}

SessionRecord _withGroupHrEffort(
  SessionRecord s,
  String groupId,
  int? hrAvg,
  int? hrMax,
  int? effort,
) {
  final inheritedEffort = s.rpe == null ? effort : null;
  return s.copyWith(
    groupId: groupId,
    hrAvg: hrAvg,
    hrMax: hrMax,
    rpe: inheritedEffort,
    load: inheritedEffort == null
        ? s.load
        : computeLoad(s.duration, inheritedEffort),
  );
}

/// Applies a workout effort to sessions of a group that don't have an RPE yet.
void _applyEffortToGroup(
  List<SessionRecord> sessions,
  String groupId,
  HealthWorkout workout,
  int effort,
) {
  for (var i = 0; i < sessions.length; i++) {
    final s = sessions[i];
    if (s.groupId != groupId || s.rpe != null) continue;
    if (_overlap(workout.start, workout.end, sessionStart(s), sessionEnd(s)) <=
        0) {
      continue;
    }
    sessions[i] = s.copyWith(
      rpe: effort,
      load: computeLoad(s.duration, effort),
    );
  }
}
