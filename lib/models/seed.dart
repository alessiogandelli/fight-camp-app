// Seed data ported from src/data/seed.ts.
import 'types.dart';

Technique _t(
  String id,
  String name,
  String shortName,
  TechniqueCategory category, [
  String? description,
  String? nameEn,
  String? shortNameEn,
  String? descriptionEn,
]) =>
    Technique(
      id: id,
      name: name,
      shortName: shortName,
      category: category,
      description: description,
      nameEn: nameEn,
      shortNameEn: shortNameEn,
      descriptionEn: descriptionEn,
    );

final seedTechniques = <Technique>[
  _t('t-jab', 'Jab', 'JAB', TechniqueCategory.boxing, 'Pugno diretto della mano avanti', 'Jab', 'JAB', 'Lead-hand straight punch'),
  _t('t-cross', 'Diretto', 'DIRETTO', TechniqueCategory.boxing, 'Pugno diretto della mano dietro', 'Cross', 'CROSS', 'Rear-hand straight punch'),
  _t('t-lead-hook', 'Gancio sinistro', 'GANCIO SX', TechniqueCategory.boxing, null, 'Lead Hook', 'LEAD HOOK'),
  _t('t-rear-hook', 'Gancio destro', 'GANCIO DX', TechniqueCategory.boxing, null, 'Rear Hook', 'REAR HOOK'),
  _t('t-lead-uppercut', 'Montante sinistro', 'MONTANTE SX', TechniqueCategory.boxing, null, 'Lead Uppercut', 'LEAD UPPERCUT'),
  _t('t-rear-uppercut', 'Montante destro', 'MONTANTE DX', TechniqueCategory.boxing, null, 'Rear Uppercut', 'REAR UPPERCUT'),
  _t('t-jab-body', 'Jab al corpo', 'JAB CORPO', TechniqueCategory.boxing, 'Jab al corpo', 'Jab to Body', 'JAB BODY', 'Jab to the body'),
  _t('t-cross-body', 'Diretto al corpo', 'DIRETTO CORPO', TechniqueCategory.boxing, 'Diretto al corpo', 'Cross to Body', 'CROSS BODY', 'Cross to the body'),
  _t('t-lead-hook-body', 'Gancio sinistro al corpo', 'GANCIO SX CORPO', TechniqueCategory.boxing, null, 'Lead Hook to Body', 'LEAD HOOK BODY'),
  _t('t-rear-hook-body', 'Gancio destro al corpo', 'GANCIO DX CORPO', TechniqueCategory.boxing, null, 'Rear Hook to Body', 'REAR HOOK BODY'),
  _t('t-lead-teep', 'Teep sinistro', 'TEEP SX', TechniqueCategory.kicks, 'Calcio spinta con la gamba avanti', 'Lead Teep', 'LEAD TEEP', 'Lead push kick'),
  _t('t-rear-teep', 'Teep destro', 'TEEP DX', TechniqueCategory.kicks, 'Calcio spinta con la gamba dietro', 'Rear Teep', 'REAR TEEP', 'Rear push kick'),
  _t('t-lead-round', 'Calcio sinistro', 'CALCIO SX', TechniqueCategory.kicks, null, 'Lead Round Kick', 'LEAD KICK'),
  _t('t-rear-round', 'Calcio destro', 'CALCIO DX', TechniqueCategory.kicks, null, 'Rear Round Kick', 'REAR KICK'),
  _t('t-lead-low', 'Calcio basso sinistro', 'CALCIO BASSO SX', TechniqueCategory.kicks, null, 'Lead Low Kick', 'LEAD LOW KICK'),
  _t('t-rear-low', 'Calcio basso destro', 'CALCIO BASSO DX', TechniqueCategory.kicks, null, 'Rear Low Kick', 'REAR LOW KICK'),
  _t('t-straight-knee', 'Ginocchio dritto', 'GINOCCHIO DRITTO', TechniqueCategory.knees, 'Ginocchio dritto in avanti', 'Straight Knee', 'STRAIGHT KNEE', 'Straight knee'),
  _t('t-lead-knee', 'Ginocchio laterale sinistro', 'GINOCCHIO LAT SX', TechniqueCategory.knees, 'Ginocchio laterale dal clinch', 'Lead Knee', 'LEAD KNEE', 'Side knee from clinch'),
  _t('t-rear-knee', 'Ginocchio laterale destro', 'GINOCCHIO LAT DX', TechniqueCategory.knees, 'Ginocchio laterale dal clinch', 'Rear Knee', 'REAR KNEE', 'Side knee from clinch'),
  _t("t-upward-elbow", "Gomito verso l'alto", 'GOMITO SU', TechniqueCategory.elbows, "Gomito dal basso verso l'alto", 'Upward Elbow', 'UPWARD ELBOW'),
  _t("t-lead-elbow", 'Gomito verso il basso', 'GOMITO GIÙ', TechniqueCategory.elbows, "Gomito dall'alto verso il basso", 'Downward Elbow', 'DOWNWARD ELBOW'),
  _t('t-horizontal-elbow', 'Gomito laterale', 'GOMITO LAT', TechniqueCategory.elbows, 'Gomito orizzontale', 'Horizontal Elbow', 'HORIZ ELBOW'),
  _t('t-slip-left', 'Schivata sinistra', 'SCHIVATA SX', TechniqueCategory.defense, null, 'Slip Left', 'SLIP LEFT'),
  _t('t-slip-right', 'Schivata destra', 'SCHIVATA DX', TechniqueCategory.defense, null, 'Slip Right', 'SLIP RIGHT'),
  _t('t-roll', 'Roll', 'ROLL', TechniqueCategory.defense, null, 'Roll', 'ROLL'),
  _t('t-pull-back', 'Arretramento', 'ARRETRAMENTO', TechniqueCategory.defense, null, 'Pull Back', 'PULL BACK'),
  _t('t-check', 'Parata', 'PARATA', TechniqueCategory.defense, null, 'Check', 'CHECK'),
  _t('t-step-left', 'Passo a sinistra', 'PASSO SX', TechniqueCategory.defense, null, 'Step Left', 'STEP LEFT'),
  _t('t-step-right', 'Passo a destra', 'PASSO DX', TechniqueCategory.defense, null, 'Step Right', 'STEP RIGHT'),
  _t('t-pivot', 'Pivot', 'PIVOT', TechniqueCategory.defense, null, 'Pivot', 'PIVOT'),
  _t('t-pancake', 'Pancake', 'PANCAKE', TechniqueCategory.stretching, 'Apertura delle anche in avanti', 'Pancake', 'PANCAKE'),
  _t('t-figure4-sx', 'Figure 4 sinistro', 'FIG4 SX', TechniqueCategory.stretching, 'Esterni dell\'anca sinistra', 'Figure 4 Left', 'FIG4 LEFT'),
  _t('t-figure4-dx', 'Figure 4 destro', 'FIG4 DX', TechniqueCategory.stretching, 'Esterni dell\'anca destra', 'Figure 4 Right', 'FIG4 RIGHT'),
  _t('t-hipflexor-sx', 'Flessore anca sx', 'FLESS SX', TechniqueCategory.stretching, 'Flessore dell\'anca sinistro', 'Hip Flexor Left', 'HIPFLX LEFT'),
  _t('t-hipflexor-dx', 'Flessore anca dx', 'FLESS DX', TechniqueCategory.stretching, 'Flessore dell\'anca destro', 'Hip Flexor Right', 'HIPFLX RIGHT'),
  _t('t-lat-sx', 'Lat sinistro', 'LAT SX', TechniqueCategory.stretching, 'Dorsali sinistri', 'Lat Stretch Left', 'LAT LEFT'),
  _t('t-lat-dx', 'Lat destro', 'LAT DX', TechniqueCategory.stretching, 'Dorsali destri', 'Lat Stretch Right', 'LAT RIGHT'),
];

Combination _c(String id, String name, List<String> techniqueIds, [bool favorite = false]) => Combination(
      id: id,
      name: name,
      techniqueIds: techniqueIds,
      favorite: favorite,
      createdAt: 0,
    );

final seedCombinations = <Combination>[
  _c('combo-01', 'COMBO 01', ['t-jab', 't-cross', 't-lead-hook', 't-rear-low'], true),
  _c('combo-02', 'COMBO 02', ['t-jab', 't-cross', 't-rear-knee'], true),
  _c('combo-03', 'COMBO 03', ['t-lead-teep', 't-cross', 't-lead-hook', 't-rear-round']),
  _c('combo-04', 'COMBO 04', ['t-jab', 't-cross', 't-lead-hook', 't-rear-knee']),
  _c('combo-05', 'COMBO 05', ['t-cross', 't-lead-hook', 't-rear-low']),
  _c('combo-06', 'COMBO 06', ['t-lead-teep', 't-cross', 't-rear-round']),
  _c('combo-07', 'COMBO 07', ['t-jab', 't-lead-hook', 't-rear-uppercut', 't-rear-low']),
  _c('combo-08', 'COMBO 08', ['t-jab', 't-cross-body', 't-lead-hook-body', 't-rear-low']),
];

/// Seed stretching routines: same entity as combos, stretching techniques.
final seedStretchRoutines = <Combination>[
  _c('routine-stretch-full', 'FULL BODY STRETCH', [
    't-pancake',
    't-figure4-sx',
    't-figure4-dx',
    't-hipflexor-sx',
    't-hipflexor-dx',
    't-lat-sx',
    't-lat-dx',
  ]),
];

WorkoutBlock _b(
  String id,
  BlockType type,
  int duration, {
  int rounds = 1,
  int restDuration = 0,
  List<String> combinationIds = const [],
  String? label,
}) =>
    WorkoutBlock(
      id: id,
      type: type,
      duration: duration,
      rounds: rounds,
      restDuration: restDuration,
      combinationIds: combinationIds,
      label: label,
    );

WorkoutBlock _roundB(String id, int duration, int restDuration, [List<String> combinationIds = const []]) =>
    _b(id, BlockType.round, duration, restDuration: restDuration, combinationIds: combinationIds);

final seedWorkouts = <Workout>[
  Workout(
    id: 'workout-basics',
    name: 'HEAVY BAG BASICS',
    type: WorkoutType.heavyBag,
    createdAt: 0,
    blocks: [
      _roundB('wb-b1', 180, 60, ['combo-01']),
      _roundB('wb-b2', 180, 60, ['combo-02']),
      _roundB('wb-b3', 180, 60, ['combo-03']),
      _roundB('wb-b4', 180, 60, ['combo-01', 'combo-02', 'combo-03', 'combo-04', 'combo-05']),
      _b('wb-b5', BlockType.free, 180),
    ],
  ),
  Workout(
    id: 'workout-tabata',
    name: 'TABATA BLITZ',
    type: WorkoutType.tabata,
    createdAt: 0,
    blocks: [
      _b('wt-b1', BlockType.circuit, 20, rounds: 8, restDuration: 10),
    ],
  ),
  Workout(
    id: 'workout-sharp',
    name: '30/30 SHARPENING',
    type: WorkoutType.intervals,
    createdAt: 0,
    blocks: [
      _b('ws-b1', BlockType.circuit, 30, rounds: 10, restDuration: 30),
    ],
  ),
];

final seedStretchingWorkout = Workout(
  id: 'workout-stretching',
  name: 'STRETCHING ROUTINE',
  type: WorkoutType.stretching,
  createdAt: 0,
  blocks: [
    _b('str-b1', BlockType.stretching, 10 * 60, label: 'FULL BODY STRETCH'),
  ],
);

const seedPresets = <TimerPreset>[
  TimerPreset(id: 'preset-3030', name: '30/30 × 10', rounds: 10, workDuration: 30, restDuration: 30),
  TimerPreset(id: 'preset-4515', name: '45/15 × 8', rounds: 8, workDuration: 45, restDuration: 15),
  TimerPreset(id: 'preset-31', name: '3:00/1:00 × 5', rounds: 5, workDuration: 180, restDuration: 60),
  TimerPreset(id: 'preset-tabata', name: 'TABATA 20/10 × 8', rounds: 8, workDuration: 20, restDuration: 10),
];

AppData seedData() {
  final now = DateTime.now().millisecondsSinceEpoch;
  return AppData(
    version: 4,
    techniques: seedTechniques,
    combinations: [...seedCombinations, ...seedStretchRoutines]
        .map((c) => Combination(id: c.id, name: c.name, techniqueIds: c.techniqueIds, favorite: c.favorite, createdAt: now))
        .toList(),
    workouts: [...seedWorkouts, seedStretchingWorkout]
        .map((w) => Workout(id: w.id, name: w.name, type: w.type, blocks: w.blocks, createdAt: now))
        .toList(),
    sessions: const [],
    presets: seedPresets,
    plans: const [],
    settings: const Settings(sound: true, vibration: true, prepSeconds: 3),
  );
}
