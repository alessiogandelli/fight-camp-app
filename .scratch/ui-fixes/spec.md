# UI fixes — overlap, progress, toast, builder, gradient

## Problem Statement

Cinque difetti di UI rompono l'esperienza in punti visibili:

1. Il bottom sheet delle combinazioni (e in generale ogni modale) viene renderizzato **sotto la top bar**: il titolo dello sheet e la "X" finiscono dietro "FIGHT CAMP" e l'ingranaggio.
2. Nella card "Progressi" le tre metriche hanno etichette lunghe che vengono troncate e si toccano; la barra dell'obiettivo usa un colore più scuro del pannello e sembra un buco.
3. Le snackbar (il toast custom) mostrano una **doppia sottolineatura gialla** sotto il testo.
4. Aprendo un workout/combo c'è una **sovrapposizione di due pagine** durante la transizione, la bottom nav resta usabile e si può cambiare tab durante la modifica; Salva/Annulla stanno in fondo allo scroll.
5. Il **gradiente** della home parte sotto la status bar: si vede un bordo netto.

## Solution

1. Le modali usano il root navigator, così coprono header e bottom nav.
2. La pagina Progressi viene ristrutturata: in cima una pulse con streak settimanale e numero di allenamenti, poi le statistiche (con le combinazioni più allenate in evidenza) e in fondo lo storico.
3. Il toast viene reso dentro un `Material`, così non eredita più lo stile di fallback rosso/sottolineato.
4. I builder di workout, combo e routine diventano **bottom sheet** con footer sticky Annulla/Salva: niente transizione tra pagine, niente tab switch a metà edit.
5. Il gradiente della home estende sotto la status bar (nessun taglio del `SafeArea`).

## User Stories

1. Come utente che apre il selettore combinazioni, voglio vedere il titolo e la X sopra ogni altra chrome, così so cosa sto compilando.
2. Come utente su mobile, voglio che ogni modale copra header e bottom nav, così non ci sono sovrapposizioni.
3. Come utente, voglio che le snackbar siano pulite (testo leggibile, senza decorazioni strane), così capisco subito il messaggio.
4. Come utente della pagina Progressi, voglio vedere a colpo d'occhio la streak settimanale e quanti allenamenti ho fatto questa settimana.
5. Come utente, voglio che le statistiche interessanti (combinazioni più allenate, tecniche, carico) vengano prima dello storico sessioni.
6. Come utente, voglio che lo storico completo delle sessioni sia in fondo alla pagina Progressi.
7. Come utente che modifica un workout, voglio che si apra come bottom sheet con Salva e Annulla sempre visibili.
8. Come utente che modifica una combo, voglio la stessa cosa, senza poter cambiare tab per errore.
9. Come utente che modifica una routine di stretching, voglio lo stesso comportamento dei workout e delle combo.
10. Come utente che apre la home, voglio che il gradiente parta dal bordo superiore senza righe nette.
11. Come manutentore, voglio test che coprano i flussi principali (builder, progress) e `flutter analyze` pulito.

## Implementation Decisions

- **Modali**: `showAppModal` usa `showModalBottomSheet(..., useRootNavigator: true)`. Vale per tutte le modali esistenti (picker, quick start, tecniche custom, log sessione, piani settimanali).
- **Toast**: il contenuto del toast viene avvolto in `Material(type: MaterialType.transparency)`, così il `DefaultTextStyle` viene dal tema e non da `_errorTextStyle` di `MaterialApp`.
- **Progressi**: nuovo helper `weeklyStreak(sessions)` in `lib/lib/stats.dart` (settimane consecutive lunedì-based con almeno una sessione; se la settimana corrente non ha sessioni la catena parte dalla precedente). La pulse mostra streak settimanale + allenamenti della settimana corrente, con barra obiettivo opzionale.
- **Ordine pagina Progressi**: `Pulse → StatsContent → HistoryCard`.
- **StatsContent**: la card "Combinazioni più usate" sale subito dopo la griglia riassuntiva, prima dei grafici di carico. Le progress bar della frequenza tecniche usano `AppColors.line` come traccia (non `AppColors.bg`).
- **Builder come sheet**: i tre builder espongono una funzione `show...Sheet(...)`; il widget interno costruisce `Column(Expanded(SingleChildScrollView(contenuto)), footer sticky)`. Titolo nell'header della modale. Save/Cancel nel footer. Save ritorna un risultato al chiamante; il chiamante mostra il toast e, per "Salva e avvia", fa `push('/live')`. Le route annidate dei builder vengono rimosse da `main.dart`.
- **Gradiente home**: nella branch home il `SafeArea` non applica il top; l'header è posizionato a `MediaQuery.padding.top`; l'hero include `padding.top` nel suo padding superiore.
- **l10n**: nuove chiavi per la pulse (`progressWeeklyStreak`, `progressWeekWorkouts`, `progressWeeksUnit`), in `app_it.arb` + `app_en.arb`, poi `flutter gen-l10n`.

## Testing Decisions

- I test verificano **comportamento esterno**, non dettagli implementativi.
- Prior art: `test/workout_builder_test.dart` (widget test end-to-end del builder), `test/smoke_test.dart` (boot + tab + sessione), `test/progress_test.dart` (pagina Progressi).
- `workout_builder_test.dart` va aggiornato: il builder si apre dalla lista (FAB), non più via `GoRouter.go('/workouts/new')`.
- Nuovo/aggiornato test per `weeklyStreak` (unit su `lib/stats.dart`) e per la pagina Progressi.
- Gate di ogni ticket: `flutter analyze` + `flutter test`.

## Out of Scope

- Riprogettazione grafica oltre i punti elencati.
- Deep link verso i builder (vengono rimossi: si entra solo dalle liste).
- Modifiche al motore di sessione o al modello dati.

## Further Notes

- Le 4 immagini del report sono state ispezionate: la sottolineatura gialla è `_errorTextStyle` di `MaterialApp`; il bordo del gradiente è il passaggio `#0B0B0E → #251516` a y≈70.
- Working tree pulito al momento della stesura (HEAD `0f27c1b ui refresh`).
