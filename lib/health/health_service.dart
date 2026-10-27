// Orchestrates one Health sync: ask access, fetch, plan, persist series, apply.
import '../data/store.dart';
import '../lib/format.dart';
import 'health_import.dart';
import 'health_kit_source.dart';
import 'health_source.dart';
import 'hr_series.dart';

/// The default service used by the app. Tests build their own with fakes.
final healthService = HealthService();

class HealthSyncResult {
  final bool available;
  final bool ran;
  final int newSessions;
  final int attachedWorkouts;
  final int skippedWorkouts;
  final int enrichedWorkouts;
  final bool backfilled;

  const HealthSyncResult({
    this.available = true,
    this.ran = true,
    this.newSessions = 0,
    this.attachedWorkouts = 0,
    this.skippedWorkouts = 0,
    this.enrichedWorkouts = 0,
    this.backfilled = false,
  });

  static const unavailable = HealthSyncResult(available: false, ran: false);
  static const skippedRun = HealthSyncResult(ran: false);

  int get importedCount => newSessions + attachedWorkouts;
  bool get dataUpdated => importedCount > 0 || enrichedWorkouts > 0;
}

class HealthService {
  final HealthSource source;
  final HrSeriesStore series;

  /// First import covers this much history; later syncs re-read a small
  /// overlap so workouts written late by another app are still caught.
  static const firstWindow = Duration(days: 30);
  static const catchUpCap = Duration(days: 90);
  static const enrichmentWindow = Duration(days: 90);
  static const overlap = Duration(days: 2);
  static const autoSyncInterval = Duration(hours: 1);

  HealthService({HealthSource? source, HrSeriesStore? series})
    : source = source ?? HealthKitSource(),
      series = series ?? FileHrSeriesStore();

  Future<bool> available() => source.available();

  /// Latest resting heart rate, used as a Karvonen suggestion in Settings.
  Future<int?> restingHeartRateSuggestion() => source.latestRestingHeartRate();

  /// Syncs even when the automatic toggle is off (the "Importa ora" button).
  Future<HealthSyncResult> syncNow(AppStore store) =>
      _sync(store, askAccess: true);

  /// Called when the app opens: no permission sheet, at most once per hour,
  /// only when the user enabled the sync.
  Future<HealthSyncResult> maybeAutoSync(AppStore store) async {
    final settings = store.data.settings;
    if (!settings.healthSync) return HealthSyncResult.skippedRun;
    final last = settings.healthLastSync;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (last != null && now - last < autoSyncInterval.inMilliseconds) {
      return HealthSyncResult.skippedRun;
    }
    return _sync(store, askAccess: false);
  }

  Future<HealthSyncResult> _sync(
    AppStore store, {
    required bool askAccess,
  }) async {
    if (!await source.available()) return HealthSyncResult.unavailable;
    if (askAccess) await source.requestAccess();

    final now = DateTime.now();
    final last = store.data.settings.healthLastSync;
    final needsBackfill = !store.data.settings.healthEnriched;
    final DateTime from;
    if (needsBackfill && askAccess) {
      from = now.subtract(enrichmentWindow);
    } else if (last == null) {
      from = now.subtract(firstWindow);
    } else {
      final overlapFrom = DateTime.fromMillisecondsSinceEpoch(
        last,
      ).subtract(overlap);
      final cap = now.subtract(catchUpCap);
      from = overlapFrom.isBefore(cap) ? cap : overlapFrom;
    }

    final batch = await source.fetch(from: from, to: now);
    final plan = planHealthImport(
      data: store.data,
      batch: batch,
      lang: store.lang,
      newId: uid,
    );
    for (final write in plan.series) {
      await series.write(write.externalId, write.samples);
    }
    for (final write in plan.distanceSeries) {
      await series.writeDistance(write.externalId, write.samples);
    }
    await series.prune({for (final l in plan.links) l.externalId});
    store.applyHealthImport(
      sessions: plan.sessions,
      links: plan.links,
      syncedAt: now.millisecondsSinceEpoch,
    );
    if (needsBackfill &&
        askAccess &&
        (batch.workouts.isNotEmpty || plan.hasChanges)) {
      store.setSettings(healthEnriched: true);
    }
    return HealthSyncResult(
      newSessions: plan.newSessions,
      attachedWorkouts: plan.attachedWorkouts,
      skippedWorkouts: plan.skippedWorkouts,
      enrichedWorkouts: plan.enrichedWorkouts,
      backfilled: needsBackfill,
    );
  }
}
