# 02: Naming — Fight Camp ovunque

**What to build:** Il prodotto si chiama Fight Camp in ogni superficie user-facing e negli identificatori tecnici di persistence (nessun dato utente da preservare: chiavi rinominate senza migrazione).

- Wordmark nell'header dell'app: `FIGHT CAMP` (non localizzato, è un brand).
- Label launcher: Android e iOS mostrano "Fight Camp".
- Chiavi di persistence rinominate con prefisso `fight-camp:*`, con bump del numero di versione dei dati.
- Rimosso il codice legacy di pulizia delle vecchie chiavi v1.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Launcher (Android/iOS) mostra "Fight Camp"
- [ ] Header dell'app mostra "FIGHT CAMP"
- [ ] Nessuna occorrenza user-facing di "Combat Training" resta in UI o label
- [ ] Persistence ridenominata e funzionante: dati seed ricaricati al primo avvio con le nuove chiavi
- [ ] Nessuna rottura del salvataggio/caricamento dopo la ridenominazione