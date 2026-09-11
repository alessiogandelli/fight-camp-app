# 05: Builder come bottom sheet con footer sticky

**What to build:** Workout, combo e routine di stretching si aprono come bottom sheet con i pulsanti Annulla e Salva sempre visibili in basso. Durante la modifica non c'è una transizione tra due pagine e non si può cambiare tab per errore.

**Blocked by:** 01 (il footer sticky riusa il contenitore modale con root navigator)

**Status:** done

- [x] `showWorkoutBuilderSheet` apre il builder workout come sheet; Salva/Annulla sticky
- [x] `showComboBuilderSheet` apre il builder combo come sheet; Salva/Annulla sticky
- [x] `showRoutineBuilderSheet` apre il builder routine come sheet; Salva/Annulla sticky
- [x] "Salva e avvia" dal workout salva, chiude lo sheet e avvia la sessione live (sotto la Row Annulla/Salva)
- [x] Le liste (Workout, Libreria) aprono gli sheet al tap sulla card e sulla FAB
- [x] Il picker combinazioni e la modale nuova tecnica annidata funzionano dentro lo sheet
- [x] Le route annidate `/workouts/new`, `/workouts/:id`, `/library/new`, `/library/:id`, `/library/routine/...` sono rimosse
- [x] `test/workout_builder_test.dart` aggiornato (apertura da lista)
- [x] `flutter analyze` pulito e test verdi (80/80, 2026-09-11)

## Comments
