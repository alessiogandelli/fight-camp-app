# Fight Camp — Domain Glossary

Il vocabolario canonico del progetto. Solo linguaggio di dominio: nessun dettaglio implementativo.

## Terminologia

### Timer
L'unico strumento di allenamento dell'app: una sequenza di fasi *preparazione → lavoro → pausa* ripetute per N round. Ogni attività su Allenati è un Timer configurato diversamente; non esistono "modalità" separate.

### Allenati
La tab del timer generico: serve a iniziare rapidamente un allenamento configurando il Timer direttamente. L'app ricorda l'ultima configurazione usata.

### Workout
Una configurazione **singola e uniforme** del Timer (lavoro, pausa, round sempre uguali) salvata e riutilizzabile, con titolo personalizzato. Può includere opzionalmente una lista di Combo (workout da sacco), una Routine (workout di stretching) oppure un Circuito di potenziamento. Il tipo è **derivato** dal contenuto: ha una Routine → stretching; ha Combo → sacco; combo di soli esercizi di potenziamento → potenziamento; pausa zero e round singolo → continuo (es. corda); altrimenti → circuito. Un allenamento reale è spesso più Workout eseguiti in successione (riscaldamento, poi sacco, poi stretching), non un unico workout composto da parti diverse.

### Combo
Una lista ordinata di Tecniche da eseguire al sacco. Vive nella Libreria.

### Routine
Una lista ordinata di esercizi di **stretching**. Concetto distinto dalla Combo: la Combo è una sequenza di colpi, la Routine è un blocco di esercizi fisici. Vive nel **Workout**: si sceglie, crea o modifica mentre si configura un Workout, non nella Libreria.

### Tecnica
Un movimento elementare con nome e categoria (pugni, calci, ginocchia, gomitate, difesa/movimento, potenziamento, stretching). È l'atomo di cui sono fatte le Combo, i Circuiti e le Routine.

### Circuito
Una lista ordinata di esercizi di **potenziamento** (push up, squat, plank…), ciascuno con un eventuale numero di ripetizioni. Vive nel **Workout** ed è l'equivalente della Combo per il corpo libero: stessa entità sotto il cofano, tecniche di categoria potenziamento. Non compare nella Libreria.

### Libreria
La tab che contiene liste ordinate di movimenti e lo strumento extra, in quattro sezioni: **Sacco** (Combo), **Potenziamento** (catalogo in sola consultazione degli esercizi a corpo libero), **Stretching** (catalogo in sola consultazione degli esercizi di stretching), **Tool** (flessioni).

### Tool
Strumento extra non basato sul Timer (attualmente solo il contatore di flessioni). Vive nella sezione Tool della Libreria.

### Allenamento
Il blocco di sessioni eseguite di seguito (al massimo 15 minuti di stacco fra una e l'altra) e/o coperte dallo stesso workout di Apple Salute: riscaldamento, sacco e stretching sono **un** Allenamento, non tre. È l'unità che Progressi conta ("12 allenamenti") e che lo Storico mostra come una scheda espandibile. Può esistere anche senza sessioni dell'app, quando arriva solo da Salute.

### Sessione
L'unità atomica registrata: il risultato completato (o abbandonato) di un Timer o di un Workout, oppure un workout importato da Salute. Più Sessioni ravvicinate formano un Allenamento. Visibile dentro l'Allenamento in Progressi e Storico.

### Progressi
La pagina che mostra come sta andando l'allenamento: riassunti, volume nel tempo, lista delle Sessioni.

## Confusioni da evitare

- **Timer ≠ Modo**: non ci sono "modi". Il Timer è unico e parametrico.
- **Combo ≠ Routine**: le Combo sono colpi, le Routine sono esercizi di stretching. Non sono la stessa cosa, anche se condividono la struttura di lista ordinata di Tecniche.
- **Combo/Routine ≠ Workout**: una Combo o una Routine è una lista di movimenti; un Workout è una configurazione del Timer che può referenziare una di esse.
- **Workout ≠ sequenza di blocchi**: un Workout è un'unica configurazione a intervalli uniformi, non una sequenza di parti eterogenee.
- **Allenamento ≠ Sessione**: l'Allenamento è il blocco reale (più Sessioni, più eventuali workout di Salute); la Sessione è il singolo pezzo registrato. I Progressi contano Allenamenti, le statistiche di volume sommano Sessioni.