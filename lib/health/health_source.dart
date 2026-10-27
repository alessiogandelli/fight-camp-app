// Read-only access to the phone's health store, behind an interface so the
// import logic can be tested without a device and without HealthKit.
import '../models/types.dart';

/// One distance interval recorded by the watch inside a workout.
class DistanceSample {
  final int start;
  final int end;
  final double meters;
  const DistanceSample(this.start, this.end, this.meters);
}

/// A workout as the health store reports it, already normalised.
class HealthWorkout {
  final String externalId;
  final int start;
  final int end;

  /// HealthKit activity type name (e.g. `RUNNING`, `KICKBOXING`).
  final String activity;
  final String sourceName;
  final double? distanceKm;
  final int? energyKcal;

  /// Apple's workout effort (1–10), user-entered or estimated by the system.
  final int? effortScore;

  /// Per-interval distance samples associated with this workout.
  final List<DistanceSample> distanceSamples;

  const HealthWorkout({
    required this.externalId,
    required this.start,
    required this.end,
    required this.activity,
    this.sourceName = '',
    this.distanceKm,
    this.energyKcal,
    this.effortScore,
    this.distanceSamples = const [],
  });

  int get durationSec => ((end - start) / 1000).round().clamp(1, 1 << 31);
}

/// One heart-rate sample from the health store.
class HeartSample {
  final int ms;
  final int bpm;
  const HeartSample(this.ms, this.bpm);
}

/// Everything one sync window returns.
class HealthBatch {
  final List<HealthWorkout> workouts;
  final List<HeartSample> samples;
  const HealthBatch({this.workouts = const [], this.samples = const []});

  static const empty = HealthBatch();
}

/// What the app needs from HealthKit / Health Connect. Only reads.
abstract class HealthSource {
  /// Whether this platform can talk to a health store at all.
  Future<bool> available();

  /// Asks for read access to workouts and heart rate. Returns false when the
  /// user declines (HealthKit does not disclose read denials, so this only
  /// reports that the sheet was shown).
  Future<bool> requestAccess();

  /// Workouts and heart-rate samples inside the window.
  Future<HealthBatch> fetch({required DateTime from, required DateTime to});

  /// Most recent resting heart rate, used only to suggest a Karvonen input.
  Future<int?> latestRestingHeartRate();
}

/// Maps a health activity name to the app's workout type.
WorkoutType workoutTypeForActivity(String activity) {
  switch (activity.toUpperCase()) {
    case 'RUNNING':
    case 'RUNNING_TREADMILL':
    case 'TRACK_AND_FIELD':
      return WorkoutType.running;
    case 'BOXING':
    case 'KICKBOXING':
    case 'MARTIAL_ARTS':
    case 'WRESTLING':
      return WorkoutType.muayThai;
    case 'HIGH_INTENSITY_INTERVAL_TRAINING':
      return WorkoutType.intervals;
    case 'TRADITIONAL_STRENGTH_TRAINING':
    case 'FUNCTIONAL_STRENGTH_TRAINING':
    case 'CROSS_TRAINING':
    case 'WEIGHTLIFTING':
    case 'CALISTHENICS':
      return WorkoutType.strength;
    case 'JUMP_ROPE':
    case 'CARDIO_DANCE':
    case 'ELLIPTICAL':
    case 'ROWING':
    case 'STAIR_CLIMBING':
    case 'MIXED_CARDIO':
      return WorkoutType.conditioning;
    case 'FLEXIBILITY':
    case 'YOGA':
    case 'PILATES':
    case 'MIND_AND_BODY':
    case 'COOLDOWN':
    case 'PREPARATION_AND_RECOVERY':
      return WorkoutType.stretching;
    case 'WALKING':
    case 'HIKING':
      return WorkoutType.aerobic;
    default:
      return WorkoutType.other;
  }
}
