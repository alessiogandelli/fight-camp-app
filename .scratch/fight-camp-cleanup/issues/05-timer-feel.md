# 05: Timer feel — beep, gesture, aptici

**What to build:** Il comportamento del timer live diventa silenzioso all'inizio dei segmenti e non più soggetto a input accidentali.

- Eliminato il beep iniziale quando parte un nuovo intervallo/round; restano solo i beep del countdown 3-2-1 (e i segnali informativi di fine segmento e fine sessione).
- Rimosse le gesture di swipe che cambiano round (avanti/indietro); resta il long-press per l'uscita con conferma. Nessuna gesture non intenzionale può compromettere l'allenamento.
- Feedback aptico su tutti i controlli principali: play, pausa, avanti, indietro, restart, esci — coerente e associato all'interazione riconosciuta.

**Blocked by:** 04

**Status:** ready-for-agent

- [ ] All'inizio di un round non c'è il beep iniziale, solo il countdown 3-2-1
- [ ] Nessun cambio round tramite swipe; il long-press di uscita richiede conferma
- [ ] Aptico presente sui controlli del timer (inclusi quelli che oggi non lo hanno)
- [ ] I beep restano soggetti all'impostazione del suono esistente