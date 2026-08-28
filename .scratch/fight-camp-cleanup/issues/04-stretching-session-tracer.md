# 04: Tracer bullet — sessione stretching end-to-end

**What to build:** Il dimostratore verticale: dal workout seed "STRETCHING ROUTINE" (che referenzia la routine full body) parte una sessione nel timer live con la cadenza fissa di stretching.

- Cadenza fissa **30" di posizione / 10" di pausa**, avanzamento automatico, l'utente non tocca nulla.
- A ogni posizione: nome dell'esercizio e immagine SVG grande (quelle già presenti nel progetto) ben visibili; nella pausa, anteprima del prossimo esercizio.
- Durata totale calcolata automaticamente dalla routine (n esercizi × 40"), mai tagliata né ciclata.
- Il workout stretching ha intervalli fissi 30/10 e round = numero di esercizi della routine, in sola lettura.
- Questo ticket valida modello + engine + UI live in un colpo solo.

**Blocked by:** 03

**Status:** ready-for-agent

- [ ] Avviando il workout stretching, la sessione mostra ogni esercizio con nome + SVG per 30"
- [ ] La pausa di 10" mostra l'anteprima dell'esercizio successivo
- [ ] L'avanzamento è automatico senza alcun input
- [ ] La durata totale mostrata è la somma (n × 40")