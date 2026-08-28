# Fight Camp — Domain Glossary

Il vocabolario canonico del progetto. Solo linguaggio di dominio: nessun dettaglio implementativo.

## Terminologia

### Timer
L'unico strumento di allenamento dell'app: una sequenza di fasi *preparazione → lavoro → pausa* ripetute per N round. Ogni attività su Allenati è un Timer configurato diversamente; non esistono "modalità" separate.

### Allenati
La tab del timer generico: serve a iniziare rapidamente un allenamento configurando il Timer direttamente. L'app ricorda l'ultima configurazione usata.

### Workout
Una configurazione **singola e uniforme** del Timer (lavoro, pausa, round sempre uguali) salvata e riutilizzabile, con titolo personalizzato. Può includere opzionalmente una lista di Combo (workout da sacco) oppure una Routine (workout di stretching). Il tipo è **derivato** dal contenuto: ha una Routine → stretching; ha Combo → sacco; pausa zero e round singolo → continuo (es. corda); altrimenti → circuito. Un allenamento reale è spesso più Workout eseguiti in successione (riscaldamento, poi sacco, poi stretching), non un unico workout composto da parti diverse.

### Combo
Una lista ordinata di Tecniche da eseguire al sacco. Vive nella Libreria.

### Routine
Una lista ordinata di esercizi di **stretching**. Concetto distinto dalla Combo: la Combo è una sequenza di colpi, la Routine è un blocco di esercizi fisici. Vive nella Libreria.

### Tecnica
Un movimento elementare con nome e categoria (pugni, calci, ginocchia, gomitate, difesa/movimento, stretching). È l'atomo di cui sono fatte le Combo e le Routine.

### Libreria
La tab che contiene le liste ordinate di movimenti e lo strumento extra, in tre sezioni: **Sacco** (Combo), **Stretching** (Routine), **Tool** (flessioni).

### Tool
Strumento extra non basato sul Timer (attualmente solo il contatore di flessioni). Vive nella sezione Tool della Libreria.

### Sessione
Un allenamento registrato: il risultato completato (o abbandonato) di un Timer o di un Workout. Visibile in Progressi.

### Progressi
La pagina che mostra come sta andando l'allenamento: riassunti, volume nel tempo, lista delle Sessioni.

## Confusioni da evitare

- **Timer ≠ Modo**: non ci sono "modi". Il Timer è unico e parametrico.
- **Combo ≠ Routine**: le Combo sono colpi, le Routine sono esercizi di stretching. Non sono la stessa cosa, anche se condividono la struttura di lista ordinata di Tecniche.
- **Combo/Routine ≠ Workout**: una Combo o una Routine è una lista di movimenti; un Workout è una configurazione del Timer che può referenziare una di esse.
- **Workout ≠ sequenza di blocchi**: un Workout è un'unica configurazione a intervalli uniformi, non una sequenza di parti eterogenee.