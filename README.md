VEAF_misison_library
====================


-----------------------------
0.0 Introduction
-----------------------------
- initiator    : MagicBra (veaf.magicbra-a@t-gmail.com)
- contributors : 
- testers      :


-----------------------------
0.42 Major Versions and releases
-----------------------------
- 2014/11/16 : 1.0 release
- 2014/11/17 : 1.1 dismount automation added
- 2014/11/18 : 1.2 automated objective site generation.
- 2014/12/11 : 1.3 randome smokes in area (infantry warfare simulation)
- 2014/01/02 : 1.4 Ground patrols added

-----------------------------
1.0 Licensing
-----------------------------
Unless specified this repository is created under opensource Apache 2.0 licence.
Fell free to read the licence file before distribution. 

All included libraries in the folder /scripts/community have their own licensing regarding their authors.
Please refer to the txt file included in this folder for more infos. 

----------------------------
2.0 Purpose : 
-----------------------------
- Simplify the mission edition with no scripting knowledge needed
- The mission creator is able to include advanced functionalities just by naming a zone or some units
- Possibility to add randomization to enhance the mission re-playability 
- Every functionality can be deactivated from the header.
- Some tweaks are available in the scripts header (such as the identification tags)

-----------------------------
3.0 Installation 
-----------------------------

- download mist >= 3.4 (http://forums.eagle.ru/showthread.php?t=98616)
- in the ME add a new trigger :
  type : once (init mission)
  condition : time more (1) 
  actions :
      do script file (mist.lua)
      do script file (veaf_library.lua)
      
- in the ME, create groups and zones corresponding to the chosen functionalities
  check 4.0 for more infos.

-----------------------------
4.0 Usage
-----------------------------

> 4.1 Groups to move inside a zone list.

- Functionality : 
  From time to time all groups identified will move between

- how to :
  - in the script, make sure that the variable "ENABLE_VEAF_RANDOM_MOVE_ZONE" is true
  - in the ME, add a group with part of the name matching the tag defined in "VEAF_random_move_zone_zoneTag" (default : veafrz).
    ex : abrams_001_veafrz, veafrz_RED_IFV_42
  - add at least 1 zone with part of the name matching the tag defined in "VEAF_random_move_zone_groupTag" (defaul : veafrz).
   ex : City01_veafrz, veafrz_zone84

- misc : 
  - Change waypoint modification frequency (in the script) : VEAF_random_move_zone_timer (in seconds). default 10 minutes (=600).
 
- Example mission : VEAF_random_zone_move.miz
   
> 4.2 Automated ground dismount

- Functionality : 
  units can dismount from ground vehicules. This units can be a rifle squad, AAA, manpads, mortar.
  It's possible to assign randomly a type of dismount, based on probabilities that can be tuned in the script.
  It's possible to assign only one type of dimount.
  All actions are only activated using the units names (not the group names)

- how to :
  - in the ME, triggers, after adding MIST and before adding veaf_library. Add an action "do script file", and chose "DismountsScript.lua" (included in the /scripts/community/ folder of this library).
  - in the script, make sure that the variable "ENABLE_VEAF_DISMOUNT_GROUND" is true (default)
  - in the ME, set a part of the name of the transport vehicle (can be any vehicle) to the appropriate dismount type tag : 
    - 'veafdm_rnd' : random based on probability settings
    - 'veafdm_sol' : Soldier Squad (rifle + mg + AT)
    - 'veafdm_aaa' : AAA (ZU-23)
    - 'veafdm_mpd' : manpads team
    - 'veafdm_mot' : mortar team
    - ex : veafdm_rnd01, red_veafdm_sol, veafdm_aaa_Blue
  
- misc : 
  - identification tags can be changed in the script header
  - appearance probabilities in percent can be sent in the script header :
    - VEAF_dismount_ground_mortar_prob : probability of a mortar team (default = 25)
    - VEAF_dismount_ground_AAA_prob : probability of a AAA (default = 10)
    - VEAF_dismount_ground_manpads_prob = probability of a manpad (default = 05)

- Example mission : VEAF_dismount_ground.miz

  
> 4.3 Automated objectives/site creation based on zone name

- Functionality : 
  Buildings will be added in a zone matching a tag. the coalition is also tagged in tha name.
  It's possible to add a specific objective type or make a random one.
  Each building had a little randomization on the placement and their numbers and orientation so each site looks different.
  For now the types available are : Warehouse, Logistics Depot, Oil Pumping Station, Factory (with big smokes).

- how to :
	- in the script, make sure that the variable "ENABLE_VEAF_CREATE_OBJECTIVES" is true (default)
    - in the ME, add a trigger zone and set its radius (recommended 500 to 1500), the buildings will pop inside.
    - For the zone, set its name to contain the good type tag and coalition tag (default is red):
		- 'veafobj_rnd' : random objective type
		- 'veafobj_wh' : warehouse objective type 
		- 'veafobj_fac' : factory objective type (big smokes and toilets ... yep)
		- 'veafobj_log' : logistics objective type (with some bunkers and watchtowers)
		- 'veafobj_pump' : Oil pumping site objective type
		- 'blueside' : makes the objective with blue units (USA)
		- 'redside' : makes the objective with red units (Russia)
    - ex : veafobj_rnd_blueside, redside_veafobj_pump_42, veafobj_wh.redside01
  
- known issue : 
	- sometimes some buildings (1 or 2) won't appear, it's an issue of the scripting engine. But most of them are there. 

- Example mission : VEAF_dismount_ground.miz


> 4.4 Automated random smoke generation based on zone name

- Functionality : 
  A determined number a smokes will be generated in each zones with the correct tag. 
  each smoke has a random colour and starts with a small offset altitude (so they all look different on the battlefield) 
  the smoke lifetime is determined by the game engine (about 300sec when this script was created)

- how to :
	- in the script, make sure that the variable "ENABLE_VEAF_GENERATE_RANDOM_SMOKES" is true (default)
    - in the ME, add a trigger zone and set its radius (recommended 500 to 1500), the smokes will pop inside.
    - For the zone, set its name to contain the good tag identified by the variable VEAF_generate_random_smokes_in_zone_zoneTag in the script (default is 'VEAFsmokernd'):
    - ex of zone names in ME : VEAFsmokernd, VEAFsmokernd01, VEAFsmokernd #42, totoVEAFsmokerndtiti
  
- known issue : 
	- too many smokes can slow down the clients in multilayer and create timeout from the server (tested with 100 w/o problem) .

- Example mission : VEAF_random_smokes.miz


> 4.5 Automated patrol for ground groups 

- Functionality : 
  Each group matching the tag in its name will patrol go back to its first waypoint when passing the last one. 

- how to :
    - in the ME, name a group with the correct tag identified in the script by VEAF_ground_patrol_groupTag (default : veafpat)
    - ex of group names in ME : veafobj_rnd_blueside_veafpat, veafpat #42, AAA.veafpat
  
- known issue : 
	- the script engine may not follow the determined roads if the WP are too close, and the groups may change their formation type.

- Example mission : VEAF_Automated_patrols.miz
