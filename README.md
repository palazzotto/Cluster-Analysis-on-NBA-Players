# Cluster Analysis on NBA Players

## In breve

**279 giocatori NBA di rotazione, 3 archetipi statistici, una domanda:** i ruoli tradizionali bastano davvero a descrivere come gioca un atleta?

Questo progetto usa dati della stagione NBA 2025-26, statistiche per 36 minuti, PCA e clustering per individuare profili di gioco senza partire dalle etichette PG, SG, SF, PF e C.

## Risultati principali

| Risultato | Valore |
| --- | --- |
| Giocatori analizzati | 279 con almeno 1.000 minuti |
| Archetipi identificati | 3 |
| Varianza spiegata da PC1 + PC2 | 58,64% |
| Soluzione scelta | PCA + Ward + k-means, K = 3 |
| Calinski-Harabasz della soluzione scelta | 83,09 |
| Accuratezza LDA in LOOCV | 94,62% |

La soluzione a 3 cluster ha ottenuto un indice Calinski-Harabasz superiore all'alternativa diretta a 2 cluster (83,09 contro 75,53), misurato sulle stesse 10 variabili standardizzate.

## I tre archetipi

| Cluster | Profilo statistico | Esempi nel campione |
| --- | --- | --- |
| 1 — Creatori ad alto utilizzo | Più tentativi da due, tiri liberi, assist e palle perse: giocatori che organizzano e concentrano una quota rilevante dell'attacco. | Luka Dončić, Shai Gilgeous-Alexander, Stephen Curry, Nikola Jokić, Giannis Antetokounmpo |
| 2 — Perimetro e gioco a basso volume interno | Più volume da tre rispetto ai tentativi al ferro, con minore presenza a rimbalzo e ai liberi. | Klay Thompson, Duncan Robinson |
| 3 — Lunghi, rimbalzo e protezione del ferro | Forte impronta su rimbalzi offensivi e difensivi e stoppate; meno volume perimetrale. | Victor Wembanyama, Rudy Gobert, Chet Holmgren, Jarrett Allen |

> Gli archetipi non sono giudizi di valore: descrivono similarità statistiche. Un giocatore può essere un'eccezione interessante all'interno del proprio gruppo.

## Come leggere il progetto senza entrare nel codice

- Il punto centrale non è predire le partite: è capire **quali giocatori producono in modo simile**.
- Le statistiche sono normalizzate per 36 minuti, per confrontare atleti con minuti giocati diversi.
- La PCA riduce le 10 metriche principali; il clustering raggruppa i profili vicini nello spazio statistico.
- La validazione LDA/QDA verifica quanto la partizione sia riconoscibile dai dati: la migliore accuratezza cross-validata è 94,62%.

## Dati e metodo

I dati provengono dalla tabella dei totali NBA 2025-26 di [Basketball-Reference](https://www.basketball-reference.com/leagues/NBA_2026_totals.html). Sono inclusi giocatori con almeno 1.000 minuti.

Le 10 metriche analizzate per 36 minuti sono: tentativi da tre e da due, tiri liberi, rimbalzi offensivi e difensivi, assist, palle rubate, stoppate, palle perse e falli personali.

Il flusso dell'analisi è:

1. Pulizia dei dati e normalizzazione per 36 minuti.
2. Controllo di correlazioni, VIF e normalità.
3. Standardizzazione e Principal Component Analysis.
4. Confronto tra clustering gerarchico, DIANA e k-means.
5. Selezione con indice di Calinski-Harabasz.
6. Validazione della partizione tramite LDA/QDA in LOOCV.

## Per riprodurre l'analisi

Serve R 4.x con i pacchetti rvest, tidyverse, ggplot2, car, fpc, cluster e MASS. Esegui source("cod_pul_modificato.R").

## Nota sui risultati

I dati vengono letti online al momento dell'esecuzione; i valori e gli esempi possono quindi cambiare se la tabella sorgente viene aggiornata.
