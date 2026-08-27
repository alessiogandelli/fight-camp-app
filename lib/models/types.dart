// Data model ported 1:1 from src/types.ts of the web app.

enum Lang { it, en }

extension LangX on Lang {
  String get code => this == Lang.it ? 'it' : 'en';
  static Lang parse(String? s) => s == 'en' ? Lang.en : Lang.it;
}

enum TechniqueCategory { boxing, kicks, knees, elbows, defense, stretching }

const techniqueCategories = <({TechniqueCategory id, String label, String labelEn})>[
  (id: TechniqueCategory.boxing, label: 'Pugni', labelEn: 'Boxing'),
  (id: TechniqueCategory.kicks, label: 'Calci', labelEn: 'Kicks'),
  (id: TechniqueCategory.knees, label: 'Ginocchia', labelEn: 'Knees'),
  (id: TechniqueCategory.elbows, label: 'Gomitate', labelEn: 'Elbows'),
  (id: TechniqueCategory.defense, label: 'Difesa / Movimento', labelEn: 'Defense / Movement'),
  (id: TechniqueCategory.stretching, label: 'Stretching', labelEn: 'Stretching'),
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
  String shortIn(Lang lang) => lang == Lang.en ? (shortNameEn ?? shortName) : shortName;

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
  }) =>
      Technique(
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

TechniqueCategory _categoryFrom(dynamic v) =>
    TechniqueCategory.values.firstWhere((c) => c.name == v, orElse: () => TechniqueCategory.boxing);

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
        techniqueIds:
            ((j['techniqueIds'] ?? []) as List).map((e) => e.toString()).toList(growable: false),
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

enum RoundType { combination, sequence, random, free, defense, conditioning, custom }

const roundTypes = <({RoundType id, String label, String labelEn})>[
  (id: RoundType.combination, label: 'Combinazione specifica', labelEn: 'Specific combination'),
  (id: RoundType.sequence, label: 'Sequenza di combinazioni', labelEn: 'Combination sequence'),
  (id: RoundType.random, label: 'Combinazioni casuali', labelEn: 'Random combinations'),
  (id: RoundType.free, label: 'Round libero', labelEn: 'Free round'),
  (id: RoundType.defense, label: 'Difesa', labelEn: 'Defense'),
  (id: RoundType.conditioning, label: 'Condizionamento', labelEn: 'Conditioning'),
  (id: RoundType.custom, label: 'Personalizzato', labelEn: 'Custom'),
];

String roundTypeLabel(RoundType id, Lang lang) {
  for (final r in roundTypes) {
    if (r.id == id) return lang == Lang.en ? r.labelEn : r.label;
  }
  return id.name;
}

enum RotationOrder { sequential, random }

class RandomConfig {
  final int minTechniques;
  final int maxTechniques;
  final List<TechniqueCategory> categories;
  final bool requirePunch;
  final bool requireKick;
  final bool includeDefense;
  final int count;

  const RandomConfig({
    required this.minTechniques,
    required this.maxTechniques,
    required this.categories,
    required this.requirePunch,
    required this.requireKick,
    required this.includeDefense,
    required this.count,
  });

  static const def = RandomConfig(
    minTechniques: 3,
    maxTechniques: 5,
    categories: [
      TechniqueCategory.boxing,
      TechniqueCategory.kicks,
      TechniqueCategory.knees,
      TechniqueCategory.elbows,
      TechniqueCategory.defense
    ],
    requirePunch: true,
    requireKick: true,
    includeDefense: false,
    count: 6,
  );

  factory RandomConfig.fromJson(Map<String, dynamic> j) => RandomConfig(
        minTechniques: (j['minTechniques'] ?? 3) as int,
        maxTechniques: (j['maxTechniques'] ?? 5) as int,
        categories: ((j['categories'] ?? []) as List)
            .map((v) => TechniqueCategory.values.firstWhere((c) => c.name == v,
                orElse: () => TechniqueCategory.boxing))
            .toList(),
        requirePunch: j['requirePunch'] == true,
        requireKick: j['requireKick'] == true,
        includeDefense: j['includeDefense'] == true,
        count: (j['count'] ?? 6) as int,
      );

  Map<String, dynamic> toJson() => {
        'minTechniques': minTechniques,
        'maxTechniques': maxTechniques,
        'categories': categories.map((c) => c.name).toList(),
        'requirePunch': requirePunch,
        'requireKick': requireKick,
        'includeDefense': includeDefense,
        'count': count,
      };

  RandomConfig copyWith({
    int? minTechniques,
    int? maxTechniques,
    List<TechniqueCategory>? categories,
    bool? requirePunch,
    bool? requireKick,
    bool? includeDefense,
    int? count,
  }) =>
      RandomConfig(
        minTechniques: minTechniques ?? this.minTechniques,
        maxTechniques: maxTechniques ?? this.maxTechniques,
        categories: categories ?? this.categories,
        requirePunch: requirePunch ?? this.requirePunch,
        requireKick: requireKick ?? this.requireKick,
        includeDefense: includeDefense ?? this.includeDefense,
        count: count ?? this.count,
      );
}

class RoundBase {
  final String? label;
  final int duration;
  final int restDuration;
  final RoundType type;
  final List<String> combinationIds;
  final int rotationInterval;
  final RotationOrder rotationOrder;
  final RandomConfig? randomConfig;
  final String? image;

  const RoundBase({
    this.label,
    required this.duration,
    required this.restDuration,
    required this.type,
    this.combinationIds = const [],
    this.rotationInterval = 30,
    this.rotationOrder = RotationOrder.sequential,
    this.randomConfig,
    this.image,
  });

  factory RoundBase.fromJson(Map<String, dynamic> j) => RoundBase(
        label: j['label'] as String?,
        duration: (j['duration'] ?? 0) as int,
        restDuration: (j['restDuration'] ?? 0) as int,
        type: RoundType.values.firstWhere((t) => t.name == j['type'], orElse: () => RoundType.free),
        combinationIds:
            ((j['combinationIds'] ?? []) as List).map((e) => e.toString()).toList(growable: false),
        rotationInterval: (j['rotationInterval'] ?? 30) as int,
        rotationOrder: (j['rotationOrder'] ?? 'sequential') == 'random'
            ? RotationOrder.random
            : RotationOrder.sequential,
        randomConfig: j['randomConfig'] == null ? null : RandomConfig.fromJson(j['randomConfig']),
        image: j['image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (label != null) 'label': label,
        'duration': duration,
        'restDuration': restDuration,
        'type': type.name,
        'combinationIds': combinationIds,
        'rotationInterval': rotationInterval,
        'rotationOrder': rotationOrder.name,
        if (randomConfig != null) 'randomConfig': randomConfig!.toJson(),
        if (image != null) 'image': image,
      };

  RoundBase copyWith({
    String? label,
    bool clearLabel = false,
    int? duration,
    int? restDuration,
    RoundType? type,
    List<String>? combinationIds,
    int? rotationInterval,
    RotationOrder? rotationOrder,
    RandomConfig? randomConfig,
    bool clearRandomConfig = false,
    String? image,
  }) =>
      RoundBase(
        label: clearLabel ? null : (label ?? this.label),
        duration: duration ?? this.duration,
        restDuration: restDuration ?? this.restDuration,
        type: type ?? this.type,
        combinationIds: combinationIds ?? this.combinationIds,
        rotationInterval: rotationInterval ?? this.rotationInterval,
        rotationOrder: rotationOrder ?? this.rotationOrder,
        randomConfig: clearRandomConfig ? null : (randomConfig ?? this.randomConfig),
        image: image ?? this.image,
      );
}

class WorkoutRound extends RoundBase {
  final String id;

  const WorkoutRound({
    required this.id,
    super.label,
    required super.duration,
    required super.restDuration,
    required super.type,
    super.combinationIds,
    super.rotationInterval,
    super.rotationOrder,
    super.randomConfig,
    super.image,
  });

  factory WorkoutRound.fromJson(Map<String, dynamic> j) => WorkoutRound(
        id: j['id'] as String,
        label: j['label'] as String?,
        duration: (j['duration'] ?? 0) as int,
        restDuration: (j['restDuration'] ?? 0) as int,
        type: RoundType.values.firstWhere((t) => t.name == j['type'], orElse: () => RoundType.free),
        combinationIds:
            ((j['combinationIds'] ?? []) as List).map((e) => e.toString()).toList(growable: false),
        rotationInterval: (j['rotationInterval'] ?? 30) as int,
        rotationOrder: (j['rotationOrder'] ?? 'sequential') == 'random'
            ? RotationOrder.random
            : RotationOrder.sequential,
        randomConfig: j['randomConfig'] == null ? null : RandomConfig.fromJson(j['randomConfig']),
        image: j['image'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'id': id};

  WorkoutRound copyWith({
    String? id,
    String? label,
    bool clearLabel = false,
    int? duration,
    int? restDuration,
    RoundType? type,
    List<String>? combinationIds,
    int? rotationInterval,
    RotationOrder? rotationOrder,
    RandomConfig? randomConfig,
    bool clearRandomConfig = false,
    String? image,
  }) =>
      WorkoutRound(
        id: id ?? this.id,
        label: clearLabel ? null : (label ?? this.label),
        duration: duration ?? this.duration,
        restDuration: restDuration ?? this.restDuration,
        type: type ?? this.type,
        combinationIds: combinationIds ?? this.combinationIds,
        rotationInterval: rotationInterval ?? this.rotationInterval,
        rotationOrder: rotationOrder ?? this.rotationOrder,
        randomConfig: clearRandomConfig ? null : (randomConfig ?? this.randomConfig),
        image: image ?? this.image,
      );
}

enum BlockType { round, circuit, aerobic, stretching, free }

const blockTypes = <({BlockType id, String label, String labelEn, String icon})>[
  (id: BlockType.round, label: 'Round', labelEn: 'Round', icon: '🥊'),
  (id: BlockType.circuit, label: 'Circuito', labelEn: 'Circuit', icon: '⏱'),
  (id: BlockType.aerobic, label: 'Aerobico', labelEn: 'Aerobic', icon: '🏃'),
  (id: BlockType.stretching, label: 'Stretching', labelEn: 'Stretching', icon: '🧘'),
  (id: BlockType.free, label: 'Libero', labelEn: 'Free', icon: '📝'),
];

({BlockType id, String label, String labelEn, String icon}) blockTypeMeta(BlockType id) =>
    blockTypes.firstWhere((b) => b.id == id, orElse: () => blockTypes.last);

String blockTypeLabel(BlockType id, Lang lang) =>
    lang == Lang.en ? blockTypeMeta(id).labelEn : blockTypeMeta(id).label;

/// A heterogeneous part of a Workout (see ADR 0002).
class WorkoutBlock {
  final String id;
  final String? label;
  final BlockType type;
  /// Number of series for [BlockType.round] and [BlockType.circuit]; ignored elsewhere.
  final int rounds;
  /// Work duration in seconds. For round/circuit blocks it is the duration of
  /// each series; for aerobic/stretching/free blocks it is the total duration.
  final int duration;
  /// Rest in seconds after each series except the last; ignored by the other types.
  final int restDuration;
  final List<String> combinationIds;

  const WorkoutBlock({
    required this.id,
    this.label,
    required this.type,
    this.rounds = 1,
    required this.duration,
    this.restDuration = 0,
    this.combinationIds = const [],
  });

  bool get hasCombos => combinationIds.isNotEmpty;

  factory WorkoutBlock.fromJson(Map<String, dynamic> j) => WorkoutBlock(
        id: j['id'] as String,
        label: j['label'] as String?,
        type: BlockType.values.firstWhere((b) => b.name == j['type'], orElse: () => BlockType.round),
        rounds: (j['rounds'] ?? 1) as int,
        duration: (j['duration'] ?? 0) as int,
        restDuration: (j['restDuration'] ?? 0) as int,
        combinationIds:
            ((j['combinationIds'] ?? []) as List).map((e) => e.toString()).toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (label != null) 'label': label,
        'type': type.name,
        if (type == BlockType.round || type == BlockType.circuit) 'rounds': rounds,
        'duration': duration,
        if (type == BlockType.round || type == BlockType.circuit) 'restDuration': restDuration,
        if (hasCombos) 'combinationIds': combinationIds,
      };

  WorkoutBlock copyWith({
    String? id,
    String? label,
    bool clearLabel = false,
    BlockType? type,
    int? rounds,
    int? duration,
    int? restDuration,
    List<String>? combinationIds,
  }) =>
      WorkoutBlock(
        id: id ?? this.id,
        label: clearLabel ? null : (label ?? this.label),
        type: type ?? this.type,
        rounds: rounds ?? this.rounds,
        duration: duration ?? this.duration,
        restDuration: restDuration ?? this.restDuration,
        combinationIds: combinationIds ?? this.combinationIds,
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

const workoutTypes = <({WorkoutType id, String label, String labelEn, String icon})>[
  (id: WorkoutType.heavyBag, label: 'Sacco pesante', labelEn: 'Heavy Bag', icon: '🥊'),
  (id: WorkoutType.muayThai, label: 'Muay Thai', labelEn: 'Muay Thai', icon: '🥋'),
  (id: WorkoutType.tabata, label: 'Tabata', labelEn: 'Tabata', icon: '⏱'),
  (id: WorkoutType.intervals, label: 'Intervalli', labelEn: 'Intervals', icon: '⚡'),
  (id: WorkoutType.running, label: 'Corsa', labelEn: 'Running', icon: '🏃'),
  (id: WorkoutType.strength, label: 'Forza', labelEn: 'Strength', icon: '🏋️'),
  (id: WorkoutType.conditioning, label: 'Condizionamento', labelEn: 'Conditioning', icon: '🪢'),
  (id: WorkoutType.stretching, label: 'Stretching', labelEn: 'Stretching', icon: '🧘'),
  (id: WorkoutType.other, label: 'Altro', labelEn: 'Other', icon: '📝'),
];

({WorkoutType id, String label, String labelEn, String icon}) workoutTypeMeta(WorkoutType id) =>
    workoutTypes.firstWhere((t) => t.id == id, orElse: () => workoutTypes.last);

String workoutTypeLabel(WorkoutType id, Lang lang) =>
    lang == Lang.en ? workoutTypeMeta(id).labelEn : workoutTypeMeta(id).label;

class Workout {
  final String id;
  final String name;
  final WorkoutType type;
  final List<WorkoutBlock> blocks;
  final int createdAt;

  const Workout({
    required this.id,
    required this.name,
    required this.type,
    required this.blocks,
    required this.createdAt,
  });

  factory Workout.fromJson(Map<String, dynamic> j) => Workout(
        id: j['id'] as String,
        name: (j['name'] ?? '') as String,
        type: workoutTypeFromJson((j['type'] ?? 'other') as String),
        blocks: ((j['blocks'] ?? []) as List)
            .map((r) => WorkoutBlock.fromJson(Map<String, dynamic>.from(r)))
            .toList(),
        createdAt: (j['createdAt'] ?? 0) as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.json,
        'blocks': blocks.map((r) => r.toJson()).toList(),
        'createdAt': createdAt,
      };
}

class TimerPreset {
  final String id;
  final String name;
  final int rounds;
  final int workDuration;
  final int restDuration;

  const TimerPreset({
    required this.id,
    required this.name,
    required this.rounds,
    required this.workDuration,
    required this.restDuration,
  });

  factory TimerPreset.fromJson(Map<String, dynamic> j) => TimerPreset(
        id: j['id'] as String,
        name: (j['name'] ?? '') as String,
        rounds: (j['rounds'] ?? 1) as int,
        workDuration: (j['workDuration'] ?? 30) as int,
        restDuration: (j['restDuration'] ?? 30) as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rounds': rounds,
        'workDuration': workDuration,
        'restDuration': restDuration,
      };
}

class LiveConfig {
  final String name;
  final WorkoutType type;
  final String? workoutId;
  final int prepSeconds;
  final List<RoundBase> rounds;

  const LiveConfig({
    required this.name,
    required this.type,
    this.workoutId,
    required this.prepSeconds,
    required this.rounds,
  });

  factory LiveConfig.fromJson(Map<String, dynamic> j) => LiveConfig(
        name: (j['name'] ?? '') as String,
        type: workoutTypeFromJson((j['type'] ?? 'other') as String),
        workoutId: j['workoutId'] as String?,
        prepSeconds: (j['prepSeconds'] ?? 0) as int,
        rounds: ((j['rounds'] ?? []) as List)
            .map((r) => RoundBase.fromJson(Map<String, dynamic>.from(r)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.json,
        if (workoutId != null) 'workoutId': workoutId,
        'prepSeconds': prepSeconds,
        'rounds': rounds.map((r) => r.toJson()).toList(),
      };
}

class NameRef {
  final String id;
  final String name;
  const NameRef(this.id, this.name);

  factory NameRef.fromJson(Map<String, dynamic> j) => NameRef(j['id'] as String, (j['name'] ?? '') as String);
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class UsageRef {
  final String id;
  final String name;
  final int count;
  const UsageRef(this.id, this.name, this.count);

  factory UsageRef.fromJson(Map<String, dynamic> j) =>
      UsageRef(j['id'] as String, (j['name'] ?? '') as String, (j['count'] ?? 0) as int);
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
  const StrengthEntry({required this.exercise, required this.sets, required this.reps, this.weightKg});

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
            : Feeling.values.firstWhere((f) => f.name == j['feelingAfter'], orElse: () => Feeling.ok),
        combosUsed: (j['combosUsed'] as List?)?.map((e) => NameRef.fromJson(Map<String, dynamic>.from(e))).toList(),
        techniqueUsage:
            (j['techniqueUsage'] as List?)?.map((e) => UsageRef.fromJson(Map<String, dynamic>.from(e))).toList(),
        running: j['running'] == null ? null : RunningExtra.fromJson(Map<String, dynamic>.from(j['running'])),
        strength:
            (j['strength'] as List?)?.map((e) => StrengthEntry.fromJson(Map<String, dynamic>.from(e))).toList(),
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
        if (combosUsed != null) 'combosUsed': combosUsed!.map((e) => e.toJson()).toList(),
        if (techniqueUsage != null) 'techniqueUsage': techniqueUsage!.map((e) => e.toJson()).toList(),
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

  WeekPlanItem copyWith({bool? done}) =>
      WeekPlanItem(id: id, dateKey: dateKey, type: type, label: label, durationMin: durationMin, done: done ?? this.done);
}

class Settings {
  final bool sound;
  final bool vibration;
  final int prepSeconds;
  const Settings({required this.sound, required this.vibration, required this.prepSeconds});

  factory Settings.fromJson(Map<String, dynamic> j) => Settings(
        sound: j['sound'] != false,
        vibration: j['vibration'] != false,
        prepSeconds: (j['prepSeconds'] ?? 3) as int,
      );
  Map<String, dynamic> toJson() => {'sound': sound, 'vibration': vibration, 'prepSeconds': prepSeconds};

  Settings copyWith({bool? sound, bool? vibration, int? prepSeconds}) => Settings(
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
  final List<TimerPreset> presets;
  final List<WeekPlanItem> plans;
  final Settings settings;

  const AppData({
    required this.version,
    required this.techniques,
    required this.combinations,
    required this.workouts,
    required this.sessions,
    required this.presets,
    required this.plans,
    required this.settings,
  });

  factory AppData.fromJson(Map<String, dynamic> j) => AppData(
        version: (j['version'] ?? 1) as int,
        techniques: ((j['techniques'] ?? []) as List).map((e) => Technique.fromJson(Map<String, dynamic>.from(e))).toList(),
        combinations:
            ((j['combinations'] ?? []) as List).map((e) => Combination.fromJson(Map<String, dynamic>.from(e))).toList(),
        workouts: ((j['workouts'] ?? []) as List).map((e) => Workout.fromJson(Map<String, dynamic>.from(e))).toList(),
        sessions: ((j['sessions'] ?? []) as List).map((e) => SessionRecord.fromJson(Map<String, dynamic>.from(e))).toList(),
        presets: ((j['presets'] ?? []) as List).map((e) => TimerPreset.fromJson(Map<String, dynamic>.from(e))).toList(),
        plans: ((j['plans'] ?? []) as List).map((e) => WeekPlanItem.fromJson(Map<String, dynamic>.from(e))).toList(),
        settings: Settings.fromJson(Map<String, dynamic>.from(j['settings'] ?? {})),
      );

  Map<String, dynamic> toJson() => {
        'version': version,
        'techniques': techniques.map((e) => e.toJson()).toList(),
        'combinations': combinations.map((e) => e.toJson()).toList(),
        'workouts': workouts.map((e) => e.toJson()).toList(),
        'sessions': sessions.map((e) => e.toJson()).toList(),
        'presets': presets.map((e) => e.toJson()).toList(),
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
