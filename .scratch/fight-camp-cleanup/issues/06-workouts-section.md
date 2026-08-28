# 06: Workouts end-to-end

**What to build:** La sezione Workouts diventa la casa dei workout preconfigurati riutilizzabili, ciascuno a configurazione singola.

- Lista dei workout con: titolo, icona/label del tipo derivato (stretching/sacco/continuo/circuito) e riassunto leggibile (es. "3'/1' × 5 · 2 combo").
- Creazione tramite Floating Action Button (stesso pattern della Libreria), non più bottone in linea.
- Builder riscritto come editor del timer: lavoro/pausa/round configurabili + titolo personalizzato + selezione opzionale di combo (sacco) **oppure** di routine (stretching), mutuamente esclusive. Se c'è una routine, gli intervalli sono fissi 30/10 e i round = numero esercizi, in sola lettura.
- Avvio di un workout → sessione nel timer live (sacco: timer + rotazione combo; stretching: timer + immagini, dal ticket 04).

**Blocked by:** 03, 04

**Status:** ready-for-agent

- [ ] Lista workout mostra titolo, tipo derivato e riassunto intervalli/combo
- [ ] FAB apre il builder (nessun bottone in linea)
- [ ] Il builder permette titolo personalizzato, intervalli, e combo oppure routine (mai entrambe)
- [ ] Workout sacco avviato: timer + combo in rotazione
- [ ] Il workout stretching nel builder mostra durata/round derivati in sola lettura