# Spec: Programmazione THAI — seed del docx

Status: done

## Problem Statement

Il club ha consegnato un documento (`data/combinazioni THAI.docx`, ~1170 righe) con il
programma completo: riscaldamento, cardio, circuiti di potenziamento, combinazioni
boxe-calci, sacco a coppie/singoli, colpitori, tecnica. L'app non contiene nulla di
tutto questo: le combo sono 20 finte ("COMBO 01"…), non esistono esercizi di
potenziamento né i relativi circuiti.

## Solution

Portare il contenuto del docx dentro l'app come **seed** (spedito con l'app), in italiano,
preservando i dati utente con una migrazione append-only.

1. **Nuova categoria `TechniqueCategory.conditioning`** ("Potenziamento") accanto alle 6
   esistenti.
2. **Tutte le combo del docx** (130 sequenze distinte) come `Combination`, con nome
   descrittivo dal contenuto. Include sequenze di colpi, padwork (PAO/FOCUS/SCUDO),
   drill (check-teep-knee) e ladder. Le notazioni numeriche (`1-2`, `1-2-3`, `1-10-1`,
   `2-4-6-8-10`) sono scariche di jab/diretto: collassate in un'unica voce.
3. **Esercizi di potenziamento** (~39 tecniche) e **circuiti a ripetizioni** (9 circuiti:
   WHOLE BODY 1/2, ABS+CHEST A/B, WHOLE BODY CARDIO 1/2, ABS CARDIO 1/2, LEG+ABS).
4. **Workout a intervalli** dal docx (CARDIO 1/2, SACCO A COPPIE, BOXE/SPALLE, WARM UP
   SACCO, SACCO SINGOLI, COMBINAZIONI BOXE-CALCI, WHOLE BODY CARDIO 1/2).
5. **Tutti e 9 i circuiti diventano Workout** in Allenati: i 2 a tempo mantengono i loro
   intervalli; i 7 a ripetizioni sono un **round continuo** (5:00 di default, modificabile)
   che elenca gli esercizi ×reps.
6. **Quarta sezione in Libreria**: Potenziamento, **catalogo in sola consultazione degli
   esercizi singoli** (come Stretching), con illustrazioni line-art.

## Implementation Decisions

- **Reps per riga, non sull'atomo.** `Combination` acquisisce `List<int?> reps` allineato
  a `techniqueIds`: la stessa tecnica può avere reps diverse in circuiti diversi
  (Crunch ×60 vs ×50). Le combo boxe non hanno reps (`toJson` omette la chiave).
- **Tipo workout category-aware.** Nuova funzione pura `deriveWorkoutType(w, combos, techniques)`:
  combo tutte di potenziamento → `WorkoutType.conditioning`. `Workout.type` (getter)
  resta per compatibilità; la UI usa `store.workoutTypeOf`.
- **Circuiti riusano `Combination`**, come le Routine (ADR 0004): nessuna nuova entità.
  `AppStore.isCircuit` identifica i circuiti (tutte le tecniche di categoria conditioning).
  La Libreria li **nasconde**: Potenziamento è un catalogo read-only di esercizi; i circuiti
  sono contenuto dei Workout (la card mostra esercizi ×reps).
- **Builder reps disponibile ma non esposto.** `showComboBuilderSheet(reps:, categoryFilter:)`
  e lo stepper reps restano nel builder per usi futuri; la Libreria non li richiama più.
- **Immagini line-art** in `assets/conditioning/` + `lib/lib/conditioning.dart`
  (`conditioningImageFor`), stesso stile degli SVG stretching.
- **Migrazione v8 append-only** (`storageVersion` 7→8): appende solo le entità con id non
  già presente. Idempotente, non tocca i dati utente.

## Testing Decisions

- Seam esistente `buildPlan`/`configFromWorkout`; nuovi test di integrità referenziale del
  seed in `test/thai_seed_test.dart` (id unici, riferimenti validi, categorie dei circuiti,
  round-trip JSON di `reps`, derivazione del tipo `conditioning`).
- Aggiornata la regression guard dei conteggi seed in `smoke_test.dart`/`train_timer_test.dart`.
- `flutter analyze` pulito e `flutter test` verde.

## Out of Scope

- Riscaldamento multi-parte (ADR 0003): se serve, va spezzato in workout separati.
- Drill guidati di tecnica base / blocco calcio / clinch, preparazione pro, sparring
  strutturato, planner settimanale a pagine.
- Traduzioni EN dei contenuti (restano italiani; le chiavi UI sono bilingue).
