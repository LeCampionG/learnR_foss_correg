# https://analytics.huma-num.fr/Gregoire.LeCampion/AP1_ANF_FOSS/FOSS_atelierR_CorReg
# https://lecampiong.github.io/FOSS_atelierR_CorReg/

## Pour le chargement des données, leur visualisation et manipulation
library(here)
library(dplyr)
library(DT)
library(table1)

## Pour la réalisation des tests et analyse statistiques
library(correlation)
library(parameters)
library(performance)
# Ces trois packages peuvent être appellés en une fois avec library(easystats). Easystats est une suite de packages tournée vers la réalisation de statistique et offre un environnement de travail trè sdocumenté et intéressant.
library(car)

## Représentations graphiques
library(plotly)
library(RColorBrewer)
library(ggplot2)
library(ggraph)
library(corrplot)
library(GGally)
library(gtsummary)

## Représentation cartographique
library(mapsf)

### SUR PRIX DE L'IMMO ###

# Chargement des données CSV sur le prix de l'immobilier
csv_path <- here("data", "donnees_standr.csv")
immo_df <- read.csv2(csv_path)

# Pour visualiser les données dans le doc
datatable(head(immo_df, 10))

# Chargement des données géographiques sur les EPCI
library(sf)
library(mapsf)
shp_path <- here("data", "EPCI.shp")
epci_sf <- st_read(shp_path)

# pour voir les données géographiques
mf_map(x = epci_sf)
# et la table attributaire correspondante, avec le package DT
datatable(head(epci_sf, 10))

# les 2 données n'ont pas le même nombre de lignes
nrow(immo_df)
nrow(epci_sf)
# l'option all.x = TRUE permet de garder toutes les lignes de epci_sf,
# même celles qui n'ont pas de correspondance dans immo_df
data_immo <- merge(x = epci_sf, y = immo_df, by.x = "CODE_SIREN", by.y = "SIREN", all.x = TRUE)
nrow(data_immo)
# on peut filtrer les données de la jointure pour ne voir que les epci n'ayant pas de correspondance dans le tableau immo_df
datatable(data_immo[is.na(data_immo$prix_med),])
# et pour visualiser les EPCI concernés
mf_map(x = data_immo)
mf_map(x = data_immo[is.na(data_immo$prix_med),], col = 'red', add = TRUE)
# jointure en ne gardant que les EPCI ayant une correspondance dans le tableau de données
data_immo <- merge(x = epci_sf, y = immo_df, by.x = "CODE_SIREN", by.y = "SIREN")
nrow(data_immo)
datatable(head(data_immo, 10))

# ETAPE 1 : EXPLORATION DES VARIABLES

# exploration statistique
library(table1)
table1(~ prix_med + 
         perc_log_vac + 
         perc_maison + 
         perc_tiny_log + 
         dens_pop + 
         med_niveau_vis + 
         part_log_suroccup + 
         part_agri_nb_emploi + 
         part_cadre_profintellec_nbemploi,  
         data=immo_df) 

# exploration graphique
# Distribution de la variable dépendante :
library(plotly)
add_histogram(plot_ly(data_immo, x = ~prix_med))
# Distribution des variables indépendantes :
a <- add_histogram(plot_ly(data_immo, x = ~log(perc_log_vac), name = "perc_log_vac"))
b <- add_histogram(plot_ly(data_immo, x = ~log(perc_maison), name = "perc_maison"))
c <- add_histogram(plot_ly(data_immo, x = ~log(perc_tiny_log), name = "perc_tiny_log"))
d <- add_histogram(plot_ly(data_immo, x = ~log(dens_pop), name = "dens_pop"))
e <- add_histogram(plot_ly(data_immo, x = ~log(med_niveau_vis), name = "med_niveau_vis"))
f <- add_histogram(plot_ly(data_immo, x = ~log(part_log_suroccup), name = "part_log_suroccup"))
g <- add_histogram(plot_ly(data_immo, x = ~log(part_agri_nb_emploi), name = "part_agri_nb_emploi"))
h <- add_histogram(plot_ly(data_immo, x = ~log(part_cadre_profintellec_nbemploi), name = "part_cadre_profintellec_nbemploi"))
fig = subplot(a, b, c, d, e, f, g, h, nrows = 2)
fig

# ETAPE 2 : ETUDE DES CORRELATIONS

# réalisation des corrélations
library(correlation)
data_cor <- immo_df %>% select(-SIREN)
immo_cor <- correlation(data_cor)

# résultats :

# En mode base de données
datatable(head(immo_cor, 10))

# En matrice des corrélations
summary(immo_cor)

# avec un corrélogramme
library(see)
immo_cor %>%
  summary(redundant = FALSE) %>%
  plot(type="tile", show_labels =TRUE, show_p = TRUE, digits = 1, size_text=3) +
  see::theme_modern(axis.text.angle = 45)

# méthode + complexe avec corrplot :
#création d'une matrice redondante
mat_cor_comp <- summary(immo_cor, redundant = TRUE)
# Nom des lignes = valeurs de la première colonne ("Parameter")
rownames(mat_cor_comp ) <- mat_cor_comp[,1]
# Transformation du data.frame en objet matrice (+ suppression première colonne)
mat_cor<- as.matrix(mat_cor_comp[,-1])
# Calcul du nombre total d'individus
nb <- nrow(data_cor)
# Calcul des matrices de p-values et des intervalles de confiance
p.value <- cor_to_p(mat_cor, n = nb, method = "auto")
# Extraction de la matrice des p-value uniquement
p_mat <- p.value$p
library(corrplot)
library(RColorBrewer)
corrplot(mat_cor, 
         p.mat = p_mat, 
         type = "upper", 
         order = "hclust", 
         addCoef.col = "white", 
         tl.col = "gray",
         number.cex = 0.5,
         tl.cex= 1,
         tl.srt = 45, 
         col=brewer.pal(n = 8, name = "PRGn"), 
         sig.level = 0.000001, 
         insig = "blank", 
         diag = FALSE, )

# sous forme de réseau :
library(ggraph) # needs to be loaded
immo_cor$val <-if_else(
  immo_cor$r>0, "positif", "négatif"
)
ggraph(immo_cor, layout = "stress") +
  geom_node_point(size = 8, color="grey")+
  geom_node_text(aes(label = name),family = "serif",repel = TRUE,  max.overlaps = getOption("ggrepel.max.overlaps", default = Inf))+
  geom_edge_link2(aes(filter = p<0.05, edge_colour= val, edge_width = abs(r), label = round(r, 2))) + # on peut indiquer sur le lien avec l'argument  label = r
  scale_edge_width_continuous(range = c(0.1,3))+
  scale_edge_color_manual(
    values = c("positif" = "#1B9E77",
               "négatif" = "#D95F02")
  )

# scatter plot VD /VI
# Relations bivariées - formes fonctionnelles
ggplot(data_immo, aes(x=log(perc_log_vac), y=log(prix_med))) + 
  geom_point() + geom_smooth()

# histogramme VD / toutes les VI :
library(corrr)
# Matrice de corrélation -> data.frame de corrélation
hist_cor <- as_cordf(mat_cor)
# Sélection des corrélations de la variable "year"
hist_cor <- focus(hist_cor, prix_med)
# Si la valeur est positive  = TRUE, sinon FALSE
hist_cor$correlation <- hist_cor$prix_med > 0
ggplot(hist_cor, aes(x = reorder(term, prix_med), y = prix_med, fill = correlation)) +
  geom_bar(stat = "identity", colour = "black") +
  ylab("Corrélation") +
  xlab("Variables") +
  scale_fill_discrete(labels = c("Négative", "Positive")) +
  theme_modern(axis.text.angle = 45) 

# ETAPE 3 : Régression linéaire ou Méthode des moindre carrés ordinaire (MCO)

# Dans le fonctionnement sur R il est important de stocker la régression dans un objet.
mod.lm <- lm(formula = prix_med ~ perc_log_vac + perc_maison + perc_tiny_log + dens_pop + med_niveau_vis + part_log_suroccup + part_agri_nb_emploi + part_cadre_profintellec_nbemploi, 
             data = data_immo)

# On affiche les principaux résultats avec la fonction summary
summary(mod.lm)
# affichage des résultats plus joli
library(gtsummary)
mod.lm %>%
  tbl_regression(intercept = TRUE)
# ou
library(parameters)
model_parameters(mod.lm) |> print_md()
# pour les coefs des VI
GGally::ggcoef_model(mod.lm)

# -> interpréter les résultats

# DIAGNOSTIC DU MODELE

# estimation de la multicolinéarité :

# Avec la librairie "car"
library(car)
vif(mod.lm)

# Avec la librairie "performance" de la suite easystats
# qui propose beaucoup de choses globalement pour vous faciliter la vie si vous faites de la modélisation statistique
# Toutefois attention ce sont plutôt des psychologues qui en sont à l'origine
# et ce sont donc plutôt leurs normes disciplinaires.
library(performance)
check_collinearity(mod.lm)
# On peut aussi directement l'ajouter au résumé des coefficients obtenu avec gtsummary
library(gtsummary)
mod.lm %>%
  tbl_regression(intercept = TRUE) %>% add_vif()

# représentation des résultats
# Avec la librairie "car"
library(car)
score_vif <- vif(mod.lm)
barplot(score_vif, main = "VIF Values", horiz = TRUE, col = "steelblue", las=2)
#ajout du seuil de 4
abline(v = 4, lwd = 3, lty = 2)
# et de la limite de 3
abline(v = 3, lwd = 3, lty = 2)
# Avec la librairie performance
# attention ici pour le VIF il 'agit d'un seuil qui est représenté
# à voir s'il est compatible avec la pratique de votre discipline
colinearite <-  check_collinearity(mod.lm)
plot(colinearite)

# relancement du modèle sans le % de petits logements qui a un VIF élevé
mod.lm2 <- lm(formula = prix_med ~ perc_log_vac + perc_maison + dens_pop + 
                med_niveau_vis + part_log_suroccup + part_agri_nb_emploi + 
                part_cadre_profintellec_nbemploi, data = data_immo)

summary(mod.lm2)
vif(mod.lm2)
library(gtsummary)
mod.lm2 %>%
  tbl_regression(intercept = TRUE) %>% add_vif()
GGally::ggcoef_model(mod.lm2)

# principe de parcimonie
step(mod.lm2, direction = "backward")
# relancer le modèle sans la part d'agris
mod.lm3 <- lm(formula = prix_med ~ perc_log_vac + perc_maison + dens_pop + med_niveau_vis + part_log_suroccup + part_cadre_profintellec_nbemploi, data = data_immo)
summary(mod.lm3)
# comparer les modèles
library(performance)
perf <- compare_performance(mod.lm, mod.lm2, mod.lm3)
print_md(perf)
# représentation graphique de la comparaison des modèles
library(see)
plot(perf)

# analyse des résidus :

# obtenir les résidus
res_modlm <- mod.lm$residuals
datatable(as.data.frame(res_modlm))
# visualiser les résidus
par(mfrow=c(1,3))
qqPlot(mod.lm) # diagramme quantile-quantile qui permet de vérifier l'ajustement d'une distribution à un modèle théorique, ici loi normale
hist(rstudent(mod.lm), breaks = 50, col="darkblue", border="white", main="Analyse visuelle des résidus") # Histogramme pour donner une autre indication sur la normalité
plot(rstudent(mod.lm)) # un graphique pour visualiser l'homoscédasticité des résidus
# Pour étudier la normalité on peut utiliser le test de Shapiro-Wilk
shapiro.test(mod.lm$residuals)
# Pour évaluer l'homoscédasticité on peut utiliser le test de Breusch-Pagan
# Le package car propose une fonction pour le réaliser
ncvTest(mod.lm)
# Pour la normalité des résidus
normality <- check_normality(mod.lm)
normality
plot(normality)
# Pour l'homoscédasticité
heteroscedasticity <- check_heteroscedasticity(mod.lm)
heteroscedasticity
plot(heteroscedasticity)
ind_ext <- check_outliers(mod.lm)
ind_ext
plot(ind_ext, type = "dots")

# outliers :

# Pour visualiser les individus concernés
data_immo[c(36, 266),]
# Pour relancer un nouveau modèle sans l'individu le plus extrême
# Notez que l'on peut en supprimer plusieurs d'un coup avec subset =-c(36,266)
mod.lmx <- update(mod.lm, subset=-266)
# Etudier le nouveau modèle
summary(mod.lmx)
vif(mod.lmx)
# Il est possible de comparer les deux modèles et les coefficients
car::compareCoefs(mod.lm, mod.lmx, pvals = TRUE)
# Si on r
perf2 <- compare_performance(mod.lm, mod.lmx)
print(perf2)
plot(perf2)

# autocorrélation des résidus :
check_autocorrelation(mod.lm)
# voisinage
neighbours_epci <- poly2nb(data_immo, queen = TRUE) 
neighbours_epci_w <- nb2listw(neighbours_epci)
# test de moran des residus de la régression H0: pas d'autocorrélation spatiale
library(spdep)
lm.morantest(model = mod.lm, 
             listw = neighbours_epci_w)
# Test de Geary H0 pas d'autocorrélation.
#  Attention : Pour avoir le  coefficient il faut faire 1-"Résultat test de Geary" (soit ici le coefficient est 0.67)
# Le coefficient de Geary s'étend de 0 à 2, 1 étant le "0" et signifiant aucune corrélation
# Par ailleurs, un score inférieur à 1 implique une corrélation positive et un score supérieur à 1 une corrélation négative.
geary(x = data_immo$prix_med, 
      listw = neighbours_epci_w,
      n = length(neighbours_epci), 
      n1 = length(neighbours_epci)-1, 
      S0 = Szero(neighbours_epci_w))
# carto des résidus
data_immo$res_reg <- mod.lm$residuals
# Définition d'une palette de couleur
cols_v1 <- c("#08519c", "#3182bd", "#6baed6", "#9ecae1", "#c6dbef", "#eff3ff", "#ffffce", "#fee5d9", "#fcbba1", "#fc9272",  "#fb6a4a", "#de2d26")
# Réalisation de la carte
mf_map(x = data_immo, 
       var = "res_reg", 
       type = "choro", 
       border = "#ebebeb", 
       lwd = 0.1, 
       breaks=quantile(data_immo$res_reg,seq(0,1, by=1/11)), 
       pal=cols_v1, 
       leg_title = "Résidus de régression\nlinéaire 'classique'", 
       leg_val_rnd = 1)
mf_title("Résidus modèle lm") #titre

#  vérifier en une fois toutes les conditions de votre modèle de régression
check_model(mod.lm)

