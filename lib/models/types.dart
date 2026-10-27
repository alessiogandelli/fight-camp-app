// Data model ported 1:1 from src/types.ts of the web app.

enum Lang { it, en }

extension LangX on Lang {
  String get code => this == Lang.it ? 'it' : 'en';
  static Lang parse(String? s) => s == 'en' ? Lang.en : Lang.it;
}

enum TechniqueCategory {
  boxing,
  kicks,
  knees,
  elbows,
  defense,
  conditioning,
  stretching,
}

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
        id: TechniqueCategory.conditioning,
        label: 'Potenziamento',
        labelEn: 'Conditioning',
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

  /// Optional rep target per step, aligned with [techniqueIds]. Empty (or a
  /// null entry) means "no rep count" (e.g. boxing combos). Used by
  /// conditioning circuits, where the same exercise can appear with different
  /// reps in different circuits.
  final List<int?> reps;
  final bool favorite;
  final int createdAt;

  const Combination({
    required this.id,
    required this.name,
    required this.techniqueIds,
    this.reps = const [],
    required this.favorite,
    required this.createdAt,
  });

  int? repsAt(int index) => index < reps.length ? reps[index] : null;

  factory Combination.fromJson(Map<String, dynamic> j) => Combination(
    id: j['id'] as String,
    name: (j['name'] ?? '') as String,
    techniqueIds: ((j['techniqueIds'] ?? []) as List)
        .map((e) => e.toString())
        .toList(growable: false),
    reps: ((j['reps'] ?? []) as List)
        .map((e) => e is num ? e.toInt() : null)
        .toList(growable: false),
    favorite: j['favorite'] == true,
    createdAt: (j['createdAt'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'techniqueIds': techniqueIds,
    if (reps.any((r) => r != null)) 'reps': reps,
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

/// Derives a workout's type from its content, category-aware: a workout whose
/// combos are all conditioning circuits is itself a conditioning workout.
/// Mirrors [Workout.type] for the non-conditioning cases.
WorkoutType deriveWorkoutType(
  Workout w,
  List<Combination> combos,
  List<Technique> techniques,
) {
  if (w.routineId != null) return WorkoutType.stretching;
  if (w.combinationIds.isNotEmpty) {
    final techById = {for (final t in techniques) t.id: t};
    final comboById = {for (final c in combos) c.id: c};
    final allConditioning = w.combinationIds.every((id) {
      final c = comboById[id];
      if (c == null || c.techniqueIds.isEmpty) return false;
      return c.techniqueIds.every(
        (tid) => techById[tid]?.category == TechniqueCategory.conditioning,
      );
    });
    return allConditioning ? WorkoutType.conditioning : WorkoutType.heavyBag;
  }
  if (w.restDuration == 0 && w.rounds <= 1) return WorkoutType.aerobic;
  return WorkoutType.intervals;
}

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

  /// When the session was recorded, i.e. its end (epoch ms). The start is
  /// `date - duration * 1000`; use `sessionStart`/`sessionEnd` in training.dart.
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

  /// The real-world training this session belongs to. Sessions performed back
  /// to back (or covered by the same Apple Health workout) share a group id;
  /// Progressi counts groups, not sessions. Null means "a group of its own".
  final String? groupId;

  /// Heart-rate summary, filled from Apple Health when a workout overlaps this
  /// session. Null when Health has no samples for the window.
  final int? hrAvg;
  final int? hrMax;

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
    this.groupId,
    this.hrAvg,
    this.hrMax,
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
    groupId: j['groupId'] as String?,
    hrAvg: (j['hrAvg'] as num?)?.toInt(),
    hrMax: (j['hrMax'] as num?)?.toInt(),
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
    if (groupId != null) 'groupId': groupId,
    if (hrAvg != null) 'hrAvg': hrAvg,
    if (hrMax != null) 'hrMax': hrMax,
  };

  /// Only the fields the health import enriches are overridable; everything
  /// else belongs to the session that was recorded.
  SessionRecord copyWith({
    WorkoutType? type,
    String? groupId,
    int? hrAvg,
    int? hrMax,
    int? rpe,
    int? load,
    String? notes,
    bool clearNotes = false,
  }) => SessionRecord(
    id: id,
    date: date,
    type: type ?? this.type,
    source: source,
    workoutId: workoutId,
    name: name,
    roundsCompleted: roundsCompleted,
    totalRounds: totalRounds,
    duration: duration,
    workDuration: workDuration,
    rpe: rpe ?? this.rpe,
    load: load ?? this.load,
    notes: clearNotes ? null : (notes ?? this.notes),
    energyBefore: energyBefore,
    feelingAfter: feelingAfter,
    combosUsed: combosUsed,
    techniqueUsage: techniqueUsage,
    running: running,
    strength: strength,
    groupId: groupId ?? this.groupId,
    hrAvg: hrAvg ?? this.hrAvg,
    hrMax: hrMax ?? this.hrMax,
  );
}

/// One Apple Health workout attached to a training group.
///
/// Kept separate from [SessionRecord] on purpose: a single Health workout can
/// span several sessions of the app (warm-up, bag, stretching), so an external
/// id on the session would be ambiguous. The heart-rate series itself lives on
/// disk, referenced by [externalId].
class HealthLink {
  final String externalId; // HealthKit workout UUID
  final String groupId;
  final int start;
  final int end;

  /// HealthKit activity type name, e.g. `RUNNING`, `TRADITIONAL_STRENGTH_TRAINING`.
  final String activity;
  final String sourceName;
  final double? distanceKm;
  final int? energyKcal;
  final int? avgHr;
  final int? maxHr;

  /// Apple's Effort rating for this workout (1–10), when recorded/estimated.
  final int? effortScore;

  /// Whether a downsampled heart-rate series was written for the chart.
  final bool hasSeries;

  const HealthLink({
    required this.externalId,
    required this.groupId,
    required this.start,
    required this.end,
    required this.activity,
    this.sourceName = '',
    this.distanceKm,
    this.energyKcal,
    this.avgHr,
    this.maxHr,
    this.effortScore,
    this.hasSeries = false,
  });

  HealthLink copyWith({
    String? groupId,
    bool? hasSeries,
    int? avgHr,
    int? maxHr,
    int? effortScore,
  }) => HealthLink(
    externalId: externalId,
    groupId: groupId ?? this.groupId,
    start: start,
    end: end,
    activity: activity,
    sourceName: sourceName,
    distanceKm: distanceKm,
    energyKcal: energyKcal,
    avgHr: avgHr ?? this.avgHr,
    maxHr: maxHr ?? this.maxHr,
    effortScore: effortScore ?? this.effortScore,
    hasSeries: hasSeries ?? this.hasSeries,
  );

  factory HealthLink.fromJson(Map<String, dynamic> j) => HealthLink(
    externalId: (j['externalId'] ?? '') as String,
    groupId: (j['groupId'] ?? '') as String,
    start: (j['start'] ?? 0) as int,
    end: (j['end'] ?? 0) as int,
    activity: (j['activity'] ?? 'OTHER') as String,
    sourceName: (j['sourceName'] ?? '') as String,
    distanceKm: (j['distanceKm'] as num?)?.toDouble(),
    energyKcal: (j['energyKcal'] as num?)?.toInt(),
    avgHr: (j['avgHr'] as num?)?.toInt(),
    maxHr: (j['maxHr'] as num?)?.toInt(),
    effortScore: (j['effortScore'] as num?)?.toInt(),
    hasSeries: j['hasSeries'] == true,
  );

  Map<String, dynamic> toJson() => {
    'externalId': externalId,
    'groupId': groupId,
    'start': start,
    'end': end,
    'activity': activity,
    if (sourceName.isNotEmpty) 'sourceName': sourceName,
    if (distanceKm != null) 'distanceKm': distanceKm,
    if (energyKcal != null) 'energyKcal': energyKcal,
    if (avgHr != null) 'avgHr': avgHr,
    if (maxHr != null) 'maxHr': maxHr,
    if (effortScore != null) 'effortScore': effortScore,
    if (hasSeries) 'hasSeries': true,
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

/// Appearance choice. [system] follows the phone; the other two force a
/// palette regardless of the device setting.
enum ThemeChoice {
  system('system'),
  light('light'),
  dark('dark');

  final String code;
  const ThemeChoice(this.code);

  static ThemeChoice parse(Object? value) {
    if (value is! String) return ThemeChoice.system;
    for (final choice in values) {
      if (choice.code == value) return choice;
    }
    return ThemeChoice.system;
  }
}

class Settings {
  final bool sound;
  final bool vibration;
  final int prepSeconds;

  /// Read the upcoming combo aloud during the pause before a round.
  final bool comboVoice;

  /// Which cue bank plays. See `cueBanks` in lib/cue_synth.dart.
  final String bellSet;

  /// Dark/light appearance override; defaults to following the device.
  final ThemeChoice themeChoice;

  /// Sync Apple Health workouts into the training history.
  final bool healthSync;

  /// Last successful Health import, epoch ms. Null when never synced.
  final int? healthLastSync;

  /// One-time backfill of effort scores and per-workout distance samples for
  /// workouts imported before those features existed.
  final bool healthEnriched;

  /// Manual Karvonen inputs. Null means zones are not available yet.
  final int? maxHeartRate;
  final int? restingHeartRate;

  const Settings({
    required this.sound,
    required this.vibration,
    required this.prepSeconds,
    this.comboVoice = true,
    this.bellSet = 'classic',
    this.themeChoice = ThemeChoice.system,
    this.healthSync = false,
    this.healthLastSync,
    this.healthEnriched = false,
    this.maxHeartRate,
    this.restingHeartRate,
  });

  factory Settings.fromJson(Map<String, dynamic> j) => Settings(
    sound: j['sound'] != false,
    vibration: j['vibration'] != false,
    prepSeconds: (j['prepSeconds'] ?? 3) as int,
    comboVoice: j['comboVoice'] != false,
    bellSet: (j['bellSet'] as String?) ?? 'classic',
    themeChoice: ThemeChoice.parse(j['theme']),
    healthSync: j['healthSync'] == true,
    healthLastSync: (j['healthLastSync'] as num?)?.toInt(),
    healthEnriched: j['healthEnriched'] == true,
    maxHeartRate: (j['maxHeartRate'] as num?)?.toInt(),
    restingHeartRate: (j['restingHeartRate'] as num?)?.toInt(),
  );
  Map<String, dynamic> toJson() => {
    'sound': sound,
    'vibration': vibration,
    'prepSeconds': prepSeconds,
    'comboVoice': comboVoice,
    'bellSet': bellSet,
    'theme': themeChoice.code,
    if (healthSync) 'healthSync': true,
    if (healthLastSync != null) 'healthLastSync': healthLastSync,
    if (healthEnriched) 'healthEnriched': true,
    if (maxHeartRate != null) 'maxHeartRate': maxHeartRate,
    if (restingHeartRate != null) 'restingHeartRate': restingHeartRate,
  };

  Settings copyWith({
    bool? sound,
    bool? vibration,
    int? prepSeconds,
    bool? comboVoice,
    String? bellSet,
    ThemeChoice? themeChoice,
    bool? healthSync,
    int? healthLastSync,
    bool? healthEnriched,
    int? maxHeartRate,
    int? restingHeartRate,
  }) => Settings(
    sound: sound ?? this.sound,
    vibration: vibration ?? this.vibration,
    prepSeconds: prepSeconds ?? this.prepSeconds,
    comboVoice: comboVoice ?? this.comboVoice,
    bellSet: bellSet ?? this.bellSet,
    themeChoice: themeChoice ?? this.themeChoice,
    healthSync: healthSync ?? this.healthSync,
    healthLastSync: healthLastSync ?? this.healthLastSync,
    healthEnriched: healthEnriched ?? this.healthEnriched,
    maxHeartRate: maxHeartRate ?? this.maxHeartRate,
    restingHeartRate: restingHeartRate ?? this.restingHeartRate,
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
  final List<HealthLink> healthLinks;

  const AppData({
    required this.version,
    required this.techniques,
    required this.combinations,
    required this.workouts,
    required this.sessions,
    required this.plans,
    required this.settings,
    this.healthLinks = const [],
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
    healthLinks: ((j['healthLinks'] ?? []) as List)
        .map((e) => HealthLink.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'techniques': techniques.map((e) => e.toJson()).toList(),
    'combinations': combinations.map((e) => e.toJson()).toList(),
    'workouts': workouts.map((e) => e.toJson()).toList(),
    'sessions': sessions.map((e) => e.toJson()).toList(),
    'plans': plans.map((e) => e.toJson()).toList(),
    'settings': settings.toJson(),
    if (healthLinks.isNotEmpty)
      'healthLinks': healthLinks.map((e) => e.toJson()).toList(),
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
