VEAF_mission_library
====================


-----------------------------
0.0 Introduction
-----------------------------
- initiateur    : MagicBra (veaf.magicbra-a@t-gmail.com)
- contributeurs : 
- testeurs      :


-----------------------------
0.42 Releases de versions majeures
-----------------------------
- 2014/11/16 : 1.0 release
- 2014/11/17 : 1.1 ajout du débarquement automatique
- 2014/11/18 : 1.2 génération automatique de sites objectifs.

-----------------------------
1.0 Licence
-----------------------------
Sauf mention contraire, ce repository est sous licence open source Apache 2.0.
Lisez le fichier de licence joint avant toute redistribution.

Toutes les librairies du répertoire **/scripts/community** ont des licences propres qui dépendent de leurs auteurs.
Référez vous au fichier txt joint dans ce répertoire pour plus de détails. 

----------------------------
2.0 Objectifs
-----------------------------
- Simplifier l'édition de mission sans prérequis de connaissances en codage de scripts
- Le créateur de mission peut utiliser des fonctionnalités avancées simplement en désignant une zone ou des unités
- Possibilité d'utiliser des critères aléatoires pour améliorer la re-jouabilité d'une même mission
- Chaque fonctionnalité peut être désactivée à partir du *header*.
- Quelques réglages sont disponibles à partir du header des scripts (comme les tags d'identification par exemple)

-----------------------------
3.0 Installation 
-----------------------------

- télécharger mist >= 3.4 (http://forums.eagle.ru/showthread.php?t=98616)
- dans l'éditeur de mission ajouter un nouveau trigger :
  type : once (init mission)
  condition : time more (1) 
  actions :
      do script file (mist.lua)
      do script file (veaf_library.lua)
      
- dans l'éditeur de mission, créer les groupes et les zones correspondants aux fonctionnalités choisies
  lire le paragraphe 4.0 pour plus d'informations.

-----------------------------
4.0 Utilisation
-----------------------------

> 4.1 Groupes à déplacer dans une liste de zones.

- Fonctionnalité : 
  De temps en temps les groupes identifiés se déplaceront d'une zone à l'autre

- Comment :
  - dans le script, s'assurer que la variable "ENABLE_VEAF_RANDOM_MOVE_ZONE" est sur true
  - dans l'éditeur de mission, ajouter un groupe avec une partie du nom correspondant au tag défini dans "VEAF_random_move_zone_zoneTag" (par défaut : veafrz).
    ex : abrams_001_veafrz, veafrz_RED_IFV_42
  - ajouter au moins 1 zone avec une partie du nom correspondant au tag défini dans "VEAF_random_move_zone_groupTag" (par défaut : veafrz).
   ex : City01_veafrz, veafrz_zone84

- Option : 
  - Changer la fréquence de modification des waypoints (dans le script) : VEAF_random_move_zone_timer (en secondes). Par défaut 10 minutes (=600).

- Mission de démo : VEAF_random_zone_move.miz
   
> 4.2 Débarquement automatique

- Fonctionnalité : 
  Les unités peuvent débarquer des véhicules terrestres. Ces unités peuvent être des rifle squad, AAA, manpads, mortar.
  Il est possible d'affecter un type aléatoire de débarquement, basé sur des probabilités qui peuvent être ajustées dans le script.
  Il est possible d'affecter un seul type de débarquement.
  Toutes les actions ne sont activées qu'en utilisant les noms des unités (pas les noms de groupes)

- Comment :
  - dans l'éditeur de mission, au niveau des triggers, après avoir ajouté MIST et avant d'ajouter veaf_library. Ajouter une action "do script file", et choisissez "DismountsScript.lua" (fichier dans le réperoire /scripts/community/ de cette bibliothèque).
  - dans le script, assurez-vous que la variable "ENABLE_VEAF_DISMOUNT_GROUND" est sur true (par défaut : true)
  - dans l'éditeur de mission, utiliser dans une partie du nom du véhicule de transport (pour n'importe quel véhicule) le tag du type approprié de débarquement souhaité : 
    - 'veafdm_rnd' : au hasard, basé sur les réglages de probabilités
    - 'veafdm_sol' : Soldier Squad (rifle + mg + AT)
    - 'veafdm_aaa' : AAA (ZU-23)
    - 'veafdm_mpd' : équipe de manpads
    - 'veafdm_mot' : équipe mortar
    - ex : veafdm_rnd01, red_veafdm_sol, veafdm_aaa_Blue
  
- Options : 
  - les tags d'identification peuvent être changé dans le header du script
  - les pourcentages de probabilités d'apparition peuvent être définis dans le header du script :
    - VEAF_dismount_ground_mortar_prob : probabilité d'apparition d'une équipe mortar (par défaut = 25)
    - VEAF_dismount_ground_AAA_prob : probabilité d'apparition de AAA (par défaut = 10)
    - VEAF_dismount_ground_manpads_prob = probabilité d'apparition d'équipe manpad (par défaut = 05)

- Mission de démo : VEAF_dismount_ground.miz

  
> 4.3 Création automatique d'objectifs/sites basée sur le nom de zone

- Fonctionnalité : 
  Des bâtiments sont ajoutés à une zone correpondante à un tag. La coalition est également ajoutée comme tag au nom.
  Il est possible d'ajouter un type spécifique d'objectif ou de le faire de façon aléatoire.
  Chaque bâtiment présente un petit critère aléatoire de positionnement, de nombre et d'orientation de telle sorte que chaque site puisse présenter un aspect différent.
  Pour le moment les types de bâtiments disponibles sont : Warehouse, Logistics Depot, Oil Pumping Station, Factory (avec de grosses fumées).

- Comment :
	- dans le script, s'assurer que la variable "ENABLE_VEAF_CREATE_OBJECTIVES" est sur true (par défaut : true)
    - dans l'éditeur de mission, ajouter un trigger de zone et définir son rayon (valeur recommandée entre 500 et 1500), les bâtiments vont apparaître à l'intérieur de celui-ci.
    - pour la zone, définir son nom pour qu'il contienne les tags de type et de coalition (par défaut red) :
		- 'veafobj_rnd' : type d'objectif aléatoire
		- 'veafobj_wh' : objectif de type warehouse 
		- 'veafobj_fac' : objectif de type factory (grosses fumées et toilettes ... oui)
		- 'veafobj_log' : objectif de type logistics (avec des bunkers et tours d'observation)
		- 'veafobj_pump' : objectif de type Oil pumping site
		- 'blueside' : objectif affecté au camp bleu (USA)
		- 'redside' : objectif affecté au camp rouge (Russie)
    - ex : veafobj_rnd_blueside, redside_veafobj_pump_42, veafobj_wh.redside01
  
- Problème connu : 
	- parfois certains bâtiments (1 ou 2) n'apparaissent pas, c'est un problème du moteur de script. Mais la plupart des bâtiment seront bien là. 

- Mission de démo : VEAF_dismount_ground.miz
