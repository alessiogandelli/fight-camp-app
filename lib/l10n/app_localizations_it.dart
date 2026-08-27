// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get navTrain => 'Allenati';

  @override
  String get navWorkouts => 'Workout';

  @override
  String get navCombos => 'Combo';

  @override
  String get navHistory => 'Storico';

  @override
  String get navStats => 'Stats';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonStart => 'Avvia';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonEdit => 'Modifica';

  @override
  String get commonNew => 'Nuovo';

  @override
  String get commonClear => 'Azzera';

  @override
  String get commonDone => 'Fatto';

  @override
  String get commonAll => 'Tutti';

  @override
  String get commonSequential => 'Sequenziale';

  @override
  String get commonRandom => 'Casuale';

  @override
  String get commonWork => 'Lavoro';

  @override
  String get commonRest => 'Riposo';

  @override
  String get commonRounds => 'Round';

  @override
  String get commonRound => 'Round';

  @override
  String get commonDuration => 'Durata';

  @override
  String get commonType => 'Tipo';

  @override
  String get commonName => 'Nome';

  @override
  String get commonOptional => '(facoltativo)';

  @override
  String get commonNone => 'Nessuna';

  @override
  String get commonCategory => 'Categoria';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonDecrease => 'Diminuisci';

  @override
  String get commonIncrease => 'Aumenta';

  @override
  String get commonDeleted => '(eliminato)';

  @override
  String get commonTotal => 'Totale';

  @override
  String get commonPause => 'Pausa';

  @override
  String get commonResume => 'Riprendi';

  @override
  String get commonLoad => 'Carico';

  @override
  String get unitSession => 'sessione';

  @override
  String get unitSessions => 'sessioni';

  @override
  String get unitExercise => 'esercizio';

  @override
  String get unitExercises => 'esercizi';

  @override
  String get feelingGreat => 'Ottimo';

  @override
  String get feelingGood => 'Bene';

  @override
  String get feelingOk => 'OK';

  @override
  String get feelingDrained => 'Sfinito';

  @override
  String get pickerTitle => 'Seleziona combinazioni';

  @override
  String get pickerSearch => 'Cerca…';

  @override
  String get pickerEmpty =>
      'Nessuna combinazione trovata. Creane una nella scheda Combinazioni.';

  @override
  String pickerDone(Object n) {
    return 'Fatto ($n)';
  }

  @override
  String get pickerSelectAll => 'Seleziona tutte';

  @override
  String get randomMinTechniques => 'Min tecniche';

  @override
  String get randomMaxTechniques => 'Max tecniche';

  @override
  String get randomAllowedCategories => 'Categorie consentite';

  @override
  String get randomRequirePunch => 'Almeno 1 pugno';

  @override
  String get randomRequireKick => 'Almeno 1 calcio';

  @override
  String get randomIncludeDefense => 'Includi difesa / movimento';

  @override
  String get randomGenerated => 'Combinazioni generate';

  @override
  String get comboAddTechnique => 'Aggiungi almeno una tecnica';

  @override
  String get comboGiveName => 'Dai un nome alla combinazione';

  @override
  String get comboSaved => 'Combinazione salvata';

  @override
  String get comboEdit => 'Modifica combinazione';

  @override
  String get comboNew => 'Nuova combinazione';

  @override
  String get comboToggleFavorite => 'Attiva/disattiva preferito';

  @override
  String comboTechniquesCount(Object n) {
    return 'Combinazione ($n tecniche)';
  }

  @override
  String get comboTapHint =>
      'Tocca le tecniche a destra per costruire la combinazione.';

  @override
  String get comboMoveUp => 'Sposta su';

  @override
  String get comboMoveDown => 'Sposta giù';

  @override
  String get comboRemove => 'Rimuovi';

  @override
  String get comboTechniqueLibrary => 'Libreria tecniche';

  @override
  String get comboTechnique => 'Tecnica';

  @override
  String get comboTechniqueAdded => 'Tecnica aggiunta';

  @override
  String get comboNotFound => 'Non trovato';

  @override
  String get comboNotFoundMsg => 'Questa combinazione non esiste più.';

  @override
  String get comboCustomTechniques => 'Tecniche personalizzate';

  @override
  String comboDeleteAria(Object name) {
    return 'Elimina $name';
  }

  @override
  String get comboTechniqueNeedsName => 'La tecnica ha bisogno di un nome';

  @override
  String get comboNewTechnique => 'Nuova tecnica';

  @override
  String get comboShortName => 'Nome breve mostrato';

  @override
  String get comboDescription => 'Descrizione (facoltativa)';

  @override
  String get comboAddTechniqueBtn => 'Aggiungi tecnica';

  @override
  String get combosTitle => 'Combinazioni';

  @override
  String get combosFavorites => '★ Preferite';

  @override
  String get combosSearch => 'Cerca combinazioni…';

  @override
  String get combosEmpty => 'Nessuna combinazione';

  @override
  String get combosEmptyMsg =>
      'Crea la tua prima combinazione dalla libreria tecniche.';

  @override
  String get combosCreate => 'Crea combinazione';

  @override
  String get combosDuplicated => 'Combinazione duplicata';

  @override
  String get combosDeleted => 'Combinazione eliminata';

  @override
  String get combosDeleteTitle => 'Elimina combinazione';

  @override
  String combosDeleteMsg(Object name) {
    return 'Eliminare \"$name\"? Gli allenamenti che la usano passeranno a round liberi. L\'operazione è irreversibile.';
  }

  @override
  String combosTrain(Object name) {
    return 'Allenati: $name';
  }

  @override
  String get combosRoundLength => 'Durata round';

  @override
  String get combosRestBetween => 'Riposo tra i round';

  @override
  String get combosStartSession => 'Avvia sessione';

  @override
  String get trainHeavyBag => 'Sacco pesante';

  @override
  String get trainHeavyBagSub => 'Round di combinazioni al sacco';

  @override
  String get trainComboWorkout => 'Allenamento combinato';

  @override
  String get trainComboWorkoutSub => 'Esegui un allenamento salvato';

  @override
  String get trainTabata => 'Tabata';

  @override
  String get trainTabataSub => 'Raffiche 20s lavoro / 10s riposo';

  @override
  String get trainIntervals => 'Intervalli';

  @override
  String get trainIntervalsSub => 'Preset lavoro/riposo personalizzati';

  @override
  String get trainFree => 'Round libero';

  @override
  String get trainFreeSub => 'Solo timer, nessuna combinazione';

  @override
  String get trainNothingToRun =>
      'Niente da eseguire: aggiungi prima dei round';

  @override
  String get trainInProgress => 'Sessione in corso';

  @override
  String trainAt(Object time) {
    return 'a $time';
  }

  @override
  String get trainRounds => 'Round';

  @override
  String get trainCombinations => 'Combinazioni';

  @override
  String get trainRotateEvery => 'Ruota ogni';

  @override
  String get trainOrder => 'Ordine';

  @override
  String get trainNoneFree => 'Nessuna — round liberi';

  @override
  String trainSelected(Object n) {
    return '$n selezionati';
  }

  @override
  String get trainNoWorkouts => 'Nessun allenamento salvato.';

  @override
  String get trainCreateWorkout => 'Crea un allenamento';

  @override
  String get trainFixed => 'Fissa';

  @override
  String get trainCycle => 'Ciclo';

  @override
  String get trainChangesEvery =>
      'La combinazione cambia a ogni intervallo di lavoro.';

  @override
  String get trainShowRandom => 'Mostra combinazioni casuali';

  @override
  String get trainSavePreset => 'Salva come preset';

  @override
  String get trainPresetSaved => 'Preset salvato';

  @override
  String get trainPresetDeleted => 'Preset eliminato';

  @override
  String get trainPresetHint =>
      'Tocca per caricare · doppio tocco per eliminare';

  @override
  String get trainTimerSettings => 'Impostazioni timer';

  @override
  String get trainSoundCues => 'Segnali sonori';

  @override
  String get trainVibration => 'Vibrazione';

  @override
  String get trainPrepCountdown => 'Conto alla rovescia';

  @override
  String get trainPrepHint => 'Secondi prima del round 1';

  @override
  String get trainRestSuffix => 'RIPOSO';

  @override
  String get trainFreeRounds => 'ROUND LIBERI';

  @override
  String get trainHeavyBagName => 'SACCO PESANTE';

  @override
  String get trainIntervalsName => 'INTERVALLI';

  @override
  String get livePreparing => 'PREPARAZIONE';

  @override
  String liveRoundOf(Object x, Object y) {
    return 'ROUND $x DI $y';
  }

  @override
  String get livePrevious => 'Precedente';

  @override
  String get liveSkip => 'Salta';

  @override
  String get liveRestart => 'Riavvia';

  @override
  String get liveSound => 'Suono';

  @override
  String get liveVibe => 'Vibrazione';

  @override
  String get liveExit => 'Esci';

  @override
  String get liveExitMsg =>
      'Uscire da questa sessione? I progressi non verranno salvati.';

  @override
  String get liveReady => 'Pronto a lavorare';

  @override
  String liveTotal(Object rounds, Object time) {
    return '$rounds round · $time totali';
  }

  @override
  String get liveSoundHint =>
      'Tieni il suono attivo: le campane segnano i round, i bip segnano le combinazioni.';

  @override
  String get liveGetReady => 'Preparati';

  @override
  String get livePaused => 'In pausa';

  @override
  String get liveFirstUp => 'Prima';

  @override
  String get liveNext => 'Prossimo';

  @override
  String liveNextRound(Object n) {
    return 'Prossimo — round $n';
  }

  @override
  String liveNextRoundShort(Object n) {
    return 'Prossimo round $n';
  }

  @override
  String get liveFree => 'Libero';

  @override
  String get liveThrowEverything => 'Dai tutto';

  @override
  String get liveStaySharp => 'Resta reattivo, muoviti bene';

  @override
  String get liveFreeSlot => 'LIBERO';

  @override
  String get liveDefenseSlot => 'DIFESA';

  @override
  String get liveConditioningSlot => 'CONDIZIONAMENTO';

  @override
  String get liveCustomSlot => 'PERSONALIZZATO';

  @override
  String liveRandomSlot(Object n) {
    return 'CASUALE $n';
  }

  @override
  String get workoutsTitle => 'Allenamenti';

  @override
  String get workoutsNoRounds => 'Questo allenamento non ha round';

  @override
  String get workoutsEmpty => 'Nessun allenamento';

  @override
  String get workoutsEmptyMsg =>
      'Crea un allenamento strutturato con round, riposo e combinazioni.';

  @override
  String get workoutsCreate => 'Crea allenamento';

  @override
  String get workoutsDuplicated => 'Allenamento duplicato';

  @override
  String get workoutsDeleted => 'Allenamento eliminato';

  @override
  String get workoutsDeleteTitle => 'Elimina allenamento';

  @override
  String workoutsDeleteMsg(Object name) {
    return 'Eliminare \"$name\"? Le sessioni completate nello storico restano. L\'operazione è irreversibile.';
  }

  @override
  String get builderAddRound => 'Aggiungi almeno un round';

  @override
  String get builderMinSeconds => 'Ogni round deve durare almeno 5 secondi';

  @override
  String get builderSaved => 'Allenamento salvato';

  @override
  String get builderEdit => 'Modifica allenamento';

  @override
  String get builderNew => 'Nuovo allenamento';

  @override
  String get builderWorkoutName => 'Nome allenamento';

  @override
  String builderWorkRest(Object w, Object r) {
    return 'Lavoro $w · Riposo $r';
  }

  @override
  String get builderAddRoundBtn => 'Aggiungi round';

  @override
  String get builderSaveStart => 'Salva + Avvia';

  @override
  String builderRoundN(Object n) {
    return 'Round $n';
  }

  @override
  String get builderMoveUp => 'Sposta round su';

  @override
  String get builderMoveDown => 'Sposta round giù';

  @override
  String get builderDuplicate => 'Duplica round';

  @override
  String get builderDeleteRound => 'Elimina round';

  @override
  String get builderRestLast => 'Riposo (nessuno, ultimo)';

  @override
  String get builderRestAfter => 'Riposo dopo';

  @override
  String get builderRoundType => 'Tipo di round';

  @override
  String get builderSelectCombos => 'Seleziona combinazioni…';

  @override
  String builderSelected(Object n) {
    return '$n SELEZIONATE';
  }

  @override
  String get builderFocusLabel => 'Etichetta focus (mostrata durante il round)';

  @override
  String get builderDeletedCombo => '(combinazione eliminata)';

  @override
  String get builderFreeHint =>
      'Nessuna combinazione: colpisci come preferisci.';

  @override
  String get builderNotFound =>
      'Questo allenamento non esiste più. Salvando ne creerai uno nuovo.';

  @override
  String get historyTitle => 'Storico';

  @override
  String get historyLogSession => 'Registra sessione';

  @override
  String get historySearch => 'Cerca note e allenamenti…';

  @override
  String get historyFrom => 'Da';

  @override
  String get historyTo => 'A';

  @override
  String get historyEmpty => 'Nessuna sessione';

  @override
  String get historyEmptyMsg =>
      'Termina una sessione di allenamento o registrane una manualmente e comparirà qui.';

  @override
  String get historyLogOne => 'Registra una sessione';

  @override
  String get historyRnd => 'RND';

  @override
  String get historyWorkUnit => 'LAVORO';

  @override
  String historyEnergyBefore(Object n) {
    return 'Energia prima: $n/5';
  }

  @override
  String historyFeelingAfter(Object feeling) {
    return 'Sensazione dopo: $feeling';
  }

  @override
  String get historyCombosUsed => 'Combinazioni usate';

  @override
  String get historyDeleteSession => 'Elimina sessione';

  @override
  String get historyDeleteMsg =>
      'Rimuovere questa sessione dallo storico? L\'operazione è irreversibile.';

  @override
  String get historySessionDeleted => 'Sessione eliminata';

  @override
  String get historyMinDuration => 'La durata deve essere almeno 1 minuto';

  @override
  String get historySessionLogged => 'Sessione registrata';

  @override
  String get historyNameOptional => 'Nome (facoltativo)';

  @override
  String historyRpeLoad(Object n) {
    return 'RPE — carico $n';
  }

  @override
  String get historyDistance => 'Distanza (km, facoltativa)';

  @override
  String get historyExercises => 'Esercizi';

  @override
  String get historyAdd => 'Aggiungi';

  @override
  String get historyExercisePlaceholder => 'Esercizio';

  @override
  String get historySets => 'serie';

  @override
  String get historyReps => 'rip';

  @override
  String get historyKg => 'kg';

  @override
  String get historyRemoveExercise => 'Rimuovi esercizio';

  @override
  String get historyNoExercises =>
      'Nessun esercizio aggiunto: la sessione verrà registrata solo per durata.';

  @override
  String get historyNotes => 'Note (facoltative)';

  @override
  String get historySaveSession => 'Salva sessione';

  @override
  String get statsTitle => 'Statistiche';

  @override
  String get statsEmpty =>
      'Ancora nessuno storico. Termina una sessione e le tue statistiche compariranno qui.';

  @override
  String get stats7days => '7 giorni';

  @override
  String get stats30days => '30 giorni';

  @override
  String get statsAllTime => 'Tutto';

  @override
  String get statsSessions => 'Sessioni';

  @override
  String get statsTrainingTime => 'Tempo di allenamento';

  @override
  String get statsRounds => 'Round';

  @override
  String get statsWorkTime => 'Tempo di lavoro';

  @override
  String get statsTrainingLoad => 'Carico di allenamento';

  @override
  String get statsWeeklyLoad => 'Carico settimanale';

  @override
  String get statsMonthlyLoad => 'Carico mensile';

  @override
  String get statsLoadNote =>
      'Carico = durata × RPE. Una stima semplice, non un indicatore medico.';

  @override
  String get statsConsistency => 'Costanza';

  @override
  String get statsCurrentStreak => 'Serie attuale';

  @override
  String get statsLongestStreak => 'Serie più lunga';

  @override
  String get statsSessionsPerWeek => 'Sessioni / settimana';

  @override
  String get statsHeavyBag => 'Sacco pesante';

  @override
  String get statsBagSessions => 'Sessioni al sacco';

  @override
  String get statsBagRounds => 'Round al sacco';

  @override
  String get statsBagTime => 'Tempo al sacco';

  @override
  String get statsMostUsed => 'Combinazioni più usate';

  @override
  String get statsMostUsedEmpty =>
      'Completa sessioni con combinazioni per vedere l\'uso.';

  @override
  String get statsTechFreq => 'Frequenza tecniche';

  @override
  String get statsTechEmpty => 'Ancora nessun dato sulle tecniche.';

  @override
  String get statsWeeklyOverview => 'Riepilogo settimanale';

  @override
  String get statsThisWeek => 'Questa settimana';

  @override
  String get statsLastWeek => 'Scorsa settimana';

  @override
  String statsSessionsLine(Object n, Object time, Object load) {
    return '$n sessioni · $time · carico $load';
  }

  @override
  String get statsPlan => 'Pianifica';

  @override
  String get statsPlanSession => 'Pianifica una sessione';

  @override
  String get statsLabelOptional => 'Etichetta (facoltativa)';

  @override
  String get statsPlannedMinutes => 'Minuti previsti';

  @override
  String get statsAddToWeek => 'Aggiungi alla settimana';

  @override
  String get statsTogglePlan => 'Attiva/disattiva sessione pianificata';

  @override
  String get statsDeletePlan => 'Elimina piano';

  @override
  String get statsPrevWeek => 'Settimana precedente';

  @override
  String get statsNextWeek => 'Settimana successiva';

  @override
  String get completeSelectRpe => 'Seleziona prima un RPE';

  @override
  String get completeSaved => 'Sessione salvata';

  @override
  String get completeTitle => 'Allenamento completato';

  @override
  String get completeRounds => 'Round';

  @override
  String get completeEstSession => 'Sessione stimata';

  @override
  String get completeWork => 'Lavoro';

  @override
  String get completeRest => 'Riposo';

  @override
  String get completeHowHard => 'Quanto è stato duro?';

  @override
  String get completeRpe => 'RPE —';

  @override
  String completeLoadApprox(Object n) {
    return 'Carico di allenamento ≈ $n';
  }

  @override
  String get completeEnergyBefore => 'Energia prima (facoltativa)';

  @override
  String get completeFeelingAfter => 'Sensazione dopo (facoltativa)';

  @override
  String get completeNotes => 'Note (facoltative)';

  @override
  String get completeNotesPlaceholder => 'Combinazioni rapide, fiato ok…';

  @override
  String get completeDiscard => 'Scarta';

  @override
  String get completeSaveSession => 'Salva sessione';

  @override
  String get completeDiscardTitle => 'Scarta sessione';

  @override
  String get completeDiscardMsg =>
      'Scartare questa sessione? Non comparirà nello storico.';

  @override
  String get sessionNoRounds => 'NESSUN ROUND';

  @override
  String sessionNRounds(Object n) {
    return '$n ROUND';
  }

  @override
  String get sessionRest => 'RIPOSO';

  @override
  String get sessionDeletedCombo => 'COMBINAZIONE ELIMINATA';

  @override
  String get sessionUnknown => 'Sconosciuto';

  @override
  String get pushupsTitle => 'Flessioni';

  @override
  String get pushupsSub => 'Contatore automatico con la fotocamera';

  @override
  String get pushupsHint =>
      'Posiziona il telefono a terra con la fotocamera frontale rivolta verso l\'alto e scendi sopra di lui: ogni flessione viene contata automaticamente.';

  @override
  String get pushupsName => 'Flessioni';

  @override
  String get pushupsExercise => 'Flessioni';

  @override
  String get pushupsCount => 'flessioni';

  @override
  String get pushupsDetecting => 'Rilevamento attivo';

  @override
  String get pushupsMoveCloser => 'Avvicinati o regola la sensibilità';

  @override
  String get pushupsSensitivity => 'Sensibilità';

  @override
  String get pushupsSave => 'Salva';

  @override
  String get pushupsStop => 'Ferma';

  @override
  String get pushupsSaved => 'Sessione di flessioni salvata';

  @override
  String get pushupsNothingToSave => 'Nessuna flessione da salvare';

  @override
  String get pushupsErrorPermission =>
      'Permesso fotocamera negato. Concedi l\'accesso alla fotocamera nelle impostazioni del browser.';

  @override
  String get pushupsErrorNoCamera => 'Nessuna fotocamera trovata.';

  @override
  String get pushupsErrorGeneric => 'Impossibile avviare la fotocamera.';

  @override
  String get builderAddBlock => 'Aggiungi blocco';

  @override
  String get builderBlockType => 'Tipo di blocco';

  @override
  String get builderSeries => 'Serie';

  @override
  String get builderChooseRoutine => 'Routine di stretching';

  @override
  String get navLibrary => 'Libreria';

  @override
  String get navProgress => 'Progressi';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsSound => 'Segnali sonori';

  @override
  String get settingsVibration => 'Vibrazione';

  @override
  String get settingsPrep => 'Countdown preparazione';

  @override
  String get settingsPrepHint =>
      'Parte automaticamente all\'avvio della sessione';

  @override
  String get trainPresets => 'Preset';

  @override
  String get trainCombosToggle => 'Allenati sulle combinazioni';

  @override
  String get trainTools => 'Strumenti extra';

  @override
  String get trainLastUsed => 'Ultimo uso';

  @override
  String get trainSeries => 'Serie';

  @override
  String get trainSwipeHint => 'Scorri per regolare';

  @override
  String get trainWorkoutSub => 'Esegui un allenamento salvato';

  @override
  String get trainWorkout => 'Workout';

  @override
  String get libraryTitle => 'Libreria';

  @override
  String get libraryBag => 'Sacco';

  @override
  String get libraryStretching => 'Stretching';

  @override
  String get progressTitle => 'Progressi';

  @override
  String get progressWeekSessions => 'Sessioni settimana';

  @override
  String get liveExitWorkout => 'Esci dall\'allenamento';

  @override
  String get builderGiveName => 'Dai un nome all\'allenamento';
}
