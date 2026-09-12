# ADR 0004: La Routine vive nel Workout, la Libreria elenca gli esercizi

## Status

Accepted

## Context

La Libreria esponeva tre sezioni: Sacco (Combo), Stretching (Routine), Tool (flessioni). La sezione Stretching listava quindi le **Routine**, con builder e FAB propri. All'uso reale questo crea due problemi: la Libreria — che per Sacco è un catalogo di movimenti riutilizzabili — diventa per lo stretching una lista di contenitori, e la Routine (che esiste solo in funzione di un Workout di stretching) finisce lontana dal punto in cui viene scelta. Il risultato è che per creare una routine si passa dalla Libreria, per usarla dal builder Workout, e il catalogo degli esercizi resta nascosto dentro il builder della rutina.

## Decision

La Libreria sezione **Stretching** diventa il **catalogo in sola consultazione degli esercizi di stretching** (le Tecniche di categoria stretching) con nome, descrizione e illustrazione. La **Routine** è un concetto del **Workout**: si sceglie, crea e modifica configurando un Workout, tramite il builder routine raggiungibile dal builder Workout. Restano memorizzate come `Combination` sotto il cofano (nessuna nuova entità) e il tipo `stretching` del Workout continua a derivare dalla presenza di una Routine.

## Consequences

- La Libreria torna a essere un catalogo di movimenti in tutte le sezioni: Combo per il sacco, esercizi per lo stretching, strumento flessioni per il Tool.
- Creare/modificare una Routine è un'azione del builder Workout; `showRoutineBuilderSheet` restituisce l'id della Routine salvata così il builder la seleziona subito.
- Il builder routine non è più raggiungibile dalla Libreria; la sua UI (esercizi con SVG) resta invariata.
- CONTEXT.md aggiornato: la Routine non vive più nella Libreria.
