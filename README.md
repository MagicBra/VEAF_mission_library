VEAF_misison_library
====================


-----------------------------
0.0 Introduction
-----------------------------
- initiator    : MagicBra (nosdudefr-a@t-gmail.com)
- contributors : 
- testers      :


-----------------------------
0.42 Major Versions and releases
-----------------------------
2014/11/16 : 1.0 release

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
      do sctipe file (veaf_library.lua)
      
- in the ME, create groups and zones corresponding to the choosen functionnalities
  check 4.0 for more infos.

-----------------------------
4.0 Usage
-----------------------------

> 4.1 Groups to move inside a zone list.

- Functionnality : 
  From time to time all groups identified will move between

- how to :
  - in the script, make sure that the variable "ENABLE_VEAF_RANDOM_MOVE_ZONE" is true
  - in the ME, add a group with part of the name matching the tag defined in "VEAF_random_move_zone_zoneTag" (default : veafrz).
    ex : abrams_001_veafrz, veafrz_RED_IFV_42
  - add at least 1 zone with part of the name matching the tag defined in "VEAF_random_move_zone_groupTag" (defaul : veafrz).
   ex : City01_veafrz, veafrz_zone84

- misc : 
  - Change waypoint modification frequency (in the script) : VEAF_random_move_zone_timer (in seconds). default 10 minutes (=600).
   
