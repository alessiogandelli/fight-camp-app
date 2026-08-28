# 10: Verifica finale + sweep localizzazione

**What to build:** Chiusura: l'app è coerente, localizzata e verificata in entrambe le lingue.

- Tutte le stringhe nuove dei ticket precedenti passano dal sistema di localizzazione (italiano e inglese, nessuna UI mista).
- Sweep: nessuna stringa hardcoded fuori dai casi ammessi (brand "FIGHT CAMP" e tecnici non localizzati).
- Verifica finale: analisi statica verde, test verdi, e smoke test delle tre esperienze reali: riscaldamento (solo timer da Train), workout sacco (timer + combo), workout stretching (timer + immagini).

**Blocked by:** 04, 05, 06, 07, 08, 09

**Status:** ready-for-agent

- [ ] it/en completi e coerenti per ogni nuova stringa
- [ ] Nessuna UI parzialmente tradotta o hardcoded fuori scope
- [ ] Analisi statica e test verdi
- [ ] Smoke test: timer da Train, sacco da Workouts, stretching da Workouts funzionanti