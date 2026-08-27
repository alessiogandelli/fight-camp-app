# 09: Workout builder a blocchi

**What to build:** Il builder del workout gestisce il nuovo modello a blocchi: lista ordinata di blocchi ognuno mostrato compatto con icona, nome e riepilogo tempi ("10×30\""), espandibile per modificare tempi, pause e combinazioni. Tipi disponibili: Round (con combo opzionali, copre anche lo sparring), Circuito, Aerobico, Stretching, Libero. Il blocco Stretching sceglie una routine dalla Libreria. L'esempio canonico dell'utente è buildabile e salvabile end-to-end, e il workout salvato parte da Allenati/Workout verso la sessione live.

**Blocked by:** 04 (modello blocchi), 05 (navigazione), 08 (routine stretching in Libreria).

**Status:** ready-for-agent

- [ ] Lista di blocchi compatta con icona + riepilogo tempi leggibile a colpo d'occhio
- [ ] Ogni blocco è espandibile e modificabile senza reinserire gli altri
- [ ] Riordino/duplicazione/eliminazione dei blocchi
- [ ] Blocco Round con N×durata+pausa e combo opzionali; Circuito con work/rest fissi × ripetizioni; Aerobico/Stretching/Libero con durata continua
- [ ] Blocco Stretching sceglie la routine dalla Libreria
- [ ] L'esempio canonico ("10×30\" → 3×1'30\"+45\" → tabata → sparring → stretching") si costruisce, salva e riapre identico
- [ ] Un workout salvato si avvia come sessione usando la compilazione verificata al seam `buildPlan`
- [ ] Spacing coerente via token; testi via localizzazioni generate (it/en)
- [ ] Widget test di fumo: costruzione dell'esempio canonico end-to-end
- [ ] `flutter analyze` pulito e test verdi
