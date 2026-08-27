# Spec: Ristrutturazione UX/UI dell'app

Status: ready-for-agent

## Problem Statement

L'utente dell'app si trova davanti a un'interfaccia confusa e affollata:

- La pagina **Allenati** è caotica: sei modalità in accordion impilate una sull'altra, ognuna con la sua configurazione inline, più le impostazioni audio/vibrazione sepoltissime in fondo alla stessa pagina.
- Il concetto condiviso da tutte le modalità — **un timer di lavoro/pausa con numeri grandi** — non ha alcun risalto visivo: è frammentato tra dropdown e campini di settings ripetuti e striminziti.
- Le tab **Workout** e **Combo** gestiscono male i loro componenti e i loro spazi; lo spacing generale è fatto male e incoerente.
- **Storico** e **Stats** sono due tab separate che parlano della stessa cosa (come sta andando l'allenamento).
- La lingua si cambia solo da un selettore nell'header; le impostazioni non hanno una casa.
- L'app parte sempre in italiano anche se il sistema è in inglese.
- Usare l'app **mentre ci si allena** (mani sudate, attenzione sul timer) richiede troppa frizione.

## Solution

Ristrutturare l'app attorno al suo concetto centrale, il **Timer**, e semplificare l'information architecture:

1. **Quattro tab**: Allenati, Workout, Libreria, Progressi. Storico e Stats si fondono in Progressi; Combo diventa Libreria.
2. **Allenati = Timer**: un grande display di lavoro/pausa è il protagonista; sotto, chip di preset (Sacco 3'/1', Tabata 20"/10"×8, HIIT 40"/20", Libero…); un toggle opzionale per allenarsi sulle combinazioni; una sezione "Strumenti extra" che ospita il contatore push-up (futuri tool si aggiungeranno lì).
3. **Workout = sequenza di Blocchi**: un workout è una lista ordinata di parti eterogenee (round al sacco con combo opzionali, circuito tabata, aerobico, stretching, libero) ognuna con i propri tempi — es. "10×30" senza pausa → 3×1'30"+45" pausa → tabata circuito → sparring → stretching".
4. **Libreria**: liste ordinate di movimenti sia per il sacco sia per lo stretching; uno crea la propria routine di stretching una volta e la riusa nei workout.
5. **Impostazioni**: pagina dedicata raggiunta dall'ingranaggio nell'header (dove ora c'è il selettore lingua): Lingua, Audio, Vibrazione, Countdown preparazione.
6. **Localizzazione vera**: flutter_localizations + file .arb, lingua rilevata dal sistema al primo avvio con fallback italiano.
7. **Design system minimo**: token di spacing coerenti applicati a tutte le schermate.

## User Stories

1. As an app user, I want exactly four tabs (Allenati, Workout, Libreria, Progressi), so that I never wonder where to find something.
2. As an app user, I want the work/rest timer numbers to be huge and central on Allenati, so that I can read them at a glance during training.
3. As an app user, I want preset chips (Sacco 3'/1', Sacco 2'/1', Sacco 5'/1', Tabata 20"/10"×8, HIIT 40"/20", Libero) on Allenati, so that starting a session takes one tap.
4. As an app user, I want each mode to remember the last configuration I used, so that reopening Allenati proposes exactly what I trained last time.
5. As an app user, I want to optionally attach combinations to my timer session via a simple toggle, so that I can train combos only when I want to.
6. As an app user, I want to see the current combination displayed large with automatic progression through its techniques while the timer runs, so that I can follow it without touching the phone.
7. As an app user, I want the push-up counter available under a "Strumenti extra" section on Allenati, so that it doesn't compete visually with the timer.
8. As an app user, I want future non-timer tools to be grouped in the same "Strumenti extra" section, so that Allenati stays clean as the app grows.
9. As an app user, I want a single configuration screen per activity instead of repeated inline settings, so that setup happens once, before I start sweating.
10. As an app user, I want large thumb-friendly controls (pause, skip round, stop) on the live screen, so that I can operate them mid-round without precision.
11. As an app user, I want no settings dropdowns or fiddly fields on the live screen, so that nothing distracts me from the timer.
12. As an app user, I want a workout to be an ordered sequence of heterogeneous blocks, so that I can build a full session (bag rounds → tabata circuit → sparring → stretching) in one place.
13. As an app user, I want each block type to show icon, name and a compact time summary ("10×30""), so that I can read a workout's shape at a glance.
14. As an app user, I want to expand a block to edit its times, rest and combinations, so that tweaking one part doesn't mean re-entering everything.
15. As an app user, I want a Round block with configurable rounds × duration + pause and optional combinations, so that both bag work and sparring use the same simple building block.
16. As an app user, I want a Circuito block implementing tabata-style fixed short work/rest repetitions, so that conditioning slots into my workout.
17. As an app user, I want Aerobico and Stretching blocks with a continuous duration, so that warm-ups and cool-downs are first-class parts of a workout.
18. As an app user, I want a Free/Custom block with a generic duration, so that anything else still fits.
19. As an app user, I want a Stretching block to let me pick a saved routine from the Libreria, so that I always stretch the way I designed.
20. As an app user, I want a combined Stats+History page ("Progressi"), so that one tab tells me how I'm doing.
21. As an app user, I want summary cards at the top of Progressi (sessions this week, total minutes, streak), so that my pulse-check takes two seconds.
22. As an app user, I want a weekly/monthly volume chart in Progressi, so that I can spot trends.
23. As an app user, I want a filterable list of past sessions in Progressi, with detail on tap, so that I can revisit any specific workout.
24. As an app user, I want the combos tab renamed to "Libreria", so that the name stays honest when it holds more than boxing combos.
25. As an app user, I want a segmented filter in the Libreria between sacco content and stretching content, so that each discipline's lists are one tap away.
26. As an app user, I want to create a stretching routine with the same editor used for combos, so that I don't have to learn a second tool.
27. As an app user, I want stretching exercises available alongside punching techniques when building lists, so that routines are just ordered movements like combos.
28. As a user whose phone is set to English, I want the app to start in English on first launch, so that I don't have to dig through settings.
29. As an Italian user, I want Italian as fallback when my system locale isn't supported, so that the app never shows a half-translated mess.
30. As an app user, I want the language setting inside the Settings page, so that all preferences live in one predictable place.
31. As an app user, I want a gear icon in the header where the language switcher used to be, so that settings are reachable from anywhere without spending a tab.
32. As an app user, I want sound cues, vibration and prep countdown configured in Settings, so that they stop cluttering the training screens.
33. As an app user, I want consistent spacing across every screen, so that the app feels deliberate rather than assembled.
34. As an app user returning after the update, I accept that previously saved local workouts are discarded rather than migrated, so that the new model starts clean.
35. As an app user, I want the "sessione in corso" banner kept on Allenati when I have an unfinished session, so that I can resume or discard it explicitly.
36. As a developer, I want the glossary (CONTEXT.md) and the two structural ADRs written during implementation, so that future agents inherit the vocabulary and rationale.

## Implementation Decisions

- **Un solo motore parametrico.** I sei modi esistenti (heavy bag, combo workout, tabata, intervalli, free, push-up escluso) collassano in un unico tipo di configurazione parametrica (`LiveConfig`); i preset ne sono istanze salvate. Il push-up counter resta un tool separato e non entra nel motore.
- **Modello Workout a blocchi.** `Workout` diventa una lista ordinata di blocchi tipizzati: `Round` (N serie × durata + pausa, `combinationIds` opzionali — copre anche lo sparring come round senza combo), `Circuito` (logica tabata: work/rest fissi × ripetizioni), `Aerobico` (durata continua), `Stretching` (durata continua + riferimento a routine dalla libreria), `Libero` (durata generica).
- **Stretching riusa il modello delle combo.** Nuova categoria `stretching` su `TechniqueCategory` (accanto a boxing/kicks/knees/elbows/defense); una routine di stretching è una `Combination` di tecniche di stretching. Nessuna entità nuova, stesso editor. Vengono aggiunti esercizi di stretching seed bilingue.
- **Navigazione.** Bottom bar a quattro tab: `/` (Allenati), `/workouts`, `/library` (ex `/combos`), `/progress` (merge di storico e stats). Le route full-screen della sessione live restano fuori dalla shell. Nuova route `/settings` aperta dall'icona ingranaggio nell'header, dove oggi c'è il selettore IT/EN (che viene rimosso dall'header).
- **Contenuto Impostazioni:** Lingua, Audio, Vibrazione, Countdown preparazione. Niente altro per ora.
- **Localizzazione ufficiale.** Migrazione dalle ~400 chiavi della mappa manuale a `flutter_localizations` + `gen-l10n` con file `.arb` (it/en). Rilevamento del locale di sistema al primo avvio, fallback italiano. Tutti i riferimenti a `t(lang, key)` vengono sostituiti.
- **Design system minimo.** Token di spacing (scala xs/sm/md/lg/xl + raggio pill) aggiunti ai token tema esistenti; ogni schermata toccata dalle fasi successive viene ripassata per usarli.
- **Reset dei dati locali.** I blob vecchi in SharedPreferences non vengono migrati ma azzerati: nessun workout utente è importante. I seed (tecniche, combo) vengono rigenerati col nuovo modello.
- **Documentazione di dominio.** Creazione di `CONTEXT.md` con il glossario (Timer, Preset, Tool, Workout, Blocco, Round, Circuito, Libreria, Routine, Sessione) e due ADR: "Un solo timer parametrico invece dei modi" e "Workout come sequenza di blocchi".
- **Ordine di costruzione.** Fondamenta (token + i18n + reset) → modelli/motore → navigazione → schermate (Allenati, Live, Workout builder, Libreria, Progressi, Impostazioni) → documentazione.

## Testing Decisions

- Un buon test verifica solo comportamento esterno: cosa produce il sistema dato un input, mai dettagli interni di implementazione.
- **Seam principale (esistente, il più alto possibile):** la funzione pura `buildPlan(config, techniques, combos) → Plan`. Ogni nuova funzionalità temporale deve compilarsi a una configurazione parametrica e viene testata qui: preset del timer unificato e compilazione dei blocchi workout verificano le segmenti prep/lavoro/pausa risultanti. Prior art: `test/engine_test.dart`.
- **Seam secondario (esistente):** widget test di fumo che pompano l'app e navigano le tab verificando che le nuove schermate (Allenati, Libreria, Progressi, Impostazioni, builder workout) si costruiscono senza errori. Prior art: `test/smoke_test.dart`.
- Nessun nuovo seam: la logica vive tutta nel motore puro, la UI si testa solo a livello di fumo.
- `flutter analyze` pulito è condizione di completamento di ogni fase.

## Out of Scope

- Migrazione dei workout salvati col vecchio modello (i dati locali vengono azzerati).
- Modifica dei tempi al volo durante la sessione live (±15" sul round corrente): nice-to-have rimandato.
- Nuovi strumenti oltre al push-up counter (la sezione esiste, il contenuto no).
- Tema chiaro/scuro o personalizzazione grafica oltre ai token di spacing.
- Sync cloud, account, condivisione workout.
- Metriche statistiche nuove oltre a quelle già esistenti (il merge Progressi riorganizza, non estende).
- Traduzioni in lingue ulteriori rispetto a italiano/inglese.

## Further Notes

- La decisione "stretching come Combination di tecniche stretching" era la raccomandazione dell'agente, accolta implicitamente dall'utente insieme alla scelta del nome "Libreria": se in implementazione emergesse che serve un'entità separata, fermarsi e rigrillare prima di procedere.
- L'esempio canonico dell'utente da usare come test di accettazione del builder: "10 round × 30" senza pausa, poi 3×1'30"+45" di pausa, poi un tabata per il circuito, poi sparring, poi stretching".
- Il lavoro è pensato per essere spezzato in ticket indipendenti seguendo l'ordine di costruzione indicato nelle Implementation Decisions.
