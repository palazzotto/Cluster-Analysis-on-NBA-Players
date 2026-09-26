# Cluster Analysis on NBA Players

Analisi multivariata esplorativa dei profili di gioco dei giocatori NBA della stagione 2025-26. Il progetto individua archetipi statistici a partire dai volumi di gioco normalizzati per 36 minuti.

## Obiettivo

L'analisi mira a raggruppare giocatori con caratteristiche statistiche simili, superando la sola classificazione per ruolo. I cluster risultanti rappresentano quindi profili o archetipi di gioco osservati nei dati.

## Dati e campione

I dati vengono scaricati dallo script dalla tabella dei totali NBA 2025-26 di [Basketball-Reference](https://www.basketball-reference.com/leagues/NBA_2026_totals.html). Dopo la pulizia, sono mantenuti i giocatori con almeno 1.000 minuti totali: una soglia pensata per concentrarsi sugli atleti di rotazione stabile.

Le metriche usate sono:

- tentativi da tre, da due e tiri liberi;
- rimbalzi offensivi e difensivi;
- assist, palle rubate, stoppate, palle perse e falli personali.

Queste variabili vengono convertite in valori **per 36 minuti**. Punti e minuti vengono esclusi dalla matrice finale per limitare l'effetto del tempo di impiego e della produzione complessiva sulle distanze tra giocatori.

## Metodo

1. Web scraping e pulizia dei dati.
2. Normalizzazione delle statistiche per 36 minuti.
3. Controllo di correlazioni, VIF e normalità.
4. Standardizzazione e Principal Component Analysis (PCA).
5. Confronto tra clustering gerarchico, DIANA e k-means.
6. Selezione della soluzione tramite indice di Calinski-Harabasz.
7. Validazione della partizione tramite LDA/QDA in LOOCV.

## Risultati principali

La soluzione selezionata identifica **3 cluster** di giocatori, interpretabili come archetipi statistici distinti. La PCA consente di sintetizzare le principali dimensioni di variazione e il confronto tra metodi di clustering aiuta a scegliere una partizione stabile e interpretabile.

## Riproducibilità

### Requisiti

- R 4.x
- Pacchetti: rvest, tidyverse, ggplot2, car, fpc, cluster e MASS.

### Esecuzione

Apri R nella cartella del progetto ed esegui:

source("cod_pul_modificato.R")

Lo script scarica i dati aggiornati dalla fonte e genera le analisi e i grafici.

## Contenuto della repository

| File | Descrizione |
| --- | --- |
| README.md | Documentazione del progetto |
| cod_pul_modificato.R | Script R per pulizia, analisi e visualizzazioni |

## Fonte dati

- [Basketball-Reference — NBA 2025-26 Totals](https://www.basketball-reference.com/leagues/NBA_2026_totals.html)
