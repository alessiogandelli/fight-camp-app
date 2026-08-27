# ADR 0001: Un solo timer parametrico invece dei modi

## Status

Accepted

## Context

La pagina Allenati esponeva sei "modi" separati (heavy bag, combo workout, tabata, intervalli, round libero, push-up), ognuno con configurazione inline propria. In pratica tutti i modi a eccezione del push-up condividono lo stesso meccanismo: una sequenza di fasi preparazione → lavoro → pausa ripetuta per N round, differendo solo nei valori di default e in qualche opzione (combinazioni on/off). La duplicazione produceva UI affollata e confusa: sei card di settings simili ma non identiche, senza un elemento centrale che rappresentasse ciò che l'utente guarda davvero mentre si allena — il timer.

## Decision

Collassiamo tutti i modi in **un solo Timer parametrico**. I vecchi modi diventano **Preset**: configurazioni predefinite o salvate che istanziano il Timer (Sacco 3'/1', Tabata 20"/10"×8, HIIT 40"/20", Libero…). Il motore di sessione accetta un'unica configurazione parametrica; i preset la producono. L'UI di Allenati ha il Timer come protagonista, chip di preset sotto, un toggle opzionale per le combinazioni, e una sezione "Strumenti extra" separata per il push-up counter.

## Consequences

- Un solo percorso di codice per il motore sessione da testare (seam `buildPlan`).
- Aggiungere un nuovo tipo di allenamento = aggiungere un preset, non un modo.
- Il concetto "modo" scompare dal glossario; documentato in CONTEXT.md.
- Il push-up counter resta fuori dal motore: non è un timer.
