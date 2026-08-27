# Fight Camp — Domain Glossary

Il vocabolario canonico del progetto. Solo linguaggio di dominio: nessun dettaglio implementativo.

## Terminologia

### Timer
L'unico strumento di allenamento dell'app: una sequenza di fasi *preparazione → lavoro → pausa* ripetute per N round. Ogni attività su Allenati è un Timer configurato diversamente; non esistono "modalità" separate.

### Preset
Una configurazione predefinita o salvata del Timer (es. Sacco 3'/1', Tabata 20"/10"×8, HIIT 40"/20", Libero). Un Preset istanzia un Timer pronto all'uso. L'app ricorda l'ultimo uso.

### Tool
Strumento extra non basato sul Timer (attualmente solo Push-up). Vive nella sezione "Strumenti extra" della pagina Allenati.

### Workout
Una sequenza ordinata di Blocchi che compone un allenamento completo. Salvabile, riutilizzabile, avviabile come Sessione.

### Blocco
Una parte eterogenea di un Workout con tempi propri. Tipi:

- **Round**: N serie × durata + pausa configurabile, con combinazioni opzionali. Copre anche lo sparring (round senza combinazioni).
- **Circuito**: logica tabata — lavoro/pausa brevi e fissi ripetuti.
- **Aerobico**: durata continua.
- **Stretching**: durata continua più riferimento a una Routine dalla Libreria.
- **Libero**: durata generica.

### Libreria
La tab che contiene le liste ordinate di movimenti, sia per il sacco sia per lo stretching.

### Combo
Una lista ordinata di Tecniche da eseguire al sacco. Vive nella Libreria.

### Routine
Una lista ordinata di esercizi di stretching. Nel dominio è la stessa cosa di una Combo: una lista ordinata di movimenti — cambia solo la categoria dei movimenti che contiene.

### Tecnica
Un movimento elementare con nome e categoria (pugni, calci, ginocchia, gomitate, difesa/movimento, stretching). È l'atomo di cui sono fatte le Combo e le Routine.

### Sessione
Un allenamento registrato: il risultato completato (o abbandonato) di un Timer o di un Workout. Visibile in Progressi.

### Progressi
La pagina che mostra come sta andando l'allenamento: riassunti, volume nel tempo, lista delle Sessioni.

## Confusioni da evitare

- **Timer ≠ Modo**: non ci sono "modi" (tabata, sacco, intervalli…). Quello che prima era un modo ora è un Preset del Timer.
- **Combo ≠ Workout**: una Combo è una lista di tecniche; un Workout è una sequenza di Blocchi che può contenere Combo.
- **Routine = Combo con movimenti stretching**: stessa struttura, categoria diversa.
