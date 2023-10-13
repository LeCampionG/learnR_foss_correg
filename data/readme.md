## Données de la formation iFoss

| Nom | Résumé | Source | Notes |
|--- |--- |--- |--- |
| data_marseille.csv | Données de pauvreté par IRIS pour Marseille (cf. détail des variables ci-dessous) | INSEE https://www.insee.fr/fr/statistiques/6049648 | Les variables explicatives ont été centrées-réduites |
| donnees_standr.csv  | Prix médian de l'immobilier par EPCI en France métropolitaine (cf. détail des variables ci-dessous) | base Notaires de France https://www.immobilier.notaires.fr/fr/prix-immobilier | Les variables explicatives ont été centrées-réduites |
| EPCI.shp  | EPCI France métropolitaine + Corse édition 2021 | IGN ADMIN-EXPRESS-COG édition 2021 par territoire https://geoservices.ign.fr/adminexpress | Les données de l'IGN ont été simplifiées avec [mapshaper]([https://mapshaper.org/) pour en réduire le poids, en utilisant l'algorithme *Visvalingam/weighted area* avec une valeur de 1 |
| IRIS13_GE.shp  | Iris recalés sur les données BD TOPO® (précision 1 m) | IGN IRIS…GE® https://geoservices.ign.fr/irisge |  |
| REGION.shp  | Nouvelles régions France métroplitaine + Corse édition 2021 | IGN ADMIN-EXPRESS-COG édition 2021 par territoire https://geoservices.ign.fr/adminexpress  | Les données de l'IGN ont été simplifiées avec [mapshaper]([https://mapshaper.org/) pour en réduire le poids, en utilisant l'algorithme *Visvalingam/weighted area* avec une valeur de 1 |

Détail de **data_marseille.csv** :
Ce fichier a été constitué à partir de données de l'INSEE. Il contient les variables suivantes (attention, toutes les variables hormis le taux de bas revenu ont été centrées-réduites) :

- id_IRIS : code IRIS
- label_iris : nom de l'IRIS
- code_insee : code INSEE de la commune
- label_com : nom de la commune
- tx_bas_revenu : taux de bas revenus déclarés au seuil de 60% (%) (variable DEC_TP6019 du fichier [BASE_TD_FILO_DEC_IRIS_2019.csv](https://www.insee.fr/fr/statistiques/6049648))
- PartPop_fr : 
- hlm_res_princ : part /personne de résidences principales HLM loué vide en 2017 (%) (variable P17_RP_LOCHLMV du fichier [base-ic-logement-2017](https://www.insee.fr/fr/statistiques/4799305))
- unevoiture : part de ménages disposant au moins d'une voiture en 2017 (%) (variable P17_RP_VOIT1P du fichier [base-ic-logement-2017](https://www.insee.fr/fr/statistiques/4799305))
- res120plus : part de résidences principales de 120 m2 ou plus en 2017 (%) (variable P17_RP_120M2P du fichier [base-ic-logement-2017](https://www.insee.fr/fr/statistiques/4799305))
- masc_cadre : part d'hommes de 15 ans ou plus cadres et professions intellectuelles supérieures (%) (variable C17_H15P_CS3 du fichier [base-ic-evol-struct-pop-2017](https://www.insee.fr/fr/statistiques/4799309?sommaire=4658626))
- fem_noncadre : part de femmes de 15 ans ou plus autres sans activité professionnelle (variable C17_F15P_CS8 du fichier [base-ic-evol-struct-pop-2017](https://www.insee.fr/fr/statistiques/4799309?sommaire=4658626))


Détail de **donnees_standr.csv** :
Ce fichier a été constitué par Frédéric Audard et Alice Ferrari à partir de la base Notaires de France. Il contient les variables suivantes (attention, toutes les variables hormis le prix médian ont été centrées-réduites) :

- SIREN : code SIREN de l'EPCI
- prix_med : pris médian par EPCI à la vente (au m2 ?)
- perc_log_vac : % logements vacants
- perc_maison : % maisons
- perc_tiny_log : % petits logements (surface < ?)
- dens_pop : densité de population (nb habitants / km2 ?)
- med_niveau_vis : médiane du niveau de vie
- part_log_suroccup : % logements suroccupés
- part_agri_nb_emploi : % agriculteurs
- part_cadre_profintellec_nbemploi : % cadres et professions intellectuelles

