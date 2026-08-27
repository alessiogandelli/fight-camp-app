# 04: Modello blocchi + categoria stretching + reset dati

**What to build:** Il dominio passa al nuovo modello: `Workout` è una sequenza ordinata di blocchi tipizzati (Round con combo opzionali — copre anche lo sparring; Circuito; Aerobico; Stretching con riferimento a routine; Libero), la categoria `stretching` entra tra le tecniche con seed bilingue di esercizi, e una routine di stretching è semplicemente una Combination di tecniche stretching (nessuna entità nuova). I blob vecchi in SharedPreferences vengono azzerati e i seed rigenerati col nuovo modello. La compilazione blocchi → configurazione parametrica del timer è verificata al seam esistente `buildPlan`: l'esempio canonico dell'utente ("10×30\" senza pausa → 3×1'30\"+45\" pausa → tabata circuito → sparring → stretching") produce il piano di fasi atteso.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Il modello Workout a blocchi sostituisce quello a round piatti
- [ ] Categoria stretching disponibile e popolata da seed bilingue
- [ ] Le routine di stretching sono Combination di tecniche stretching, creabili dal modello senza entità nuove
- [ ] I dati locali vecchi sono azzerati e i seed rigenerati col nuovo modello
- [ ] Test al seam `buildPlan`: ogni tipo di blocco compila alle segmenti prep/lavoro/pausa corrette, incluso l'esempio canonico end-to-end
- [ ] L'app si avvia pulita col nuovo modello (le schermate possono ancora usare adattamenti temporanei dove inevitabile)
- [ ] `flutter analyze` pulito e test verdi
