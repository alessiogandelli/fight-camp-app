# ADR 0002: Workout come sequenza di blocchi

## Status

Accepted

## Context

Il modello precedente rappresentava un Workout come una lista piatta di round omogenei (tutti dello stesso meccanismo: durata + pausa + combinazioni). Questo non rappresentava gli allenamenti reali, che mescolano parti eterogenee: l'utente descrive sessioni come "10 round × 30" senza pausa, poi 3×1'30"+45" di pausa, poi un tabata per il circuito, poi lo sparring, poi lo stretching". Forzare questo in round piatti significava perdere struttura e senso del workout.

## Decision

Un `Workout` è una **sequenza ordinata di Blocchi**, ognuno con tipo e tempi propri:

- **Round**: N serie × durata + pausa, con combinazioni opzionali. Lo sparring è un Round senza combinazioni — non un tipo separato.
- **Circuito**: logica tabata (lavoro/pausa brevi fissi × ripetizioni).
- **Aerobico**: durata continua.
- **Stretching**: durata continua + riferimento a una Routine dalla Libreria.
- **Libero**: durata generica.

Le routine di stretching riusano il modello delle Combo: sono liste ordinate di Tecniche della nuova categoria stretching. Nessuna entità dominio nuova.

## Consequences

- Ogni blocco compila alla configurazione parametrica del Timer (ADR 0001); la compilazione è testata al seam `buildPlan`.
- Il builder mostra ogni blocco compatto con riepilogo tempi ("10×30\""), espandibile per modificarlo.
- I workout salvati col vecchio modello vengono azzerati, non migrati: nessun dato utente importante, app in fase early.
- Estendere l'app (nuovi tipi di parte) = aggiungere un tipo di blocco, senza toccare il motore.
