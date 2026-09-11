import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @navTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get navTrain;

  /// No description provided for @navWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get navWorkouts;

  /// No description provided for @navCombos.
  ///
  /// In en, this message translates to:
  /// **'Combos'**
  String get navCombos;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get commonStart;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get commonNew;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonSequential.
  ///
  /// In en, this message translates to:
  /// **'Sequential'**
  String get commonSequential;

  /// No description provided for @commonRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get commonRandom;

  /// No description provided for @commonWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get commonWork;

  /// No description provided for @commonRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get commonRest;

  /// No description provided for @commonRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get commonRounds;

  /// No description provided for @commonRound.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get commonRound;

  /// No description provided for @commonDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get commonDuration;

  /// No description provided for @commonType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get commonType;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get commonOptional;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get commonCategory;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get commonDecrease;

  /// No description provided for @commonIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get commonIncrease;

  /// No description provided for @commonDeleted.
  ///
  /// In en, this message translates to:
  /// **'(deleted)'**
  String get commonDeleted;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get commonPause;

  /// No description provided for @commonResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get commonResume;

  /// No description provided for @commonLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get commonLoad;

  /// No description provided for @unitSession.
  ///
  /// In en, this message translates to:
  /// **'session'**
  String get unitSession;

  /// No description provided for @unitSessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get unitSessions;

  /// No description provided for @unitExercise.
  ///
  /// In en, this message translates to:
  /// **'exercise'**
  String get unitExercise;

  /// No description provided for @unitExercises.
  ///
  /// In en, this message translates to:
  /// **'exercises'**
  String get unitExercises;

  /// No description provided for @feelingGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get feelingGreat;

  /// No description provided for @feelingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get feelingGood;

  /// No description provided for @feelingOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get feelingOk;

  /// No description provided for @feelingDrained.
  ///
  /// In en, this message translates to:
  /// **'Drained'**
  String get feelingDrained;

  /// No description provided for @pickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select combinations'**
  String get pickerTitle;

  /// No description provided for @pickerSearch.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get pickerSearch;

  /// No description provided for @pickerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No combinations found. Create one in the Combos tab.'**
  String get pickerEmpty;

  /// No description provided for @pickerDone.
  ///
  /// In en, this message translates to:
  /// **'Done ({n})'**
  String pickerDone(Object n);

  /// No description provided for @pickerSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get pickerSelectAll;

  /// No description provided for @randomMinTechniques.
  ///
  /// In en, this message translates to:
  /// **'Min techniques'**
  String get randomMinTechniques;

  /// No description provided for @randomMaxTechniques.
  ///
  /// In en, this message translates to:
  /// **'Max techniques'**
  String get randomMaxTechniques;

  /// No description provided for @randomAllowedCategories.
  ///
  /// In en, this message translates to:
  /// **'Allowed categories'**
  String get randomAllowedCategories;

  /// No description provided for @randomRequirePunch.
  ///
  /// In en, this message translates to:
  /// **'Require at least 1 punch'**
  String get randomRequirePunch;

  /// No description provided for @randomRequireKick.
  ///
  /// In en, this message translates to:
  /// **'Require at least 1 kick'**
  String get randomRequireKick;

  /// No description provided for @randomIncludeDefense.
  ///
  /// In en, this message translates to:
  /// **'Include defense / movement'**
  String get randomIncludeDefense;

  /// No description provided for @randomGenerated.
  ///
  /// In en, this message translates to:
  /// **'Combinations generated'**
  String get randomGenerated;

  /// No description provided for @comboAddTechnique.
  ///
  /// In en, this message translates to:
  /// **'Add at least one technique'**
  String get comboAddTechnique;

  /// No description provided for @comboGiveName.
  ///
  /// In en, this message translates to:
  /// **'Give the combination a name'**
  String get comboGiveName;

  /// No description provided for @comboSaved.
  ///
  /// In en, this message translates to:
  /// **'Combination saved'**
  String get comboSaved;

  /// No description provided for @comboEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit combo'**
  String get comboEdit;

  /// No description provided for @comboNew.
  ///
  /// In en, this message translates to:
  /// **'New combo'**
  String get comboNew;

  /// No description provided for @comboToggleFavorite.
  ///
  /// In en, this message translates to:
  /// **'Toggle favorite'**
  String get comboToggleFavorite;

  /// No description provided for @comboTechniquesCount.
  ///
  /// In en, this message translates to:
  /// **'Combination ({n} techniques)'**
  String comboTechniquesCount(Object n);

  /// No description provided for @comboTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap techniques on the right to build the combination.'**
  String get comboTapHint;

  /// No description provided for @comboMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get comboMoveUp;

  /// No description provided for @comboMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get comboMoveDown;

  /// No description provided for @comboRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get comboRemove;

  /// No description provided for @comboTechniqueLibrary.
  ///
  /// In en, this message translates to:
  /// **'Technique library'**
  String get comboTechniqueLibrary;

  /// No description provided for @comboTechnique.
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get comboTechnique;

  /// No description provided for @comboTechniqueAdded.
  ///
  /// In en, this message translates to:
  /// **'Technique added'**
  String get comboTechniqueAdded;

  /// No description provided for @comboNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get comboNotFound;

  /// No description provided for @comboNotFoundMsg.
  ///
  /// In en, this message translates to:
  /// **'This combination no longer exists.'**
  String get comboNotFoundMsg;

  /// No description provided for @comboCustomTechniques.
  ///
  /// In en, this message translates to:
  /// **'Custom techniques'**
  String get comboCustomTechniques;

  /// No description provided for @comboDeleteAria.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String comboDeleteAria(Object name);

  /// No description provided for @comboTechniqueNeedsName.
  ///
  /// In en, this message translates to:
  /// **'Technique needs a name'**
  String get comboTechniqueNeedsName;

  /// No description provided for @comboNewTechnique.
  ///
  /// In en, this message translates to:
  /// **'New technique'**
  String get comboNewTechnique;

  /// No description provided for @comboShortName.
  ///
  /// In en, this message translates to:
  /// **'Short display name'**
  String get comboShortName;

  /// No description provided for @comboDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get comboDescription;

  /// No description provided for @comboAddTechniqueBtn.
  ///
  /// In en, this message translates to:
  /// **'Add technique'**
  String get comboAddTechniqueBtn;

  /// No description provided for @combosTitle.
  ///
  /// In en, this message translates to:
  /// **'Combinations'**
  String get combosTitle;

  /// No description provided for @combosFavorites.
  ///
  /// In en, this message translates to:
  /// **'★ Favorites'**
  String get combosFavorites;

  /// No description provided for @combosSearch.
  ///
  /// In en, this message translates to:
  /// **'Search combinations…'**
  String get combosSearch;

  /// No description provided for @combosEmpty.
  ///
  /// In en, this message translates to:
  /// **'No combinations'**
  String get combosEmpty;

  /// No description provided for @combosEmptyMsg.
  ///
  /// In en, this message translates to:
  /// **'Build your first combination from the technique library.'**
  String get combosEmptyMsg;

  /// No description provided for @combosCreate.
  ///
  /// In en, this message translates to:
  /// **'Create combination'**
  String get combosCreate;

  /// No description provided for @combosDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Combination duplicated'**
  String get combosDuplicated;

  /// No description provided for @combosDeleted.
  ///
  /// In en, this message translates to:
  /// **'Combination deleted'**
  String get combosDeleted;

  /// No description provided for @combosDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete combination'**
  String get combosDeleteTitle;

  /// No description provided for @combosDeleteMsg.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Workouts using it will fall back to free rounds. This cannot be undone.'**
  String combosDeleteMsg(Object name);

  /// No description provided for @combosTrain.
  ///
  /// In en, this message translates to:
  /// **'Train: {name}'**
  String combosTrain(Object name);

  /// No description provided for @combosRoundLength.
  ///
  /// In en, this message translates to:
  /// **'Round length'**
  String get combosRoundLength;

  /// No description provided for @combosRestBetween.
  ///
  /// In en, this message translates to:
  /// **'Rest between rounds'**
  String get combosRestBetween;

  /// No description provided for @combosStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get combosStartSession;

  /// No description provided for @trainHeavyBag.
  ///
  /// In en, this message translates to:
  /// **'Heavy Bag'**
  String get trainHeavyBag;

  /// No description provided for @trainHeavyBagSub.
  ///
  /// In en, this message translates to:
  /// **'Rounds of combinations on the bag'**
  String get trainHeavyBagSub;

  /// No description provided for @trainComboWorkout.
  ///
  /// In en, this message translates to:
  /// **'Combination Workout'**
  String get trainComboWorkout;

  /// No description provided for @trainComboWorkoutSub.
  ///
  /// In en, this message translates to:
  /// **'Run a saved workout'**
  String get trainComboWorkoutSub;

  /// No description provided for @trainTabata.
  ///
  /// In en, this message translates to:
  /// **'Tabata'**
  String get trainTabata;

  /// No description provided for @trainTabataSub.
  ///
  /// In en, this message translates to:
  /// **'20s work / 10s rest bursts'**
  String get trainTabataSub;

  /// No description provided for @trainIntervals.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get trainIntervals;

  /// No description provided for @trainIntervalsSub.
  ///
  /// In en, this message translates to:
  /// **'Custom work / rest presets'**
  String get trainIntervalsSub;

  /// No description provided for @trainFree.
  ///
  /// In en, this message translates to:
  /// **'Free Round'**
  String get trainFree;

  /// No description provided for @trainFreeSub.
  ///
  /// In en, this message translates to:
  /// **'Pure timer, no combinations'**
  String get trainFreeSub;

  /// No description provided for @trainNothingToRun.
  ///
  /// In en, this message translates to:
  /// **'Nothing to run — add rounds first'**
  String get trainNothingToRun;

  /// No description provided for @trainInProgress.
  ///
  /// In en, this message translates to:
  /// **'Session in progress'**
  String get trainInProgress;

  /// No description provided for @trainAt.
  ///
  /// In en, this message translates to:
  /// **'at {time}'**
  String trainAt(Object time);

  /// No description provided for @trainRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get trainRounds;

  /// No description provided for @trainCombinations.
  ///
  /// In en, this message translates to:
  /// **'Combinations'**
  String get trainCombinations;

  /// No description provided for @trainRotateEvery.
  ///
  /// In en, this message translates to:
  /// **'Rotate every'**
  String get trainRotateEvery;

  /// No description provided for @trainOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get trainOrder;

  /// No description provided for @trainNoneFree.
  ///
  /// In en, this message translates to:
  /// **'None — free rounds'**
  String get trainNoneFree;

  /// No description provided for @trainSelected.
  ///
  /// In en, this message translates to:
  /// **'{n} selected'**
  String trainSelected(Object n);

  /// No description provided for @trainReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to\nfight?'**
  String get trainReady;

  /// No description provided for @trainReadySub.
  ///
  /// In en, this message translates to:
  /// **'Set up your workout'**
  String get trainReadySub;

  /// No description provided for @trainTotalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total duration'**
  String get trainTotalDuration;

  /// No description provided for @trainSelections.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 selection} other{{n} selections}}'**
  String trainSelections(int n);

  /// No description provided for @trainNoWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No saved workouts yet.'**
  String get trainNoWorkouts;

  /// No description provided for @trainCreateWorkout.
  ///
  /// In en, this message translates to:
  /// **'Create a workout'**
  String get trainCreateWorkout;

  /// No description provided for @trainFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get trainFixed;

  /// No description provided for @trainCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get trainCycle;

  /// No description provided for @trainChangesEvery.
  ///
  /// In en, this message translates to:
  /// **'Combination changes every work interval.'**
  String get trainChangesEvery;

  /// No description provided for @trainShowRandom.
  ///
  /// In en, this message translates to:
  /// **'Show random combinations'**
  String get trainShowRandom;

  /// No description provided for @trainSavePreset.
  ///
  /// In en, this message translates to:
  /// **'Save as preset'**
  String get trainSavePreset;

  /// No description provided for @trainPresetSaved.
  ///
  /// In en, this message translates to:
  /// **'Preset saved'**
  String get trainPresetSaved;

  /// No description provided for @trainPresetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Preset deleted'**
  String get trainPresetDeleted;

  /// No description provided for @trainPresetHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to load · double-tap to delete'**
  String get trainPresetHint;

  /// No description provided for @trainTimerSettings.
  ///
  /// In en, this message translates to:
  /// **'Timer settings'**
  String get trainTimerSettings;

  /// No description provided for @trainSoundCues.
  ///
  /// In en, this message translates to:
  /// **'Sound cues'**
  String get trainSoundCues;

  /// No description provided for @trainVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get trainVibration;

  /// No description provided for @trainPrepCountdown.
  ///
  /// In en, this message translates to:
  /// **'Prep countdown'**
  String get trainPrepCountdown;

  /// No description provided for @trainPrepHint.
  ///
  /// In en, this message translates to:
  /// **'Seconds before round 1'**
  String get trainPrepHint;

  /// No description provided for @trainRestSuffix.
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get trainRestSuffix;

  /// No description provided for @trainFreeRounds.
  ///
  /// In en, this message translates to:
  /// **'FREE ROUNDS'**
  String get trainFreeRounds;

  /// No description provided for @trainHeavyBagName.
  ///
  /// In en, this message translates to:
  /// **'HEAVY BAG'**
  String get trainHeavyBagName;

  /// No description provided for @trainIntervalsName.
  ///
  /// In en, this message translates to:
  /// **'INTERVALS'**
  String get trainIntervalsName;

  /// No description provided for @livePreparing.
  ///
  /// In en, this message translates to:
  /// **'PREPARING'**
  String get livePreparing;

  /// No description provided for @liveRoundOf.
  ///
  /// In en, this message translates to:
  /// **'ROUND {x} OF {y}'**
  String liveRoundOf(Object x, Object y);

  /// No description provided for @livePrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get livePrevious;

  /// No description provided for @liveSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get liveSkip;

  /// No description provided for @liveRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get liveRestart;

  /// No description provided for @liveSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get liveSound;

  /// No description provided for @liveVibe.
  ///
  /// In en, this message translates to:
  /// **'Vibe'**
  String get liveVibe;

  /// No description provided for @liveExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get liveExit;

  /// No description provided for @liveExitMsg.
  ///
  /// In en, this message translates to:
  /// **'Leave this session? Progress will not be saved.'**
  String get liveExitMsg;

  /// No description provided for @liveReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to work'**
  String get liveReady;

  /// No description provided for @liveTotal.
  ///
  /// In en, this message translates to:
  /// **'{rounds} rounds · {time} total'**
  String liveTotal(Object rounds, Object time);

  /// No description provided for @liveSoundHint.
  ///
  /// In en, this message translates to:
  /// **'Keep sound on — beeps count down the last seconds and mark each combination.'**
  String get liveSoundHint;

  /// No description provided for @liveGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get liveGetReady;

  /// No description provided for @livePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get livePaused;

  /// No description provided for @liveFirstUp.
  ///
  /// In en, this message translates to:
  /// **'First up'**
  String get liveFirstUp;

  /// No description provided for @liveNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get liveNext;

  /// No description provided for @liveNextRound.
  ///
  /// In en, this message translates to:
  /// **'Next — round {n}'**
  String liveNextRound(Object n);

  /// No description provided for @liveNextRoundShort.
  ///
  /// In en, this message translates to:
  /// **'Next round {n}'**
  String liveNextRoundShort(Object n);

  /// No description provided for @liveFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get liveFree;

  /// No description provided for @liveThrowEverything.
  ///
  /// In en, this message translates to:
  /// **'Throw everything'**
  String get liveThrowEverything;

  /// No description provided for @liveStaySharp.
  ///
  /// In en, this message translates to:
  /// **'Stay sharp — move well'**
  String get liveStaySharp;

  /// No description provided for @liveFreeSlot.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get liveFreeSlot;

  /// No description provided for @liveDefenseSlot.
  ///
  /// In en, this message translates to:
  /// **'DEFENSE'**
  String get liveDefenseSlot;

  /// No description provided for @liveConditioningSlot.
  ///
  /// In en, this message translates to:
  /// **'CONDITIONING'**
  String get liveConditioningSlot;

  /// No description provided for @liveCustomSlot.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM'**
  String get liveCustomSlot;

  /// No description provided for @liveRandomSlot.
  ///
  /// In en, this message translates to:
  /// **'RANDOM {n}'**
  String liveRandomSlot(Object n);

  /// No description provided for @workoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workoutsTitle;

  /// No description provided for @workoutsNoRounds.
  ///
  /// In en, this message translates to:
  /// **'This workout has no rounds'**
  String get workoutsNoRounds;

  /// No description provided for @workoutsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get workoutsEmpty;

  /// No description provided for @workoutsEmptyMsg.
  ///
  /// In en, this message translates to:
  /// **'Create a structured workout with rounds, rest and combinations.'**
  String get workoutsEmptyMsg;

  /// No description provided for @workoutsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create workout'**
  String get workoutsCreate;

  /// No description provided for @workoutsDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Workout duplicated'**
  String get workoutsDuplicated;

  /// No description provided for @workoutsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Workout deleted'**
  String get workoutsDeleted;

  /// No description provided for @workoutsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete workout'**
  String get workoutsDeleteTitle;

  /// No description provided for @workoutsDeleteMsg.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Completed sessions in history are kept. This cannot be undone.'**
  String workoutsDeleteMsg(Object name);

  /// No description provided for @workoutsCombosCount.
  ///
  /// In en, this message translates to:
  /// **'{n} COMBOS'**
  String workoutsCombosCount(Object n);

  /// No description provided for @workoutsRoutine.
  ///
  /// In en, this message translates to:
  /// **'STRETCHING ROUTINE'**
  String get workoutsRoutine;

  /// No description provided for @builderAddRound.
  ///
  /// In en, this message translates to:
  /// **'Add at least one round'**
  String get builderAddRound;

  /// No description provided for @builderMinSeconds.
  ///
  /// In en, this message translates to:
  /// **'Every round must be at least 5 seconds'**
  String get builderMinSeconds;

  /// No description provided for @builderSaved.
  ///
  /// In en, this message translates to:
  /// **'Workout saved'**
  String get builderSaved;

  /// No description provided for @builderEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit workout'**
  String get builderEdit;

  /// No description provided for @builderNew.
  ///
  /// In en, this message translates to:
  /// **'New workout'**
  String get builderNew;

  /// No description provided for @builderWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Workout name'**
  String get builderWorkoutName;

  /// No description provided for @builderWorkRest.
  ///
  /// In en, this message translates to:
  /// **'Work {w} · Rest {r}'**
  String builderWorkRest(Object w, Object r);

  /// No description provided for @builderAddRoundBtn.
  ///
  /// In en, this message translates to:
  /// **'Add round'**
  String get builderAddRoundBtn;

  /// No description provided for @builderSaveStart.
  ///
  /// In en, this message translates to:
  /// **'Save + Start'**
  String get builderSaveStart;

  /// No description provided for @builderRoundN.
  ///
  /// In en, this message translates to:
  /// **'Round {n}'**
  String builderRoundN(Object n);

  /// No description provided for @builderMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move round up'**
  String get builderMoveUp;

  /// No description provided for @builderMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move round down'**
  String get builderMoveDown;

  /// No description provided for @builderDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate round'**
  String get builderDuplicate;

  /// No description provided for @builderDeleteRound.
  ///
  /// In en, this message translates to:
  /// **'Delete round'**
  String get builderDeleteRound;

  /// No description provided for @builderRestLast.
  ///
  /// In en, this message translates to:
  /// **'Rest (none, last)'**
  String get builderRestLast;

  /// No description provided for @builderRestAfter.
  ///
  /// In en, this message translates to:
  /// **'Rest after'**
  String get builderRestAfter;

  /// No description provided for @builderRoundType.
  ///
  /// In en, this message translates to:
  /// **'Round type'**
  String get builderRoundType;

  /// No description provided for @builderSelectCombos.
  ///
  /// In en, this message translates to:
  /// **'Select combinations…'**
  String get builderSelectCombos;

  /// No description provided for @builderSelected.
  ///
  /// In en, this message translates to:
  /// **'{n} SELECTED'**
  String builderSelected(Object n);

  /// No description provided for @builderFocusLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus label (shown during the round)'**
  String get builderFocusLabel;

  /// No description provided for @builderDeletedCombo.
  ///
  /// In en, this message translates to:
  /// **'(deleted combo)'**
  String get builderDeletedCombo;

  /// No description provided for @builderFreeHint.
  ///
  /// In en, this message translates to:
  /// **'No combinations — throw whatever you want.'**
  String get builderFreeHint;

  /// No description provided for @builderNotFound.
  ///
  /// In en, this message translates to:
  /// **'This workout no longer exists. Saving will create a new one.'**
  String get builderNotFound;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyLogSession.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get historyLogSession;

  /// No description provided for @historySearch.
  ///
  /// In en, this message translates to:
  /// **'Search notes and workouts…'**
  String get historySearch;

  /// No description provided for @historyFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get historyFrom;

  /// No description provided for @historyTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get historyTo;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get historyEmpty;

  /// No description provided for @historyEmptyMsg.
  ///
  /// In en, this message translates to:
  /// **'Finish a training session or log one manually and it will show up here.'**
  String get historyEmptyMsg;

  /// No description provided for @historyLogOne.
  ///
  /// In en, this message translates to:
  /// **'Log a session'**
  String get historyLogOne;

  /// No description provided for @historyRnd.
  ///
  /// In en, this message translates to:
  /// **'RND'**
  String get historyRnd;

  /// No description provided for @historyWorkUnit.
  ///
  /// In en, this message translates to:
  /// **'WORK'**
  String get historyWorkUnit;

  /// No description provided for @historyEnergyBefore.
  ///
  /// In en, this message translates to:
  /// **'Energy before: {n}/5'**
  String historyEnergyBefore(Object n);

  /// No description provided for @historyFeelingAfter.
  ///
  /// In en, this message translates to:
  /// **'Feeling after: {feeling}'**
  String historyFeelingAfter(Object feeling);

  /// No description provided for @historyCombosUsed.
  ///
  /// In en, this message translates to:
  /// **'Combinations used'**
  String get historyCombosUsed;

  /// No description provided for @historyDeleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get historyDeleteSession;

  /// No description provided for @historyDeleteMsg.
  ///
  /// In en, this message translates to:
  /// **'Remove this session from history? This cannot be undone.'**
  String get historyDeleteMsg;

  /// No description provided for @historySessionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Session deleted'**
  String get historySessionDeleted;

  /// No description provided for @historyMinDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration must be at least 1 minute'**
  String get historyMinDuration;

  /// No description provided for @historySessionLogged.
  ///
  /// In en, this message translates to:
  /// **'Session logged'**
  String get historySessionLogged;

  /// No description provided for @historyNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get historyNameOptional;

  /// No description provided for @historyRpeLoad.
  ///
  /// In en, this message translates to:
  /// **'RPE — load {n}'**
  String historyRpeLoad(Object n);

  /// No description provided for @historyDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance (km, optional)'**
  String get historyDistance;

  /// No description provided for @historyExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get historyExercises;

  /// No description provided for @historyAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get historyAdd;

  /// No description provided for @historyExercisePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get historyExercisePlaceholder;

  /// No description provided for @historySets.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get historySets;

  /// No description provided for @historyReps.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get historyReps;

  /// No description provided for @historyKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get historyKg;

  /// No description provided for @historyRemoveExercise.
  ///
  /// In en, this message translates to:
  /// **'Remove exercise'**
  String get historyRemoveExercise;

  /// No description provided for @historyNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises added — the session will be logged by duration only.'**
  String get historyNoExercises;

  /// No description provided for @historyNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get historyNotes;

  /// No description provided for @historySaveSession.
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get historySaveSession;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No training history yet. Finish a session and your numbers will build up here.'**
  String get statsEmpty;

  /// No description provided for @stats7days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get stats7days;

  /// No description provided for @stats30days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get stats30days;

  /// No description provided for @statsAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get statsAllTime;

  /// No description provided for @statsSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get statsSessions;

  /// No description provided for @statsTrainingTime.
  ///
  /// In en, this message translates to:
  /// **'Training time'**
  String get statsTrainingTime;

  /// No description provided for @statsRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get statsRounds;

  /// No description provided for @statsWorkTime.
  ///
  /// In en, this message translates to:
  /// **'Work time'**
  String get statsWorkTime;

  /// No description provided for @statsTrainingLoad.
  ///
  /// In en, this message translates to:
  /// **'Training load'**
  String get statsTrainingLoad;

  /// No description provided for @statsWeeklyLoad.
  ///
  /// In en, this message translates to:
  /// **'Weekly load'**
  String get statsWeeklyLoad;

  /// No description provided for @statsMonthlyLoad.
  ///
  /// In en, this message translates to:
  /// **'Monthly load'**
  String get statsMonthlyLoad;

  /// No description provided for @statsLoadNote.
  ///
  /// In en, this message translates to:
  /// **'Load = duration × RPE. A simple training estimate, not a medical readiness metric.'**
  String get statsLoadNote;

  /// No description provided for @statsConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get statsConsistency;

  /// No description provided for @statsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get statsCurrentStreak;

  /// No description provided for @statsLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get statsLongestStreak;

  /// No description provided for @statsSessionsPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Sessions / week'**
  String get statsSessionsPerWeek;

  /// No description provided for @statsHeavyBag.
  ///
  /// In en, this message translates to:
  /// **'Heavy bag'**
  String get statsHeavyBag;

  /// No description provided for @statsBagSessions.
  ///
  /// In en, this message translates to:
  /// **'Bag sessions'**
  String get statsBagSessions;

  /// No description provided for @statsBagRounds.
  ///
  /// In en, this message translates to:
  /// **'Bag rounds'**
  String get statsBagRounds;

  /// No description provided for @statsBagTime.
  ///
  /// In en, this message translates to:
  /// **'Bag time'**
  String get statsBagTime;

  /// No description provided for @statsMostUsed.
  ///
  /// In en, this message translates to:
  /// **'Most used combinations'**
  String get statsMostUsed;

  /// No description provided for @statsMostUsedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete sessions with combinations to see usage.'**
  String get statsMostUsedEmpty;

  /// No description provided for @statsTechFreq.
  ///
  /// In en, this message translates to:
  /// **'Technique frequency'**
  String get statsTechFreq;

  /// No description provided for @statsTechEmpty.
  ///
  /// In en, this message translates to:
  /// **'No technique data yet.'**
  String get statsTechEmpty;

  /// No description provided for @statsWeeklyOverview.
  ///
  /// In en, this message translates to:
  /// **'Weekly overview'**
  String get statsWeeklyOverview;

  /// No description provided for @statsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// No description provided for @statsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get statsLastWeek;

  /// No description provided for @statsSessionsLine.
  ///
  /// In en, this message translates to:
  /// **'{n} sessions · {time} · load {load}'**
  String statsSessionsLine(Object n, Object time, Object load);

  /// No description provided for @statsPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get statsPlan;

  /// No description provided for @statsPlanSession.
  ///
  /// In en, this message translates to:
  /// **'Plan a session'**
  String get statsPlanSession;

  /// No description provided for @statsLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get statsLabelOptional;

  /// No description provided for @statsPlannedMinutes.
  ///
  /// In en, this message translates to:
  /// **'Planned minutes'**
  String get statsPlannedMinutes;

  /// No description provided for @statsAddToWeek.
  ///
  /// In en, this message translates to:
  /// **'Add to week'**
  String get statsAddToWeek;

  /// No description provided for @statsTogglePlan.
  ///
  /// In en, this message translates to:
  /// **'Toggle planned session'**
  String get statsTogglePlan;

  /// No description provided for @statsDeletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get statsDeletePlan;

  /// No description provided for @statsPrevWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get statsPrevWeek;

  /// No description provided for @statsNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get statsNextWeek;

  /// No description provided for @completeSelectRpe.
  ///
  /// In en, this message translates to:
  /// **'Select an RPE first'**
  String get completeSelectRpe;

  /// No description provided for @completeSaved.
  ///
  /// In en, this message translates to:
  /// **'Session saved'**
  String get completeSaved;

  /// No description provided for @completeTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get completeTitle;

  /// No description provided for @completeRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get completeRounds;

  /// No description provided for @completeEstSession.
  ///
  /// In en, this message translates to:
  /// **'Est. session'**
  String get completeEstSession;

  /// No description provided for @completeWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get completeWork;

  /// No description provided for @completeRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get completeRest;

  /// No description provided for @completeHowHard.
  ///
  /// In en, this message translates to:
  /// **'How hard was it?'**
  String get completeHowHard;

  /// No description provided for @completeRpe.
  ///
  /// In en, this message translates to:
  /// **'RPE —'**
  String get completeRpe;

  /// No description provided for @completeLoadApprox.
  ///
  /// In en, this message translates to:
  /// **'Training load ≈ {n}'**
  String completeLoadApprox(Object n);

  /// No description provided for @completeEnergyBefore.
  ///
  /// In en, this message translates to:
  /// **'Energy before (optional)'**
  String get completeEnergyBefore;

  /// No description provided for @completeFeelingAfter.
  ///
  /// In en, this message translates to:
  /// **'Feeling after (optional)'**
  String get completeFeelingAfter;

  /// No description provided for @completeNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get completeNotes;

  /// No description provided for @completeNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Sharp combinations, gas tank felt good…'**
  String get completeNotesPlaceholder;

  /// No description provided for @completeDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get completeDiscard;

  /// No description provided for @completeSaveSession.
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get completeSaveSession;

  /// No description provided for @completeDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard session'**
  String get completeDiscardTitle;

  /// No description provided for @completeDiscardMsg.
  ///
  /// In en, this message translates to:
  /// **'Throw away this session? It will not appear in history.'**
  String get completeDiscardMsg;

  /// No description provided for @sessionNoRounds.
  ///
  /// In en, this message translates to:
  /// **'NO ROUNDS'**
  String get sessionNoRounds;

  /// No description provided for @sessionNRounds.
  ///
  /// In en, this message translates to:
  /// **'{n} ROUNDS'**
  String sessionNRounds(Object n);

  /// No description provided for @sessionRest.
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get sessionRest;

  /// No description provided for @sessionDeletedCombo.
  ///
  /// In en, this message translates to:
  /// **'DELETED COMBO'**
  String get sessionDeletedCombo;

  /// No description provided for @sessionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sessionUnknown;

  /// No description provided for @pushupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Push-ups'**
  String get pushupsTitle;

  /// No description provided for @pushupsSub.
  ///
  /// In en, this message translates to:
  /// **'Automatic counter using the camera'**
  String get pushupsSub;

  /// No description provided for @pushupsHint.
  ///
  /// In en, this message translates to:
  /// **'Lay the phone on the floor with the front camera facing up and lower yourself over it: each rep is counted automatically.'**
  String get pushupsHint;

  /// No description provided for @pushupsName.
  ///
  /// In en, this message translates to:
  /// **'Push-ups'**
  String get pushupsName;

  /// No description provided for @pushupsExercise.
  ///
  /// In en, this message translates to:
  /// **'Push-ups'**
  String get pushupsExercise;

  /// No description provided for @pushupsCount.
  ///
  /// In en, this message translates to:
  /// **'push-ups'**
  String get pushupsCount;

  /// No description provided for @pushupsDetecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting'**
  String get pushupsDetecting;

  /// No description provided for @pushupsMoveCloser.
  ///
  /// In en, this message translates to:
  /// **'Move closer or adjust sensitivity'**
  String get pushupsMoveCloser;

  /// No description provided for @pushupsSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get pushupsSensitivity;

  /// No description provided for @pushupsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pushupsSave;

  /// No description provided for @pushupsStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get pushupsStop;

  /// No description provided for @pushupsSaved.
  ///
  /// In en, this message translates to:
  /// **'Push-up session saved'**
  String get pushupsSaved;

  /// No description provided for @pushupsNothingToSave.
  ///
  /// In en, this message translates to:
  /// **'No push-ups to save'**
  String get pushupsNothingToSave;

  /// No description provided for @pushupsErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied. Allow camera access in your browser settings.'**
  String get pushupsErrorPermission;

  /// No description provided for @pushupsErrorNoCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera found.'**
  String get pushupsErrorNoCamera;

  /// No description provided for @pushupsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not start the camera.'**
  String get pushupsErrorGeneric;

  /// No description provided for @builderAddBlock.
  ///
  /// In en, this message translates to:
  /// **'Add block'**
  String get builderAddBlock;

  /// No description provided for @builderBlockType.
  ///
  /// In en, this message translates to:
  /// **'Block type'**
  String get builderBlockType;

  /// No description provided for @builderSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get builderSeries;

  /// No description provided for @builderChooseRoutine.
  ///
  /// In en, this message translates to:
  /// **'Stretching routine'**
  String get builderChooseRoutine;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound cues'**
  String get settingsSound;

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// No description provided for @settingsPrep.
  ///
  /// In en, this message translates to:
  /// **'Prep countdown'**
  String get settingsPrep;

  /// No description provided for @settingsPrepHint.
  ///
  /// In en, this message translates to:
  /// **'Runs automatically when the session starts'**
  String get settingsPrepHint;

  /// No description provided for @trainPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get trainPresets;

  /// No description provided for @trainCombosToggle.
  ///
  /// In en, this message translates to:
  /// **'Train with combinations'**
  String get trainCombosToggle;

  /// No description provided for @trainTools.
  ///
  /// In en, this message translates to:
  /// **'Extra tools'**
  String get trainTools;

  /// No description provided for @trainLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used'**
  String get trainLastUsed;

  /// No description provided for @trainSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get trainSeries;

  /// No description provided for @trainSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to adjust'**
  String get trainSwipeHint;

  /// No description provided for @trainWorkoutSub.
  ///
  /// In en, this message translates to:
  /// **'Run a saved workout'**
  String get trainWorkoutSub;

  /// No description provided for @trainWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get trainWorkout;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @libraryBag.
  ///
  /// In en, this message translates to:
  /// **'Bag'**
  String get libraryBag;

  /// No description provided for @libraryTool.
  ///
  /// In en, this message translates to:
  /// **'Tool'**
  String get libraryTool;

  /// No description provided for @libraryStretching.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get libraryStretching;

  /// No description provided for @routineNew.
  ///
  /// In en, this message translates to:
  /// **'New stretching routine'**
  String get routineNew;

  /// No description provided for @routineEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit stretching routine'**
  String get routineEdit;

  /// No description provided for @routineTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap stretching exercises on the right to build the routine.'**
  String get routineTapHint;

  /// No description provided for @routineExercisesCount.
  ///
  /// In en, this message translates to:
  /// **'Routine ({n} exercises)'**
  String routineExercisesCount(Object n);

  /// No description provided for @routineGiveName.
  ///
  /// In en, this message translates to:
  /// **'Give the routine a name'**
  String get routineGiveName;

  /// No description provided for @routineSaved.
  ///
  /// In en, this message translates to:
  /// **'Routine saved'**
  String get routineSaved;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressWeekSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions this week'**
  String get progressWeekSessions;

  /// No description provided for @liveExitWorkout.
  ///
  /// In en, this message translates to:
  /// **'Exit workout'**
  String get liveExitWorkout;

  /// No description provided for @builderGiveName.
  ///
  /// In en, this message translates to:
  /// **'Give the workout a name'**
  String get builderGiveName;

  /// No description provided for @liveStopAndSave.
  ///
  /// In en, this message translates to:
  /// **'Stop & save'**
  String get liveStopAndSave;

  /// No description provided for @liveStopSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get liveStopSaveTitle;

  /// No description provided for @liveStopSaveMsg.
  ///
  /// In en, this message translates to:
  /// **'Stop the session and save it to Progress?'**
  String get liveStopSaveMsg;

  /// No description provided for @liveRestartTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart session?'**
  String get liveRestartTitle;

  /// No description provided for @liveRestartMsg.
  ///
  /// In en, this message translates to:
  /// **'The timer will start over from the first round.'**
  String get liveRestartMsg;

  /// No description provided for @completeSavedToProgress.
  ///
  /// In en, this message translates to:
  /// **'Saved to Progress'**
  String get completeSavedToProgress;

  /// No description provided for @completeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get completeDone;

  /// No description provided for @completeAddDetails.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)'**
  String get completeAddDetails;

  /// No description provided for @completeRpeOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional — skip if you want'**
  String get completeRpeOptional;

  /// No description provided for @completeRpeEasy.
  ///
  /// In en, this message translates to:
  /// **'1 = easy'**
  String get completeRpeEasy;

  /// No description provided for @completeRpeMax.
  ///
  /// In en, this message translates to:
  /// **'10 = max'**
  String get completeRpeMax;

  /// No description provided for @completeAutoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save automatically — tap Done to retry'**
  String get completeAutoSaveFailed;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get commonDuplicate;

  /// No description provided for @comboDeleteTechniqueTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete technique'**
  String get comboDeleteTechniqueTitle;

  /// No description provided for @comboDeleteTechniqueMsg.
  ///
  /// In en, this message translates to:
  /// **'Delete this technique? It will be removed from your combinations.'**
  String get comboDeleteTechniqueMsg;

  /// No description provided for @progressWeeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal'**
  String get progressWeeklyGoal;

  /// No description provided for @progressGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal reached'**
  String get progressGoalReached;

  /// No description provided for @progressViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get progressViewHistory;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Train with a timer'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Set work, rest and rounds. Big numbers and loud cues — no need to touch the phone.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Your combinations, on screen'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Pick combinations from the Library and the app walks you through every technique, round after round.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'See yourself improve'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Streaks, volume and history — Progress shows the work you put in over time.'**
  String get onboardingBody3;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start training'**
  String get onboardingStart;

  /// No description provided for @settingsHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get settingsHowItWorks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
