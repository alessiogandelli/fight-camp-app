# ADR 0003: Workout a configurazione singola e uniforme

## Status

Accepted (supersedes ADR 0002)

## Context

ADR 0002 rappresentava un Workout come una sequenza ordinata di Blocchi eterogenei (round, circuito, aerobico, stretching, libero). Il feedback sull'uso reale è opposto: un allenamento vero non è un workout unico con parti diverse, ma **più sessioni separate eseguite in successione** — si fa il riscaldamento col solo timer, poi si parte il workout da sacco (timer + combo), poi quello di stretching (timer + immagini). L'utente chiede esplicitamente workout semplici: "a caratterizzare un workout è che gli intervalli di tempo sono sempre gli stessi".

## Decision

Un `Workout` è una **configurazione singola e uniforme del Timer**: lavoro, pausa e round uguali per tutta la durata. Niente sequenza di blocchi. Il tipo è derivato dal contenuto (routine → stretching, combo → sacco, pausa zero e un round → continuo, altrimenti → circuito) e l'utente sceglie solo il titolo e i valori. La Routine resta un riferimento opzionale; le Combo restano liste di Tecniche. Non esistono più Blocchi né Preset.

## Consequences

- Il builder Workout è di fatto l'editor del Timer più combo/routine opzionali; il motore compila il Workout in una configurazione del Timer (ADR 0001) come già faceva, ma senza aggregare parti eterogenee.
- Un workout di stretching ha intervalli fissi (30" posizione / 10" pausa) e round pari al numero di esercizi della Routine; la durata è calcolata, non configurabile.
- I workout salvati col modello a blocchi (ADR 0002) vengono azzerati: nessun dato utente da preservare, app in fase early.
- L'esecuzione di un workout è la stessa del timer generico: stessa LivePage, stessi dati di Sessione.