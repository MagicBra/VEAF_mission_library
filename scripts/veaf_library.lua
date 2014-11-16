------------------------------------------------------------------------
-- Function library for the VEAF missions
------------------------------------------------------------------------3.
-- initiator    : MagicBra (nosdudefr-a@t-gmail.com)
-- contributors : 
-- testers      :
------------------------------------------------------------------------
-- versions : 
-- 0.1 : + added random move between zones for a group
-- 0.2 : + added check to enable the functions 



-- enable or disable the usage of the movement between zones
ENABLE_VEAF_RANDOM_MOVE_ZONE = true;

-- part of the group name identifying the zone where groups can move
VEAF_random_move_zone_zoneTag = 'veafrz'
-- part of the group name identifying the groups afected
VEAF_random_move_zone_groupTag = 'veafrz'
-- time in seconds before the groups will have a new waypoint
VEAF_random_move_zone_timer = 600



------------------------------------------------------------------------
----- NO MODIFICATION BELIW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
----- NO MODIFICATION BELIW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
----- NO MODIFICATION BELIW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
----- NO MODIFICATION BELIW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
------------------------------------------------------------------------


function VEAF_move_group_to_random_zone(group, zoneList)
	mist.groupToRandomZone(group, zoneList)
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
			VEAF_move_group_to_random_zone(groupName, VEAF_random_move_zone_list)
	end

    -- schedule function
    timer.scheduleFunction(AUTO_VEAF_move_group_to_random_zone, nil, timer.getTime() + VEAF_random_move_zone_timer)
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
function VEAF_controller() {
	
	if (ENABLE_VEAF_RANDOM_MOVE_ZONE) then
		AUTO_VEAF_move_group_to_random_zone()
	end
end

