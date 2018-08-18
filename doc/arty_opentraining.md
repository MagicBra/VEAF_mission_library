# Artillerie pour la mission opentraining   

Le script [arty_opentraining.lua](../scripts/arty_opentraining.lua) permet de gérer des batteries d'artillerie.
Il utilise le module *arty* de l'excellent [*Moose*](https://github.com/FlightControl-Master/MOOSE).
Je n'ai pas fait grand chose d'autre que de définir des groupes (batteries) et de les initialiser pour que *Moose* permette de les gérer. 
Vous trouverez la documentation complète du module [ici](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Arty.html).

## Mission Maker

TODO

## Utilisation

### Principe

Pour commander les batteries d'artillerie, il suffit de créer un marker sur la carte F10, de mettre dans le texte de ce marker un texte qui représente une commande, et enfin de cliquer à l'extérieur du marker pour le valider.

Les commandes qui sont reconnues par ce script sont :

> arty engage

> arty move

> arty request

> arty cancel

Les paramètres sont de la forme *paramètre* *valeur*, séparés les uns des autres (et de la commande) par des virgules.
Exemple :

> arty engage, everyone, shots 50

### Liste des unités disponibles

- Alpha 1 ; artillerie de campagne (howitzer) ; clusters Alpha et Short
- Alpha 2 ; artillerie de campagne (howitzer) ; clusters Alpha et Short
- Bravo 1 ; artillerie de campagne (howitzer) ; clusters Bravo et Short
- Bravo 2 ; artillerie de campagne (howitzer) ; clusters Bravo et Short
- Long 1 ; lance roquettes multiples (MLRS) ; cluster Long
- Long 2 ; lance roquettes multiples (MLRS) ; cluster Long
- Perry 1 ; Frégate [Oliver Hazard Perry](https://en.wikipedia.org/wiki/Oliver_Hazard_Perry-class_frigate) ; cluster Perry
- Perry 2 ; Frégate [Oliver Hazard Perry](https://en.wikipedia.org/wiki/Oliver_Hazard_Perry-class_frigate) ; cluster Perry

### Liste des commandes et de leurs paramètres (non exhaustive)

#### arty engage

Déclenche une frappe d'artillerie sur l'emplacement du marqueur (ou ailleurs, voir paramètre *lldms*).

##### batteries

Détermine les unités qui vont engager le combat.
Il peut valoir *everyone* (ou *allbatteries*) pour engager toutes les batteries disponibles.
On peut aussi préciser un cluster (groupement de batteries, voir liste des batteries) en précisant *cluster* "*nom du cluster*"
Exemple : 
> arty engage, cluster "long"

Il est également possible de choisir une batterie (voir liste des batteries) en précisant *battery* "*nom de la batterie*"
Exemple : 
> arty engage, battery "Alpha 1"

##### time 

Ce paramètre permet de différer l'engagement. 
Il s'utilise comme dans l'exemple :
> arty engage, time 23:17 

##### shots

Nombre de munitions tirées (globalement, par toutes les unités participant à l'engagement).
> arty engage, shots 28

##### maxengage

Nombre de fois que la cible sera engagée (par défaut 1).
> arty engage, maxengage 4

##### radius

Rayon de dispersion des munitions, en mètres (par défaut 100).
> arty engage, radius 500

##### weapon 

Arme employée. Permet de choisir entre les différentes armes et munitions disponibles.
> arty engage, weapon smokeshells

> arty engage, weapon nuke

##### lldms

Permet de spécifier les coordonnées de l'engagement. Le marker d'origine disparait et un nouveau marker apparait à l'emplacement spécifié.
> arty engage, lldms 41:15:10N 44:17:22E

#### arty move

Fait se déplacer la batterie vers le marker.

##### time 

Ce paramètre permet de différer le déplacement 
Il s'utilise comme dans l'exemple :
> arty move, time 23:17

##### speed 

Vitesse de déplacement en km/h.

##### batteries

Détermine les unités qui vont se déplacer.
Il peut valoir *everyone* (ou *allbatteries*) pour déplacer toutes les batteries disponibles.
On peut aussi préciser un cluster (groupement de batteries, voir liste des batteries) en précisant *cluster* "*nom du cluster*"
Exemple : 
> arty move, cluster "long"

Il est également possible de choisir une batterie (voir liste des batteries) en précisant *battery* "*nom de la batterie*"
Exemple : 
> arty move, battery "Alpha 1"

##### lldms

Permet de spécifier les coordonnées du déplacement. Le marker d'origine disparait et un nouveau marker apparait à l'emplacement spécifié.
> arty move, lldms 41:15:10N 44:17:22E

#### arty request

##### batteries

Détermine les unités qui vont se répondre.
Il peut valoir *everyone* (ou *allbatteries*) pour interroger toutes les batteries disponibles.
On peut aussi préciser un cluster (groupement de batteries, voir liste des batteries) en précisant *cluster* "*nom du cluster*"
Exemple : 
> arty request, cluster "long"

Il est également possible de choisir une batterie (voir liste des batteries) en précisant *battery* "*nom de la batterie*"
Exemple : 
> arty request, battery "Alpha 1"

##### target

Demande des informations sur la cible actuelle des batteries.

##### move  

Demande des informations sur le déplacement des batteries.

##### ammo

Demande des informations sur les stocks de munitions.

#### arty cancel

Permet d'annuler la commande actuelle. Il est également possible de simplement supprimer le marker.

##### batteries

Détermine les unités qui vont se répondre.
Il peut valoir *everyone* (ou *allbatteries*) pour interroger toutes les batteries disponibles.
On peut aussi préciser un cluster (groupement de batteries, voir liste des batteries) en précisant *cluster* "*nom du cluster*"
Exemple : 
> arty request, cluster "long"

Il est également possible de choisir une batterie (voir liste des batteries) en précisant *battery* "*nom de la batterie*"
Exemple : 
> arty request, battery "Alpha 1"


