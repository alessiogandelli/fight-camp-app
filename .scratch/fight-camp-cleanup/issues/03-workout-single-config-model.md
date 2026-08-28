# 03: Modello — Workout a configurazione singola

**What to build:** Il modello dati viene rifondato senza compatibilità con il passato (nessun utente). Un Workout non è più una sequenza di blocchi: è una singola configurazione del timer a intervalli uniformi.

Forma del tipo (deciso nel grilling):

```
Workout {
  id,
  name,                  // titolo personalizzabile
  workDuration,          // durata lavoro
  restDuration,          // durata pausa
  rounds,                // numero di round
  combinationIds?,       // combo da sacco, opzionale
  routineId?,            // routine di stretching, opzionale
}
```

- Eliminati `WorkoutBlock`, `BlockType`, `TimerPreset` e il campo presets dall'aggregato dati.
- Tipo del workout **derivato** dal contenuto: ha routine → stretching; ha combo → sacco; pausa 0 e 1 round → continuo (es. corda); altrimenti → circuito. Il titolo è l'unica cosa che l'utente sceglie liberamente.
- Seed ridefiniti: basics = 3'/1' × 4 con rotazione combo; tabata = 20"/10" × 8; stretching = routine full body agganciata.
- Catalogo tecniche: la categoria gomiti separa **Left Elbow** e **Right Elbow** al posto dell'unico gomito laterale; restano gomito verso l'alto e gomito verso il basso.
- È un refactor ampio (tutto il codice che usava i blocchi si rompe insieme); senza dati da preservare è un unico ticket breaking, verificabile con analisi statica e avvio con i seed.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] Analisi statica verde dopo la rimozione di blocchi/preset
- [ ] L'app parte e popola i seed nuovi (workout singoli, gomiti sx/dx)
- [ ] Nessuna occorrenza residua di WorkoutBlock/BlockType/TimerPreset nel codice
- [ ] Il tipo derivato (stretching/sacco/continuo/circuito) è calcolabile da un Workout