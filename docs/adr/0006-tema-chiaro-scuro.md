# ADR 0006: Tema chiaro e scuro

## Status

Accepted (estende ADR 0005)

## Context

L'app era progettata solo per il tema scuro: `AppColors` era un insieme di costanti compilate con i valori scuri. Su iOS la barra a schede in liquid glass è disegnata dal sistema e segue l'aspetto del telefono: con il telefono in modalità chiara la barra diventava bianca su un'app nera. La prima correzione (forzare `UIUserInterfaceStyle = Dark`) rende coerente il nativo ma ignora la preferenza dell'utente. La richiesta è un tema chiaro vero, non un'app scura con elementi bianchi.

## Decision

- **Due palette, stessi token.** `AppPalette.dark` e `AppPalette.light` in `lib/ui/theme.dart` espongono gli stessi nomi (`bg`, `panel`, `panel2`, `line`, `ink`, `mut`, `primary`, `glow`, `work`, `rest`, `error`, `warning`, `success`). Il vocabolario semantico di ADR 0005 resta valido: cambiano i valori, non i significati.
- **Scelta in app: Sistema / Chiaro / Scuro.** `Settings.themeChoice` (default `system`) vive in Impostazioni, in cima. `system` segue l'aspetto del telefono; `light`/`dark` lo forzano. `FightCampApp` legge `platformBrightness`, reagisce a `didChangePlatformBrightness` e risolve l'aspetto effettivo dalla scelta salvata. `buildTheme(brightness)` deriva la `ThemeData` (dialoghi, input, switch) dalla stessa palette.
- **Remount deliberato alla cambio di aspetto.** I token sono letti durante il build; per far ripitturare anche i widget `const`, `MaterialApp.router` ha una `key` legata alla luminosità. Lo stato di navigazione vive in `GoRouter`, quindi la rotta corrente sopravvive al remount (coperto da `test/theme_test.dart`).
- **Nativo coerente.** `UIUserInterfaceStyle` non è più forzato e `GlassStatusBarStyle.auto` + `overlayStyleFor(brightness)` allineano status bar e navigation bar. La barra a schede in liquid glass di iOS 26 è però una `UITabBar` nativa, che segue `UIUserInterfaceStyle` dell'app, non il tema Flutter: senza intervento, forzare "Scuro" su un telefono chiaro lascerebbe una barra bianca. Il canale `fight_camp/appearance` (AppDelegate.swift + `lib/lib/appearance.dart`) imposta `overrideUserInterfaceStyle` sulla finestra quando l'utente forza un tema, e lo riporta a `.unspecified` con "Sistema".
- **Valori del tema chiaro.** `bg #F5F5F7`, `panel #FFFFFF`, `panel2 #EDEDF1`, `line #E0E0E6`, `ink #14141A`, `mut #6C6C77`, `primary #E01E2B`, `glow #F7E7E8`. I colori di stato vengono scuriti perché restano leggibili come testo su bianco: `work #15803D`, `rest #D62B2B`, `warning #9A5B00`, `error #B91C1C`, `success #15803D`.

## Consequences

- I colori non sono più costanti di compilazione: usarli in un'espressione `const` è un errore che il compilatore segnala, e ogni nuovo widget deve leggere i token durante il `build`.
- Il remount dell'app frame alla cambio di aspetto è deliberato: garantisce che anche i widget `const` ripitturino, al costo di azzerare le posizioni di scroll (la rotta resta).
- Contrasto del tema chiaro (WCAG, calcolato): `ink` su `bg` **16.85**, `mut` **4.76**, `primary` **4.39**, `work` **4.61**, `rest` **4.55**, `warning` **4.98**, `error` **5.94**. Testo bianco su `primary` **4.78**, su `work` **5.02**, su `rest` **4.95** — tutti sopra AA, a differenza del tema scuro dove il bianco su `primary` restava a 4.17.
- Le illustrazioni di stretching e potenziamento sono SVG con sfondo scuro: nel tema chiaro restano tessere scure dentro le card bianche (scelta: sembrano poster, nessun asset duplicato). Se in futuro servisse, si possono generare varianti chiare e sceglierle in base a `AppColors.isDark`.
- Lo splash nativo (iOS/Android) resta scuro in entrambi i temi perché il logo ha lo sfondo nero; lo splash Flutter segue invece la palette.
