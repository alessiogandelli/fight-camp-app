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
]) => Technique(
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
  _t(
    't-jab',
    'Jab',
    'JAB',
    TechniqueCategory.boxing,
    'Pugno diretto della mano avanti',
    'Jab',
    'JAB',
    'Lead-hand straight punch',
  ),
  _t(
    't-cross',
    'Diretto',
    'DIRETTO',
    TechniqueCategory.boxing,
    'Pugno diretto della mano dietro',
    'Cross',
    'CROSS',
    'Rear-hand straight punch',
  ),
  _t(
    't-lead-hook',
    'Gancio sinistro',
    'GANCIO SX',
    TechniqueCategory.boxing,
    null,
    'Lead Hook',
    'LEAD HOOK',
  ),
  _t(
    't-rear-hook',
    'Gancio destro',
    'GANCIO DX',
    TechniqueCategory.boxing,
    null,
    'Rear Hook',
    'REAR HOOK',
  ),
  _t(
    't-lead-uppercut',
    'Montante sinistro',
    'MONTANTE SX',
    TechniqueCategory.boxing,
    null,
    'Lead Uppercut',
    'LEAD UPPERCUT',
  ),
  _t(
    't-rear-uppercut',
    'Montante destro',
    'MONTANTE DX',
    TechniqueCategory.boxing,
    null,
    'Rear Uppercut',
    'REAR UPPERCUT',
  ),
  _t(
    't-jab-body',
    'Jab al corpo',
    'JAB CORPO',
    TechniqueCategory.boxing,
    'Jab al corpo',
    'Jab to Body',
    'JAB BODY',
    'Jab to the body',
  ),
  _t(
    't-cross-body',
    'Diretto al corpo',
    'DIRETTO CORPO',
    TechniqueCategory.boxing,
    'Diretto al corpo',
    'Cross to Body',
    'CROSS BODY',
    'Cross to the body',
  ),
  _t(
    't-lead-hook-body',
    'Gancio sinistro al corpo',
    'GANCIO SX CORPO',
    TechniqueCategory.boxing,
    null,
    'Lead Hook to Body',
    'LEAD HOOK BODY',
  ),
  _t(
    't-rear-hook-body',
    'Gancio destro al corpo',
    'GANCIO DX CORPO',
    TechniqueCategory.boxing,
    null,
    'Rear Hook to Body',
    'REAR HOOK BODY',
  ),
  _t(
    't-lead-teep',
    'Teep sinistro',
    'TEEP SX',
    TechniqueCategory.kicks,
    'Calcio spinta con la gamba avanti',
    'Lead Teep',
    'LEAD TEEP',
    'Lead push kick',
  ),
  _t(
    't-rear-teep',
    'Teep destro',
    'TEEP DX',
    TechniqueCategory.kicks,
    'Calcio spinta con la gamba dietro',
    'Rear Teep',
    'REAR TEEP',
    'Rear push kick',
  ),
  _t(
    't-lead-disturb',
    'Calcio disturbato sinistro',
    'DISTURBO SX',
    TechniqueCategory.kicks,
    'Calcio di disturbo con la gamba avanti',
    'Lead Disturb Kick',
    'DISTURB KICK',
    'Lead disturbance kick',
  ),
  _t(
    't-lead-round',
    'Calcio sinistro',
    'CALCIO SX',
    TechniqueCategory.kicks,
    null,
    'Lead Round Kick',
    'LEAD KICK',
  ),
  _t(
    't-rear-round',
    'Calcio destro',
    'CALCIO DX',
    TechniqueCategory.kicks,
    null,
    'Rear Round Kick',
    'REAR KICK',
  ),
  _t(
    't-lead-low',
    'Calcio basso sinistro',
    'CALCIO BASSO SX',
    TechniqueCategory.kicks,
    null,
    'Lead Low Kick',
    'LEAD LOW KICK',
  ),
  _t(
    't-rear-low',
    'Calcio basso destro',
    'CALCIO BASSO DX',
    TechniqueCategory.kicks,
    null,
    'Rear Low Kick',
    'REAR LOW KICK',
  ),
  _t(
    't-straight-knee',
    'Ginocchio dritto',
    'GINOCCHIO DRITTO',
    TechniqueCategory.knees,
    'Ginocchio dritto in avanti',
    'Straight Knee',
    'STRAIGHT KNEE',
    'Straight knee',
  ),
  _t(
    't-lead-knee',
    'Ginocchio laterale sinistro',
    'GINOCCHIO LAT SX',
    TechniqueCategory.knees,
    'Ginocchio laterale dal clinch',
    'Lead Knee',
    'LEAD KNEE',
    'Side knee from clinch',
  ),
  _t(
    't-rear-knee',
    'Ginocchio laterale destro',
    'GINOCCHIO LAT DX',
    TechniqueCategory.knees,
    'Ginocchio laterale dal clinch',
    'Rear Knee',
    'REAR KNEE',
    'Side knee from clinch',
  ),
  _t(
    "t-upward-elbow",
    "Gomito verso l'alto",
    'GOMITO SU',
    TechniqueCategory.elbows,
    "Gomito dal basso verso l'alto",
    'Upward Elbow',
    'UPWARD ELBOW',
  ),
  _t(
    "t-lead-elbow",
    'Gomito verso il basso',
    'GOMITO GIÙ',
    TechniqueCategory.elbows,
    "Gomito dall'alto verso il basso",
    'Downward Elbow',
    'DOWNWARD ELBOW',
  ),
  _t(
    't-elbow-sx',
    'Gomito sinistro',
    'GOMITO SX',
    TechniqueCategory.elbows,
    'Gomito laterale sinistro',
    'Left Elbow',
    'LEFT ELBOW',
  ),
  _t(
    't-elbow-dx',
    'Gomito destro',
    'GOMITO DX',
    TechniqueCategory.elbows,
    'Gomito laterale destro',
    'Right Elbow',
    'RIGHT ELBOW',
  ),
  _t(
    't-slip-left',
    'Schivata sinistra',
    'SCHIVATA SX',
    TechniqueCategory.defense,
    null,
    'Slip Left',
    'SLIP LEFT',
  ),
  _t(
    't-slip-right',
    'Schivata destra',
    'SCHIVATA DX',
    TechniqueCategory.defense,
    null,
    'Slip Right',
    'SLIP RIGHT',
  ),
  _t('t-roll', 'Roll', 'ROLL', TechniqueCategory.defense, null, 'Roll', 'ROLL'),
  _t(
    't-pull-back',
    'Arretramento',
    'ARRETRAMENTO',
    TechniqueCategory.defense,
    null,
    'Pull Back',
    'PULL BACK',
  ),
  _t(
    't-check',
    'Parata',
    'PARATA',
    TechniqueCategory.defense,
    null,
    'Check',
    'CHECK',
  ),
  _t(
    't-step-left',
    'Passo a sinistra',
    'PASSO SX',
    TechniqueCategory.defense,
    null,
    'Step Left',
    'STEP LEFT',
  ),
  _t(
    't-step-right',
    'Passo a destra',
    'PASSO DX',
    TechniqueCategory.defense,
    null,
    'Step Right',
    'STEP RIGHT',
  ),
  _t(
    't-pivot',
    'Pivot',
    'PIVOT',
    TechniqueCategory.defense,
    null,
    'Pivot',
    'PIVOT',
  ),
  _t(
    't-pancake',
    'Pancake',
    'PANCAKE',
    TechniqueCategory.stretching,
    'Apertura delle anche in avanti',
    'Pancake',
    'PANCAKE',
  ),
  _t(
    't-figure4-sx',
    'Figure 4 sinistro',
    'FIG4 SX',
    TechniqueCategory.stretching,
    'Esterni dell\'anca sinistra',
    'Figure 4 Left',
    'FIG4 LEFT',
  ),
  _t(
    't-figure4-dx',
    'Figure 4 destro',
    'FIG4 DX',
    TechniqueCategory.stretching,
    'Esterni dell\'anca destra',
    'Figure 4 Right',
    'FIG4 RIGHT',
  ),
  _t(
    't-hipflexor-sx',
    'Flessore anca sx',
    'FLESS SX',
    TechniqueCategory.stretching,
    'Flessore dell\'anca sinistro',
    'Hip Flexor Left',
    'HIPFLX LEFT',
  ),
  _t(
    't-hipflexor-dx',
    'Flessore anca dx',
    'FLESS DX',
    TechniqueCategory.stretching,
    'Flessore dell\'anca destro',
    'Hip Flexor Right',
    'HIPFLX RIGHT',
  ),
  _t(
    't-lat-sx',
    'Lat sinistro',
    'LAT SX',
    TechniqueCategory.stretching,
    'Dorsali sinistri',
    'Lat Stretch Left',
    'LAT LEFT',
  ),
  _t(
    't-lat-dx',
    'Lat destro',
    'LAT DX',
    TechniqueCategory.stretching,
    'Dorsali destri',
    'Lat Stretch Right',
    'LAT RIGHT',
  ),
  _t(
    't-butterfly',
    'Farfalla',
    'FARFALLA',
    TechniqueCategory.stretching,
    'Apertura delle anche con le piante dei piedi unite',
    'Butterfly',
    'BUTTERFLY',
    'Hip opener with the soles of the feet together',
  ),
  _t(
    't-forward-fold',
    'Piegamento avanti',
    'PIEG. AVANTI',
    TechniqueCategory.stretching,
    'Allungamento dei posteriori da seduto, gambe distese',
    'Seated Forward Fold',
    'FORWARD FOLD',
    'Seated hamstring and lower-back stretch, legs extended',
  ),
  _t(
    't-calf',
    'Polpaccio',
    'POLPACCIO',
    TechniqueCategory.stretching,
    'Polpaccio al muro, tallone a terra',
    'Calf Stretch',
    'CALF',
    'Calf stretch against the wall, heel down',
  ),
  _t(
    't-quad',
    'Quadricipite',
    'QUADRICIPITE',
    TechniqueCategory.stretching,
    'Quadricipite in piedi, caviglia verso il gluteo',
    'Standing Quad Stretch',
    'STANDING QUAD',
    'Standing quad stretch, ankle pulled to the glute',
  ),
  _t(
    't-triceps',
    'Tricipite',
    'TRICIPITE',
    TechniqueCategory.stretching,
    'Tricipite con il gomito sopra la testa',
    'Triceps Stretch',
    'TRICEPS',
    'Overhead triceps stretch with the elbow above the head',
  ),
  _t(
    't-chest',
    'Apertura petto',
    'PETTO',
    TechniqueCategory.stretching,
    'Apertura del petto, spalle indietro',
    'Chest Opener',
    'CHEST',
    'Open the chest and pull the shoulders back',
  ),
  _t(
    't-neck',
    'Collo',
    'COLLO',
    TechniqueCategory.stretching,
    'Allungamento laterale del collo',
    'Neck Stretch',
    'NECK',
    'Lateral neck stretch',
  ),
  _t(
    't-wrist',
    'Polso',
    'POLSO',
    TechniqueCategory.stretching,
    'Avambraccio e polso, dita estese',
    'Wrist & Forearm Stretch',
    'WRIST',
    'Forearm and wrist stretch with the fingers extended',
  ),
  _t(
    't-pigeon',
    'Piccione',
    'PICCIONE',
    TechniqueCategory.stretching,
    'Anca e gluteo, gamba davanti piegata',
    'Pigeon Pose',
    'PIGEON',
    'Hip and glute stretch with the front leg bent',
  ),
  // --- Extra boxing/kick technique atoms from the club programme. ---
  _t('t-shadow-boxing', 'Shadow boxing', 'SHADOW', TechniqueCategory.boxing),
  _t('t-boxe-line', 'Boxe in linea', 'BOXE LINEA', TechniqueCategory.boxing),
  _t(
    't-lead-mid',
    'Calcio medio sinistro',
    'CALCIO MEDIO SX',
    TechniqueCategory.kicks,
  ),
  _t(
    't-rear-mid',
    'Calcio medio destro',
    'CALCIO MEDIO DX',
    TechniqueCategory.kicks,
  ),
  _t(
    't-lead-side',
    'Calcio laterale sinistro',
    'CALICO SX',
    TechniqueCategory.kicks,
  ),
  _t(
    't-rear-side',
    'Calcio laterale destro',
    'CALICO DX',
    TechniqueCategory.kicks,
  ),
  _t(
    't-lead-round-double',
    'Calcio doppiato sinistro',
    'CALCIO SX DOPPIO',
    TechniqueCategory.kicks,
  ),
  _t(
    't-rear-round-double',
    'Calcio doppiato destro',
    'CALCIO DX DOPPIO',
    TechniqueCategory.kicks,
  ),
  _t(
    't-sfondamento',
    'Calcio sfondamento',
    'SFONDAMENTO',
    TechniqueCategory.kicks,
  ),
  _t(
    't-ascendente-dx',
    'Calcio ascendente destro',
    'CALCIO ASC DX',
    TechniqueCategory.kicks,
  ),
  _t(
    't-kick-in-out',
    'Calcio interno-esterno',
    'CALCIO INT-EST',
    TechniqueCategory.kicks,
  ),
  _t(
    't-knee-jump',
    'Ginocchiata in salto',
    'GINOCCHIATA SALTO',
    TechniqueCategory.knees,
  ),
  _t(
    't-elbow-front',
    'Gomito frontale',
    'GOMITO FRONTALE',
    TechniqueCategory.elbows,
  ),
  _t(
    't-elbow-spin',
    'Gomito girato',
    'GOMITO GIRATO',
    TechniqueCategory.elbows,
  ),
  _t(
    't-block-kick',
    'Blocco calcio',
    'BLOCCO CALCIO',
    TechniqueCategory.defense,
  ),
  _t(
    't-block-low',
    'Blocco calcio basso',
    'BLOCCO BASSO',
    TechniqueCategory.defense,
  ),
  _t(
    't-block-mid',
    'Blocco calcio medio',
    'BLOCCO MEDIO',
    TechniqueCategory.defense,
  ),
  _t(
    't-block-high',
    'Blocco calcio alto',
    'BLOCCO ALTO',
    TechniqueCategory.defense,
  ),
  _t(
    't-block-hook',
    'Blocco gancio',
    'BLOCCO GANCIO',
    TechniqueCategory.defense,
  ),
  _t(
    't-step-forward',
    'Passo avanti',
    'PASSO AVANTI',
    TechniqueCategory.defense,
  ),
  _t('t-switch-foot', 'Switch foot', 'SWITCH FOOT', TechniqueCategory.defense),
  _t('t-balancing', 'Balancing', 'BALANCING', TechniqueCategory.defense),
  _t('t-sweep', 'Spazzata', 'SPAZZATA', TechniqueCategory.defense),
  // --- Conditioning exercises (bodyweight / strength). ---
  _t('t-cond-pushup', 'Push up', 'PUSH UP', TechniqueCategory.conditioning),
  _t(
    't-cond-pushup-diamond',
    'Diamond push up',
    'DIAMOND PUSH UP',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-pushup-wide',
    'Wide push up',
    'WIDE PUSH UP',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-pushup-explosive',
    'Explosive push up',
    'EXPLOSIVE PUSH UP',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-pushup-side',
    'Side to side push up',
    'SIDE PUSH UP',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-pushup-fists',
    'Push up pugni chiusi',
    'PUSH UP PUGNI',
    TechniqueCategory.conditioning,
  ),
  _t('t-cond-squat', 'Squat', 'SQUAT', TechniqueCategory.conditioning),
  _t(
    't-cond-sumo-squat',
    'Sumo squat',
    'SUMO SQUAT',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-jump-squat',
    'Jump squat',
    'JUMP SQUAT',
    TechniqueCategory.conditioning,
  ),
  _t('t-cond-lunges', 'Affondi', 'AFFONDI', TechniqueCategory.conditioning),
  _t(
    't-cond-jump-lunges',
    'Jump lounges',
    'JUMP LOUNGES',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-switch-lunges',
    'Switching lunges',
    'SWITCH LUNGES',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-lunge-knee-dx',
    'Affondi + ginocchiata Dx',
    'AFFONDI+GIN DX',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-lunge-knee-sx',
    'Affondi + ginocchiata Sx',
    'AFFONDI+GIN SX',
    TechniqueCategory.conditioning,
  ),
  _t('t-cond-crunch', 'Crunch', 'CRUNCH', TechniqueCategory.conditioning),
  _t('t-cond-bicycles', 'Bicycles', 'BICYCLES', TechniqueCategory.conditioning),
  _t('t-cond-crucifix', 'Crucifix', 'CRUCIFIX', TechniqueCategory.conditioning),
  _t('t-cond-vups', 'V-ups', 'V-UPS', TechniqueCategory.conditioning),
  _t(
    't-cond-russian-twist',
    'Russian twist',
    'RUSSIAN TWIST',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-toe-touch',
    'Toe touch',
    'TOE TOUCH',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-leg-raises',
    'Leg raises',
    'LEG RAISES',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-side-crunch-dx',
    'Side crunch Dx',
    'SIDE CRUNCH DX',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-side-crunch-sx',
    'Side crunch Sx',
    'SIDE CRUNCH SX',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-abs-laterali',
    'ABS laterali Sx/Dx',
    'ABS LATERALI',
    TechniqueCategory.conditioning,
  ),
  _t('t-cond-plank', 'Plank', 'PLANK', TechniqueCategory.conditioning),
  _t(
    't-cond-low-high-plank',
    'Low to high plank',
    'LOW-HIGH PLANK',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-shoulder-taps',
    'Shoulder taps',
    'SHOULDER TAPS',
    TechniqueCategory.conditioning,
  ),
  _t('t-cond-squadra', 'Squadra', 'SQUADRA', TechniqueCategory.conditioning),
  _t(
    't-cond-mountain-climbers',
    'Mountain climbers',
    'MOUNTAIN CLIMBERS',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-switch-mountain-climbers',
    'Switching mountain climbers',
    'SWITCH MTN CLIMBERS',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-in-outs',
    'In & outs',
    'IN & OUTS',
    TechniqueCategory.conditioning,
  ),
  _t('t-cond-burpees', 'Burpees', 'BURPEES', TechniqueCategory.conditioning),
  _t(
    't-cond-half-burpees',
    'Half burpees',
    'HALF BURPEES',
    TechniqueCategory.conditioning,
  ),
  _t('t-cond-dorsali', 'Dorsali', 'DORSALI', TechniqueCategory.conditioning),
  _t(
    't-cond-dorsali-avanti',
    'Dorsali mani avanti',
    'DORSALI AVANTI',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-dorsali-fianchi',
    'Dorsali mani sui fianchi',
    'DORSALI FIANCHI',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-dorsali-incrociate',
    'Dorsali mani incrociate',
    'DORSALI INCROCIATE',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-dorsali-cross-foot',
    'Dorsali incrociati mano piede',
    'DORSALI MANO-PIEDE',
    TechniqueCategory.conditioning,
  ),
  _t(
    't-cond-knee-floor',
    'Ginocchiata da terra',
    'GINOCCHIATA TERRA',
    TechniqueCategory.conditioning,
  ),
];

Combination _c(
  String id,
  String name,
  List<String> techniqueIds, [
  bool favorite = false,
]) => Combination(
  id: id,
  name: name,
  techniqueIds: techniqueIds,
  favorite: favorite,
  createdAt: 0,
);

final seedCombinations = <Combination>[
  _c('combo-01', 'COMBO 01', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-low',
  ], true),
  _c('combo-02', 'COMBO 02', ['t-jab', 't-cross', 't-rear-knee'], true),
  _c('combo-03', 'COMBO 03', [
    't-lead-teep',
    't-cross',
    't-lead-hook',
    't-rear-round',
  ]),
  _c('combo-04', 'COMBO 04', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-knee',
  ]),
  _c('combo-05', 'COMBO 05', ['t-cross', 't-lead-hook', 't-rear-low']),
  _c('combo-06', 'COMBO 06', ['t-lead-teep', 't-cross', 't-rear-round']),
  _c('combo-07', 'COMBO 07', [
    't-jab',
    't-lead-hook',
    't-rear-uppercut',
    't-rear-low',
  ]),
  _c('combo-08', 'COMBO 08', [
    't-jab',
    't-cross-body',
    't-lead-hook-body',
    't-rear-low',
  ]),
  _c('combo-09', 'COMBO 09', ['t-jab', 't-cross', 't-lead-hook']),
  _c('combo-10', 'COMBO 10', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-round',
  ]),
  _c('combo-11', 'COMBO 11', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-round',
    't-cross',
    't-lead-hook-body',
  ]),
  _c('combo-12', 'COMBO 12', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-round',
    't-cross',
    't-lead-hook-body',
    't-rear-round',
  ]),
  _c('combo-13', 'COMBO 13', ['t-lead-disturb', 't-jab', 't-cross']),
  _c('combo-14', 'COMBO 14', [
    't-lead-round',
    't-jab',
    't-cross',
    't-lead-uppercut',
  ]),
  _c('combo-15', 'COMBO 15', [
    't-lead-round',
    't-jab',
    't-cross',
    't-lead-uppercut',
    't-straight-knee',
  ]),
  _c('combo-16', 'COMBO 16', [
    't-lead-round',
    't-jab',
    't-cross',
    't-lead-uppercut',
    't-straight-knee',
    't-rear-round',
  ]),
  _c('combo-17', 'COMBO 17', ['t-jab', 't-jab', 't-rear-hook']),
  _c('combo-18', 'COMBO 18', ['t-jab', 't-jab', 't-rear-hook', 't-check']),
  _c('combo-19', 'COMBO 19', [
    't-jab',
    't-jab',
    't-rear-hook',
    't-check',
    't-rear-uppercut',
    't-lead-hook',
  ]),
  _c('combo-20', 'COMBO 20', [
    't-jab',
    't-jab',
    't-rear-hook',
    't-check',
    't-rear-uppercut',
    't-lead-hook',
    't-rear-round',
  ]),
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

final seedWorkouts = <Workout>[
  // 30" x 20 without pause.
  Workout(
    id: 'workout-warmup',
    name: 'RISCALDAMENTO',
    workDuration: 30,
    restDuration: 0,
    rounds: 20,
    createdAt: 0,
  ),
  // 1:30 work / 45" pause, 3 rounds.
  Workout(
    id: 'workout-rope',
    name: 'CORDA',
    workDuration: 90,
    restDuration: 45,
    rounds: 3,
    createdAt: 0,
  ),
  // 30" work / 10" pause, 10 rounds.
  Workout(
    id: 'workout-circuit',
    name: 'CIRCUITO',
    workDuration: 30,
    restDuration: 10,
    rounds: 10,
    createdAt: 0,
  ),
  // 1:30 work / 1:00 pause, endless (rounds == 0): runs until stopped.
  Workout(
    id: 'workout-sparring',
    name: 'SPARRING',
    workDuration: 90,
    restDuration: 60,
    rounds: 0,
    createdAt: 0,
  ),
  // 2:00 work / 30" pause, 12 rounds: one seeded combination per round.
  Workout(
    id: 'workout-combinations',
    name: 'COMBINAZIONI',
    workDuration: 120,
    restDuration: 30,
    rounds: 12,
    combinationIds: [
      'combo-09',
      'combo-10',
      'combo-11',
      'combo-12',
      'combo-13',
      'combo-14',
      'combo-15',
      'combo-16',
      'combo-17',
      'combo-18',
      'combo-19',
      'combo-20',
    ],
    createdAt: 0,
  ),
];

final seedStretchingWorkout = Workout(
  id: 'workout-stretching',
  name: 'STRETCHING ROUTINE',
  workDuration: 30,
  restDuration: 10,
  rounds: seedStretchRoutines.first.techniqueIds.length,
  routineId: seedStretchRoutines.first.id,
  createdAt: 0,
);

final seedCombosThai = <Combination>[
  // Jab – diretto – calcio circolare sinistro.
  _c('combo-thai-01', 'JAB-DIRETTO-CALCIO SX', [
    't-jab',
    't-cross',
    't-lead-round',
  ]),
  // Jab – diretto – gancio sinistro - calcio circolare destro.
  _c('combo-thai-02', 'JAB-DIRETTO-GANCIO SX-CALCIO DX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-round',
  ]),
  // Jab – diretto - calcio circolare sinistro doppiato – diretto – gancio Sx.
  _c('combo-thai-03', 'JAB-DIRETTO-CALCIO SX DOPPIO-DIRETTO-GANCIO SX', [
    't-jab',
    't-cross',
    't-lead-round-double',
    't-cross',
    't-lead-hook',
  ]),
  // Jab – diretto – gancio sinistro al corpo – gancio sinistro – block destro – calcio circolare destro.
  _c(
    'combo-thai-04',
    'JAB-DIRETTO-GANCIO SX CORPO-GANCIO SX-PARATA-CALCIO DX',
    [
      't-jab',
      't-cross',
      't-lead-hook-body',
      't-lead-hook',
      't-check',
      't-rear-round',
    ],
  ),
  // Teep Sx - 1 - 2 - gancio Sx - diretto Dx – calcio Dx
  _c('combo-thai-05', 'TEEP SX-JAB-DIRETTO-GANCIO SX-DIRETTO-CALCIO DX', [
    't-lead-teep',
    't-jab',
    't-cross',
    't-lead-hook',
    't-cross',
    't-rear-round',
  ]),
  // Disturbo interno calcio Sx – Jab - diretto – Calcio Dx
  _c('combo-thai-06', 'DISTURBO SX-JAB-DIRETTO-CALCIO DX', [
    't-lead-disturb',
    't-jab',
    't-cross',
    't-rear-round',
  ]),
  // 1-2 -gancio Sx - montante Dx - check Dx
  _c('combo-thai-07', 'JAB-DIRETTO-GANCIO SX-MONTANTE DX-PARATA', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-uppercut',
    't-check',
  ]),
  // Calcio Sx – calcio Dx X 2 - check Sx
  _c('combo-thai-08', 'CALCIO SX-CALCIO DX-PARATA', [
    't-lead-round',
    't-rear-round',
    't-check',
  ]),
  // 1-2-gancio Sx - calcio Dx - gomitata Sx
  _c('combo-thai-09', 'JAB-DIRETTO-GANCIO SX-CALCIO DX-GOMITO SX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-round',
    't-elbow-sx',
  ]),
  // Jab - Diretto – schivata indietro
  _c('combo-thai-10', 'JAB-DIRETTO-INDIETRO', [
    't-jab',
    't-cross',
    't-pull-back',
  ]),
  // Jab - gancio Sx - diretto Dx
  _c('combo-thai-11', 'JAB-GANCIO SX-DIRETTO', [
    't-jab',
    't-lead-hook',
    't-cross',
  ]),
  // 1-2-3- gancio Dx
  _c('combo-thai-12', 'JAB-DIRETTO-JAB-GANCIO DX', [
    't-jab',
    't-cross',
    't-jab',
    't-rear-hook',
  ]),
  // 1-2- montante Sx - Gancio Dx
  _c('combo-thai-13', 'JAB-DIRETTO-MONTANTE SX-GANCIO DX', [
    't-jab',
    't-cross',
    't-lead-uppercut',
    't-rear-hook',
  ]),
  // 1 - diretto corpo Dx - gancio Sx – diretto Dx
  _c('combo-thai-14', 'JAB-DIRETTO CORPO-GANCIO SX-DIRETTO', [
    't-jab',
    't-cross-body',
    't-lead-hook',
    't-cross',
  ]),
  // 1-2 – uscita indietro – diretto Dx – gancio Sx
  _c('combo-thai-15', 'JAB-DIRETTO-INDIETRO-DIRETTO-GANCIO SX', [
    't-jab',
    't-cross',
    't-pull-back',
    't-cross',
    't-lead-hook',
  ]),
  // 1 / 1-2 / 1-2-3 / 1-2 / 1
  _c('combo-thai-16', 'JAB-DIRETTO', ['t-jab', 't-cross']),
  // 1-2-gancio Sx- gancio Sx corpo
  _c('combo-thai-17', 'JAB-DIRETTO-GANCIO SX-GANCIO SX CORPO', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-lead-hook-body',
  ]),
  // Check Sx – teep Sx – knee Dx  1’
  _c('combo-thai-18', 'PARATA-TEEP SX-GINOCCHIO DX', [
    't-check',
    't-lead-teep',
    't-rear-knee',
  ]),
  // Check Dx – teep Dx – knee Sx  1’
  _c('combo-thai-19', 'PARATA-TEEP DX-GINOCCHIO SX', [
    't-check',
    't-rear-teep',
    't-lead-knee',
  ]),
  // Switch foot x 3/4 - gancio – diretto 1’
  _c('combo-thai-20', 'SWITCH FOOT-GANCIO SX-DIRETTO', [
    't-switch-foot',
    't-lead-hook',
    't-cross',
  ]),
  // Switch foot x 3/4 – elbow x 2  1’
  _c('combo-thai-21', 'SWITCH FOOT-GOMITO FRONTALE', [
    't-switch-foot',
    't-elbow-front',
  ]),
  // Calico Dx – check Dx – teep Sx  1’
  _c('combo-thai-22', 'CALICO DX-PARATA-TEEP SX', [
    't-rear-side',
    't-check',
    't-lead-teep',
  ]),
  // Calico Sx – check Sx – teep Dx  1’
  _c('combo-thai-23', 'CALICO SX-PARATA-TEEP DX', [
    't-lead-side',
    't-check',
    't-rear-teep',
  ]),
  // Calcio Sx – knee Dx – check Dx 1’
  _c('combo-thai-24', 'CALCIO SX-GINOCCHIO DX-PARATA', [
    't-lead-round',
    't-rear-knee',
    't-check',
  ]),
  // 1-2-Gancio Sx / 1-2-3-Gancio Dx
  _c('combo-thai-25', 'JAB-DIRETTO-GANCIO SX-JAB-DIRETTO-JAB-GANCIO DX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-jab',
    't-cross',
    't-jab',
    't-rear-hook',
  ]),
  // 1-1-2-Gancio Sx
  _c('combo-thai-26', 'JAB x2-DIRETTO-GANCIO SX', [
    't-jab',
    't-jab',
    't-cross',
    't-lead-hook',
  ]),
  // - 1-gancio Sx-diretto Dx-montante Sx
  _c('combo-thai-27', 'JAB-GANCIO SX-DIRETTO-MONTANTE SX', [
    't-jab',
    't-lead-hook',
    't-cross',
    't-lead-uppercut',
  ]),
  // - 1-10-1 kick Dx
  _c('combo-thai-28', 'JAB-DIRETTO-CALCIO DX', [
    't-jab',
    't-cross',
    't-rear-round',
  ]),
  // - 1-gancio Dx-ginocchiata Sx
  _c('combo-thai-29', 'JAB-GANCIO DX-GINOCCHIO SX', [
    't-jab',
    't-rear-hook',
    't-lead-knee',
  ]),
  // Jab-Diretto-Gancio Sx
  _c('combo-thai-30', 'JAB-DIRETTO-GANCIO SX', [
    't-jab',
    't-cross',
    't-lead-hook',
  ]),
  // Jab-Diretto-Gancio Sx-Calcio Dx-Diretto-Gancio Sx corpo
  _c(
    'combo-thai-31',
    'JAB-DIRETTO-GANCIO SX-CALCIO DX-DIRETTO-GANCIO SX CORPO',
    [
      't-jab',
      't-cross',
      't-lead-hook',
      't-rear-round',
      't-cross',
      't-lead-hook-body',
    ],
  ),
  // Jab-Diretto-Gancio Sx-Calcio Dx-Diretto-Gancio Sx corpo-Calcio Dx
  _c(
    'combo-thai-32',
    'JAB-DIRETTO-GANCIO SX-CALCIO DX-DIRETTO-GANCIO SX CORPO-CALCIO DX',
    [
      't-jab',
      't-cross',
      't-lead-hook',
      't-rear-round',
      't-cross',
      't-lead-hook-body',
      't-rear-round',
    ],
  ),
  // Calcio Sx disturbo-Jab-Diretto
  _c('combo-thai-33', 'DISTURBO SX-JAB-DIRETTO', [
    't-lead-disturb',
    't-jab',
    't-cross',
  ]),
  // Calcio Sx-Jab-Diretto-Montante Sx
  _c('combo-thai-34', 'CALCIO SX-JAB-DIRETTO-MONTANTE SX', [
    't-lead-round',
    't-jab',
    't-cross',
    't-lead-uppercut',
  ]),
  // Calcio Sx-Jab-Diretto-Montante Sx-Ginocchiata Dx
  _c('combo-thai-35', 'CALCIO SX-JAB-DIRETTO-MONTANTE SX-GINOCCHIO DX', [
    't-lead-round',
    't-jab',
    't-cross',
    't-lead-uppercut',
    't-rear-knee',
  ]),
  // Calcio Sx-Jab-Diretto-Montante Sx-Ginocchiata Dx-Calcio Dx
  _c(
    'combo-thai-36',
    'CALCIO SX-JAB-DIRETTO-MONTANTE SX-GINOCCHIO DX-CALCIO DX',
    [
      't-lead-round',
      't-jab',
      't-cross',
      't-lead-uppercut',
      't-rear-knee',
      't-rear-round',
    ],
  ),
  // Jab-Jab-Gancio Dx
  _c('combo-thai-37', 'JAB x2-GANCIO DX', ['t-jab', 't-jab', 't-rear-hook']),
  // Jab-Jab-Gancio Dx- Blocco calcio con trattenuta (usando braccio Sx)
  _c('combo-thai-38', 'JAB x2-GANCIO DX-BLOCCO CALCIO', [
    't-jab',
    't-jab',
    't-rear-hook',
    't-block-kick',
  ]),
  // Jab-Jab-Gancio Dx- Blocco calcio-Montante Dx-Gancio Sx
  _c('combo-thai-39', 'JAB x2-GANCIO DX-BLOCCO CALCIO-MONTANTE DX-GANCIO SX', [
    't-jab',
    't-jab',
    't-rear-hook',
    't-block-kick',
    't-rear-uppercut',
    't-lead-hook',
  ]),
  // Jab-Jab-Gancio Dx- Blocco calcio-Montante Dx-Gancio Sx-Calcio Dx
  _c(
    'combo-thai-40',
    'JAB x2-GANCIO DX-BLOCCO CALCIO-MONTANTE DX-GANCIO SX-CALCIO DX',
    [
      't-jab',
      't-jab',
      't-rear-hook',
      't-block-kick',
      't-rear-uppercut',
      't-lead-hook',
      't-rear-round',
    ],
  ),
  // Jab-Jab-Diretto
  _c('combo-thai-41', 'JAB x2-DIRETTO', ['t-jab', 't-jab', 't-cross']),
  // Jab-Jab-Diretto-Gancio Sx-Ginocchiata Dx
  _c('combo-thai-42', 'JAB x2-DIRETTO-GANCIO SX-GINOCCHIO DX', [
    't-jab',
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-knee',
  ]),
  // Jab-Jab-Diretto-Gancio Sx-Ginocchiata Dx-Calcio Dx
  _c('combo-thai-43', 'JAB x2-DIRETTO-GANCIO SX-GINOCCHIO DX-CALCIO DX', [
    't-jab',
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-knee',
    't-rear-round',
  ]),
  // Jab-Diretto-Ginocchiata Sx
  _c('combo-thai-44', 'JAB-DIRETTO-GINOCCHIO SX', [
    't-jab',
    't-cross',
    't-lead-knee',
  ]),
  // Jab-Diretto-Ginocchiata Sx-Calcio basso Dx
  _c('combo-thai-45', 'JAB-DIRETTO-GINOCCHIO SX-CALCIO BASSO DX', [
    't-jab',
    't-cross',
    't-lead-knee',
    't-rear-low',
  ]),
  // Jab-Diretto-Cancio Sx corpo-Calcio Dx
  _c('combo-thai-46', 'JAB-DIRETTO-GANCIO SX CORPO-CALCIO DX', [
    't-jab',
    't-cross',
    't-lead-hook-body',
    't-rear-round',
  ]),
  // Jab-Diretto-Gancio Sx-Diretto-Calcio Sx
  _c('combo-thai-47', 'JAB-DIRETTO-GANCIO SX-DIRETTO-CALCIO SX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-cross',
    't-lead-round',
  ]),
  // Gancio Sx-Diretto-Calcio Sx
  _c('combo-thai-48', 'GANCIO SX-DIRETTO-CALCIO SX', [
    't-lead-hook',
    't-cross',
    't-lead-round',
  ]),
  // Gancio Sx-Calcio Dx basso
  _c('combo-thai-49', 'GANCIO SX-CALCIO BASSO DX', [
    't-lead-hook',
    't-rear-low',
  ]),
  // Gancio Sx-Calcio Dx basso-Diretto-Gancio Sx
  _c('combo-thai-50', 'GANCIO SX-CALCIO BASSO DX-DIRETTO-GANCIO SX', [
    't-lead-hook',
    't-rear-low',
    't-cross',
    't-lead-hook',
  ]),
  // Calcio Dx-Tip
  _c('combo-thai-51', 'CALCIO DX-TEEP SX', ['t-rear-round', 't-lead-teep']),
  // Calcio Dx-Tip-Jab-Diretto
  _c('combo-thai-52', 'CALCIO DX-TEEP SX-JAB-DIRETTO', [
    't-rear-round',
    't-lead-teep',
    't-jab',
    't-cross',
  ]),
  // Calcio Dx-Tip-Jab-Diretto-Calcio Sx
  _c('combo-thai-53', 'CALCIO DX-TEEP SX-JAB-DIRETTO-CALCIO SX', [
    't-rear-round',
    't-lead-teep',
    't-jab',
    't-cross',
    't-lead-round',
  ]),
  // Jab-Diretto-Gancio Sx-Gancio Sx corpo -Calcio Dx basso
  _c('combo-thai-54', 'JAB-DIRETTO-GANCIO SX-GANCIO SX CORPO-CALCIO BASSO DX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-lead-hook-body',
    't-rear-low',
  ]),
  // Jab-Diretto-Calcio Sx basso
  _c('combo-thai-55', 'JAB-DIRETTO-CALCIO BASSO SX', [
    't-jab',
    't-cross',
    't-lead-low',
  ]),
  // Jab-Diretto-Ganci-Montanti
  _c('combo-thai-56', 'JAB-DIRETTO-GANCIO SX-MONTANTE SX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-lead-uppercut',
  ]),
  // Jab-Diretto-Gancio Sx corpo
  _c('combo-thai-57', 'JAB-DIRETTO-GANCIO SX CORPO', [
    't-jab',
    't-cross',
    't-lead-hook-body',
  ]),
  // Jab-Diretto-Gancio Sx corpo-Low Kick Dx
  _c('combo-thai-58', 'JAB-DIRETTO-GANCIO SX CORPO-CALCIO BASSO DX', [
    't-jab',
    't-cross',
    't-lead-hook-body',
    't-rear-low',
  ]),
  // Jab-Diretto-Gancio Sx corpo-Calcio basso Dx-Calcio Sx
  _c('combo-thai-59', 'JAB-DIRETTO-GANCIO SX CORPO-CALCIO BASSO DX-CALCIO SX', [
    't-jab',
    't-cross',
    't-lead-hook-body',
    't-rear-low',
    't-lead-round',
  ]),
  // Jab-Diretto-Calcio Sx basso-Calcio Sx
  _c('combo-thai-60', 'JAB-DIRETTO-CALCIO BASSO SX-CALCIO SX', [
    't-jab',
    't-cross',
    't-lead-low',
    't-lead-round',
  ]),
  // Jab-Diretto-Calcio Sx basso-Calcio Sx-Diretto-Gancio Sx
  _c(
    'combo-thai-61',
    'JAB-DIRETTO-CALCIO BASSO SX-CALCIO SX-DIRETTO-GANCIO SX',
    [
      't-jab',
      't-cross',
      't-lead-low',
      't-lead-round',
      't-cross',
      't-lead-hook',
    ],
  ),
  // Jab-Diretto-Gancio Sx corpo-Gancio Sx
  _c('combo-thai-62', 'JAB-DIRETTO-GANCIO SX CORPO-GANCIO SX', [
    't-jab',
    't-cross',
    't-lead-hook-body',
    't-lead-hook',
  ]),
  // Jab-Diretto-Gancio Sx corpo-Gancio Sx-Calcio Dx
  _c('combo-thai-63', 'JAB-DIRETTO-GANCIO SX CORPO-GANCIO SX-CALCIO DX', [
    't-jab',
    't-cross',
    't-lead-hook-body',
    't-lead-hook',
    't-rear-round',
  ]),
  // Jab-Diretto-Gancio Sx corpo-Gancio Sx-Calcio Dx-Gancio Sx-Diretto Dx
  _c(
    'combo-thai-64',
    'JAB-DIRETTO-GANCIO SX CORPO-GANCIO SX-CALCIO DX-GANCIO SX-DIRETTO',
    [
      't-jab',
      't-cross',
      't-lead-hook-body',
      't-lead-hook',
      't-rear-round',
      't-lead-hook',
      't-cross',
    ],
  ),
  // Jab-Calcio Dx
  _c('combo-thai-65', 'JAB-CALCIO DX', ['t-jab', 't-rear-round']),
  // Jab-Caclio Dx-Jab-Diretto
  _c('combo-thai-66', 'JAB-CALCIO DX-JAB-DIRETTO', [
    't-jab',
    't-rear-round',
    't-jab',
    't-cross',
  ]),
  // Jab-Caclio Dx-Jab-Diretto-Calcio Sx
  _c('combo-thai-67', 'JAB-CALCIO DX-JAB-DIRETTO-CALCIO SX', [
    't-jab',
    't-rear-round',
    't-jab',
    't-cross',
    't-lead-round',
  ]),
  // Jab-Calcio Dx-Diretto-Calcio Sx
  _c('combo-thai-68', 'JAB-CALCIO DX-DIRETTO-CALCIO SX', [
    't-jab',
    't-rear-round',
    't-cross',
    't-lead-round',
  ]),
  // Jab-Diretto-Montante Sx-Calcio Dx basso
  _c('combo-thai-69', 'JAB-DIRETTO-MONTANTE SX-CALCIO BASSO DX', [
    't-jab',
    't-cross',
    't-lead-uppercut',
    't-rear-low',
  ]),
  // Jab-Gancio Sx-Diretto Dx-Teep-Calcio Dx
  _c('combo-thai-70', 'JAB-GANCIO SX-DIRETTO-TEEP SX-CALCIO DX', [
    't-jab',
    't-lead-hook',
    't-cross',
    't-lead-teep',
    't-rear-round',
  ]),
  // 10 Calci Dx+Sx – no stop Boxing
  _c('combo-thai-71', 'CALCIO DX-SHADOW', ['t-rear-round', 't-shadow-boxing']),
  // Calcio Sx basso-Jab-Diretto-Gancio Sx
  _c('combo-thai-72', 'CALCIO BASSO SX-JAB-DIRETTO-GANCIO SX', [
    't-lead-low',
    't-jab',
    't-cross',
    't-lead-hook',
  ]),
  // Jab-Jab-Calcio Dx basso-Gancio Sx-Calcio Dx basso
  _c('combo-thai-73', 'JAB x2-CALCIO BASSO DX-GANCIO SX-CALCIO BASSO DX', [
    't-jab',
    't-jab',
    't-rear-low',
    't-lead-hook',
    't-rear-low',
  ]),
  // Jab-Jab-Calcio Dx basso-Gancio Sx-Diretto
  _c('combo-thai-74', 'JAB x2-CALCIO BASSO DX-GANCIO SX-DIRETTO', [
    't-jab',
    't-jab',
    't-rear-low',
    't-lead-hook',
    't-cross',
  ]),
  // Jab-Jab-Calcio Dx basso-Gancio Sx-Diretto-Calcio Sx
  _c('combo-thai-75', 'JAB x2-CALCIO BASSO DX-GANCIO SX-DIRETTO-CALCIO SX', [
    't-jab',
    't-jab',
    't-rear-low',
    't-lead-hook',
    't-cross',
    't-lead-round',
  ]),
  // Jab-Gancio Sx-Calcio Dx doppio
  _c('combo-thai-76', 'JAB-GANCIO SX-CALCIO DX DOPPIO', [
    't-jab',
    't-lead-hook',
    't-rear-round-double',
  ]),
  // Jab-Jab-Diretto-Calcio Sx-Gancio Dx-Montante Sx
  _c('combo-thai-77', 'JAB x2-DIRETTO-CALCIO SX-GANCIO DX-MONTANTE SX', [
    't-jab',
    't-jab',
    't-cross',
    't-lead-round',
    't-rear-hook',
    't-lead-uppercut',
  ]),
  // Jab – Jab - ginocchiata frontale Dx
  _c('combo-thai-78', 'JAB x2-GINOCCHIO DRITTO', [
    't-jab',
    't-jab',
    't-straight-knee',
  ]),
  // Jab - diretto - ginocchiata frontale Sx
  _c('combo-thai-79', 'JAB-DIRETTO-GINOCCHIO DRITTO', [
    't-jab',
    't-cross',
    't-straight-knee',
  ]),
  // Calcio basso Dx - ginocchiata Dx
  _c('combo-thai-80', 'CALCIO BASSO DX-GINOCCHIO DX', [
    't-rear-low',
    't-rear-knee',
  ]),
  // Calcio basso Sx - ginocchiata Sx
  _c('combo-thai-81', 'CALCIO BASSO SX-GINOCCHIO SX', [
    't-lead-low',
    't-lead-knee',
  ]),
  // Ginocchiata Sx - ginocchiata Dx
  _c('combo-thai-82', 'GINOCCHIO SX-GINOCCHIO DX', [
    't-lead-knee',
    't-rear-knee',
  ]),
  // Jab - jab - passo avanti Dx - ginocchiata Sx – gomitata laterale Dx
  _c('combo-thai-83', 'JAB x2-PASSO AVANTI-GINOCCHIO SX-GOMITO DX', [
    't-jab',
    't-jab',
    't-step-forward',
    't-lead-knee',
    't-elbow-dx',
  ]),
  // Jab – Diretto – ginocchiata Sx – ginocchiata Dx – diretto Dx ad uscire - gomitata girata Sx
  _c(
    'combo-thai-84',
    'JAB-DIRETTO-GINOCCHIO SX-GINOCCHIO DX-DIRETTO-GOMITO GIRATO',
    [
      't-jab',
      't-cross',
      't-lead-knee',
      't-rear-knee',
      't-cross',
      't-elbow-spin',
    ],
  ),
  // Calcio Dx-Jab-Diretto-Gancio Sx
  _c('combo-thai-85', 'CALCIO DX-JAB-DIRETTO-GANCIO SX', [
    't-rear-round',
    't-jab',
    't-cross',
    't-lead-hook',
  ]),
  // Calcio Sx-Jab-Diretto
  _c('combo-thai-86', 'CALCIO SX-JAB-DIRETTO', [
    't-lead-round',
    't-jab',
    't-cross',
  ]),
  // Jab-Diretto-Gancio Sx-Diretto-Calcio Dx
  _c('combo-thai-87', 'JAB-DIRETTO-GANCIO SX-DIRETTO-CALCIO DX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-cross',
    't-rear-round',
  ]),
  // Jab- Diretto-Ginocchiata Sx-Calcio Dx
  _c('combo-thai-88', 'JAB-DIRETTO-GINOCCHIO SX-CALCIO DX', [
    't-jab',
    't-cross',
    't-lead-knee',
    't-rear-round',
  ]),
  // Jab- Diretto-Gancio Sx-Ginocchiata Dx-Calcio Dx
  _c('combo-thai-89', 'JAB-DIRETTO-GANCIO SX-GINOCCHIO DX-CALCIO DX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-knee',
    't-rear-round',
  ]),
  // Calcio basso Dx-Calcio medio Dx
  _c('combo-thai-90', 'CALCIO BASSO DX-CALCIO MEDIO DX', [
    't-rear-low',
    't-rear-mid',
  ]),
  // Calcio basso Sx-Calcio medio Sx
  _c('combo-thai-91', 'CALCIO BASSO SX-CALCIO MEDIO SX', [
    't-lead-low',
    't-lead-mid',
  ]),
  // Jab- Diretto-Gancio Sx- Calcio basso Dx-Calcio medio Dx
  _c('combo-thai-92', 'JAB-DIRETTO-GANCIO SX-CALCIO BASSO DX-CALCIO MEDIO DX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-low',
    't-rear-mid',
  ]),
  // Jab- Diretto-Tip-Calcio Dx
  _c('combo-thai-93', 'JAB-DIRETTO-TEEP SX-CALCIO DX', [
    't-jab',
    't-cross',
    't-lead-teep',
    't-rear-round',
  ]),
  // Jab-Diretto al corpo-Calcio Sx
  _c('combo-thai-94', 'JAB-DIRETTO CORPO-CALCIO SX', [
    't-jab',
    't-cross-body',
    't-lead-round',
  ]),
  // Jab- Diretto al corpo-Gancio Sx -Calcio Dx
  _c('combo-thai-95', 'JAB-DIRETTO CORPO-GANCIO SX-CALCIO DX', [
    't-jab',
    't-cross-body',
    't-lead-hook',
    't-rear-round',
  ]),
  // Jab-Gancio Sx-Diretto Dx-Calcio Sx-Calcio Dx
  _c('combo-thai-96', 'JAB-GANCIO SX-DIRETTO-CALCIO SX-CALCIO DX', [
    't-jab',
    't-lead-hook',
    't-cross',
    't-lead-round',
    't-rear-round',
  ]),
  // Blocco Gancio parte Dx-Diretto Dx-Gancio Sx
  _c('combo-thai-97', 'BLOCCO GANCIO-DIRETTO-GANCIO SX', [
    't-block-hook',
    't-cross',
    't-lead-hook',
  ]),
  // Blocco Gancio parte Sx-Gancio Sx-Diretto Dx
  _c('combo-thai-98', 'BLOCCO GANCIO-GANCIO SX-DIRETTO', [
    't-block-hook',
    't-lead-hook',
    't-cross',
  ]),
  // Blocco Gancio parte Dx-Diretto Dx-Gancio Sx-Diretto Dx
  _c('combo-thai-99', 'BLOCCO GANCIO-DIRETTO-GANCIO SX-DIRETTO', [
    't-block-hook',
    't-cross',
    't-lead-hook',
    't-cross',
  ]),
  // Blocco Gancio parte Sx-Gancio Sx-Diretto Dx-Gancio Sx
  _c('combo-thai-100', 'BLOCCO GANCIO-GANCIO SX-DIRETTO-GANCIO SX', [
    't-block-hook',
    't-lead-hook',
    't-cross',
    't-lead-hook',
  ]),
  // Blocco Gancio parte Sx-Gancio Sx-Diretto Dx-Gancio Sx-Calcio Basso Dx
  _c(
    'combo-thai-101',
    'BLOCCO GANCIO-GANCIO SX-DIRETTO-GANCIO SX-CALCIO BASSO DX',
    ['t-block-hook', 't-lead-hook', 't-cross', 't-lead-hook', 't-rear-low'],
  ),
  // Blocco Gancio parte Dx-Diretto Dx-Gancio Sx-Diretto Dx-Calcio Basso Sx
  _c(
    'combo-thai-102',
    'BLOCCO GANCIO-DIRETTO-GANCIO SX-DIRETTO-CALCIO BASSO SX',
    ['t-block-hook', 't-cross', 't-lead-hook', 't-cross', 't-lead-low'],
  ),
  // Jab-Diretto-Blocco Gancio parte Dx-Diretto Dx-Gancio Sx
  _c('combo-thai-103', 'JAB-DIRETTO-BLOCCO GANCIO-DIRETTO-GANCIO SX', [
    't-jab',
    't-cross',
    't-block-hook',
    't-cross',
    't-lead-hook',
  ]),
  // Jab-Diretto-Blocco Gancio parte Dx-Diretto Dx-Gancio Sx-Calcio Dx
  _c(
    'combo-thai-104',
    'JAB-DIRETTO-BLOCCO GANCIO-DIRETTO-GANCIO SX-CALCIO DX',
    [
      't-jab',
      't-cross',
      't-block-hook',
      't-cross',
      't-lead-hook',
      't-rear-round',
    ],
  ),
  // Blocco Gancio parte Dx-Diretto Dx-Gancio Sx-Diretto Dx-Calcio Sx
  _c('combo-thai-105', 'BLOCCO GANCIO-DIRETTO-GANCIO SX-DIRETTO-CALCIO SX', [
    't-block-hook',
    't-cross',
    't-lead-hook',
    't-cross',
    't-lead-round',
  ]),
  // Jab-Diretto-Jab-Diretto-Calcio Dx
  _c('combo-thai-106', 'JAB-DIRETTO-JAB-DIRETTO-CALCIO DX', [
    't-jab',
    't-cross',
    't-jab',
    't-cross',
    't-rear-round',
  ]),
  // Jab-Diretto-Jab-Diretto-Calcio Dx-Blocco Dx
  _c('combo-thai-107', 'JAB-DIRETTO-JAB-DIRETTO-CALCIO DX-BLOCCO CALCIO', [
    't-jab',
    't-cross',
    't-jab',
    't-cross',
    't-rear-round',
    't-block-kick',
  ]),
  // Jab-Diretto-Jab-Diretto-Calcio Sx-Blocco Sx
  _c('combo-thai-108', 'JAB-DIRETTO-JAB-DIRETTO-CALCIO SX-BLOCCO CALCIO', [
    't-jab',
    't-cross',
    't-jab',
    't-cross',
    't-lead-round',
    't-block-kick',
  ]),
  // Calcio Dx - Jab
  _c('combo-thai-109', 'CALCIO DX-JAB', ['t-rear-round', 't-jab']),
  // Calcio Dx basso-Jab-Jab-Diretto
  _c('combo-thai-110', 'CALCIO BASSO DX-JAB x2-DIRETTO', [
    't-rear-low',
    't-jab',
    't-jab',
    't-cross',
  ]),
  // Calcio Dx basso-Jab-Jab-Diretto - Gancio Sx
  _c('combo-thai-111', 'CALCIO BASSO DX-JAB x2-DIRETTO-GANCIO SX', [
    't-rear-low',
    't-jab',
    't-jab',
    't-cross',
    't-lead-hook',
  ]),
  // Jab-Diretto-Gancio Sx - Jab - Diretto
  _c('combo-thai-112', 'JAB-DIRETTO-GANCIO SX-JAB-DIRETTO', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-jab',
    't-cross',
  ]),
  // Jab-Diretto-Gancio Sx - Jab – Diretto – Calcio Dx
  _c('combo-thai-113', 'JAB-DIRETTO-GANCIO SX-JAB-DIRETTO-CALCIO DX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-jab',
    't-cross',
    't-rear-round',
  ]),
  // Jab- Jab-Diretto-Gancio al corpo Sx
  _c('combo-thai-114', 'JAB x2-DIRETTO-GANCIO SX CORPO', [
    't-jab',
    't-jab',
    't-cross',
    't-lead-hook-body',
  ]),
  // Jab- Jab-Diretto-Gancio al corpo Sx-Calcio Dx basso
  _c('combo-thai-115', 'JAB x2-DIRETTO-GANCIO SX CORPO-CALCIO BASSO DX', [
    't-jab',
    't-jab',
    't-cross',
    't-lead-hook-body',
    't-rear-low',
  ]),
  // Jab-Teep
  _c('combo-thai-116', 'JAB-TEEP SX', ['t-jab', 't-lead-teep']),
  // Jab-Teep-Jab-Diretto
  _c('combo-thai-117', 'JAB-TEEP SX-JAB-DIRETTO', [
    't-jab',
    't-lead-teep',
    't-jab',
    't-cross',
  ]),
  // Jab-Teep-Jab-Diretto-Montante-Calcio Dx
  _c('combo-thai-118', 'JAB-TEEP SX-JAB-DIRETTO-MONTANTE SX-CALCIO DX', [
    't-jab',
    't-lead-teep',
    't-jab',
    't-cross',
    't-lead-uppercut',
    't-rear-round',
  ]),
  // Jab-Diretto-Gancio al corpo-Jab-Jab-Diretto
  _c('combo-thai-119', 'JAB-DIRETTO-GANCIO SX CORPO-JAB x2-DIRETTO', [
    't-jab',
    't-cross',
    't-lead-hook-body',
    't-jab',
    't-jab',
    't-cross',
  ]),
  // Jab-Gancio Sx-Gancio Sx corpo-Diretto-Jab
  _c('combo-thai-120', 'JAB-GANCIO SX-GANCIO SX CORPO-DIRETTO-JAB', [
    't-jab',
    't-lead-hook',
    't-lead-hook-body',
    't-cross',
    't-jab',
  ]),
  // Jab-Gancio Dx-Gancio Sx-Jab-Diretto
  _c('combo-thai-121', 'JAB-GANCIO DX-GANCIO SX-JAB-DIRETTO', [
    't-jab',
    't-rear-hook',
    't-lead-hook',
    't-jab',
    't-cross',
  ]),
  // Diretto-Gancio Sx-Diretto-Jab-Jab
  _c('combo-thai-122', 'DIRETTO-GANCIO SX-DIRETTO-JAB x2', [
    't-cross',
    't-lead-hook',
    't-cross',
    't-jab',
    't-jab',
  ]),
  // Jab-Gomitata laterale Dx
  _c('combo-thai-123', 'JAB-GOMITO DX', ['t-jab', 't-elbow-dx']),
  // Jab-Diretto-Montante Sx-Ginocchiata Dx-Gomitata Sx
  _c('combo-thai-124', 'JAB-DIRETTO-MONTANTE SX-GINOCCHIO DX-GOMITO SX', [
    't-jab',
    't-cross',
    't-lead-uppercut',
    't-rear-knee',
    't-elbow-sx',
  ]),
  // Jab-Diretto ad uscire-Gomitata Girata Sx-Gancio di ritorno Dx
  _c('combo-thai-125', 'JAB-DIRETTO-GOMITO GIRATO-GANCIO DX', [
    't-jab',
    't-cross',
    't-elbow-spin',
    't-rear-hook',
  ]),
  // Jab-Diretto-Gancio Sx-Ginocchiata Dx
  _c('combo-thai-126', 'JAB-DIRETTO-GANCIO SX-GINOCCHIO DX', [
    't-jab',
    't-cross',
    't-lead-hook',
    't-rear-knee',
  ]),
  // Calcio Sx-Diretto-Gancio Sx (10 reps)
  _c('combo-thai-127', 'CALCIO SX-DIRETTO-GANCIO SX', [
    't-lead-round',
    't-cross',
    't-lead-hook',
  ]),
  // Diretto – calcio Sx
  _c('combo-thai-128', 'DIRETTO-CALCIO SX', ['t-cross', 't-lead-round']),
  // Tip – calcio Dx
  _c('combo-thai-129', 'TEEP SX-CALCIO DX', ['t-lead-teep', 't-rear-round']),
  // Jab – gancio Dx – calcio Sx
  _c('combo-thai-130', 'JAB-GANCIO DX-CALCIO SX', [
    't-jab',
    't-rear-hook',
    't-lead-round',
  ]),
];

/// Conditioning circuit: an ordered exercise list, optionally with a rep
/// target per exercise (null = timed / no reps).
Combination _ci(String id, String name, List<String> ids, List<int?> reps) =>
    Combination(
      id: id,
      name: name,
      techniqueIds: ids,
      reps: reps,
      favorite: false,
      createdAt: 0,
    );

final seedConditioningCircuits = <Combination>[
  _ci(
    'circuit-wb-1',
    'WHOLE BODY 1',
    [
      't-cond-pushup',
      't-cond-switch-lunges',
      't-cond-bicycles',
      't-cond-dorsali',
      't-cond-pushup-diamond',
      't-cond-squat',
      't-cond-crucifix',
      't-cond-dorsali-fianchi',
      't-cond-pushup-wide',
      't-cond-knee-floor',
      't-cond-crunch',
      't-cond-dorsali-incrociate',
    ],
    [12, 20, 60, 20, 12, 20, 20, 20, 12, 20, 60, 10],
  ),
  _ci(
    'circuit-wb-2',
    'WHOLE BODY 2',
    [
      't-cond-crunch',
      't-cond-pushup',
      't-cond-squat',
      't-cond-dorsali-avanti',
      't-cond-crucifix',
      't-cond-pushup-diamond',
      't-cond-jump-squat',
      't-cond-dorsali-fianchi',
      't-cond-vups',
      't-cond-pushup-wide',
      't-cond-lunges',
      't-cond-dorsali-incrociate',
      't-cond-abs-laterali',
      't-cond-pushup-fists',
      't-cond-jump-lunges',
      't-cond-dorsali-cross-foot',
    ],
    [60, 13, 20, 20, 20, 13, 20, 20, 20, 13, 30, 20, 20, 13, 20, 20],
  ),
  _ci(
    'circuit-abs-chest-a',
    'ABS + CHEST A',
    [
      't-cond-leg-raises',
      't-cond-crucifix',
      't-cond-bicycles',
      't-cond-russian-twist',
      't-cond-toe-touch',
      't-cond-switch-mountain-climbers',
      't-cond-side-crunch-dx',
      't-cond-side-crunch-sx',
    ],
    [20, 15, 60, 40, 15, 40, 20, 20],
  ),
  _ci(
    'circuit-abs-chest-b',
    'ABS + CHEST B',
    [
      't-cond-pushup',
      't-cond-shoulder-taps',
      't-cond-pushup-diamond',
      't-cond-low-high-plank',
      't-cond-pushup-wide',
    ],
    [15, 30, 15, 10, 15],
  ),
  _ci(
    'circuit-wb-cardio-a',
    'WHOLE BODY CARDIO 1',
    [
      't-cond-mountain-climbers',
      't-cond-burpees',
      't-cond-pushup',
      't-cond-switch-lunges',
      't-cond-low-high-plank',
      't-cond-pushup-wide',
      't-cond-jump-squat',
      't-cond-in-outs',
      't-cond-dorsali',
    ],
    const [null, null, null, null, null, null, null, null, null],
  ),
  _ci(
    'circuit-wb-cardio-b',
    'WHOLE BODY CARDIO 2',
    [
      't-cond-half-burpees',
      't-cond-pushup',
      't-cond-squat',
      't-cond-pushup-wide',
      't-cond-sumo-squat',
      't-cond-pushup-side',
      't-cond-lunges',
      't-cond-pushup-explosive',
      't-cond-jump-squat',
    ],
    const [null, null, null, null, null, null, null, null, null],
  ),
  _ci(
    'circuit-abs-cardio-a',
    'ABS CARDIO 1',
    [
      't-cond-leg-raises',
      't-cond-crunch',
      't-cond-bicycles',
      't-cond-crucifix',
      't-cond-plank',
    ],
    const [20, 50, 60, 20, null],
  ),
  _ci(
    'circuit-abs-cardio-b',
    'ABS CARDIO 2',
    [
      't-cond-leg-raises',
      't-cond-crunch',
      't-cond-bicycles',
      't-cond-crucifix',
      't-cond-plank',
    ],
    const [20, 50, 60, 20, null],
  ),
  _ci(
    'circuit-leg-abs',
    'LEG + ABS',
    [
      't-cond-squat',
      't-cond-lunges',
      't-cond-sumo-squat',
      't-cond-switch-lunges',
      't-cond-jump-squat',
      't-cond-lunge-knee-dx',
      't-cond-lunge-knee-sx',
      't-cond-mountain-climbers',
      't-cond-vups',
      't-cond-toe-touch',
      't-cond-russian-twist',
      't-cond-crucifix',
      't-cond-squadra',
    ],
    const [20, 20, 20, 20, 15, 15, 15, 40, 15, 20, 30, 20, null],
  ),
];

final seedThaiWorkouts = <Workout>[
  Workout(
    id: 'workout-thai-cardio-1',
    name: 'CARDIO 1',
    workDuration: 50,
    restDuration: 10,
    rounds: 7,
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-cardio-2',
    name: 'CARDIO 2',
    workDuration: 50,
    restDuration: 10,
    rounds: 4,
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-sacco-coppie',
    name: 'SACCO A COPPIE BOXE-CALCI',
    workDuration: 60,
    restDuration: 60,
    rounds: 2,
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-boxe-spalle',
    name: 'BOXE/SPALLE PESETTI',
    workDuration: 60,
    restDuration: 20,
    rounds: 2,
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-warmup-sacco',
    name: 'WARM UP SACCO',
    workDuration: 30,
    restDuration: 7,
    rounds: 2,
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-sacco-singoli',
    name: 'SACCO SINGOLI',
    workDuration: 90,
    restDuration: 30,
    rounds: 2,
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-combinazioni',
    name: 'COMBINAZIONI BOXE-CALCI',
    workDuration: 120,
    restDuration: 60,
    rounds: 8,
    combinationIds: [
      'combo-thai-01',
      'combo-thai-02',
      'combo-thai-03',
      'combo-thai-04',
      'combo-thai-05',
      'combo-thai-06',
      'combo-thai-07',
      'combo-thai-08',
    ],
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-wb-cardio-a',
    name: 'WHOLE BODY CARDIO 1',
    workDuration: 45,
    restDuration: 15,
    rounds: 2,
    combinationIds: ['circuit-wb-cardio-a'],
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-wb-cardio-b',
    name: 'WHOLE BODY CARDIO 2',
    workDuration: 45,
    restDuration: 15,
    rounds: 2,
    combinationIds: ['circuit-wb-cardio-b'],
    createdAt: 0,
  ),
  // Rep-based circuits: a single continuous round (no per-exercise timer) that
  // lists the whole circuit. Default 5:00, editable from the workout builder.
  Workout(
    id: 'workout-thai-wb-1',
    name: 'WHOLE BODY 1',
    workDuration: 300,
    restDuration: 0,
    rounds: 1,
    combinationIds: ['circuit-wb-1'],
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-wb-2',
    name: 'WHOLE BODY 2',
    workDuration: 300,
    restDuration: 0,
    rounds: 1,
    combinationIds: ['circuit-wb-2'],
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-abs-chest-a',
    name: 'ABS + CHEST A',
    workDuration: 300,
    restDuration: 0,
    rounds: 1,
    combinationIds: ['circuit-abs-chest-a'],
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-abs-chest-b',
    name: 'ABS + CHEST B',
    workDuration: 300,
    restDuration: 0,
    rounds: 1,
    combinationIds: ['circuit-abs-chest-b'],
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-abs-cardio-a',
    name: 'ABS CARDIO 1',
    workDuration: 300,
    restDuration: 0,
    rounds: 1,
    combinationIds: ['circuit-abs-cardio-a'],
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-abs-cardio-b',
    name: 'ABS CARDIO 2',
    workDuration: 300,
    restDuration: 0,
    rounds: 1,
    combinationIds: ['circuit-abs-cardio-b'],
    createdAt: 0,
  ),
  Workout(
    id: 'workout-thai-leg-abs',
    name: 'LEG + ABS',
    workDuration: 300,
    restDuration: 0,
    rounds: 1,
    combinationIds: ['circuit-leg-abs'],
    createdAt: 0,
  ),
];

AppData seedData() {
  final now = DateTime.now().millisecondsSinceEpoch;
  return AppData(
    version: 10,
    techniques: seedTechniques,
    combinations:
        [
              ...seedCombinations,
              ...seedStretchRoutines,
              ...seedCombosThai,
              ...seedConditioningCircuits,
            ]
            .map(
              (c) => Combination(
                id: c.id,
                name: c.name,
                techniqueIds: c.techniqueIds,
                reps: c.reps,
                favorite: c.favorite,
                createdAt: now,
              ),
            )
            .toList(),
    workouts: [...seedWorkouts, seedStretchingWorkout, ...seedThaiWorkouts]
        .map(
          (w) => Workout(
            id: w.id,
            name: w.name,
            workDuration: w.workDuration,
            restDuration: w.restDuration,
            rounds: w.rounds,
            combinationIds: w.combinationIds,
            routineId: w.routineId,
            createdAt: now,
          ),
        )
        .toList(),
    sessions: const [],
    plans: const [],
    settings: const Settings(sound: true, vibration: true, prepSeconds: 3),
  );
}
