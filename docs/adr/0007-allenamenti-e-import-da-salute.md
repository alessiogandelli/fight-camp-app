# ADR 0007: Allenamenti e import da Apple Salute

## Status

Accepted (implemented; enriched with effort, distance and zones)

## Context

L'app registrava ogni pezzo di allenamento come sessione indipendente: riscaldamento, sacco e stretching nella stessa serata contavano come tre sessioni in Progressi. Il `CONTEXT.md` già dice che «un allenamento reale è spesso più Workout eseguiti in successione», ma il modello dati non aveva un modo per rappresentare quel "di più".

In parallelo, l'utente voleva importare automaticamente da Apple Salute le corse e gli allenamenti registrati da Apple Watch o da altre app. Il rischio immediato era il doppio conteggio: la stessa serata esiste già in Salute come **un** workout e nell'app come **tre** sessioni.

## Decision

### 1. L'unità di lettura è l'Allenamento

Un **Allenamento** è un insieme di sessioni ravvicinate (distanza fra la fine di una e l'inizio della successiva ≤ **15 minuti**) e/o coperte dallo stesso workout di Salute. Le sessioni che lo compongono condividono un `groupId` (`SessionRecord.groupId`); una sessione senza `groupId` è un allenamento a sé.

- L'aggregazione è **al confine di lettura** (`lib/training/training.dart`), non una nuova entità persistita: `trainingsOf(sessions, links)` produce gli allenamenti, `trainingCount(sessions)` il conteggio.
- Le statistiche continuano a sommare le sessioni membro (durata, round, carico, tecniche) ma **contano** gli allenamenti. Il conteggio cambia anche per lo storico già registrato, per scelta esplicita: la migrazione storage v9 assegna i `groupId`.
- Le nuove sessioni ricevono il gruppo della sessione più vicina entro 15 minuti quando vengono salvate (`AppStore.addSession`).

### 2. I workout di Salute sono link, non sessioni

Un workout di Salute può coprire più sessioni, quindi l'UUID non può stare sulla sessione. `HealthLink` (in `AppData.healthLinks`) porta UUID, intervallo, attività, sorgente, distanza, calorie e riassunto dei battiti; il `groupId` lo lega all'allenamento.

Regola di import (`lib/health/health_import.dart`, puro e testabile):

- workout senza sessioni appartenenti → diventa **una** sessione `source: 'health'` con il proprio gruppo;
- workout che si sovrappone per ≥50% del più breve fra sessione e workout (minimo 2 minuti) → si **allega** al suo gruppo, nessuna sessione nuova;
- workout che copre sessioni di gruppi diversi → i gruppi si **fondono**: il workout è la prova che era un unico allenamento;
- stesso UUID già importato, o workout che duplica un altro (stesso inizio ±10 min e sovrapposizione ≥50%) → saltato.

### 3. Battiti

Media e massimo si calcolano dai campioni `HEART_RATE` nell'intervallo del workout: sull'allenamento (pesati sulla durata) e su ogni sessione coperta. La serie temporale è ridotta a bucket da 10 secondi e salvata **su file** (`Application Support/health/<uuid>.json`), non dentro il blob SharedPreferences, che altrimenti crescerebbe di megabyte e verrebbe riscritto a ogni modifica.

### 4. Sola lettura, iOS

L'app non scrive mai su Salute (nessun `NSHealthUpdateUsageDescription`, solo `NSHealthShareUsageDescription` e l'entitlement HealthKit). Sync automatica all'avvio/ritorno in foreground, al massimo una volta l'ora e solo se attivata; import manuale da Impostazioni con finestra di 30 giorni al primo giro. Il primo avvio include una slide di onboarding che chiede di collegare Apple Salute, attiva la sync e importa subito la prima finestra.

### 5. Effort, distanza e carico

Oltre ai dati del plugin `health`, un canale Swift read-only legge:

- `workoutEffortScore` e, in fallback, `estimatedWorkoutEffortScore` (iOS 18+);
- i campioni `distanceWalkingRunning` associati al workout, usati per gli split;
- l'ultima `restingHeartRate`, solo come suggerimento per le zone Karvonen.

L'effort Apple è trattato come RPE 1–10: per un workout solo Salute diventa `rpe` e `load = minuti × effort`; se il workout è agganciato a sessioni Fight Camp, l'effort viene applicato solo alle sessioni senza RPE manuale. Questo rende la card Load popolata anche per gli import, senza sovrascrivere le valutazioni dell'utente. Un backfill una tantum di 90 giorni arricchisce i workout già importati.

I campioni di distanza sono salvati su file accanto alla serie HR (`<uuid>.distance.json`); non viene salvata la posizione GPS. Gli split sono calcolati al volo e la sezione viene nascosta se la copertura è insufficiente.

### 6. Zone di frequenza

Le zone usano il metodo Karvonen con FC massima e FC a riposo confermate dall'utente in Impostazioni. L'app suggerisce il massimo osservato nelle serie HR e l'ultima resting HR importata, ma non applica automaticamente la formula 220−età. Le zone native di HealthKit (iOS 27 / SDK 27) non sono ancora compilabili con Xcode 26.2 e verranno usate quando disponibili.

### 7. Timeline dei battiti e pezzi dichiarati

La scheda Allenamento disegna le fasce dei pezzi (sessioni, workout Salute e pezzi dichiarati) dietro la curva HR, tutte sullo stesso clock che parte dall'inizio dell'Allenamento. I buchi fra due sessioni possono essere dichiarati dall'utente come **pausa** o **esercizio senza timer** (`TrainingSegment`, storage v10): i pezzi entrano nella durata dell'Allenamento, gli esercizi anche nel mix per tipo. Il ritmo, calcolato dai campioni di distanza, è tracciato nello stesso grafico su un secondo asse invertito (più veloce in alto).

## Consequences

- Progressi e Storico mostrano un allenamento invece di N sessioni; i conteggi storici diminuiscono (es. 3 → 1) senza perdere durata o carico.
- HealthKit non rivela se la lettura è stata negata: zero workout non significa "nessun allenamento". L'UI rimanda a Impostazioni › Salute › Accesso dati, non a un messaggio di assenza dati.
- La sync richiede iPhone sbloccato e app in foreground; niente background delivery in v1.
- Gli allenamenti importati senza RPE né effort hanno carico 0 e non entrano nella media del carico: la UI mostra la copertura e "dati insufficienti" invece di una percentuale fuorviante.
- Android/Health Connect: il `HealthSource` è un'interfaccia, quindi il supporto è un'implementazione in più (manifest e permessi), non un refactor.
- Il guscio di aggregazione rende banale, in futuro, scrivere le sessioni Fight Camp su Salute (chiudere gli anelli) senza toccare il modello.
