# 01: Docs di dominio — CONTEXT.md e ADR

**What to build:** Il progetto ha una documentazione di dominio che gli agenti dei ticket successivi possono ereditare: un glossario `CONTEXT.md` con i termini fissati durante il grilling (Timer, Preset, Tool, Workout, Blocco, Round, Circuito, Libreria, Routine, Sessione) e due ADR che registrano le decisioni strutturali: "Un solo timer parametrico invece dei modi" e "Workout come sequenza di blocchi".

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Esiste `CONTEXT.md` alla radice con solo glossario (zero dettagli implementativi), nel formato standard del repo
- [ ] Esiste un ADR per la decisione "un solo timer parametrico" con alternative considerate e trade-off
- [ ] Esiste un ADR per la decisione "workout come sequenza di blocchi" con tipi di blocco definiti
- [ ] I termini usati nei due ADR coincidono con quelli del glossario
