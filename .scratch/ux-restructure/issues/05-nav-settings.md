# 05: Navigazione a 4 tab + pagina Impostazioni

**What to build:** Il bottom bar ha quattro tab: Allenati, Workout, Libreria, Progressi. Libreria e Progressi mostrano inizialmente le pagine esistenti come placeholder (le loro ricostruzioni sono ticket dedicati). Nell'header, dove oggi c'è il selettore IT/EN, ora c'è un ingranaggio che apre la pagina Impostazioni con: Lingua (con default rilevato dal sistema), Audio, Vibrazione, Countdown preparazione. Le impostazioni audio/vibrazione/prep lasciano la pagina Allenati.

**Blocked by:** 02 (token spacing), 03 (i18n expand).

**Status:** ready-for-agent

- [ ] Quattro tab navigabili; le voci Storico/Stats/Combo non esistono più come tab separate
- [ ] Ingrenaggio nell'header al posto del selettore lingua; apre la pagina Impostazioni
- [ ] Impostazioni contiene Lingua, Audio, Vibrazione, Countdown preparazione, tutte persistite
- [ ] Cambiare lingua dalle impostazioni aggiorna subito l'app
- [ ] Le schermate nuove usano i token di spacing e i lookup gen-l10n
- [ ] Widget test di fumo esteso: le quattro tab si costruiscono e la pagina Impostazioni si apre
- [ ] `flutter analyze` pulito e test verdi
