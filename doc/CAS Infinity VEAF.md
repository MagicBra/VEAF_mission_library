# CAS Infinity VEAF - création de zones de combat pour l'entrainement   

Le script [CAS Infinity VEAF.lua](../scripts/CAS Infinity VEAF.lua) permet de générer facilement des zones de combat aléatoires, pour permettre un entrainement sur mesure.
En fonction du type d'entrainement souhaité et d'appareil piloté, il est possible de choisir des cibles faciles à abattre, ou très fortement défendues.

## Mission Maker

TODO

## Utilisation

### Principe

Pour générer une zone de CAS, il suffit de créer un marker sur la carte F10, de mettre dans le texte de ce marker un texte qui représente une commande, et enfin de cliquer à l'extérieur du marker pour le valider.

La commande qui est reconnue par ce script est :

> create ao

Les paramètres sont de la forme *paramètre* *valeur*, séparés les uns des autres (et de la commande) par des virgules.
Exemple :

> create ao, size 3, sam 1, armor 0

### Liste des paramètres et valeurs par défaut

Chacun des paramètres possède une valeur par défaut. Si le paramètre est omis, c'est cette valeur qui sera utilisée.

#### size

Règle la taille du groupe

Valeur par défaut : 1
Champ d'application : 1 à 5

En modifiant ce paramètre, on peut créer des groupes de 2 à 5 fois plus grand que la taille par défaut.
Attention : comme les groupes sont générés aléatoirement, la taille réelle peut différer de ce que le paramètre signifie.

#### sam

Règle la difficulté de la mission en changeant les défenses anti-aériennes du groupe.
Attention : pour les pilotes d'hélicoptère, voir aussi le paramètre *armor*

Valeur par défaut : 1
Champ d'application : 0 à 5

A zéro, aucune défense n'est générée.
Entre 1 et 3, on augmente progressivement le nombre de défenses sans changer la fréquence de distribution statistique (qui gouverne le type de défense généré).
En passant à 4, puis 5, on augmente également la probabilité que les défenses soient plus coriaces (par exemple il devient moins rare de voir des SA-15)

#### armor

Règle le type de blindés générés. 

Valeur par défaut : 1
Champ d'application : 0 à 5

A zéro, aucun blindé n'est généré.
En augmentant la valeur, les blindés générés sont de plus en plus lourds et dangereux.
Attention : comme les groupes sont générés aléatoirement, il est possible (quoi que peu probable) d'avoir des T90 dans un groupe *armor 1* ou de n'avoir que des BRDM dans un groupe *armor 5*. 

#### spacing

Règle l'espacement des unités et la taille de la zone.
Valeur par défaut : 3
Champ d'application : 1 à 5

Pour chaque type d'unité (fantassin, transport, blindé, défense), la taille par défaut de la zone de placement diffère. 
En modifiant ce paramètre, il est possible de réduire (2, voire 1) ou d'augmenter (4, ou 5) la taille de cette zone, et donc d'espacer moins ou plus les unités.

## Règles de génération

TODO