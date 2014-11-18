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
2014/11/16 : 1.0 release
2014/11/16 : 1.1 dismount automation added

-----------------------------
1.0 Licencing
-----------------------------
This repository is created under opensource Apache 2.0 licence.
Fell free to read the licence file before distribution. 

----------------------------
2.0 Purpose : 
-----------------------------
- Create a mission library for DCS WORLD to simplify the misison creation 
- no coding or scripting for the missions creator only unit naming in the ME
- Every function can be deactivated from the header.

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
   
> 4.1 Automated ground dismount

- Functionality : 
  units can dismount from ground vehicules. This units can be a rifle squad, AAA, manpads, mortar.
  It's possible to assign randomly a type of dismount, based on probabilities that can be tuned in the script.
  It's possible to assign only one type of dimount.
  All actions are only activated using the units names (not the group names)

- how to :
  - in the ME, triggers, after adding MIST and before adding veaf_library. Add an action "do script file", and chose "DismountsScript.lua" (included in the /scripts/ folder of this library).
  - in the script, make sure that the variable "ENABLE_VEAF_DISMOUNT_GROUND" is true (default)
  - in the ME, set a part of the name of the transport vehicle (can be any vehicle) to the appropriate dismount type tag : 
    - 'veafdm_rnd' : random based on probability settings
    - 'veafdm_sol' : Soldier Squad (rifle + mg + AT)
    - 'veafdm_aaa' : AAA (ZU-23)
    - 'veafdm_mpd' : manpads team
    - 'veafdm_mot' : mortar team
   ex : veafdm_rnd01, red_veafdm_sol, veafdm_aaa_Blue
  
- misc : 
  - identification tags can be changed in the script header
  - appearance probabilities in percent can be sent in the script header :
    - VEAF_dismount_ground_mortar_prob : probability of a mortar team (default = 25)
    - VEAF_dismount_ground_AAA_prob : probability of a AAA (default = 10)
    - VEAF_dismount_ground_manpads_prob = probability of a manpad (default = 05)

- Example mission : VEAF_dismount_ground