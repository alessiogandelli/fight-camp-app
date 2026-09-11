// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navTrain => 'Train';

  @override
  String get navWorkouts => 'Workouts';

  @override
  String get navCombos => 'Combos';

  @override
  String get navHistory => 'History';

  @override
  String get navStats => 'Stats';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonStart => 'Start';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonNew => 'New';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonDone => 'Done';

  @override
  String get commonAll => 'All';

  @override
  String get commonSequential => 'Sequential';

  @override
  String get commonRandom => 'Random';

  @override
  String get commonWork => 'Work';

  @override
  String get commonRest => 'Rest';

  @override
  String get commonRounds => 'Rounds';

  @override
  String get commonRound => 'Round';

  @override
  String get commonDuration => 'Duration';

  @override
  String get commonType => 'Type';

  @override
  String get commonName => 'Name';

  @override
  String get commonOptional => '(optional)';

  @override
  String get commonNone => 'None';

  @override
  String get commonCategory => 'Category';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDecrease => 'Decrease';

  @override
  String get commonIncrease => 'Increase';

  @override
  String get commonDeleted => '(deleted)';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonPause => 'Pause';

  @override
  String get commonResume => 'Resume';

  @override
  String get commonLoad => 'Load';

  @override
  String get unitSession => 'session';

  @override
  String get unitSessions => 'sessions';

  @override
  String get unitExercise => 'exercise';

  @override
  String get unitExercises => 'exercises';

  @override
  String get feelingGreat => 'Great';

  @override
  String get feelingGood => 'Good';

  @override
  String get feelingOk => 'OK';

  @override
  String get feelingDrained => 'Drained';

  @override
  String get pickerTitle => 'Select combinations';

  @override
  String get pickerSearch => 'Search…';

  @override
  String get pickerEmpty =>
      'No combinations found. Create one in the Combos tab.';

  @override
  String pickerDone(Object n) {
    return 'Done ($n)';
  }

  @override
  String get pickerSelectAll => 'Select all';

  @override
  String get randomMinTechniques => 'Min techniques';

  @override
  String get randomMaxTechniques => 'Max techniques';

  @override
  String get randomAllowedCategories => 'Allowed categories';

  @override
  String get randomRequirePunch => 'Require at least 1 punch';

  @override
  String get randomRequireKick => 'Require at least 1 kick';

  @override
  String get randomIncludeDefense => 'Include defense / movement';

  @override
  String get randomGenerated => 'Combinations generated';

  @override
  String get comboAddTechnique => 'Add at least one technique';

  @override
  String get comboGiveName => 'Give the combination a name';

  @override
  String get comboSaved => 'Combination saved';

  @override
  String get comboEdit => 'Edit combo';

  @override
  String get comboNew => 'New combo';

  @override
  String get comboToggleFavorite => 'Toggle favorite';

  @override
  String comboTechniquesCount(Object n) {
    return 'Combination ($n techniques)';
  }

  @override
  String get comboTapHint =>
      'Tap techniques on the right to build the combination.';

  @override
  String get comboMoveUp => 'Move up';

  @override
  String get comboMoveDown => 'Move down';

  @override
  String get comboRemove => 'Remove';

  @override
  String get comboTechniqueLibrary => 'Technique library';

  @override
  String get comboTechnique => 'Technique';

  @override
  String get comboTechniqueAdded => 'Technique added';

  @override
  String get comboNotFound => 'Not found';

  @override
  String get comboNotFoundMsg => 'This combination no longer exists.';

  @override
  String get comboCustomTechniques => 'Custom techniques';

  @override
  String comboDeleteAria(Object name) {
    return 'Delete $name';
  }

  @override
  String get comboTechniqueNeedsName => 'Technique needs a name';

  @override
  String get comboNewTechnique => 'New technique';

  @override
  String get comboShortName => 'Short display name';

  @override
  String get comboDescription => 'Description (optional)';

  @override
  String get comboAddTechniqueBtn => 'Add technique';

  @override
  String get combosTitle => 'Combinations';

  @override
  String get combosFavorites => '★ Favorites';

  @override
  String get combosSearch => 'Search combinations…';

  @override
  String get combosEmpty => 'No combinations';

  @override
  String get combosEmptyMsg =>
      'Build your first combination from the technique library.';

  @override
  String get combosCreate => 'Create combination';

  @override
  String get combosDuplicated => 'Combination duplicated';

  @override
  String get combosDeleted => 'Combination deleted';

  @override
  String get combosDeleteTitle => 'Delete combination';

  @override
  String combosDeleteMsg(Object name) {
    return 'Delete \"$name\"? Workouts using it will fall back to free rounds. This cannot be undone.';
  }

  @override
  String combosTrain(Object name) {
    return 'Train: $name';
  }

  @override
  String get combosRoundLength => 'Round length';

  @override
  String get combosRestBetween => 'Rest between rounds';

  @override
  String get combosStartSession => 'Start session';

  @override
  String get trainHeavyBag => 'Heavy Bag';

  @override
  String get trainHeavyBagSub => 'Rounds of combinations on the bag';

  @override
  String get trainComboWorkout => 'Combination Workout';

  @override
  String get trainComboWorkoutSub => 'Run a saved workout';

  @override
  String get trainTabata => 'Tabata';

  @override
  String get trainTabataSub => '20s work / 10s rest bursts';

  @override
  String get trainIntervals => 'Intervals';

  @override
  String get trainIntervalsSub => 'Custom work / rest presets';

  @override
  String get trainFree => 'Free Round';

  @override
  String get trainFreeSub => 'Pure timer, no combinations';

  @override
  String get trainNothingToRun => 'Nothing to run — add rounds first';

  @override
  String get trainInProgress => 'Session in progress';

  @override
  String trainAt(Object time) {
    return 'at $time';
  }

  @override
  String get trainRounds => 'Rounds';

  @override
  String get trainCombinations => 'Combinations';

  @override
  String get trainRotateEvery => 'Rotate every';

  @override
  String get trainOrder => 'Order';

  @override
  String get trainNoneFree => 'None — free rounds';

  @override
  String trainSelected(Object n) {
    return '$n selected';
  }

  @override
  String get trainReady => 'Ready to\nfight?';

  @override
  String get trainReadySub => 'Set up your workout';

  @override
  String get trainTotalDuration => 'Total duration';

  @override
  String trainSelections(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n selections',
      one: '1 selection',
    );
    return '$_temp0';
  }

  @override
  String get trainNoWorkouts => 'No saved workouts yet.';

  @override
  String get trainCreateWorkout => 'Create a workout';

  @override
  String get trainFixed => 'Fixed';

  @override
  String get trainCycle => 'Cycle';

  @override
  String get trainChangesEvery => 'Combination changes every work interval.';

  @override
  String get trainShowRandom => 'Show random combinations';

  @override
  String get trainSavePreset => 'Save as preset';

  @override
  String get trainPresetSaved => 'Preset saved';

  @override
  String get trainPresetDeleted => 'Preset deleted';

  @override
  String get trainPresetHint => 'Tap to load · double-tap to delete';

  @override
  String get trainTimerSettings => 'Timer settings';

  @override
  String get trainSoundCues => 'Sound cues';

  @override
  String get trainVibration => 'Vibration';

  @override
  String get trainPrepCountdown => 'Prep countdown';

  @override
  String get trainPrepHint => 'Seconds before round 1';

  @override
  String get trainRestSuffix => 'REST';

  @override
  String get trainFreeRounds => 'FREE ROUNDS';

  @override
  String get trainHeavyBagName => 'HEAVY BAG';

  @override
  String get trainIntervalsName => 'INTERVALS';

  @override
  String get livePreparing => 'PREPARING';

  @override
  String liveRoundOf(Object x, Object y) {
    return 'ROUND $x OF $y';
  }

  @override
  String get livePrevious => 'Previous';

  @override
  String get liveSkip => 'Skip';

  @override
  String get liveRestart => 'Restart';

  @override
  String get liveSound => 'Sound';

  @override
  String get liveVibe => 'Vibe';

  @override
  String get liveExit => 'Exit';

  @override
  String get liveExitMsg => 'Leave this session? Progress will not be saved.';

  @override
  String get liveReady => 'Ready to work';

  @override
  String liveTotal(Object rounds, Object time) {
    return '$rounds rounds · $time total';
  }

  @override
  String get liveSoundHint =>
      'Keep sound on — beeps count down the last seconds and mark each combination.';

  @override
  String get liveGetReady => 'Get ready';

  @override
  String get livePaused => 'Paused';

  @override
  String get liveFirstUp => 'First up';

  @override
  String get liveNext => 'Next';

  @override
  String liveNextRound(Object n) {
    return 'Next — round $n';
  }

  @override
  String liveNextRoundShort(Object n) {
    return 'Next round $n';
  }

  @override
  String get liveFree => 'Free';

  @override
  String get liveThrowEverything => 'Throw everything';

  @override
  String get liveStaySharp => 'Stay sharp — move well';

  @override
  String get liveFreeSlot => 'FREE';

  @override
  String get liveDefenseSlot => 'DEFENSE';

  @override
  String get liveConditioningSlot => 'CONDITIONING';

  @override
  String get liveCustomSlot => 'CUSTOM';

  @override
  String liveRandomSlot(Object n) {
    return 'RANDOM $n';
  }

  @override
  String get workoutsTitle => 'Workouts';

  @override
  String get workoutsNoRounds => 'This workout has no rounds';

  @override
  String get workoutsEmpty => 'No workouts yet';

  @override
  String get workoutsEmptyMsg =>
      'Create a structured workout with rounds, rest and combinations.';

  @override
  String get workoutsCreate => 'Create workout';

  @override
  String get workoutsDuplicated => 'Workout duplicated';

  @override
  String get workoutsDeleted => 'Workout deleted';

  @override
  String get workoutsDeleteTitle => 'Delete workout';

  @override
  String workoutsDeleteMsg(Object name) {
    return 'Delete \"$name\"? Completed sessions in history are kept. This cannot be undone.';
  }

  @override
  String workoutsCombosCount(Object n) {
    return '$n COMBOS';
  }

  @override
  String get workoutsRoutine => 'STRETCHING ROUTINE';

  @override
  String get builderAddRound => 'Add at least one round';

  @override
  String get builderMinSeconds => 'Every round must be at least 5 seconds';

  @override
  String get builderSaved => 'Workout saved';

  @override
  String get builderEdit => 'Edit workout';

  @override
  String get builderNew => 'New workout';

  @override
  String get builderWorkoutName => 'Workout name';

  @override
  String builderWorkRest(Object w, Object r) {
    return 'Work $w · Rest $r';
  }

  @override
  String get builderAddRoundBtn => 'Add round';

  @override
  String get builderSaveStart => 'Save + Start';

  @override
  String builderRoundN(Object n) {
    return 'Round $n';
  }

  @override
  String get builderMoveUp => 'Move round up';

  @override
  String get builderMoveDown => 'Move round down';

  @override
  String get builderDuplicate => 'Duplicate round';

  @override
  String get builderDeleteRound => 'Delete round';

  @override
  String get builderRestLast => 'Rest (none, last)';

  @override
  String get builderRestAfter => 'Rest after';

  @override
  String get builderRoundType => 'Round type';

  @override
  String get builderSelectCombos => 'Select combinations…';

  @override
  String builderSelected(Object n) {
    return '$n SELECTED';
  }

  @override
  String get builderFocusLabel => 'Focus label (shown during the round)';

  @override
  String get builderDeletedCombo => '(deleted combo)';

  @override
  String get builderFreeHint => 'No combinations — throw whatever you want.';

  @override
  String get builderNotFound =>
      'This workout no longer exists. Saving will create a new one.';

  @override
  String get historyTitle => 'History';

  @override
  String get historyLogSession => 'Log session';

  @override
  String get historySearch => 'Search notes and workouts…';

  @override
  String get historyFrom => 'From';

  @override
  String get historyTo => 'To';

  @override
  String get historyEmpty => 'No sessions yet';

  @override
  String get historyEmptyMsg =>
      'Finish a training session or log one manually and it will show up here.';

  @override
  String get historyLogOne => 'Log a session';

  @override
  String get historyRnd => 'RND';

  @override
  String get historyWorkUnit => 'WORK';

  @override
  String historyEnergyBefore(Object n) {
    return 'Energy before: $n/5';
  }

  @override
  String historyFeelingAfter(Object feeling) {
    return 'Feeling after: $feeling';
  }

  @override
  String get historyCombosUsed => 'Combinations used';

  @override
  String get historyDeleteSession => 'Delete session';

  @override
  String get historyDeleteMsg =>
      'Remove this session from history? This cannot be undone.';

  @override
  String get historySessionDeleted => 'Session deleted';

  @override
  String get historyMinDuration => 'Duration must be at least 1 minute';

  @override
  String get historySessionLogged => 'Session logged';

  @override
  String get historyNameOptional => 'Name (optional)';

  @override
  String historyRpeLoad(Object n) {
    return 'RPE — load $n';
  }

  @override
  String get historyDistance => 'Distance (km, optional)';

  @override
  String get historyExercises => 'Exercises';

  @override
  String get historyAdd => 'Add';

  @override
  String get historyExercisePlaceholder => 'Exercise';

  @override
  String get historySets => 'sets';

  @override
  String get historyReps => 'reps';

  @override
  String get historyKg => 'kg';

  @override
  String get historyRemoveExercise => 'Remove exercise';

  @override
  String get historyNoExercises =>
      'No exercises added — the session will be logged by duration only.';

  @override
  String get historyNotes => 'Notes (optional)';

  @override
  String get historySaveSession => 'Save session';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsEmpty =>
      'No training history yet. Finish a session and your numbers will build up here.';

  @override
  String get stats7days => '7 days';

  @override
  String get stats30days => '30 days';

  @override
  String get statsAllTime => 'All time';

  @override
  String get statsSessions => 'Sessions';

  @override
  String get statsTrainingTime => 'Training time';

  @override
  String get statsRounds => 'Rounds';

  @override
  String get statsWorkTime => 'Work time';

  @override
  String get statsTrainingLoad => 'Training load';

  @override
  String get statsWeeklyLoad => 'Weekly load';

  @override
  String get statsMonthlyLoad => 'Monthly load';

  @override
  String get statsLoadNote =>
      'Load = duration × RPE. A simple training estimate, not a medical readiness metric.';

  @override
  String get statsConsistency => 'Consistency';

  @override
  String get statsCurrentStreak => 'Current streak';

  @override
  String get statsLongestStreak => 'Longest streak';

  @override
  String get statsSessionsPerWeek => 'Sessions / week';

  @override
  String get statsHeavyBag => 'Heavy bag';

  @override
  String get statsBagSessions => 'Bag sessions';

  @override
  String get statsBagRounds => 'Bag rounds';

  @override
  String get statsBagTime => 'Bag time';

  @override
  String get statsMostUsed => 'Most used combinations';

  @override
  String get statsMostUsedEmpty =>
      'Complete sessions with combinations to see usage.';

  @override
  String get statsTechFreq => 'Technique frequency';

  @override
  String get statsTechEmpty => 'No technique data yet.';

  @override
  String get statsWeeklyOverview => 'Weekly overview';

  @override
  String get statsThisWeek => 'This week';

  @override
  String get statsLastWeek => 'Last week';

  @override
  String statsSessionsLine(Object n, Object time, Object load) {
    return '$n sessions · $time · load $load';
  }

  @override
  String get statsPlan => 'Plan';

  @override
  String get statsPlanSession => 'Plan a session';

  @override
  String get statsLabelOptional => 'Label (optional)';

  @override
  String get statsPlannedMinutes => 'Planned minutes';

  @override
  String get statsAddToWeek => 'Add to week';

  @override
  String get statsTogglePlan => 'Toggle planned session';

  @override
  String get statsDeletePlan => 'Delete plan';

  @override
  String get statsPrevWeek => 'Previous week';

  @override
  String get statsNextWeek => 'Next week';

  @override
  String get completeSelectRpe => 'Select an RPE first';

  @override
  String get completeSaved => 'Session saved';

  @override
  String get completeTitle => 'Workout complete';

  @override
  String get completeRounds => 'Rounds';

  @override
  String get completeEstSession => 'Est. session';

  @override
  String get completeWork => 'Work';

  @override
  String get completeRest => 'Rest';

  @override
  String get completeHowHard => 'How hard was it?';

  @override
  String get completeRpe => 'RPE —';

  @override
  String completeLoadApprox(Object n) {
    return 'Training load ≈ $n';
  }

  @override
  String get completeEnergyBefore => 'Energy before (optional)';

  @override
  String get completeFeelingAfter => 'Feeling after (optional)';

  @override
  String get completeNotes => 'Notes (optional)';

  @override
  String get completeNotesPlaceholder =>
      'Sharp combinations, gas tank felt good…';

  @override
  String get completeDiscard => 'Discard';

  @override
  String get completeSaveSession => 'Save session';

  @override
  String get completeDiscardTitle => 'Discard session';

  @override
  String get completeDiscardMsg =>
      'Throw away this session? It will not appear in history.';

  @override
  String get sessionNoRounds => 'NO ROUNDS';

  @override
  String sessionNRounds(Object n) {
    return '$n ROUNDS';
  }

  @override
  String get sessionRest => 'REST';

  @override
  String get sessionDeletedCombo => 'DELETED COMBO';

  @override
  String get sessionUnknown => 'Unknown';

  @override
  String get pushupsTitle => 'Push-ups';

  @override
  String get pushupsSub => 'Automatic counter using the camera';

  @override
  String get pushupsHint =>
      'Lay the phone on the floor with the front camera facing up and lower yourself over it: each rep is counted automatically.';

  @override
  String get pushupsName => 'Push-ups';

  @override
  String get pushupsExercise => 'Push-ups';

  @override
  String get pushupsCount => 'push-ups';

  @override
  String get pushupsDetecting => 'Detecting';

  @override
  String get pushupsMoveCloser => 'Move closer or adjust sensitivity';

  @override
  String get pushupsSensitivity => 'Sensitivity';

  @override
  String get pushupsSave => 'Save';

  @override
  String get pushupsStop => 'Stop';

  @override
  String get pushupsSaved => 'Push-up session saved';

  @override
  String get pushupsNothingToSave => 'No push-ups to save';

  @override
  String get pushupsErrorPermission =>
      'Camera permission denied. Allow camera access in your browser settings.';

  @override
  String get pushupsErrorNoCamera => 'No camera found.';

  @override
  String get pushupsErrorGeneric => 'Could not start the camera.';

  @override
  String get builderAddBlock => 'Add block';

  @override
  String get builderBlockType => 'Block type';

  @override
  String get builderSeries => 'Series';

  @override
  String get builderChooseRoutine => 'Stretching routine';

  @override
  String get navLibrary => 'Library';

  @override
  String get navProgress => 'Progress';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSound => 'Sound cues';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsPrep => 'Prep countdown';

  @override
  String get settingsPrepHint => 'Runs automatically when the session starts';

  @override
  String get trainPresets => 'Presets';

  @override
  String get trainCombosToggle => 'Train with combinations';

  @override
  String get trainTools => 'Extra tools';

  @override
  String get trainLastUsed => 'Last used';

  @override
  String get trainSeries => 'Series';

  @override
  String get trainSwipeHint => 'Swipe to adjust';

  @override
  String get trainWorkoutSub => 'Run a saved workout';

  @override
  String get trainWorkout => 'Workouts';

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryBag => 'Bag';

  @override
  String get libraryTool => 'Tool';

  @override
  String get libraryStretching => 'Stretching';

  @override
  String get routineNew => 'New stretching routine';

  @override
  String get routineEdit => 'Edit stretching routine';

  @override
  String get routineTapHint =>
      'Tap stretching exercises on the right to build the routine.';

  @override
  String routineExercisesCount(Object n) {
    return 'Routine ($n exercises)';
  }

  @override
  String get routineGiveName => 'Give the routine a name';

  @override
  String get routineSaved => 'Routine saved';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressWeekSessions => 'Sessions this week';

  @override
  String get liveExitWorkout => 'Exit workout';

  @override
  String get builderGiveName => 'Give the workout a name';

  @override
  String get liveStopAndSave => 'Stop & save';

  @override
  String get liveStopSaveTitle => 'End session';

  @override
  String get liveStopSaveMsg => 'Stop the session and save it to Progress?';

  @override
  String get liveRestartTitle => 'Restart session?';

  @override
  String get liveRestartMsg =>
      'The timer will start over from the first round.';

  @override
  String get completeSavedToProgress => 'Saved to Progress';

  @override
  String get completeDone => 'Done';

  @override
  String get completeAddDetails => 'Add details (optional)';

  @override
  String get completeRpeOptional => 'Optional — skip if you want';

  @override
  String get completeRpeEasy => '1 = easy';

  @override
  String get completeRpeMax => '10 = max';

  @override
  String get completeAutoSaveFailed =>
      'Couldn\'t save automatically — tap Done to retry';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonDuplicate => 'Duplicate';

  @override
  String get comboDeleteTechniqueTitle => 'Delete technique';

  @override
  String get comboDeleteTechniqueMsg =>
      'Delete this technique? It will be removed from your combinations.';

  @override
  String get progressWeeklyGoal => 'Weekly goal';

  @override
  String get progressGoalReached => 'Weekly goal reached';

  @override
  String get progressViewHistory => 'View all';

  @override
  String get onboardingTitle1 => 'Train with a timer';

  @override
  String get onboardingBody1 =>
      'Set work, rest and rounds. Big numbers and loud cues — no need to touch the phone.';

  @override
  String get onboardingTitle2 => 'Your combinations, on screen';

  @override
  String get onboardingBody2 =>
      'Pick combinations from the Library and the app walks you through every technique, round after round.';

  @override
  String get onboardingTitle3 => 'See yourself improve';

  @override
  String get onboardingBody3 =>
      'Streaks, volume and history — Progress shows the work you put in over time.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start training';

  @override
  String get settingsHowItWorks => 'How it works';
}
