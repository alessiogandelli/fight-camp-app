# 07: Library — Sacco / Stretching / Tool

**What to build:** La Libreria accoglie tre sezioni e lo stretching ottiene una rappresentazione e un builder propri, distinti dalle combo.

- La tab Library presenta tre sezioni: **Sacco** (combo da sacco), **Stretching** (routine), **Tool** (contatore flessioni).
- Sezione Stretching: lista delle routine con nome e anteprime delle immagini SVG; builder dedicato dove ogni esercizio della routine (dal catalogo stretching) è mostrato con nome + SVG grande; nessun riuso della UI del builder combo. FAB adattivo: crea combo in Sacco, crea routine in Stretching.
- Tool: il contatore flessioni viene riposizionato qui (via dalla Home) e si **auto-stoppa** quando si lascia la pagina — questo elimina il beep casuale in Home causato dal rilevatore fotocamera lasciato attivo.
- Le Routine restano memorizzate come Combo sotto il cofano (nessuna nuova entità di persistence), ma nel dominio e nella UI sono concetti separati.

**Blocked by:** 03

**Status:** ready-for-agent

- [ ] La tab Library mostra tre sezioni selezionabili
- [ ] Sezione Stretching: elenco routine, builder con SVG per esercizio, FAB crea routine
- [ ] Sezione Sacco: elenco combo, FAB crea combo
- [ ] Flessioni presenti in Tool e nessun beep quando si è in Home o altrove senza sessioni attive