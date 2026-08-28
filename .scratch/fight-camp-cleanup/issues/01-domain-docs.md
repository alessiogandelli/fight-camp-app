# 01: Domain docs — glossario e ADR

**What to build:** Il vocabolario canonico del progetto viene aggiornato alle nuove decisioni di dominio prima che il codice cambi, così i ticket successivi usano la stessa lingua.

- `CONTEXT.md` viene riscritto: **Workout** = configurazione singola del Timer (lavoro/pausa/round uniformi) con titolo personalizzato e tipo derivato, non una sequenza di blocchi; i termini **Blocco** e **Preset** escono dal glossario; **Routine** non è più sinonimo di Combo (Routine = lista ordinata di esercizi di stretching, Combo = lista ordinata di tecniche da sacco, concetti distinti); **Libreria** contiene tre sezioni (sacco, stretching, tool); **Tool** (flessioni) vive nella Libreria, non nella pagina Allenati.
- Nuova ADR che documenta la scelta "Workout a configurazione singola e uniforme" (rompe l'idea precedente di sequenza di blocchi; giustifica il perché: sessioni di allenamento reali sono attività separate eseguite in successione, non blocchi di un unico workout).

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] CONTEXT.md coerente con il nuovo dominio, senza dettagli implementativi
- [ ] ADR registrata in docs/adr/ che spiega la scelta e l'alternativa scartata
- [ ] Terminologia del nuovo modello (Workout, Routine, Combo, Libreria, Tool) usata dai ticket successivi