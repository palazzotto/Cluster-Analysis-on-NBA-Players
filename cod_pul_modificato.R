# Cluster Analysis on NBA Players
# Web scraping, PCA, clustering e validazione discriminante

options(scipen = 999)
library(rvest)
library(tidyverse)
library(car)
library(fpc)
library(cluster)
library(MASS)

# 1. Acquisizione e pulizia dei dati NBA 2025-26
url <- "https://www.basketball-reference.com/leagues/NBA_2026_totals.html"
tabella_grezza <- read_html(url) %>%
  html_element("#totals_stats") %>%
  html_table()

tabella_pulita <- tabella_grezza %>%
  group_by(Player) %>%
  filter(n() == 1 | grepl("TM$", Team)) %>%
  ungroup()
tabella_pulita <- tabella_pulita[-c(583), ]

data <- as.data.frame(tabella_pulita[, c(2, 3, 4, 5, 6, 8, 13, 16, 20, 22, 23, 25:30)])
rownames(data) <- make.unique(as.character(data$Player))
data$Player <- NULL

cols_numeriche <- c("Age", "G", "MP", "3PA", "2PA", "FTA", "ORB", "DRB", "AST", "STL", "BLK", "TOV", "PF", "PTS")
data[cols_numeriche] <- lapply(data[cols_numeriche], as.numeric)
data <- data %>% filter(MP >= 1000)

# 2. Parametrizzazione per 36 minuti e diagnostica
var_volumi <- c("3PA", "2PA", "FTA", "ORB", "DRB", "AST", "STL", "BLK", "TOV", "PF", "PTS")
data36 <- data %>%
  mutate(across(all_of(var_volumi), ~ round((.x / MP) * 36, 1)))

var_studio <- c("3PA", "2PA", "FTA", "ORB", "DRB", "AST", "STL", "BLK", "TOV", "PF")
data_definitivo_num <- data36 %>% select(all_of(var_studio))

matrice_correlazione <- cor(data_definitivo_num, use = "complete.obs")
print(round(matrice_correlazione, 2))

set.seed(123)
y_fake <- rnorm(nrow(data_definitivo_num))
vif_definitivo <- vif(lm(y_fake ~ ., data = data_definitivo_num))
print(vif_definitivo)

risultati_shapiro <- data_definitivo_num %>%
  summarise(across(everything(), ~ shapiro.test(.x)$p.value)) %>%
  pivot_longer(cols = everything(), names_to = "Variabile", values_to = "p_value")
print(risultati_shapiro)

# 3. PCA: riduzione dimensionale su variabili standardizzate
data_scalato <- scale(data_definitivo_num)
pca_res <- prcomp(data_scalato, center = FALSE, scale. = FALSE)
print(summary(pca_res))
print(round(pca_res$rotation[, 1:5], 3))

data_pca <- as.data.frame(round(pca_res$x[, 1:5], 3))

# 4. Benchmarking gerarchico nello spazio PCA
matrice_distanze <- dist(data_pca, method = "euclidean")
metodi_linkage <- c("single", "average", "centroid", "complete", "ward.D2")
k_scelto <- 3

for (metodo in metodi_linkage) {
  hc <- hclust(matrice_distanze, method = metodo)
  cluster_temp <- cutree(hc, k = k_scelto)
  ch <- calinhara(data_pca, cluster_temp)
  cat("Metodo:", metodo, "| K =", k_scelto, "| CH:", round(ch, 5), "\n")
}

# 5. Soluzione finale: Ward + k-means ibrido, K = 3
hc_ward <- hclust(matrice_distanze, method = "ward.D2")
id_ward <- cutree(hc_ward, k = 3)
centroidi_iniziali <- aggregate(data_pca, list(Cluster = id_ward), mean)[, -1]

set.seed(123)
km <- kmeans(data_pca, centers = centroidi_iniziali)
ch_kmeans_pca <- calinhara(data_pca, km$cluster)
cat("CH K-means ibrido nello spazio PCA:", round(ch_kmeans_pca, 5), "\n")

# 6. Profilazione degli archetipi ottenuti
data36$Cluster <- factor(km$cluster[rownames(data36)])
profilo_cluster <- data36 %>%
  group_by(Cluster) %>%
  summarise(
    Giocatori_Totali = n(),
    across(all_of(var_studio), ~ round(mean(.x, na.rm = TRUE), 2), .names = "Media_{.col}")
  )

print(table(data36$Cluster))
print(profilo_cluster)

# 7. Confronto con una soluzione diretta DIANA + k-means, K = 2
data_scaled_diretto <- as.data.frame(scale(data_definitivo_num))
dv_diretto <- diana(data_scaled_diretto, metric = "euclidean", stand = FALSE)
id_diana_2 <- cutree(dv_diretto, k = 2)
centroidi_diana <- aggregate(data_scaled_diretto, list(Cluster = id_diana_2), mean)[, -1]
km_diretto_diana <- kmeans(data_scaled_diretto, centers = centroidi_diana)

cluster_pca_su_standardizzati <- km$cluster[rownames(data_scaled_diretto)]
cluster_standardizzati <- km_diretto_diana$cluster[rownames(data_scaled_diretto)]

confronto_ch_finale <- data.frame(
  Partizione = c(
    "PCA-score: K-means con centroidi Ward (K = 3)",
    "Dati standardizzati: K-means con centroidi DIANA (K = 2)"
  ),
  Indice_Calinski_Harabasz = c(
    calinhara(data_scaled_diretto, cluster_pca_su_standardizzati),
    calinhara(data_scaled_diretto, cluster_standardizzati)
  )
)
print(confronto_ch_finale)

# 8. Validazione discriminante LOOCV della partizione PCA a 3 cluster
valuta_discriminante_loocv <- function(dati, metodo) {
  modello_cv <- if (metodo == "LDA") {
    lda(Cluster ~ ., data = dati, CV = TRUE)
  } else {
    qda(Cluster ~ ., data = dati, CV = TRUE)
  }
  tavola <- table(Osservati = dati$Cluster, Predetti = modello_cv$class)
  accuratezza <- sum(diag(tavola)) / sum(tavola)
  print(tavola)
  cat("Accuratezza", metodo, "LOOCV:", round(accuratezza * 100, 2), "%\n")
  accuratezza
}

data_discriminante_pca <- data_pca %>% select(PC1, PC2, PC3, PC4, PC5) %>%
  mutate(Cluster = factor(km$cluster[rownames(data_pca)]))
data_discriminante_standardizzati <- data_scaled_diretto %>%
  mutate(Cluster = factor(cluster_pca_su_standardizzati))

risultati <- data.frame(
  Modello = c("LDA", "LDA", "QDA", "QDA"),
  Predittori = c("5 PCA-score", "10 variabili standardizzate", "5 PCA-score", "10 variabili standardizzate"),
  Accuratezza_LOOCV = c(
    valuta_discriminante_loocv(data_discriminante_pca, "LDA"),
    valuta_discriminante_loocv(data_discriminante_standardizzati, "LDA"),
    valuta_discriminante_loocv(data_discriminante_pca, "QDA"),
    valuta_discriminante_loocv(data_discriminante_standardizzati, "QDA")
  )
)
print(risultati)
