# Cluster Analysis on NBA Players

Analisi multivariata esplorativa dei profili di gioco dei giocatori NBA della stagione 2025-26. Il progetto individua archetipi statistici a partire dai volumi di gioco normalizzati per 36 minuti.

## Obiettivo

L'analisi raggruppa giocatori con caratteristiche statistiche simili, oltre la sola classificazione per ruolo. I cluster risultanti rappresentano profili o archetipi di gioco osservati nei dati.

## Dati e campione

I dati vengono scaricati dallo script dalla tabella dei totali NBA 2025-26 di [Basketball-Reference](https://www.basketball-reference.com/leagues/NBA_2026_totals.html). Dopo la pulizia, sono mantenuti i giocatori con almeno 1.000 minuti totali, così da concentrarsi sugli atleti di rotazione stabile.

Le metriche usate comprendono tentativi da tre, da due e tiri liberi; rimbalzi offensivi e difensivi; assist, palle rubate, stoppate, palle perse e falli personali. Tutte vengono convertite in valori per 36 minuti. Punti e minuti vengono esclusi dalla matrice finale per ridurre l'effetto del tempo di impiego e della produzione complessiva sulle distanze tra giocatori.

## Metodo

1. Web scraping, pulizia dei record e gestione dei giocatori trasferiti tra squadre.
2. Diagnostica di correlazioni, multicollinearità (VIF), distribuzioni e normalità (Shapiro-Wilk).
3. Standardizzazione Z-score e Principal Component Analysis (PCA).
4. Confronto di algoritmi gerarchici agglomerativi, DIANA e k-means.
5. Valutazione interna con indice di Calinski-Harabasz.
6. Profilazione dei centroidi tramite le medie delle statistiche per 36 minuti.
7. Validazione con LDA e QDA in leave-one-out cross-validation (LOOCV).

## Risultati principali

La soluzione selezionata dal flusso principale è una partizione in **3 cluster**: si parte da un clustering gerarchico Ward nello spazio delle prime cinque componenti principali e si usano i centroidi ottenuti per inizializzare k-means.

Il codice confronta questa partizione con una soluzione alternativa a 2 cluster, ottenuta direttamente sulle 10 variabili standardizzate con DIANA e k-means. Il confronto finale impiega l'indice di Calinski-Harabasz sulla stessa matrice standardizzata, rendendo le due partizioni confrontabili. Per ogni cluster vengono stampate numerosità e medie per 36 minuti, utili all'interpretazione degli archetipi.

LDA e QDA stimano infine quanto la partizione a 3 cluster sia riproducibile attraverso i punteggi PCA e le variabili originali standardizzate; il risultato è riportato come accuratezza LOOCV.

> I valori numerici finali dipendono dalla versione corrente della tabella Basketball-Reference interrogata al momento dell'esecuzione.

## Riproducibilità

### Requisiti

- R 4.x
- Pacchetti: rvest, tidyverse, ggplot2, car, fpc, cluster, MASS

### Esecuzione

Eseguire source("cod_pul_modificato.R").

Lo script scarica i dati, produce grafici diagnostici e stampa indici di valutazione, profili medi dei cluster e risultati della validazione discriminante.

## Contenuto della repository

| File | Descrizione |
| --- | --- |
| cod_pul_modificato.R | Script completo: acquisizione dati, pulizia, PCA, clustering e validazione LDA/QDA. |

## Fonte dati

- [Basketball-Reference — NBA 2025-26 Totals](https://www.basketball-reference.com/leagues/NBA_2026_totals.html)

