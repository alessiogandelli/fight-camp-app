# ADR 0005: Colori semantici

## Status

Accepted

## Context

I colori erano sovraccarichi. `accent` (`#FF4D4D`) era usato allo stesso tempo come brand, come colore di errore/distruzione (persino `ColorScheme.error`), e come stato WORK del timer; `rest` era **blu** (`#4CC3FF`); `go` e `warn` erano nomi non semantici. Il risultato: un rosso che significa tre cose diverse e un timer in cui "riposo" è blu, contro ogni aspettativa.

## Decision

Un unico vocabolario semantico, definito in `lib/ui/theme.dart` e sincronizzato nel prototipo web (`src/index.css`):

| token | valore | significato |
| --- | --- | --- |
| `primary` | `#E63946` | brand Fight Camp. **Mai** per errori o per il timer. |
| `work` | `#22C55E` | stato timer WORK / go. |
| `rest` | `#EF4444` | stato timer REST / stop. |
| `error` | `#B91C1C` | errori reali, validazione, azioni distruttive. |
| `warning` | `#F59E0B` | avvisi. |
| `success` | `#22C55E` | successo generico. |

Regole:

- **Timer**: verde = WORK, rosso = REST, ambra = preparazione. Una sola funzione `phaseColor(SegmentKind)` è la fonte di verità; nessun page re-implementa la mappa.
- **`primary` ≠ `error`**: le azioni distruttive (elimina, esci, azzera) usano `error`, non il brand.
- **`ColorScheme.error`** usa `AppColors.error` (non più `accent`).
- **Hard rename**: `accent`, `go`, `warn` rimossi sia dall'app sia dal prototipo web; resta un solo vocabolario.

Decisione collegata (`live-button-color`): il pulsante play/pausa del Live mostra **l'azione**, non lo stato — play/riprendi = verde (`work`), pausa = rosso (`rest`).

## Consequences

- Il REST del timer passa da blu a rosso; il brand passa da `#FF4D4D` a `#E63946` (leggermente più scuro). Entrambi sono cambi visibili.
- Contrasto (WCAG, calcolato):
  - `work` su `bg` **8.73**, `warning` su `bg` **9.26**, `rest` su `bg` **5.29**, `primary` su `bg` **4.77**.
  - `ink` su `error` **5.87**, `white` su `error` **6.47**.
  - **`ink`/`white` su `primary` restano sotto AA 4.5** (**3.78** / **4.17**): evitare testo piccolo su fondo `primary` (o scurire il brand); il testo grande passa (≥ 3:1).
  - `error` su `panel` **2.89**: non usare `error` come traccia/bordo di componenti UI su `panel`.
- `lib/ui/theme.dart` importa `SegmentKind` da `engine/plan.dart` per `phaseColor`.
