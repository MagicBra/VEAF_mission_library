-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF transport mission command and functions for DCS World
-- By zip (2018)
--
-- Features:
-- ---------
-- * Listen to marker change events and creates a transport training mission, with optional parameters
-- * Possibilities :
-- *    - create a zone with cargo to pick up, another with friendly troops awaiting their cargo, and optionaly enemy units on the way
-- * Works with all current and future maps (Caucasus, NTTR, Normandy, PG, ...)
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires the base veaf.lua script library (version 1.0 or higher)
-- * It also requires the veafMarkers.lua script library (version 1.0 or higher)
-- * It also requires the veafSpawn.lua script library (version 1.0 or higher)
--
-- Basic Usage:
-- ------------
-- 1.) Place a mark on the F10 map.
-- 2.) As text enter "veaf transport mission"
-- 3.) Click somewhere else on the map to submit the new text.
-- 4.) The command will be processed. A message will appear to confirm this
-- 5.) The original mark will disappear.
--
-- Options:
-- --------
-- Type "veaf transport mission" to create a default transport mission
--      add ", defense [1-5]" to specify air defense cover on the way (1 = light, 5 = heavy)
--      add ", size [1-5]" to change the number of cargo items to be transported (1 per participating helo, usually)
--      add ", blocade [1-5]" to specify enemy blocade around the drop zone (1 = light, 5 = heavy)
--
-- *** NOTE ***
-- * All keywords are CaSE inSenSITvE.
-- * Commas are the separators between options ==> They are IMPORTANT!
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafTransportMission = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafTransportMission.Id = "TRANSPORT MISSION - "

--- Version.
veafTransportMission.Version = "0.0.2"

--- Key phrase to look for in the mark text which triggers the command.
veafTransportMission.Keyphrase = "veaf transport "

veafTransportMission.CargoTypes = {"ammo_cargo", "barrels_cargo", "container_cargo", "fueltank_cargo" }

--- Number of seconds between each check of the friendly group watchdog function
veafTransportMission.SecondsBetweenWatchdogChecks = 15

--- Number of seconds between each smoke request on the target
veafTransportMission.SecondsBetweenSmokeRequests = 180

--- Number of seconds between each flare request on the target
veafTransportMission.SecondsBetweenFlareRequests = 120

--- Name of the friendly group that waits for the cargo
veafTransportMission.BlueGroupName = "Blue Cargo Group"

--- Name of the enemy group that defends the way to the friendlies
veafTransportMission.RedDefenseGroupName = "Red Defense Cargo Group"

--- Name of the enemy group that blocades the friendlies
veafTransportMission.RedBlocadeGroupName = "Red Blocade Cargo Group"

veafTransportMission.RadioMenuName = "TRANSPORT MISSION (" .. veafTransportMission.Version .. ")"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Friendly group watchdog function id
veafTransportMission.friendlyGroupAliveCheckTaskID = 'none'

--- Radio menus paths
veafTransportMission.targetMarkersPath = nil
veafTransportMission.targetInfoPath = nil
veafTransportMission.rootPath = nil

-- Humans Groups (associative array groupId => group)
veafTransportMission.humanGroups = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafTransportMission.logInfo(message)
    veaf.logInfo(veafTransportMission.Id .. message)
end

function veafTransportMission.logDebug(message)
    veaf.logDebug(veafTransportMission.Id .. message)
end

function veafTransportMission.logTrace(message)
    veaf.logTrace(veafTransportMission.Id .. message)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event handler functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Function executed when a mark has changed. This happens when text is entered or changed.
function veafTransportMission.onEventMarkChange(eventPos, event)
    -- Check if marker has a text and the veafTransportMission.keyphrase keyphrase.
    if event.text ~= nil and event.text:lower():find(veafTransportMission.Keyphrase) then

        -- Analyse the mark point text and extract the keywords.
        local options = veafTransportMission.markTextAnalysis(event.text)

        if options then
            -- Check options commands
            if options.transportmission then
                -- create the mission
                veafTransportMission.generateTransportMission(eventPos, options.size, options.defense, options.blocade, event.initiator)
            end
        else
            -- None of the keywords matched.
            return
        end

        -- Delete old mark.
        veafTransportMission.logTrace(string.format("Removing mark # %d.", event.idx))
        trigger.action.removeMark(event.idx)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Analyse the mark text and extract keywords.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Extract keywords from mark text.
function veafTransportMission.markTextAnalysis(text)

    -- Option parameters extracted from the mark text.
    local switch = {}
    switch.transportmission = false

    -- size ; number of cargo to be transported
    switch.size = 1

    -- defense [1-5] : air defense cover on the way (1 = light, 5 = heavy)
    switch.defense = 0

    -- blocade [1-5] : enemy blocade around the drop zone (1 = light, 5 = heavy)
    switch.blocade = 0

    -- Check for correct keywords.
    if text:lower():find(veafTransportMission.Keyphrase .. "mission") then
        switch.transportmission = true
    else
        return nil
    end

    -- keywords are split by ","
    local keywords = veaf.split(text, ",")

    for _, keyphrase in pairs(keywords) do
        -- Split keyphrase by space. First one is the key and second, ... the parameter(s) until the next comma.
        local str = veaf.breakString(veaf.trim(keyphrase), " ")
        local key = str[1]
        local val = str[2]

        if switch.transportmission and key:lower() == "size" then
            -- Set size.
            veafTransportMission.logDebug(string.format("Keyword size = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 1 then
                switch.size = nVal
            end
        end

        if switch.transportmission and key:lower() == "defense" then
            -- Set defense.
            veafTransportMission.logDebug(string.format("Keyword defense = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 0 then
                switch.defense = nVal
            end
        end

        if switch.transportmission and key:lower() == "blocade" then
            -- Set armor.
            veafTransportMission.logDebug(string.format("Keyword blocade = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 0 then
                switch.blocade = nVal
            end
        end
    end

    return switch
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CAS target group generation and management
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafTransportMission.generateFriendlyGroup(groupPosition, activateAdf)
    local groupName = veafSpawn.spawnGroup(groupPosition, "US infgroup", "USA", 0, 0, 0, 10)
    if activateAdf then
        local groupPosition = veaf.getAveragePosition(groupName)
        local mission = { 
            id = 'Mission', 
            params = { 
                ["communication"] = true,
                ["start_time"] = 0,
                route = { 
                    points = { 
                        -- first point
                        [1] = { 
                            ["type"] = "Turning Point",
                            ["action"] = "Turning Point",
                            ["x"] = groupPosition.x,
                            ["y"] = groupPosition.z,
                            ["alt"] = groupPosition.y,-- in meters
                            ["alt_type"] = "BARO", 
                            ["speed"] = 0,  -- speed in m/s
                            ["speed_locked"] = boolean, 
                            ["task"] = 
                            {
                                ["id"] = "ComboTask",
                                ["params"] = 
                                {
                                    ["tasks"] = 
                                    {
                                        [1] = 
                                        {
                                            ["enabled"] = true,
                                            ["auto"] = true,
                                            ["id"] = "WrappedAction",
                                            ["number"] = 1,
                                            ["params"] = 
                                            {
                                                ["action"] = 
                                                {
                                                    ["id"] = "EPLRS",
                                                    ["params"] = 
                                                    {
                                                        ["value"] = true,
                                                        ["groupId"] = 1,
                                                    }, -- end of ["params"]
                                                }, -- end of ["action"]
                                            }, -- end of ["params"]
                                        }, -- end of [1]
                                        [2] = 
                                        {
                                            ["enabled"] = true,
                                            ["auto"] = false,
                                            ["id"] = "WrappedAction",
                                            ["number"] = 2,
                                            ["params"] = 
                                            {
                                                ["action"] = 
                                                {
                                                    ["id"] = "SetFrequency",
                                                    ["params"] = 
                                                    {
                                                        ["power"] = 35,
                                                        ["modulation"] = 0,
                                                        ["frequency"] = 530000,
                                                    }, -- end of ["params"]
                                                }, -- end of ["action"]
                                            }, -- end of ["params"]
                                        }, -- end of [2]
                                        [3] = 
                                        {
                                            ["enabled"] = true,
                                            ["auto"] = false,
                                            ["id"] = "WrappedAction",
                                            ["number"] = 3,
                                            ["params"] = 
                                            {
                                                ["action"] = 
                                                {
                                                    ["id"] = "TransmitMessage",
                                                    ["params"] = 
                                                    {
                                                        ["loop"] = true,
                                                        ["subtitle"] = "DictKey_subtitle_91",
                                                        ["duration"] = 5,
                                                        ["file"] = "ResKey_advancedFile_92",
                                                    }, -- end of ["params"]
                                                }, -- end of ["action"]
                                            }, -- end of ["params"]
                                        }, -- end of [3]
                                    }, -- end of ["tasks"]                                
                                }, -- end of ["params"]
                            }, -- end of ["task"]
                        }, -- enf of [1]
                    }, 
                } 
            } 
        }
    
        -- replace whole mission
        local unitGroup = Group.getByName(groupName)
        unitGroup:getController():setTask(mission)
    end
    
end

--- Generates a transport mission
function veafTransportMission.generateTransportMission(targetSpot, size, defense, blocade, initiatorUnit)
    local unitName = ""
    if initiatorUnit then
        unitName = initiatorUnit:getName()
    end
    veafTransportMission.logDebug(string.format("generateTransportMission(size = %s, defense=%s, blocade=%d, initiatorUnit=%s)",size, defense, blocade, unitName))
    veafTransportMission.logDebug("generateTransportMission: targetSpot " .. veaf.vecToString(targetSpot))

    if veafTransportMission.friendlyGroupAliveCheckTaskID ~= 'none' then
        trigger.action.outText("A transport mission already exists !", 5)
        return
    end

    local friendlyUnits = {}

    -- generate a friendly group around the target target spot
    local groupPosition = veaf.findPointInZone(targetSpot, 100, false)
    if groupPosition ~= nil then
        veafTransportMission.logTrace("groupPosition=" .. veaf.vecToString(groupPosition))
        groupPosition = { x = groupPosition.x, z = groupPosition.y, y = 0 }
        veafTransportMission.logTrace("groupPosition=" .. veaf.vecToString(groupPosition))
        veafTransportMission.generateFriendlyGroup(groupPosition, true)
    else
        veafTransportMission.logInfo("cannot find a suitable position for group "..groupId)
    end

    -- generate cargo to be picked up near the player helo
    local playerPosition = veaf.placePointOnLand(initiatorUnit:getPosition().p)
    veafTransportMission.logTrace("playerPosition=" .. veaf.vecToString(playerPosition))
    for i = 1, size do
        local spawnSpot = { x = playerPosition.x + 50, z = playerPosition.z + i * 10, y = playerPosition.y }
        veafTransportMission.logTrace("spawnSpot=" .. veaf.vecToString(spawnSpot))
        local cargoType = veafTransportMission.CargoTypes[math.random(#veafTransportMission.CargoTypes)]
        veafSpawn.spawnCargo(spawnSpot, cargoType, false)
    end

    -- generate enemy air defense on the way
    if defense > 0 then
    end

    -- generate enemy blocade forces
    if blocade > 0 then
    end

    -- build menu for each player
    for groupId, group in pairs(veafTransportMission.humanGroups) do
        -- add radio menu for target information (by player group)
        missionCommands.addCommandForGroup(groupId, 'Target information', veafTransportMission.rootPath, veafTransportMission.reportTargetInformation, groupId)
    end

    -- add radio menus for commands
    missionCommands.addCommand('Skip current objective', veafTransportMission.rootPath, veafTransportMission.skip)
    veafTransportMission.targetMarkersPath = missionCommands.addSubMenu("Target markers", veafTransportMission.rootPath)
    missionCommands.addCommand('Request smoke on target area', veafTransportMission.targetMarkersPath, veafTransportMission.smokeTarget)
    missionCommands.addCommand('Request illumination flare over target area', veafTransportMission.targetMarkersPath, veafTransportMission.flareTarget)

    local message = "See F10 radio menu for details\n" -- TODO
    trigger.action.outText(message,5)

    -- start checking for targets destruction
    veafTransportMission.friendlyGroupWatchdog()
end

--- Checks if the friendly group is still alive, and if not announces the failure of the transport mission
function veafTransportMission.friendlyGroupWatchdog() 
    local nbVehicles, nbInfantry = veafUnits.countInfantryAndVehicles(veafTransportMission.BlueGroupName)
    if nbVehicles > 0 then
        veafTransportMission.logTrace("Group is still alive with "..nbVehicles.." vehicles and "..nbInfantry.." soldiers")
        veafTransportMission.groupAliveCheckTaskID = mist.scheduleFunction(veafTransportMission.friendlyGroupWatchdog,{},timer.getTime()+veafTransportMission.SecondsBetweenWatchdogChecks)
    else
        trigger.action.outText("Friendly group has been destroyed! The mission is a failure!", 5)
        veafTransportMission.cleanupAfterMission()
    end
end

function veafTransportMission.reportTargetInformation()
    -- TODO
end

function veafTransportMission.smokeTarget()
    -- TODO
end

function veafTransportMission.flareTarget()
    -- TODO
end

--- Called from the "Skip delivery" radio menu : remove the current transport mission
function veafTransportMission.skip()
    veafTransportMission.cleanupAfterMission()
    trigger.action.outText("Transport mission cleaned up.", 5)
end

--- Cleanup after either mission is ended or aborted
function veafTransportMission.cleanupAfterMission()
    veafTransportMission.logTrace("cleanupAfterMission START")

    -- destroy groups
    veafTransportMission.logTrace("destroy friendly group")
    local group = Group.getByName(veafTransportMission.BlueGroupName)
    if group and group:isExist() == true then
        group:destroy()
    end
    veafTransportMission.logTrace("destroy enemy defense group")
    group = Group.getByName(veafTransportMission.RedDefenseGroupName)
    if group and group:isExist() == true then
        group:destroy()
    end

    veafTransportMission.logTrace("destroy enemy blocade group")
    group = Group.getByName(veafTransportMission.RedBlocadeGroupName)
    if group and group:isExist() == true then
        group:destroy()
    end

    -- remove the watchdog function
    veafTransportMission.logTrace("remove the watchdog function")
    if veafTransportMission.friendlyGroupAliveCheckTaskID ~= 'none' then
        mist.removeFunction(veafTransportMission.friendlyGroupAliveCheckTaskID)
    end
    veafTransportMission.friendlyGroupAliveCheckTaskID = 'none'

    -- build menu for each player
    for name, player in pairs(mist.DBs.humansByName) do
        -- update the radio menu
        missionCommands.removeItemForGroup(player.groupId, {veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Target information'})
    end

    missionCommands.removeItem({veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Skip current objective'})
    missionCommands.removeItem({veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Get current objective situation'})
    missionCommands.removeItem({veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Target markers'})

    veafTransportMission.logTrace("cleanupAfterMission DONE")

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Radio menu and help
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Build the initial radio menu
function veafTransportMission.buildRadioMenu()

    veafTransportMission.rootPath = missionCommands.addSubMenu(veafTransportMission.RadioMenuName, veaf.radioMenuPath)

    -- build menu for each group
    for groupId, group in pairs(veafTransportMission.humanGroups) do
        missionCommands.addCommandForGroup(groupId, "HELP", veafTransportMission.rootPath, veafTransportMission.help)
    end

end

--      add ", defense [1-5]" to specify air defense cover on the way (1 = light, 5 = heavy)
--      add ", size [1-5]" to change the number of cargo items to be transported (1 per participating helo, usually)
--      add ", blocade [1-5]" to specify enemy blocade around the drop zone (1 = light, 5 = heavy)
function veafTransportMission.help()
    local text =
        'Create a marker and type "veaf transport mission" in the text\n' ..
        'This will create a default friendly group awaiting cargo that you need to transport\n' ..
        'You can add options (comma separated) :\n' ..
        '   "defense [0-5]" to specify air defense cover on the way (1 = light, 5 = heavy)\n' ..
        '   "size [1-5]" to change the number of cargo items to be transported (1 per participating helo, usually)\n' ..
        '   "sblocade [0-5]" to specify enemy blocade around the drop zone (1 = light, 5 = heavy)'

    trigger.action.outText(text, 30)
end


-- prepare humans groups
function veafTransportMission.buildHumanGroups()

    veafTransportMission.humanGroups = {}

    -- build menu for each player
    for name, unit in pairs(mist.DBs.humansByName) do
        -- not already in groups list ?
        if veafTransportMission.humanGroups[unit.groupName] == nil then
            veafTransportMission.logTrace(string.format("human player found name=%s, unit=%s", name, unit.groupName))
            veafTransportMission.humanGroups[unit.groupId] = unit.groupName
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafTransportMission.initialize()
    veafTransportMission.buildHumanGroups()
    veafTransportMission.buildRadioMenu()
    veafMarkers.registerEventHandler(veafMarkers.MarkerChange, veafTransportMission.onEventMarkChange)
end

veafTransportMission.logInfo(string.format("Loading version %s", veafTransportMission.Version))

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)

