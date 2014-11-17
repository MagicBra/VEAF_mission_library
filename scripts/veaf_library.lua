------------------------------------------------------------------------
-- Function library for the VEAF missions
-- More infos : http://www.VEAF.org
-- last version : https://github.com/MagicBra/VEAF_misison_library
------------------------------------------------------------------------
-- Other ressources and thanks : 
-- MIST  library from Grimes and Speed (http://wiki.hoggit.us/view/Mission_Scripting_Tools_Documentation)
-- Dismount script from mbot (http://forums.eagle.ru/showthread.php?t=109676)
--
-- thanks everyone of DCS community for making all the tests and reports :)
------------------------------------------------------------------------
-- initiator    : MagicBra (nosdudefr-a@t-gmail.com)
-- contributors : 
-- testers      :
------------------------------------------------------------------------
-- versions : 
-- 0.1 : + added random move between zones for a group
-- 0.2 : + added check to enable the functions 

------------------------------------------------------------------------------------------------------------
-- Configuration for the movement between random zones for ground units
------------------------------------------------------------------------------------------------------------

-- enable or disable the usage of the movement between zones
ENABLE_VEAF_RANDOM_MOVE_ZONE = false;
-- part of the group name identifying the zone where groups can move
VEAF_random_move_zone_zoneTag = 'veafrz'
-- part of the group name identifying the groups afected
VEAF_random_move_zone_groupTag = 'veafrz'
-- time in seconds before the groups will have a new waypoint
VEAF_random_move_zone_timer = 600

------------------------------------------------------------------------------------------------------------
-- Configuration for the auto dismount for ground units
------------------------------------------------------------------------------------------------------------

-- enable troups to embark and disembark form ground vehicules
ENABLE_VEAF_DISMOUNT_GROUND = true
-- tag in the vehicule name that will have dismount with a random dismount
VEAF_dismount_ground_random_tag = 'Unit'
-- tag in the vehicule name that will have dismount with a fireteam (rifles)
VEAF_dismount_ground_soldiers_tag = 'veafdm_sol'
-- tag in the vehicule name that will have dismount with a AAA
VEAF_dismount_ground_AAA_tag = 'veafdm_aaa'
-- tag in the vehicule name that will have dismount with a manpads
VEAF_dismount_ground_manpads_tag = 'veafdm_mpd'
-- tag in the vehicule name that will have dismount with a mortar team
VEAF_dismount_ground_mortars_tag = 'veafdm_mot'

-- in cas of random : probability of dismount in percent, default is soldier
VEAF_dismount_ground_mortar_prob = 25
VEAF_dismount_ground_AAA_prob = 10
VEAF_dismount_ground_manpads_prob = 05


------------------------------------------------------------------------
----- NO MODIFICATION BELIW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
----- NO MODIFICATION BELIW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
----- NO MODIFICATION BELIW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
----- NO MODIFICATION BELIW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
------------------------------------------------------------------------

------------------------------------------------------------------------------
-- function : VEAF_get_units_with_tag
-- args     : 1, searchTag : part of the unit name to search in the zone list
-- output   : array : units identified
------------------------------------------------------------------------------
-- Objective: returns an array of units identified by the tag in arg1
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 18/11/14 + creation
------------------------------------------------------------------------------
function VEAF_get_units_with_tag(searchTag)

	local unitsArray = {}
	
	for _, u in pairs(mist.DBs.aliveUnits) do
		name = u.unit:getName()
		if string.find(string.lower(name), string.lower(searchTag)) then
            table.insert(unitsArray, name)
        end
	end
	
	return unitsArray
	
end

------------------------------------------------------------------------------
-- function : VEAF_get_zones_with_tag
-- args     : 1, searchTag : part of the zone name to search in the zone list
-- output   : array : groups identified
------------------------------------------------------------------------------
-- Objective: returns an array of groups identified by the tag in arg1
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 16/11/14 + creation
------------------------------------------------------------------------------
function VEAF_get_zones_with_tag(searchTag)

    local zonesArray = {}

    for name, zone in pairs(mist.DBs.zonesByName) do
        if string.find(string.lower(name), string.lower(searchTag)) then
            table.insert(zonesArray, name)
        end
    end
    return zonesArray;
    
end

------------------------------------------------------------------------------
-- function : VEAF_get_groups_with_tag
-- args     : 1, searchTag : part of the name to search in the group list
-- output   : array : groups identified
------------------------------------------------------------------------------
-- Objective: returns an array of groups identified by the tag in arg1
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 12/11/14 + creation
-- Version  : 1.1 16/11/14 ~ case sensitive removed
------------------------------------------------------------------------------
function VEAF_get_groups_with_tag(searchTag)

	local groupsArray = {}
	
	 for groupName, groupData in pairs(mist.DBs.groupsByName) do
		if string.find(string.lower(groupName), string.lower(searchTag)) then
			table.insert(groupsArray, groupName)
		end
	end
	return groupsArray
	
end

------------------------------------------------------------------------------
-- function : VEAF_get_group_coalition
-- args     : 1, groupName : exact name of the group to seachr the coa for
-- output   : array : groups identified
------------------------------------------------------------------------------
-- Objective: returns the coalition blue or red of the group
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 17/11/14 + creation
------------------------------------------------------------------------------
function VEAF_get_group_coalition(groupName)
	
	local groupCoa = 'unknown'
	
	for groupName, groupData in pairs(mist.DBs.groupsByName) do
		if (string.lower(groupName) == string.lower(searchTag)) then
			groupCoa = groupData.coalition
		end
	end
	return groupCoa
	
end

------------------------------------------------------------------------------
-- function : AUTO_VEAF_move_group_to_random_zone
-- args     : N/A
-- output   : N/A
------------------------------------------------------------------------------
-- Objective: move any groups identified with a tag to a random zone list identified by a tag
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 0.1 10/11/14 + creation
--            0.2 12/11/14 + add automation
--            1.0 16/11/14 ~ replace zone list for tag search, 
--						   + add tag search param for group search
------------------------------------------------------------------------------
function AUTO_VEAF_move_group_to_random_zone()

	--- search zones with tag (global var)
	local zoneList  = VEAF_get_zones_with_tag(VEAF_random_move_zone_zoneTag)
	local groupList = VEAF_get_groups_with_tag(VEAF_random_move_zone_groupTag)
	
	-- actions !
	for id, groupName in pairs(groupList) do
			VEAF_move_group_to_random_zone(groupName, zoneList)
	end

    -- schedule function
    timer.scheduleFunction(AUTO_VEAF_move_group_to_random_zone, nil, timer.getTime() + VEAF_random_move_zone_timer)
end

-- core function to move units
function VEAF_move_group_to_random_zone(group, zoneList)
	mist.groupToRandomZone(group, zoneList)
end



------------------------------------------------------------------------------
-- function : AUTO_VEAF_move_group_to_random_zone
-- args     : N/A
-- output   : N/A
------------------------------------------------------------------------------
-- Objective: add dismount to units based on a tag in their name
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 17/11/14 + creation
------------------------------------------------------------------------------
function AUTO_VEAF_dismount_ground()

	--- search units with tag (global var)
	local unitsListWithRandom = VEAF_get_units_with_tag(VEAF_dismount_ground_random_tag)
	local unitsListOnlySoldier = VEAF_get_units_with_tag(VEAF_dismount_ground_soldiers_tag)
	local unitsListOnlyAAA = VEAF_get_units_with_tag(VEAF_dismount_ground_AAA_tag)
	local unitsListOnlyManpads = VEAF_get_units_with_tag(VEAF_dismount_ground_manpads_tag)
	local unitsListOnlyMortars = VEAF_get_units_with_tag(VEAF_dismount_ground_mortars_tag)
	
	
	-- add dismount with rifles/soldiers only
	for id, unitName in pairs(unitsListOnlySoldier) do
			AddDismounts(unitName, "Rifle")
	end
	
	-- add dismount with AAA only
	for id, unitName in pairs(unitsListOnlyAAA) do
			AddDismounts(unitName, "ZU-23")
	end
	
	-- add dismount with manpads only
	for id, unitName in pairs(unitsListOnlyManpads) do
			AddDismounts(unitName, "MANPADS")
	end
	
	-- add dismount with manpads only
	for id, unitName in pairs(unitsListOnlyMortars) do
			AddDismounts(unitName, "Mortar")
	end
	
	-- add dismount with manpads only
	for id, unitName in pairs(unitsListWithRandom) do
			-- making a little random magic pipidibou !
			proba = math.random(1,100)
			mountType = _VEAF_get_random_mount_type(proba)
			--AddDismounts(unitName, mountType)
			return {unitName, proba, mountType)
	end

    -- schedule function
    --timer.scheduleFunction(AUTO_VEAF_move_group_to_random_zone, nil, timer.getTime() + VEAF_random_move_zone_timer)
end

-- Private function that will return the mount type 
function _VEAF_get_random_mount_type(proba)
	
	-- random values 
	--local proba = 0
	local maxprobaName = ''
	local maxprobaValue = 0
	local middleProbaName = ''
	local middleProbaValue = 0
	local lowProbaName = ''
	local lowProbaValue = 0
	
	local mountType = "Rifle"
	


	tableProba = {
					{VEAF_dismount_ground_mortar_prob, 'VEAF_dismount_ground_mortar_prob'},
					{VEAF_dismount_ground_AAA_prob, 'VEAF_dismount_ground_AAA_prob'},
					{VEAF_dismount_ground_manpads_prob,'VEAF_dismount_ground_manpads_prob'}
				 }
	
    table.sort(tableProba, compare)
	
	-- dereferenced vars : 
    maxprobaName = tableProba[3][2]
	maxprobaValue = tableProba[3][1]
	middleProbaName = tableProba[2][2]
	middleProbaValue = tableProba[2][1]
    lowProbaName = tableProba[1][2]
	lowProbaValue = tableProba[1][1]
	
	-- check which probability is matched
	if(proba <= lowProbaValue) then
		doProba = "low"
	elseif ( (proba > lowProbaValue) and (proba <= middleProbaValue) ) then
		doProba = "middle"
	elseif ( (proba > middleProbaValue) and (proba <= maxprobaValue) ) then
		doProba = "high"
	else
		doProba = "default"
	end
	
	-- check if we are in low probability
	if ( doProba == "low" ) then
	
		for _,p in pairs(tableProba) do
			if (lowProbaName == 'VEAF_dismount_ground_mortar_prob') then
				mountType = "Mortar"
			elseif (lowProbaName == 'VEAF_dismount_ground_AAA_prob') then
				mountType = "ZU-23"
			elseif (lowProbaName == 'VEAF_dismount_ground_manpads_prob') then	
				mountType = "MANPADS"
			end
		end
	
	end
	
	-- check if we are in middle probability
	if ( doProba == "middle" ) then
	
		for _,p in pairs(tableProba) do
			if (middleProbaName == 'VEAF_dismount_ground_mortar_prob') then
				mountType = "Mortar"
			elseif (middleProbaName == 'VEAF_dismount_ground_AAA_prob') then
				mountType = "ZU-23"
			elseif (middleProbaName == 'VEAF_dismount_ground_manpads_prob') then	
				mountType = "MANPADS"
			end
		end
	
	end	
	
	-- check if we are in high probability
	if ( doProba == "high" ) then
	
		for _,p in pairs(tableProba) do
			if (maxprobaName == 'VEAF_dismount_ground_mortar_prob') then
				mountType = "Mortar"
			elseif (maxprobaName == 'VEAF_dismount_ground_AAA_prob') then
				mountType = "ZU-23"
			elseif (maxprobaName == 'VEAF_dismount_ground_manpads_prob') then	
				mountType = "MANPADS"
			end
		end
	
	end	

	-- else the mountType is set to default 'rifle'
	
			
	return mountType

end

-- core function used for array compare in table sort : table.sort(myArray, compare)
function compare(a,b)
     return a[1] < b[1]
end


------------------------------------------------------------------------------
-- function : VEAF_controller
-- args     : N/A
-- output   : N/A
------------------------------------------------------------------------------
-- Objective: controls if functions have to be executed or not based on global vas.
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 16/11/14 + creation
------------------------------------------------------------------------------
function VEAF_controller() 
	
	if (ENABLE_VEAF_RANDOM_MOVE_ZONE) then
		AUTO_VEAF_move_group_to_random_zone()
	end
	if (ENABLE_VEAF_DISMOUNT_GROUND) then
		AUTO_VEAF_dismount_ground()
	end
	
end

-- main loop
--timer.scheduleFunction(VEAF_controller, nil, timer.getTime() + 1)
return AUTO_VEAF_dismount_ground()