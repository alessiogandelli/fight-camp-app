# 11: i18n — contract: rimozione della vecchia mappa

**What to build:** Con tutte le schermate ricostruite sui lookup gen-l10n, la vecchia mappa manuale dei messaggi viene eliminata: nessun caller residuo, l'unica fonte di verità per i testi sono i file `.arb`. Fase *contract* dell'expand–contract iniziato nel ticket 03.

**Blocked by:** 06 (Allenati), 07 (Live), 08 (Libreria), 09 (Workout builder), 10 (Progressi).

**Status:** ready-for-agent

- [ ] Nessun riferimento residuo alla mappa manuale dei messaggi
- [ ] La mappa manuale e il relativo helper di lookup sono eliminati
- [ ] Tutti i testi dell'app passano dai file `.arb` in it/en
- [ ] Cambiare lingua dalle Impostazioni continua a funzionare ovunque
- [ ] `flutter analyze` pulito e tutti i test verdi
