# 07: Live page centrata sul timer

**What to build:** La schermata di sessione live viene ridisegnata ruotando attorno al timer: numeri di lavoro/pausa enormi e centrati, la combinazione corrente mostrata in grande con avanzamento automatico tra le tecniche quando ci sono combo attive, e solo controlli pollice-friendly minimi (pausa, skip round, stop). Niente dropdown né campi di settings ripetuti durante la sessione: tutto il setup avviene prima, su Allenati.

**Blocked by:** 04 (configurazione parametrica), 06 (Allenati avvia le sessioni col nuovo formato).

**Status:** ready-for-agent

- [ ] Numeri lavoro/pausa enormi, centrati, leggibili a distanza
- [ ] Con combo attive: tecnica corrente in grande, avanzamento automatico alla successiva
- [ ] Solo pausa/skip/stop come controlli, grandi e raggiungibili col pollice
- [ ] Nessun dropdown o campo di configurazione nella schermata live
- [ ] Cue audio/vibrazione esistenti continuano a funzionare secondo le impostazioni
- [ ] Spacing coerente via token; testi via localizzazioni generate (it/en)
- [ ] `flutter analyze` pulito e test verdi (il comportamento temporale resta coperto dal seam `buildPlan`)
