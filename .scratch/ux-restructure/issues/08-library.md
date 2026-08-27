# 08: Libreria — combo al sacco e routine di stretching nella stessa tab

**What to build:** La vecchia tab Combo diventa **Libreria**: liste ordinate di movimenti per il sacco e per lo stretching, con segmented interno Sacco/Stretching. Le routine di stretching si creano con lo stesso editor delle combo scegliendo esercizi dalla nuova categoria stretching. Il flusso utente: apro Libreria → filtro Stretching → creo la mia routine → la riuso nei workout.

**Blocked by:** 03 (i18n expand), 04 (categoria stretching + seed), 05 (tab Libreria esiste).

**Status:** ready-for-agent

- [ ] Tab Libreria con segmented Sacco/Stretching che filtra le liste
- [ ] L'editor esistente delle combo crea anche routine di stretching (nessun editor duplicato)
- [ ] Ricerca/filtri esistenti funzionano su entrambe le sezioni
- [ ] Le routine stretching create appaiono nel modello come Combination di tecniche stretching
- [ ] Spacing coerente via token; testi via localizzazioni generate (it/en)
- [ ] Widget test di fumo: creazione di una routine di stretching end-to-end
- [ ] `flutter analyze` pulito e test verdi
