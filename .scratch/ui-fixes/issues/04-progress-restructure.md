# 04: Pagina Progressi ristrutturata

**What to build:** La pagina Progressi mostra in cima una pulse con la streak settimanale e il numero di allenamenti della settimana; sotto le statistiche (con le combinazioni più allenate in evidenza) e in fondo lo storico delle sessioni. Le etichette non vengono più troncate e la barra dell'obiettivo non sembra un buco.

**Blocked by:** None (can start immediately)

**Status:** done

- [x] Nuovo helper `weeklyStreak` in `lib/lib/stats.dart` (settimane consecutive lunedì-based con almeno una sessione)
- [x] Pulse con streak settimanale e allenamenti della settimana corrente, senza troncamenti
- [x] Ordine pagina: Pulse → statistiche → storico sessioni
- [x] La card "Combinazioni più usate" è tra le prime statistiche, prima dei grafici di carico
- [x] Le progress bar usano una traccia visibile (`AppColors.line`), non lo sfondo scuro
- [x] Nuove stringhe l10n it/en generate
- [x] Test di `weeklyStreak` e della pagina Progressi verdi (80/80, 2026-09-11)
- [x] `flutter analyze` pulito e test verdi

## Comments
