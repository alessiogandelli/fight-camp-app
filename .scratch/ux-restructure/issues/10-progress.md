# 10: Progressi — merge di Storico e Stats

**What to build:** Le due vecchie tab Storico e Stats si fondono nella pagina **Progressi**: in cima card riassuntive (sessioni settimana, minuti totali, streak), poi grafico settimanale/mensile del volume, sotto lista delle sessioni filtrabile per tipo/data con dettaglio al tap. La pagina riorganizza le funzionalità esistenti, non ne aggiunge di nuove.

**Blocked by:** 03 (i18n expand), 05 (tab Progressi esiste).

**Status:** ready-for-agent

- [ ] Una sola pagina Progressi; Storico e Stats non esistono più come destinazioni separate
- [ ] Card riassuntive: sessioni della settimana, minuti totali, streak
- [ ] Grafico volume settimanale/mensile commutabile
- [ ] Lista sessioni filtrabile (tipo/data) con schermata di dettaglio al tap
- [ ] I dati delle sessioni registrate col nuovo motore compaiono correttamente
- [ ] Spacing coerente via token; testi via localizzazioni generate (it/en)
- [ ] Widget test di fumo: la pagina si costruisce e mostra una sessione di esempio
- [ ] `flutter analyze` pulito e test verdi
