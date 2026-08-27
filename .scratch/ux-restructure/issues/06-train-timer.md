# 06: Allenati = Timer

**What to build:** La pagina Allenati viene ricostruita attorno al Timer: display grande di lavoro/pausa protagonista, sotto chip di preset (Sacco 3'/1', Sacco 2'/1', Sacco 5'/1', Tabata 20"/10"×8, HIIT 40"/20", Libero) con memoria dell'ultima configurazione usata, toggle opzionale per allenarsi sulle combinazioni con selezione/rotazione, e sezione "Strumenti extra" che ospita il contatore push-up. Il banner "sessione in corso" resta in cima quando esiste una sessione non finita. I sei modi inline scompaiono: ogni preset porta alla sua configurazione prima di avviare. Le impostazioni audio/vibrazione/prep non sono più su questa pagina (vedi ticket 05).

**Blocked by:** 02 (token spacing), 03 (i18n expand), 04 (modello/configurazione parametrica).

**Status:** ready-for-agent

- [ ] Allenati mostra il timer grande come elemento centrale, con numeri lavoro/pausa leggibili a colpo d'occhio
- [ ] I preset elencati sono presenti e ognuno istanzia la configurazione parametrica corretta (verificato al seam `buildPlan`)
- [ ] L'ultima configurazione usata viene ricordata e riproposta alla riapertura
- [ ] Toggle combinazioni opzionale: senza attivazione si allena a vuoto, attivo si scelgono combo e rotazione
- [ ] Push-up vive sotto "Strumenti extra"; nessun modo separato residuo nella pagina
- [ ] Banner sessione in corso presente solo quando esiste, con resume/discard
- [ ] Spacing coerente via token; testi via localizzazioni generate (it/en)
- [ ] Widget test di fumo: la pagina si costruisce e un preset avvia la sessione live
- [ ] `flutter analyze` pulito e test verdi
