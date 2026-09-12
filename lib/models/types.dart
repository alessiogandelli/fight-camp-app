// Data model ported 1:1 from src/types.ts of the web app.

enum Lang { it, en }

extension LangX on Lang {
  String get code => this == Lang.it ? 'it' : 'en';
  static Lang parse(String? s) => s == 'en' ? Lang.en : Lang.it;
}

enum TechniqueCategory { boxing, kicks, knees, elbows, defense, stretching }

const techniqueCategories =
    <({TechniqueCategory id, String label, String labelEn})>[
      (id: TechniqueCategory.boxing, label: 'Pugni', labelEn: 'Boxing'),
      (id: TechniqueCategory.kicks, label: 'Calci', labelEn: 'Kicks'),
      (id: TechniqueCategory.knees, label: 'Ginocchia', labelEn: 'Knees'),
      (id: TechniqueCategory.elbows, label: 'Gomitate', labelEn: 'Elbows'),
      (
        id: TechniqueCategory.defense,
        label: 'Difesa / Movimento',
        labelEn: 'Defense / Movement',
      ),
      (
        id: TechniqueCategory.stretching,
        label: 'Stretching',
        labelEn: 'Stretching',
      ),
    ];

String categoryLabel(TechniqueCategory id, Lang lang) {
  for (final c in techniqueCategories) {
    if (c.id == id) return lang == Lang.en ? c.labelEn : c.label;
  }
  return id.name;
}

class Technique {
  final String id;
  final String name;
  final String shortName;
  final TechniqueCategory category;
  final String? description;
  final String? nameEn;
  final String? shortNameEn;
  final String? descriptionEn;
  final bool custom;

  const Technique({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    this.description,
    this.nameEn,
    this.shortNameEn,
    this.descriptionEn,
    this.custom = false,
  });

  String nameIn(Lang lang) => lang == Lang.en ? (nameEn ?? name) : name;
  String shortIn(Lang lang) =>
      lang == Lang.en ? (shortNameEn ?? shortName) : shortName;
  String? descriptionIn(Lang lang) =>
      lang == Lang.en ? (descriptionEn ?? description) : description;

  factory Technique.fromJson(Map<String, dynamic> j) => Technique(
    id: j['id'] as String,
    name: (j['name'] ?? '') as String,
    shortName: (j['shortName'] ?? '') as String,
    category: _categoryFrom(j['category']),
    description: j['description'] as String?,
    nameEn: j['nameEn'] as String?,
    shortNameEn: j['shortNameEn'] as String?,
    descriptionEn: j['descriptionEn'] as String?,
    custom: j['custom'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'shortName': shortName,
    'category': category.name,
    if (description != null) 'description': description,
    if (nameEn != null) 'nameEn': nameEn,
    if (shortNameEn != null) 'shortNameEn': shortNameEn,
    if (descriptionEn != null) 'descriptionEn': descriptionEn,
    if (custom) 'custom': true,
  };

  Technique copyWith({
    String? id,
    String? name,
    String? shortName,
    TechniqueCategory? category,
    String? description,
    String? nameEn,
    String? shortNameEn,
    String? descriptionEn,
    bool? custom,
  }) => Technique(
    id: id ?? this.id,
    name: name ?? this.name,
    shortName: shortName ?? this.shortName,
    category: category ?? this.category,
    description: description ?? this.description,
    nameEn: nameEn ?? this.nameEn,
    shortNameEn: shortNameEn ?? this.shortNameEn,
    descriptionEn: descriptionEn ?? this.descriptionEn,
    custom: custom ?? this.custom,
  );
}

TechniqueCategory _categoryFrom(dynamic v) => TechniqueCategory.values
    .firstWhere((c) => c.name == v, orElse: () => TechniqueCategory.boxing);

class Combination {
  final String id;
  final String name;
  final List<String> techniqueIds;
  final bool favorite;
  final int createdAt;

  const Combination({
    required this.id,
    required this.name,
    required this.techniqueIds,
    required this.favorite,
    required this.createdAt,
  });

  factory Combination.fromJson(Map<String, dynamic> j) => Combination(
    id: j['id'] as String,
    name: (j['name'] ?? '') as String,
    techniqueIds: ((j['techniqueIds'] ?? []) as List)
        .map((e) => e.toString())
        .toList(growable: false),
    favorite: j['favorite'] == true,
    createdAt: (j['createdAt'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'techniqueIds': techniqueIds,
    'favorite': favorite,
    'createdAt': createdAt,
  };
}

enum RoundType { combination, free, defense, conditioning, custom }

class RoundBase {
  final String? label;
  final int duration;
  final int restDuration;
  final RoundType type;
  final List<String> combinationIds;
  final String? image;

  const RoundBase({
    this.label,
    required this.duration,
    required this.restDuration,
    required this.type,
    this.combinationIds = const [],
    this.image,
  });

  factory RoundBase.fromJson(Map<String, dynamic> j) => RoundBase(
    label: j['label'] as String?,
    duration: (j['duration'] ?? 0) as int,
    restDuration: (j['restDuration'] ?? 0) as int,
    type: RoundType.values.firstWhere(
      (t) => t.name == j['type'],
      orElse: () => RoundType.free,
    ),
    combinationIds: ((j['combinationIds'] ?? []) as List)
        .map((e) => e.toString())
        .toList(growable: false),
    image: j['image'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (label != null) 'label': label,
    'duration': duration,
    'restDuration': restDuration,
    'type': type.name,
    'combinationIds': combinationIds,
    if (image != null) 'image': image,
  };

  RoundBase copyWith({
    String? label,
    bool clearLabel = false,
    int? duration,
    int? restDuration,
    RoundType? type,
    List<String>? combinationIds,
    String? image,
  }) => RoundBase(
    label: clearLabel ? null : (label ?? this.label),
    duration: duration ?? this.duration,
    restDuration: restDuration ?? this.restDuration,
    type: type ?? this.type,
    combinationIds: combinationIds ?? this.combinationIds,
    image: image ?? this.image,
  );
}

enum WorkoutType {
  heavyBag('heavy-bag'),
  muayThai('muay-thai'),
  tabata,
  intervals,
  running,
  strength,
  conditioning,
  aerobic,
  stretching,
  other;

  const WorkoutType([this._json]);
  final String? _json;

  String get json => _json ?? name;
}

WorkoutType workoutTypeFromJson(String s) => WorkoutType.values.firstWhere(
  (t) => t.json == s,
  orElse: () => WorkoutType.other,
);

const workoutTypes =
    <({WorkoutType id, String label, String labelEn, String icon})>[
      (
        id: WorkoutType.heavyBag,
        label: 'Sacco pesante',
        labelEn: 'Heavy Bag',
        icon: '🥊',
      ),
      (
        id: WorkoutType.muayThai,
        label: 'Muay Thai',
        labelEn: 'Muay Thai',
        icon: '🥋',
      ),
      (id: WorkoutType.tabata, label: 'Tabata', labelEn: 'Tabata', icon: '⏱'),
      (
        id: WorkoutType.intervals,
        label: 'Intervalli',
        labelEn: 'Intervals',
        icon: '⚡',
      ),
      (id: WorkoutType.running, label: 'Corsa', labelEn: 'Running', icon: '🏃'),
      (
        id: WorkoutType.strength,
        label: 'Forza',
        labelEn: 'Strength',
        icon: '🏋️',
      ),
      (
        id: WorkoutType.conditioning,
        label: 'Condizionamento',
        labelEn: 'Conditioning',
        icon: '🪢',
      ),
      (
        id: WorkoutType.aerobic,
        label: 'Aerobico',
        labelEn: 'Aerobic',
        icon: '🏃',
      ),
      (
        id: WorkoutType.stretching,
        label: 'Stretching',
        labelEn: 'Stretching',
        icon: '🧘',
      ),
      (id: WorkoutType.other, label: 'Altro', labelEn: 'Other', icon: '📝'),
    ];

({WorkoutType id, String label, String labelEn, String icon}) workoutTypeMeta(
  WorkoutType id,
) =>
    workoutTypes.firstWhere((t) => t.id == id, orElse: () => workoutTypes.last);

String workoutTypeLabel(WorkoutType id, Lang lang) =>
    lang == Lang.en ? workoutTypeMeta(id).labelEn : workoutTypeMeta(id).label;

/// A single uniform timer configuration (work/rest/rounds), optionally
/// referencing Combos (bag workout) or a Routine (stretching workout).
/// The type is derived from the content, not stored (ADR 0003).
/// [rounds] == 0 marks an endless workout (runs until the user stops it).
class Workout {
  final String id;
  final String name;
  final int workDuration;
  final int restDuration;
  final int rounds;
  final List<String> combinationIds;
  final String? routineId;
  final int createdAt;

  const Workout({
    required this.id,
    required this.name,
    required this.workDuration,
    required this.restDuration,
    required this.rounds,
    this.combinationIds = const [],
    this.routineId,
    required this.createdAt,
  });

  bool get hasCombos => combinationIds.isNotEmpty;

  WorkoutType get type {
    if (routineId != null) return WorkoutType.stretching;
    if (combinationIds.isNotEmpty) return WorkoutType.heavyBag;
    if (restDuration == 0 && rounds <= 1) return WorkoutType.aerobic;
    return WorkoutType.intervals;
  }

  factory Workout.fromJson(Map<String, dynamic> j) => Workout(
    id: j['id'] as String,
    name: (j['name'] ?? '') as String,
    workDuration: (j['workDuration'] ?? 0) as int,
    restDuration: (j['restDuration'] ?? 0) as int,
    rounds: (j['rounds'] ?? 1) as int,
    combinationIds: ((j['combinationIds'] ?? []) as List)
        .map((e) => e.toString())
        .toList(growable: false),
    routineId: j['routineId'] as String?,
    createdAt: (j['createdAt'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'workDuration': workDuration,
    'restDuration': restDuration,
    'rounds': rounds,
    if (combinationIds.isNotEmpty) 'combinationIds': combinationIds,
    if (routineId != null) 'routineId': routineId,
    'createdAt': createdAt,
  };

  Workout copyWith({
    String? id,
    String? name,
    int? workDuration,
    int? restDuration,
    int? rounds,
    List<String>? combinationIds,
    String? routineId,
    bool clearRoutineId = false,
    int? createdAt,
  }) => Workout(
    id: id ?? this.id,
    name: name ?? this.name,
    workDuration: workDuration ?? this.workDuration,
    restDuration: restDuration ?? this.restDuration,
    rounds: rounds ?? this.rounds,
    combinationIds: combinationIds ?? this.combinationIds,
    routineId: clearRoutineId ? null : (routineId ?? this.routineId),
    createdAt: createdAt ?? this.createdAt,
  );
}

class LiveConfig {
  final String name;
  final WorkoutType type;
  final String? workoutId;
  final int prepSeconds;
  final List<RoundBase> rounds;

  /// Endless session: the engine keeps appending rounds of the last pattern
  /// until the user stops it. [rounds] then holds only the initial batch.
  final bool endless;

  const LiveConfig({
    required this.name,
    required this.type,
    this.workoutId,
    required this.prepSeconds,
    required this.rounds,
    this.endless = false,
  });

  factory LiveConfig.fromJson(Map<String, dynamic> j) => LiveConfig(
    name: (j['name'] ?? '') as String,
    type: workoutTypeFromJson((j['type'] ?? 'other') as String),
    workoutId: j['workoutId'] as String?,
    prepSeconds: (j['prepSeconds'] ?? 0) as int,
    endless: j['endless'] == true,
    rounds: ((j['rounds'] ?? []) as List)
        .map((r) => RoundBase.fromJson(Map<String, dynamic>.from(r)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.json,
    if (workoutId != null) 'workoutId': workoutId,
    'prepSeconds': prepSeconds,
    if (endless) 'endless': true,
    'rounds': rounds.map((r) => r.toJson()).toList(),
  };
}

class NameRef {
  final String id;
  final String name;
  const NameRef(this.id, this.name);

  factory NameRef.fromJson(Map<String, dynamic> j) =>
      NameRef(j['id'] as String, (j['name'] ?? '') as String);
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class UsageRef {
  final String id;
  final String name;
  final int count;
  const UsageRef(this.id, this.name, this.count);

  factory UsageRef.fromJson(Map<String, dynamic> j) => UsageRef(
    j['id'] as String,
    (j['name'] ?? '') as String,
    (j['count'] ?? 0) as int,
  );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'count': count};
}

enum Feeling { great, good, ok, drained }

String feelingLabel(Feeling f, Lang lang) {
  switch (f) {
    case Feeling.great:
      return lang == Lang.en ? 'Great' : 'Ottimo';
    case Feeling.good:
      return lang == Lang.en ? 'Good' : 'Bene';
    case Feeling.ok:
      return 'OK';
    case Feeling.drained:
      return lang == Lang.en ? 'Drained' : 'Sfinito';
  }
}

class RunningExtra {
  final double? distanceKm;
  final int? paceSecPerKm;
  const RunningExtra({this.distanceKm, this.paceSecPerKm});

  factory RunningExtra.fromJson(Map<String, dynamic> j) => RunningExtra(
    distanceKm: (j['distanceKm'] as num?)?.toDouble(),
    paceSecPerKm: (j['paceSecPerKm'] as num?)?.toInt(),
  );
  Map<String, dynamic> toJson() => {
    if (distanceKm != null) 'distanceKm': distanceKm,
    if (paceSecPerKm != null) 'paceSecPerKm': paceSecPerKm,
  };
}

class StrengthEntry {
  final String exercise;
  final int sets;
  final int reps;
  final double? weightKg;
  const StrengthEntry({
    required this.exercise,
    required this.sets,
    required this.reps,
    this.weightKg,
  });

  factory StrengthEntry.fromJson(Map<String, dynamic> j) => StrengthEntry(
    exercise: (j['exercise'] ?? '') as String,
    sets: (j['sets'] ?? 0) as int,
    reps: (j['reps'] ?? 0) as int,
    weightKg: (j['weightKg'] as num?)?.toDouble(),
  );
  Map<String, dynamic> toJson() => {
    'exercise': exercise,
    'sets': sets,
    'reps': reps,
    if (weightKg != null) 'weightKg': weightKg,
  };
}

class SessionRecord {
  final String id;
  final int date;
  final WorkoutType type;
  final String source; // 'timer' | 'manual'
  final String? workoutId;
  final String name;
  final int? roundsCompleted;
  final int? totalRounds;
  final int duration;
  final int? workDuration;
  final int? rpe;
  final int load;
  final String? notes;
  final int? energyBefore;
  final Feeling? feelingAfter;
  final List<NameRef>? combosUsed;
  final List<UsageRef>? techniqueUsage;
  final RunningExtra? running;
  final List<StrengthEntry>? strength;

  const SessionRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.source,
    this.workoutId,
    required this.name,
    this.roundsCompleted,
    this.totalRounds,
    required this.duration,
    this.workDuration,
    this.rpe,
    required this.load,
    this.notes,
    this.energyBefore,
    this.feelingAfter,
    this.combosUsed,
    this.techniqueUsage,
    this.running,
    this.strength,
  });

  factory SessionRecord.fromJson(Map<String, dynamic> j) => SessionRecord(
    id: j['id'] as String,
    date: (j['date'] ?? 0) as int,
    type: workoutTypeFromJson((j['type'] ?? 'other') as String),
    source: (j['source'] ?? 'manual') as String,
    workoutId: j['workoutId'] as String?,
    name: (j['name'] ?? '') as String,
    roundsCompleted: (j['roundsCompleted'] as num?)?.toInt(),
    totalRounds: (j['totalRounds'] as num?)?.toInt(),
    duration: (j['duration'] ?? 0) as int,
    workDuration: (j['workDuration'] as num?)?.toInt(),
    rpe: (j['rpe'] as num?)?.toInt(),
    load: (j['load'] ?? 0) as int,
    notes: j['notes'] as String?,
    energyBefore: (j['energyBefore'] as num?)?.toInt(),
    feelingAfter: j['feelingAfter'] == null
        ? null
        : Feeling.values.firstWhere(
            (f) => f.name == j['feelingAfter'],
            orElse: () => Feeling.ok,
          ),
    combosUsed: (j['combosUsed'] as List?)
        ?.map((e) => NameRef.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    techniqueUsage: (j['techniqueUsage'] as List?)
        ?.map((e) => UsageRef.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    running: j['running'] == null
        ? null
        : RunningExtra.fromJson(Map<String, dynamic>.from(j['running'])),
    strength: (j['strength'] as List?)
        ?.map((e) => StrengthEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'type': type.json,
    'source': source,
    if (workoutId != null) 'workoutId': workoutId,
    'name': name,
    if (roundsCompleted != null) 'roundsCompleted': roundsCompleted,
    if (totalRounds != null) 'totalRounds': totalRounds,
    'duration': duration,
    if (workDuration != null) 'workDuration': workDuration,
    if (rpe != null) 'rpe': rpe,
    'load': load,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    if (energyBefore != null) 'energyBefore': energyBefore,
    if (feelingAfter != null) 'feelingAfter': feelingAfter!.name,
    if (combosUsed != null)
      'combosUsed': combosUsed!.map((e) => e.toJson()).toList(),
    if (techniqueUsage != null)
      'techniqueUsage': techniqueUsage!.map((e) => e.toJson()).toList(),
    if (running != null) 'running': running!.toJson(),
    if (strength != null) 'strength': strength!.map((e) => e.toJson()).toList(),
  };
}

class WeekPlanItem {
  final String id;
  final String dateKey; // YYYY-MM-DD
  final WorkoutType type;
  final String label;
  final int? durationMin;
  final bool done;

  const WeekPlanItem({
    required this.id,
    required this.dateKey,
    required this.type,
    required this.label,
    this.durationMin,
    required this.done,
  });

  factory WeekPlanItem.fromJson(Map<String, dynamic> j) => WeekPlanItem(
    id: j['id'] as String,
    dateKey: (j['dateKey'] ?? '') as String,
    type: workoutTypeFromJson((j['type'] ?? 'other') as String),
    label: (j['label'] ?? '') as String,
    durationMin: (j['durationMin'] as num?)?.toInt(),
    done: j['done'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateKey': dateKey,
    'type': type.json,
    'label': label,
    if (durationMin != null) 'durationMin': durationMin,
    'done': done,
  };

  WeekPlanItem copyWith({bool? done}) => WeekPlanItem(
    id: id,
    dateKey: dateKey,
    type: type,
    label: label,
    durationMin: durationMin,
    done: done ?? this.done,
  );
}

class Settings {
  final bool sound;
  final bool vibration;
  final int prepSeconds;
  const Settings({
    required this.sound,
    required this.vibration,
    required this.prepSeconds,
  });

  factory Settings.fromJson(Map<String, dynamic> j) => Settings(
    sound: j['sound'] != false,
    vibration: j['vibration'] != false,
    prepSeconds: (j['prepSeconds'] ?? 3) as int,
  );
  Map<String, dynamic> toJson() => {
    'sound': sound,
    'vibration': vibration,
    'prepSeconds': prepSeconds,
  };

  Settings copyWith({bool? sound, bool? vibration, int? prepSeconds}) =>
      Settings(
        sound: sound ?? this.sound,
        vibration: vibration ?? this.vibration,
        prepSeconds: prepSeconds ?? this.prepSeconds,
      );
}

class AppData {
  final int version;
  final List<Technique> techniques;
  final List<Combination> combinations;
  final List<Workout> workouts;
  final List<SessionRecord> sessions;
  final List<WeekPlanItem> plans;
  final Settings settings;

  const AppData({
    required this.version,
    required this.techniques,
    required this.combinations,
    required this.workouts,
    required this.sessions,
    required this.plans,
    required this.settings,
  });

  factory AppData.fromJson(Map<String, dynamic> j) => AppData(
    version: (j['version'] ?? 1) as int,
    techniques: ((j['techniques'] ?? []) as List)
        .map((e) => Technique.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    combinations: ((j['combinations'] ?? []) as List)
        .map((e) => Combination.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    workouts: ((j['workouts'] ?? []) as List)
        .map((e) => Workout.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    sessions: ((j['sessions'] ?? []) as List)
        .map((e) => SessionRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    plans: ((j['plans'] ?? []) as List)
        .map((e) => WeekPlanItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    settings: Settings.fromJson(Map<String, dynamic>.from(j['settings'] ?? {})),
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'techniques': techniques.map((e) => e.toJson()).toList(),
    'combinations': combinations.map((e) => e.toJson()).toList(),
    'workouts': workouts.map((e) => e.toJson()).toList(),
    'sessions': sessions.map((e) => e.toJson()).toList(),
    'plans': plans.map((e) => e.toJson()).toList(),
    'settings': settings.toJson(),
  };
}

class ActiveSnapshot {
  final LiveConfig config;
  final int totalElapsedMs;
  final String status; // 'running' | 'paused'
  final int savedAt;

  const ActiveSnapshot({
    required this.config,
    required this.totalElapsedMs,
    required this.status,
    required this.savedAt,
  });

  factory ActiveSnapshot.fromJson(Map<String, dynamic> j) => ActiveSnapshot(
    config: LiveConfig.fromJson(Map<String, dynamic>.from(j['config'])),
    totalElapsedMs: (j['totalElapsedMs'] ?? 0) as int,
    status: (j['status'] ?? 'paused') as String,
    savedAt: (j['savedAt'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
    'config': config.toJson(),
    'totalElapsedMs': totalElapsedMs,
    'status': status,
    'savedAt': savedAt,
  };
}

class SessionSummary {
  final int totalRounds;
  final int totalSeconds;
  final int workSeconds;
  final int restSeconds;
  final List<NameRef> combosUsed;
  final List<UsageRef> techniqueUsage;

  const SessionSummary({
    required this.totalRounds,
    required this.totalSeconds,
    required this.workSeconds,
    required this.restSeconds,
    required this.combosUsed,
    required this.techniqueUsage,
  });
}
