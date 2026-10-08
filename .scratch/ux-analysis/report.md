# Analisi UX — Fight Camp (iOS)

Data: 2026-09-16 · Build: `1.3.0+9` (`com.fightcamp`) · HEAD `ec515ea`
Metodo: guida dell'app sull'iPhone 17 Pro via **Orca emulator** (`attach` + `tap` + `gesture` + `ax`) con cattura frame dallo stream MJPEG.

## Ambiente e metodo

| Voce | Valore |
| --- | --- |
| Device | iPhone 17 Pro, iOS 26.2, udid `279EA608-FA94-4CE5-BBAB-A22263856C0F` |
| Schermo logico | **402 × 874 pt** (derivato: capture 1206 × 2622 px = 3×, `NavigationBar` dichiarata `height: 64` in `lib/main.dart:218`) |
| Avvio | `xcrun simctl launch … com.fightcamp` (Orca non ha un verbo `launch` iOS: `install/launch/permissions/logcat` sono Android-only) |
| Input | `orca emulator tap <x> <y>` con coordinate normalizzate 0..1, origine in alto a sinistra |
| Prove visuali | `ffmpeg` su `http://127.0.0.1:3100/stream.mjpeg`, in `shots/` |
| Prove semantica | `orca emulator ax --json` → albero accessibilità con frame normalizzati |
| Lingua app | `it` (preferenza utente); locale simulatore `en_IT` |
| Stato dati | dati seed preesistenti (6 workout, 9 combo, 5 piani, 1 sessione `CORSA`) — **non modificati** |

### Limiti dichiarati

1. **Stato non resettato** su richiesta: onboarding visto tramite la voce "Come funziona" (`lib/pages/settings_page.dart:152`), non da first-run reale. Gli empty state di app appena installata non sono stati osservati direttamente.
2. **`Complete` non verificata a schermo**: raggiungerla avrebbe registrato una Sessione. Analizzata solo staticamente da `lib/pages/complete_page.dart`.
3. **Audio, vibrazione e haptics non osservabili** dallo stream.
4. `orca emulator type` invia **solo US-ASCII**: impossibile digitare testo accentato. I campi di testo non sono stati esercitati.
5. L'albero `ax` contiene nodi con frame `0×0` (fuori schermo / non layoutati): i valori di quei nodi non sono stati usati come prova.
6. Il **push-up counter** non è valutabile nel simulatore (nessuna camera): il riquadro di anteprima resta vuoto.
7. La ribbon `DEBUG` è della build di debug, non un difetto dell'app.
8. Sessione eseguita su **una sola** configurazione (13 round × 3'00" / 1'35", 5 combo) per non alterare i dati.

---

## Quadro d'insieme

La UI è visivamente coerente, curata e con una gerarchia forte: il **Live** è la schermata migliore dell'app (timer enorme, combo leggibile a distanza, controlli grandi 72–108 pt, zero impostazioni). I problemi si concentrano in tre aree, in ordine di impatto sull'utente reale:

1. **Ergonomia in palestra**: quasi ogni azione secondaria è sotto i 44 pt (`−/+` 28–32 pt, chip `AVVIA` nelle liste 36 pt, `duplica` 36 pt, gear 38 pt), le FAB coprono contenuto reale delle card, e lo scrubber di Lavoro/Riposo non si riconosce come trascinabile. Mani sudate, telefono a terra, poca luce, fretta: è l'utente che si allena.
2. **Dati e copy falsi o incoerenti**: Progressi scrive "1 giorni", mostra `↓100%` con volume zero, disegna un picco nel grafico con `0 min`; lo Storico perde la data; il formato tempo cambia tra `0:30`, `00:30` e `03:00`; restano termini legacy da "modalità separate" che `CONTEXT.md` dichiara inesistenti.
3. **Accessibilità tecnica**: solo un sottoinsieme di questa area serve un utente non vedente (ruoli VoiceOver, etichette dei comandi Live, alternative ai grafici). La parte che conta per tutti — stato di selezione invisibile su chip e checkbox, header che sparisce su 3 tab — è già coperta dai punti sopra, e la radice è comune: controlli custom con `GestureDetector` (`lib/ui/widgets.dart:97`) senza layer semantico. Dettaglio in "Accessibilità: quanto conta davvero".
4. **Drift tra specifiche e implementazione**: `ux-restructure/spec.md` chiede un modello a **blocchi** (Round/Circuito/Aerobico/Stretching/Libero) e le **preset chip** su Allenati; l'implementazione ha una configurazione singola uniforme (ADR 0003) e nessun preset. Il repo documenta due prodotti diversi.

---

## Finding

Severità: **B** bloccante · **A** alta · **M** media · **b** bassa.

### Accessibilità

| ID | Sev | Finding | Evidenza |
| --- | --- | --- | --- |
| UX-01 | B | **Nessuna semantica in tutta l'app.** 0 occorrenze di `Semantics`/`semanticsLabel`/`MergeSemantics`; i bottoni sono `GestureDetector` (`lib/ui/widgets.dart:97`) invece di `InkWell`/`Semantics`. VoiceOver annuncia il testo ma non che è toccabile: solo bottom nav, `SALTA`, `Nessuna`, `VEDI TUTTO`, `Annulla/ESCI` e le FAB espongono `role=button`. | `grep -rln "Semantics(" lib/` → vuoto; `ax/01-train.json`… |
| UX-02 | B | **34 controlli senza etichetta** nelle schermate osservate. Elenco misure (pt): Allenati 7 (`gear` 38×38, `−/+` lavoro/riposo 30×30, `−/+` round 28×28); Workout 4 (`duplica` 36×36); Libreria 3 (`duplica` 36×36); Progressi 7 (pallini giorni 43×26); Storico 1 (`back` 36×36); Impostazioni 4 (`back` 36×36, switch audio 44×26, `−/+` countdown 32×32); Builder 7 (chiudi 36×36, 6 stepper 32×32); Picker combo 1 (chiudi 36×36). | `shots/01-train.jpg`, `09-settings.jpg`, `17-workout-builder.jpg` |
| UX-03 | A | **Tap target sotto i 44 pt** su quasi tutte le azioni secondarie: `−/+` 28–32 pt, `duplica` 36 pt, `gear` 38 pt, `AVVIA` nelle card 36 pt (`BtnSize.sm` = 36, `lib/ui/widgets.dart:70-71`). Sull'Allenati 7 controlli su 7 sono sotto soglia. | `shots/01-train.jpg`, `02-workouts.jpg`, `03-library.jpg` |
| UX-04 | A | **I 3 controlli del Live sono senza etichetta.** Skip-back 72×72, pausa/play 108×108, skip-forward 72×72 pt: dimensione corretta, ma `label=""`. Sono i comandi usati con le mani sudate: un utente non vedente non può pausare né saltare un round. | `ax/12-live-work.json` |
| UX-05 | A | **Le barre di Lavoro/Riposo su Allenati sono scrubber drag senza semantica.** `lib/pages/train_page.dart:716-721` usa `onHorizontalDragUpdate` su un widget custom: nell'albero `ax` non c'è né `slider`, né etichetta, né valore. Modificano la durata dell'allenamento in modo totalmente silenzioso per le tecnologie assistive (e non c'è feedback di affordance per nessuno: sembrano barre di progresso). | `ax/01-train.json` (nessun nodo slider), `train_page.dart:716` |
| UX-06 | A | **Le checkbox del picker combinazioni non esistono come controlli.** I quadratini sono visibili (`shots/18-combo-picker.jpg`) ma le righe sono `role=text` senza stato: impossibile sapere quali combo sono selezionate o attivarle con VoiceOver. Idem per chip filtro, segmented `SACCO/STRETCHING/TOOL`, `SETTIMANA/4 SETTIMANE/TUTTO`: nessun trait di selezione. | `ax/18-combo-picker.json`, `ax/03-library.json` |
| UX-07 | M | **Albero accessibilità incoerente tra tab**: l'header con logo e ingranaggio è presente nell'AX solo sulla home e **del tutto assente** su Workout/Libreria/Progressi (0 occorrenze di "FIGHT CAMP"), pur essendo visibile a schermo. Conseguenza: dalle altre tab le **Impostazioni non sono raggiungibili** con VoiceOver. | `ax/01-train.json` = 1, `ax/02-workouts.json` = 0, `ax/03-library.json` = 0, `ax/06-progress.json` = 0 |
| UX-08 | M | **Campi di testo senza etichetta associata**: `NOME ALLENAMENTO` (`value="CIRCUITO COPY"`), `0:30`, `0:10` sono `text field` con `label=""`; l'etichetta è un nodo separato. Anche lo slider `SENSIBILITÀ` ha `label=""` e solo `value="50%"`. | `ax/17-workout-builder.json`, `ax/05-library-tool.json` |
| UX-09 | M | **Back button senza etichetta** in Storico e Impostazioni (36×36, `label=""`). | `ax/08-history.json`, `ax/09-settings.json` |
| UX-10 | M | **Nessun dato accessibile per il grafico volume** e per i pallini di COSTANZA: i 7 marker giornalieri sono nodi vuoti 43×26 pt, la serie settimanale è solo disegnata. Un utente non vedente non riceve alcuna informazione su costanza e volume. | `ax/06-progress.json` |

### Contrasto (calcolato dai token di `lib/ui/theme.dart`)

| Coppia | Rapporto | Esito |
| --- | --- | --- |
| `ink #F4F4F1` su `accent #FF4D4D` | **2.97** | ❌ fallisce anche per testo grande (3:1) |
| `white #FFFFFF` su `accent` (label dei bottoni primary, `widgets.dart:60`) | **3.27** | ⚠️ passa solo come "testo grande"; a 11–12.5 px (`sm`/`md`) **fallisce AA 4.5** |
| `line #26262E` su `panel #121216` | **1.24** | ❌ bordi, separatori e tracce delle progress bar quasi invisibili (serve 3:1 per componenti UI) |
| `mut #9A9AA5` su `panel2 #1A1A20` | 6.22 | ✅ |
| `accent` su `bg` | 6.08 | ✅ |
| `warn #FFB224` su `accent` | 1.81 | ❌ (combinazione da evitare) |

| ID | Sev | Finding |
| --- | --- | --- |
| UX-11 | M | Le etichette dei bottoni pieni rossi sono a **3.27:1**: sopra la soglia solo per testo grande. Le chip `AVVIA` da 36 pt usano 11 px → sotto soglia. |
| UX-12 | M | `AppColors.line` su `panel` a **1.24:1**: i bordi delle card e le tracce delle progress bar (`lib/pages/stats_page.dart:172`, "OBIETTIVO SETTIMANALE") non si distinguono dal fondo. È la stessa causa del difetto #2 di `ui-fixes`: la spec prescriveva `AppColors.line` al posto di `bg`, ma il token scelto resta insufficiente. |

### Contenuti, dati e copy

| ID | Sev | Finding | Evidenza |
| --- | --- | --- | --- |
| UX-13 | A | **"1 giorni"**: non esiste pluralizzazione per l'unità. `lib/pages/stats_page.dart:936` passa `l.progressDaysUnit` = `"giorni"` (stringa semplice, `app_it.arb:394`) mentre altrove l'app usa già `plural` (`progressActiveDays`, `app_it.arb:373`). | `shots/07-progress-scrolled.jpg` ("1 giorni" in RECORD PERSONALI) |
| UX-14 | A | **Formato tempo incoerente** per lo stesso concetto: `0:30` nel builder (`TimeField._fmt`, `lib/ui/widgets.dart:791`), `00:30` nelle card lista (`fmtClock`, `lib/lib/format.dart:6`), `03:00`/`02:52` nel Live. | `shots/17-workout-builder.jpg` vs `02-workouts.jpg` vs `12-live-work.jpg` |
| UX-15 | A | **Progressi mente sullo stato zero**: con `0 min` di volume mostra `↓100% vs periodo precedente` (giallo) **e** contemporaneamente `—` su ROUND, SESSIONI, TEMPO DI LAVORO, COMBINAZIONI. Due convenzioni diverse per lo stesso "nessun dato". | `shots/06-progress.jpg`, `07-progress-scrolled.jpg` |
| UX-16 | A | **Picco fantasma nel grafico volume** a `0 min` totali: la serie disegna un picco evidente in corrispondenza di `7/9`. | `shots/06-progress.jpg` |
| UX-17 | M | **"ADESSO" va a capo in "ADES / SO"** nella card COSTANZA (etichetta stretta a 2 righe). | `shots/06-progress.jpg` |
| UX-18 | M | **Lo storico perde la data**: le sessioni mostrano solo il giorno della settimana (`SABATO · 30:00`). Due sessioni in sabati diversi sono indistinguibili; `dayLabel` (`format.dart:41`) preferisce il weekday entro 7 giorni e mostra la data solo oltre. | `shots/08-history.jpg`, `07-progress-scrolled.jpg` |
| UX-19 | A | **Il filtro date dello Storico mostra due dropdown identici "Tutti"** sotto le etichette `DA` / `A`: non c'è modo di capire che è un intervallo di date, né quale sia il valore. | `shots/08-history.jpg` |
| UX-20 | A | **Termini legacy da "modalità" nello Storico**: `Sacco pesante`, `Muay Thai`, `Tabata`, `Intervalli`, `Forza`, `Condizionamento` come filtri di tipo attività, mentre `CONTEXT.md` dichiara esplicitamente *"non esistono modi… Timer ≠ Modo"* e il builder chiama lo stesso campo `⚡ Intervalli`. | `shots/08-history.jpg`, `shots/17-workout-builder.jpg` |
| UX-21 | M | **Terminologia incoerente**: la tab si chiama `WORKOUT` ma l'overline della pagina dice `ALLENAMENTI`; l'onboarding dice `SERIE ATTUALE` / "Serie, volume e storico" mentre ovunque altro si dice `ROUND`. | `shots/02-workouts.jpg`, `shots/22-onboarding-3.jpg` |
| UX-22 | M | **Onboarding con nomi tecnici in inglese** in un'interfaccia italiana: la slide 2 hardcoda `['JAB','CROSS','HOOK','UPPERCUT']` (`lib/pages/onboarding_page.dart:412`) mentre le tecniche reali sono `JAB`, `DIRETTO`, `GANCIO SX`, `MONTANTE DX`. | `shots/21-onboarding-2.jpg` |
| UX-23 | b | **Le illustrazioni dell'onboarding non corrispondono alla UI reale**: la slide 1 promette un timer **circolare ad anello** (il Live usa un numero gigante + barra lineare), la slide 3 promette un **grafico a barre** e una card a fiamma `12 SERIE ATTUALE` (Progressi ha un grafico ad area e una card `COSTANZA` a pallini). | `shots/20-onboarding-1.jpg`, `22-onboarding-3.jpg` vs `12-live-work.jpg`, `06-progress.jpg` |
| UX-24 | A | **Impostazioni manca della voce Vibrazione** prevista dalla spec (Lingua, Audio, Vibrazione, Countdown): la UI espone solo `Lingua`, `SEGNALI SONORI`, `COUNTDOWN PREPARAZIONE`. Il dato `settings.vibration: true` esiste già nel blob persistito. Anche il nome `SEGNALI SONORI` copre solo l'audio. | `shots/09-settings.jpg`; `ax/09-settings.json` |
| UX-25 | M | **Progressi è una pagina di empty state impilati**: pulse con 0 sessioni, COSTANZA 0 giorni, PROGRESSO con 0/—, "COMBINAZIONI PIÙ USATE" vuota, RECORD PERSONALI (30 min / 1 giorni), "Ancora nessun dato sulle tecniche", STORICO con 1 riga. Con quasi nessun dato la pagina resta lunghissima. | `shots/06-progress.jpg`, `07-progress-scrolled.jpg` |
| UX-26 | M | **Tool push-up: anteprima camera vuota senza spiegazione.** Un rettangolo vuoto con icona "video off" e nessun testo ("camera non disponibile / permesso negato"). La descrizione sopra spiega solo il posizionamento del telefono. | `shots/05-library-tool.jpg` |
| UX-27 | M | **`AZZERA / AVVIA / SALVA` hanno lo stesso peso visivo di AVVIA** e `SALVA` è l'unico pieno (accent): la gerarchia suggerisce che l'azione primaria sia salvare, non avviare. `AZZERA` (distruttiva) pesa come `AVVIA`. | `shots/05-library-tool.jpg` |
| UX-28 | b | **I nomi degli esercizi di stretching non sono omogenei**: `FIGURE 4 SINISTRO` / `FLESSORE ANCA SX` / `PANCAKE` / `FARFALLA` mescolano traduzione, abbreviazione e inglese. | `shots/04-library-stretching.jpg` |
| UX-29 | b | **Il picker combinazioni mescola Combo e Routine**: include `FULL BODY STRETCH` (una routine di stretching) tra le combo, mentre esiste il campo dedicato `ROUTINE DI STRETCHING`. Il concetto di "Libreria di sacco" viene meno. | `ax/18-combo-picker.json` |
| UX-30 | b | **Due bundle installati sul simulatore**: `com.fightcamp` (build 9) e `com.fightcamp.fightCamp` (build 1). Artefatto d'ambiente, ma rende ambiguo quale app si sta ispezionando. | `xcrun simctl listapps …` |

### Layout e feedback

| ID | Sev | Finding | Evidenza |
| --- | --- | --- | --- |
| UX-31 | A | **La FAB copre contenuto reale**: in Libreria copre `MODIFICA >` della terza card, in Workout copre la card in fondo. La lista non riserva padding per la FAB+bottom bar. | `shots/03-library.jpg`, `02-workouts.jpg` |
| UX-32 | A | **Modali: coprono la bottom nav ma non l'header.** `ui-fixes` chiedeva che ogni modale coprisse header e bottom nav; il titolo/X non finiscono più dietro l'header (fix riuscito), ma `FIGHT CAMP` e l'ingranaggio restano visibili e cliccabili dietro lo scrim. Inoltre il footer del builder (`ANNULLA / SALVA / SALVA + AVVIA` su due righe) appare **appeso fuori dalla superficie dello sheet**, staccato dal corpo della modale. | `shots/17-workout-builder.jpg`, `18-combo-picker.jpg` |
| UX-33 | M | **Dialog di uscita senza gerarchia distruttiva**: `Annulla` e `ESCI` sono entrambi accent (rosso); l'azione distruttiva non è marcata e il "sicuro" sembra pericoloso. La copy alterna `Esci`, `ESCI`, `ESCI DALL'ALLENAMENTO`, `Uscire da questa sessione?`. | `shots/14-live-exit-dialog.jpg` |
| UX-34 | b | **Chip filtro tagliate senza affordance di scroll**: in Libreria l'ultima chip (`Ginoc…`) è tagliata dal bordo destro senza fade né indicazione che la riga scorre. | `shots/03-library.jpg` |
| UX-35 | b | **Icona fuorviante** in Impostazioni: `COME FUNZIONA` usa un cappello da laurea (guida/manuale) invece di info/aiuto. | `shots/09-settings.jpg` |
| UX-36 | b | **Timer in preparazione**: l'etichetta è gialla (`warn`) ma il numero grande resta bianco; il colore non accompagna il cambio di fase. | `shots/11-live-prep.jpg` |
| UX-37 | b | Il pulsante centrale del Live è **verde** (`AppColors.go`) anche quando significa **pausa** (`shots/12-live-work.jpg`); diventa rosso in pausa per riprendere (`13-live-paused.jpg`). Il verde viene semanticamente usato come "azione generica". | `shots/12-live-work.jpg` |

---

## Frizione: cosa serve davvero per i task chiave

| Task | Tap richiesti (osservati) | Note |
| --- | --- | --- |
| Avviare l'ultimo allenamento del sacco con combo | **1** (AVVIA) | ✅ La memoria dell'ultima configurazione funziona (`fight-camp:last-timer`). |
| Avviare una sessione *da zero* con tempi diversi | 4–8: `−/+` su lavoro e riposo, oppure drag sugli scrubber, poi AVVIA | ❌ **Mancano le preset chip** previste dalla spec (Sacco 3'/1', Tabata 20"/10"×8, HIIT, Libero): "iniziare in un tap" è vero solo per l'ultima configurazione. |
| Avviare un workout salvato | 1 (AVVIA sulla card) | ✅ ma la chip AVVIA è alta 36 pt, sotto soglia. |
| Capire a che punto sono dell'allenamento | 0 | ✅ `ROUND n DI m` + pallini di round + barra di fase, ottima lettura a distanza. |
| Mettere in pausa con le mani sudate | 1 | ✅ target 108×108 pt, ottimo. |
| Modificare un workout esistente | 1 (MODIFICA) + N nel builder | ✅ sheet con footer sticky. |
| Trovare una combo nella Libreria | 1 (tab) + 1 (segment) + eventuale filtro | ⚠️ ricerca presente; chip filtro per categoria *tecnica* applicate alle *combo* è una tassonomia ambigua. |
| Registrare una sessione manuale | 1 (FAB) + N nel form | non esercitato (avrebbe scritto dati). |
| Trovare una sessione passata | tab Progressi → VEDI TUTTO → riconoscere il giorno | ⚠️ senza data completa la ricerca è ambigua (UX-18). |

---

## Verifica di regressione sulle spec esistenti

### `.scratch/ux-restructure/spec.md`

| Story | Esito |
| --- | --- |
| 1 Quattro tab | ✅ Allenati / Workout / Libreria / Progressi |
| 2 Numeri timer enormi e centrali | ✅ (`02:52` a piena larghezza) |
| 3 Preset chip su Allenati | ❌ **assenti**: nessuna chip, solo l'ultima configurazione |
| 4 Ricorda l'ultima configurazione | ✅ |
| 5 Toggle opzionale per le combinazioni | ✅ card `Combinazioni` |
| 6 Combo corrente grande con progressione automatica | ✅ |
| 7/8 Push-up in "Strumenti extra" su Allenati | ⚠️ spostato in **Libreria → Tool**: `CONTEXT.md` (più recente) lo conferma, `spec.md` è rimasto indietro |
| 9 Una sola schermata di configurazione per attività | ✅ sheet builder |
| 10/11 Controlli grandi sul Live, nessuna impostazione | ✅ / ✅ |
| 12-19 Workout come **sequenza di blocchi** eterogenei (Round/Circuito/Aerobico/Stretching/Libero) | ❌ **non implementato**: il builder ha Lavoro/Riposo/Round uniformi + una Routine opzionale. `ADR 0003` ha superato `ADR 0002`, quindi il test di accettazione della spec ("10×30 → 3×1'30"+45" → tabata → sparring → stretching") **non è costruibile**. `spec.md` va aggiornato o marcato superato. |
| 20-23 Progressi unificata (pulse, grafico, lista filtrabile) | ✅ struttura, ma con i difetti UX-13/15/16/17/18/19/25 |
| 24-27 Libreria, segmented sacco/stretching, editor condiviso | ✅ |
| 28/29 Locale di sistema + fallback italiano | ✅ (lingua `it` persistita) |
| 30-32 Impostazioni con Lingua/Audio/Vibrazione/Countdown, gear nell'header | ⚠️ **Vibrazione assente** (UX-24); gear presente ma non accessibile (UX-02/07) |
| 33 Token di spacing coerenti | ✅ `AppSpacing` usato |
| 34 Reset dei dati locali | ✅ |
| 35 Banner "sessione in corso" su Allenati | ➖ non verificato (nessuna sessione attiva) |
| 36 Documentazione di dominio | ✅ `CONTEXT.md` + 4 ADR |

### `.scratch/ui-fixes/spec.md`

| # | Difetto | Esito |
| --- | --- | --- |
| 1 | Modali sotto la top bar | ⚠️ **parziale**: titolo e X non sono più coperti, ma l'header resta visibile dietro lo scrim (UX-32) |
| 2 | Card Progressi: etichette troncate, barra a colori sbagliati | ⚠️ card ristrutturata; restano traccia a basso contrasto (UX-12) e nuovi difetti di copy/dati (UX-13/15/16/17) |
| 3 | Toast con doppia sottolineatura | ➖ non verificato (nessun toast indotto) |
| 4 | Builder come sheet con footer sticky, niente tab switch | ✅ sheet + footer; ⚠️ footer visivamente staccato dalla superficie (UX-32) |
| 5 | Gradiente home sotto la status bar | ✅ nessun taglio netto: il glow rosso parte dal bordo superiore |

---

## Accessibilità: quanto conta davvero

Fight Camp è un'app di Muay Thai: un utente completamente non vedente che si allena al sacco è un caso marginale, e i finding di sola tecnologia assistiva non sono la priorità del prodotto. Vale però la pena separare due gruppi, perché **la causa è la stessa** e i due gruppi si risolvono insieme.

| Gruppo | Finding | Chi colpisce |
| --- | --- | --- |
| **A — impatta chiunque, in palestra** | UX-03 (tap target 28–38 pt), UX-31 (FAB sopra le card), UX-12 (tracce a 1.24:1), UX-11 (testo bianco su rosso a 3.27:1), UX-05 (scrubber senza affordance), UX-06 (nessuno stato di selezione visibile) | Mani sudate, telefono a terra, poca luce, fretta: l'utente reale |
| **B — solo tecnologie assistive** | UX-01 (ruoli), UX-02/04 (etichette), UX-07 (header), UX-09 (back), UX-10 (grafici), UX-08 (label dei campi) | VoiceOver / Switch Control |

Il gruppo A è un problema di prodotto; il gruppo B quasi non esiste per il pubblico target. **Ma la radice è comune**: controlli custom costruiti con `GestureDetector` (`lib/ui/widgets.dart:97`) e icone disegnate a mano, senza layer semantico. Portare quei controlli a ≥44 pt, etichettati e con stato di selezione visibile chiude il gruppo A e, di fatto, anche il gruppo B — quindi vale la pena farlo comunque, ordinato per impatto reale.

## Priorità consigliate

Ordinate per impatto sull'utente reale (gruppo A prima), non per gravità formale.

1. **UX-03 + UX-31 + UX-05** — target ≥ 44 pt ovunque (`−/+`, chip `AVVIA` nelle liste, `duplica`, gear), padding per le FAB perché non coprano le card, e affordance sullo scrubber di Lavoro/Riposo (sembra una barra di progresso, non si capisce che si trascina). Sono i tre difetti che l'utente incontra *ogni* sessione.
2. **UX-13 + UX-15 + UX-16** — un solo comportamento per "nessun dato" in Progressi, plurali corretti (`1 giorni`), niente picco nel grafico con `0 min`. Sono dati falsi: erodono la fiducia più di un problema grafico.
3. **UX-11 + UX-12** — contrasto: tracce/bordi a 1.24:1 e label dei bottoni pieni a 3.27:1. Si leggono solo al buio con luminosità al massimo.
4. **UX-24** — ripristinare la voce Vibrazione in Impostazioni: l'utente si allena guardando il sacco, non lo schermo.
5. **UX-20 + UX-21 + UX-22 + UX-18/19** — terminologia legacy (`modalità`, `serie`), data mancante nello Storico, due dropdown "Tutti" identici, nomi tecnici in inglese hardcoded nell'onboarding.
6. **UX-06 + UX-01/02/04/07** — stato di selezione visibile su chip/segmented/checkbox, poi ruoli ed etichette (che arrivano insieme ai fix sopra se i controlli diventano widget con semantica).
7. **Decisione di prodotto su `ux-restructure`** — o si implementano preset chip e modello a blocchi (come da spec), o si aggiornano spec e ADR per riflettere la configurazione singola: adesso il repo dice due cose diverse.

---

## Allegati

Le prove visive sono in `shots/` (frame 1206×2622 px, 3×): `01-train`, `02-workouts`, `03-library`, `04-library-stretching`, `05-library-tool`, `06-progress`, `07-progress-scrolled`, `08-history`, `09-settings`, `11-live-prep`, `12-live-work`, `13-live-paused`, `14-live-exit-dialog`, `17-workout-builder`, `18-combo-picker`, `20-onboarding-1`, `21-onboarding-2`, `22-onboarding-3`.

Riproduzione: `orca emulator attach "iPhone 17 Pro"` → `xcrun simctl launch 279EA608-FA94-4CE5-BBAB-A22263856C0F com.fightcamp` → `orca emulator tap <x> <y>` → `orca emulator ax --json`. Lo stato dell'app **non è stato alterato**: la sessione live è stata chiusa con "Esci" (scarta) e la lista sessioni contiene ancora solo `CORSA`.
