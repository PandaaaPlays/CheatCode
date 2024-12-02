# DETU DB Tools

*_Cet outil est temporaire et sera probablement migré vers GitLab CI prochainement._*
## Outil de vérification des accès VEO par CIP

Permet de lister les accès d'un CIP donné, sur l'ensemble des serveurs de base de données VÉO 1.

## Pré-requis

Accès GitLab 
 -> ```git clone git@gitlab.sti.usherbrooke.ca:sdtde-detu/DETU-DB-Tools.git ```

PowerShell
 -> Autorisation d'exécuter des scripts ```set-executionpolicy remotesigned ```

Accès SSH autorisé -> ```acces.sti.usherbrooke.ca```

## Installation

Utiliser le raccourci Windows **".\Vérification_accès_VEO_par_CIP - Raccourci.lnk"** pour lancer l'outil.

*_On peut également directement utiliser le script PowerShell **"Execute-VerificationCIP.ps1"**._*


## ./config

Contient les informations de connexion aux différentes bases de données, qui seront utilisées par l'outil.


## ./init

Contient différents scripts d'initialisation afin de permettre le fonctionnement de l'outil.


## ./sql

Contient les scripts SQL utilisés par l'outils. 