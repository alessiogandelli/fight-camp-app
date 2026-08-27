# 03: i18n — expand: gen-l10n con file .arb specchianti la mappa esistente

**What to build:** L'infrastruttura di localizzazione ufficiale è attiva: flutter_localizations + gen-l10n con file `.arb` (it/en) che specchiano le chiavi della mappa manuale esistente (~400 chiavi). Il delegato generato è installato nell'app; il locale di sistema viene rilevato al primo avvio con fallback italiano. Le schermate esistenti continuano a usare la vecchia mappa: questa ticket è la fase *expand* — nessuna migrazione di chiamate. Ogni schermata ricostruita dai ticket successivi adotterà direttamente i lookup generati; l'eliminazione della mappa vecchia avviene nel ticket contract finale.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] gen-l10n configurato e file `.arb` it/en generati con tutte le chiavi esistenti
- [ ] Il delegato di localizzazione è installato nell'app
- [ ] Un lookup di prova via localizzazioni generate funziona in entrambe le lingue
- [ ] Con sistema in inglese l'app risolve correttamente il locale per i nuovi lookup (fallback IT verificato)
- [ ] Nessuna schermata esistente migrata; l'app si comporta come prima
- [ ] `flutter analyze` pulito e test esistenti verdi
