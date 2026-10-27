// Real implementation on top of the `health` plugin (HealthKit on iOS,
// Health Connect on Android). Read-only: the app never writes to Health.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

import 'health_source.dart';

class HealthKitSource implements HealthSource {
  final Health _health = Health();
  static const _native = MethodChannel('fight_camp/health_extra');
  bool _configured = false;

  static const _workoutTypes = [HealthDataType.WORKOUT];
  static const _hrTypes = [HealthDataType.HEART_RATE];

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<bool> available() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.iOS) return true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        return await _health.isHealthConnectAvailable();
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  @override
  Future<bool> requestAccess() async {
    if (!await available()) return false;
    await _ensureConfigured();
    // On iOS one native request covers workouts, HR, distance, effort and
    // resting HR, avoiding a second HealthKit permission sheet.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final nativeGranted = await _native.invokeMethod<bool>('requestAccess');
        if (nativeGranted != null) return nativeGranted;
      } catch (_) {
        // Fall back to the plugin's workout/HR authorization.
      }
    }
    try {
      return await _health.requestAuthorization(
        [..._workoutTypes, ..._hrTypes],
        permissions: const [HealthDataAccess.READ, HealthDataAccess.READ],
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<HealthBatch> fetch({
    required DateTime from,
    required DateTime to,
  }) async {
    if (!await available()) return HealthBatch.empty;
    await _ensureConfigured();
    try {
      final workouts = await _health.getHealthDataFromTypes(
        types: _workoutTypes,
        startTime: from,
        endTime: to,
      );
      final hr = await _health.getHealthDataFromTypes(
        types: _hrTypes,
        startTime: from,
        endTime: to,
      );
      final mapped = workouts.map(_workout).whereType<HealthWorkout>().toList();
      final enriched = await _enrichWorkouts(mapped);
      return HealthBatch(
        workouts: enriched,
        samples: hr.map(_sample).whereType<HeartSample>().toList(),
      );
    } catch (_) {
      return HealthBatch.empty;
    }
  }

  @override
  Future<int?> latestRestingHeartRate() async {
    if (!await available()) return null;
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;
    try {
      return await _native.invokeMethod<int>('latestRestingHeartRate');
    } catch (_) {
      return null;
    }
  }

  Future<List<HealthWorkout>> _enrichWorkouts(
    List<HealthWorkout> workouts,
  ) async {
    if (workouts.isEmpty || defaultTargetPlatform != TargetPlatform.iOS) {
      return workouts;
    }
    try {
      final raw = await _native.invokeMethod<List<dynamic>>('enrichWorkouts', {
        for (final workout in workouts)
          workout.externalId: {'start': workout.start, 'end': workout.end},
      });
      if (raw == null) return workouts;
      final byId = <String, Map<dynamic, dynamic>>{};
      for (final item in raw) {
        if (item is! Map) continue;
        final id = item['id'];
        if (id is String) byId[id] = item;
      }
      return [
        for (final workout in workouts)
          _withExtras(workout, byId[workout.externalId]),
      ];
    } catch (_) {
      return workouts;
    }
  }

  HealthWorkout _withExtras(
    HealthWorkout workout,
    Map<dynamic, dynamic>? extra,
  ) {
    if (extra == null) return workout;
    final effort = extra['effort'];
    final rawDistance = extra['distance'];
    final samples = <DistanceSample>[];
    if (rawDistance is List) {
      for (final point in rawDistance) {
        if (point is! Map) continue;
        samples.add(
          DistanceSample(
            (point['start'] as num).toInt(),
            (point['end'] as num).toInt(),
            (point['meters'] as num).toDouble(),
          ),
        );
      }
    }
    return HealthWorkout(
      externalId: workout.externalId,
      start: workout.start,
      end: workout.end,
      activity: workout.activity,
      sourceName: workout.sourceName,
      distanceKm: workout.distanceKm,
      energyKcal: workout.energyKcal,
      effortScore: effort is num ? effort.round() : null,
      distanceSamples: samples,
    );
  }

  HealthWorkout? _workout(HealthDataPoint p) {
    final value = p.value;
    if (value is! WorkoutHealthValue) return null;
    final start = p.dateFrom.millisecondsSinceEpoch;
    final end = p.dateTo.millisecondsSinceEpoch;
    if (end <= start) return null;
    return HealthWorkout(
      externalId: p.uuid,
      start: start,
      end: end,
      activity: value.workoutActivityType.name,
      sourceName: p.sourceName,
      distanceKm: _distanceKm(value),
      energyKcal: _energyKcal(value),
    );
  }

  HeartSample? _sample(HealthDataPoint p) {
    final value = p.value;
    if (value is! NumericHealthValue) return null;
    final bpm = value.numericValue.round();
    if (bpm <= 0) return null;
    return HeartSample(p.dateFrom.millisecondsSinceEpoch, bpm);
  }

  double? _distanceKm(WorkoutHealthValue v) {
    final d = v.totalDistance;
    if (d == null || d <= 0) return null;
    switch (v.totalDistanceUnit) {
      case HealthDataUnit.METER:
        return d / 1000;
      case HealthDataUnit.MILE:
        return d * 1.609344;
      default:
        return null;
    }
  }

  int? _energyKcal(WorkoutHealthValue v) {
    final e = v.totalEnergyBurned;
    if (e == null || e <= 0) return null;
    // The plugin reports the workout's energy in kilocalories on both
    // platforms (Apple Health normalises it), so no conversion is applied.
    return e;
  }
}
