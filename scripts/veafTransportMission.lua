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
veafTransportMission.Version = "0.0.3"

--- Key phrase to look for in the mark text which triggers the command.
veafTransportMission.Keyphrase = "veaf transport "

veafTransportMission.CargoTypes = {"ammo_cargo", "barrels_cargo", "container_cargo", "fueltank_cargo" }

--- Number of seconds between each check of the friendly group ADF loop function
veafTransportMission.SecondsBetweenAdfLoops = 30

--- Number of seconds between each check of the friendly group watchdog function
veafTransportMission.SecondsBetweenWatchdogChecks = 15

--- Number of seconds between each smoke request on the target
veafTransportMission.SecondsBetweenSmokeRequests = 180

--- Number of seconds between each flare request on the target
veafTransportMission.SecondsBetweenFlareRequests = 120

--- Name of the friendly group that waits for the cargo
veafTransportMission.BlueGroupName = "Cargo - Allied Group"

--- Name of the enemy group that defends the way to the friendlies
veafTransportMission.RedDefenseGroupName = "Cargo - Enemy Air Defense Group"

--- Name of the enemy group that blocades the friendlies
veafTransportMission.RedBlocadeGroupName = "Cargo - Enemy Blocade Group"

veafTransportMission.RadioMenuName = "TRANSPORT MISSION (" .. veafTransportMission.Version .. ")"

veafTransportMission.adfRadioSound = "l10n/DEFAULT/beacon.ogg"

veafTransportMission.adfFrequency = 550000000 -- in hz

veafTransportMission.adfPower = 1000 -- in Watt
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Friendly group watchdog function id
veafTransportMission.friendlyGroupAliveCheckTaskID = 'none'

-- Friendly group ADF transmission loop function id
veafTransportMission.friendlyGroupAdfLoopTaskID = 'none'

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

function veafTransportMission.doRadioTransmission(groupName)
    veafTransportMission.logTrace("doRadioTransmission("..groupName..")")
    local group = Group.getByName(groupName)
    if group then
        veafTransportMission.logTrace("Group is transmitting")
        local averageGroupPosition = veaf.getAveragePosition(groupName)
        veafTransportMission.logTrace("averageGroupPosition=" .. veaf.vecToString(averageGroupPosition))
        trigger.action.radioTransmission(veafTransportMission.adfRadioSound, averageGroupPosition, 1, false, veafTransportMission.adfFrequency, veafTransportMission.adfPower)
    end
    
    veafTransportMission.friendlyGroupAdfLoopTaskID = mist.scheduleFunction(veafTransportMission.doRadioTransmission, { groupName }, timer.getTime() + veafTransportMission.SecondsBetweenAdfLoops)
end

function veafTransportMission.generateFriendlyGroup(groupPosition)
    veafSpawn._doSpawnGroup(groupPosition, "US infgroup", "USA", 0, 0, 0, 10, veafTransportMission.BlueGroupName, true)
    veafTransportMission.doRadioTransmission(veafTransportMission.BlueGroupName)
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
        groupPosition = veaf.placePointOnLand(groupPosition)
        veafTransportMission.logTrace("groupPosition on land=" .. veaf.vecToString(groupPosition))
        veafTransportMission.generateFriendlyGroup(groupPosition)
    else
        veafTransportMission.logInfo("cannot find a suitable position for group "..groupId)
        return
    end

    -- generate cargo to be picked up near the player helo
    veafTransportMission.logDebug("Generating cargo")
    local playerPosition = veaf.placePointOnLand(initiatorUnit:getPosition().p)
    veafTransportMission.logTrace("playerPosition=" .. veaf.vecToString(playerPosition))
    for i = 1, size do
        local spawnSpot = { x = playerPosition.x + 50, z = playerPosition.z + i * 10, y = playerPosition.y }
        veafTransportMission.logTrace("spawnSpot=" .. veaf.vecToString(spawnSpot))
        local cargoType = veafTransportMission.CargoTypes[math.random(#veafTransportMission.CargoTypes)]
        veafSpawn.spawnCargo(spawnSpot, cargoType, false)
    end
    veafTransportMission.logDebug("Done generating cargo")

    -- generate enemy air defense on the way
    if defense > 0 then
        veafTransportMission.logDebug("Generating air defense")

        -- compute player route to friendly group
        -- local startPoint = playerPosition
        -- local endPoint = groupPosition
        -- local vec = {x = endPoint.x - startPoint.x, y = endPoint.y - startPoint.y, z = endPoint.z - startPoint.z}
        -- local hdgToDropZoneInRadians = mist.utils.getDir(vec)
        -- local dist = mist.utils.get2DDist(startPoint, endPoint)
        
    
        -- place groups in a circle 

        veafTransportMission.logDebug("Done generating air defense")
    end

    -- generate enemy blocade forces
    if blocade > 0 then
        veafTransportMission.logDebug("Generating blocade")
        veafTransportMission.logDebug("Done generating blocade")
    end

    -- build menu for each player
    for groupId, group in pairs(veafTransportMission.humanGroups) do
        -- add radio menu for target information (by player group)
        missionCommands.addCommandForGroup(groupId, 'Drop zone information', veafTransportMission.rootPath, veafTransportMission.reportTargetInformation, groupId)
    end

    -- add radio menus for commands
    missionCommands.addCommand('Skip current objective', veafTransportMission.rootPath, veafTransportMission.skip)
    veafTransportMission.targetMarkersPath = missionCommands.addSubMenu("Drop zone markers", veafTransportMission.rootPath)
    missionCommands.addCommand('Request smoke on drop zone', veafTransportMission.targetMarkersPath, veafTransportMission.smokeTarget)
    missionCommands.addCommand('Request illumination flare over drop zone', veafTransportMission.targetMarkersPath, veafTransportMission.flareTarget)

    local message = "See F10 radio menu for details\n" -- TODO
    trigger.action.outText(message,5)

    -- start checking for targets destruction
    veafTransportMission.friendlyGroupWatchdog()
end

--- Checks if the friendly group is still alive, and if not announces the failure of the transport mission
function veafTransportMission.friendlyGroupWatchdog() 
    local nbVehicles, nbInfantry = veafUnits.countInfantryAndVehicles(veafTransportMission.BlueGroupName)
    if nbVehicles + nbInfantry > 0 then
        --veafTransportMission.logTrace("Group is still alive with "..nbVehicles.." vehicles and "..nbInfantry.." soldiers")
        veafTransportMission.friendlyGroupAliveCheckTaskID = mist.scheduleFunction(veafTransportMission.friendlyGroupWatchdog,{},timer.getTime()+veafTransportMission.SecondsBetweenWatchdogChecks)
    else
        trigger.action.outText("Friendly group has been destroyed! The mission is a failure!", 5)
        veafTransportMission.cleanupAfterMission()
    end
end

function veafTransportMission.reportTargetInformation(groupId)
    -- generate information dispatch
    local nbVehicles, nbInfantry = veafUnits.countInfantryAndVehicles(veafTransportMission.BlueGroupName)

    local message =      "DROP ZONE : ressuply a group of " .. nbVehicles .. " vehicles and " .. nbInfantry .. " soldiers.\n"
    message = message .. "\n"
    message = message .. "NAVIGATION: They will transmit on 550 kHz every " .. veafTransportMission.SecondsBetweenAdfLoops .. " seconds.\n"

    -- add coordinates and position from bullseye
    local averageGroupPosition = veaf.getAveragePosition(veafTransportMission.BlueGroupName)
    local lat, lon = coord.LOtoLL(averageGroupPosition)
    local mgrsString = mist.tostringMGRS(coord.LLtoMGRS(lat, lon), 3)
    local bullseye = mist.utils.makeVec3(mist.DBs.missionData.bullseye.blue, 0)
    local vec = {x = averageGroupPosition.x - bullseye.x, y = averageGroupPosition.y - bullseye.y, z = averageGroupPosition.z - bullseye.z}
    local dir = mist.utils.round(mist.utils.toDegree(mist.utils.getDir(vec, bullseye)), 0)
    local dist = mist.utils.get2DDist(averageGroupPosition, bullseye)
    local distMetric = mist.utils.round(dist/1000, 0)
    local distImperial = mist.utils.round(mist.utils.metersToNM(dist), 0)
    local fromBullseye = string.format('%03d', dir) .. ' for ' .. distMetric .. 'km /' .. distImperial .. 'nm'

    message = message .. "LAT LON (decimal): " .. mist.tostringLL(lat, lon, 2) .. ".\n"
    message = message .. "LAT LON (DMS)    : " .. mist.tostringLL(lat, lon, 0, true) .. ".\n"
    message = message .. "MGRS/UTM         : " .. mgrsString .. ".\n"
    message = message .. "FROM BULLSEYE    : " .. fromBullseye .. ".\n"
    message = message .. "\n"

    -- get altitude, qfe and wind information
    local altitude = veaf.getLandHeight(averageGroupPosition)
    --local qfeHp = mist.utils.getQFE(averageGroupPosition, false)
    --local qfeinHg = mist.utils.getQFE(averageGroupPosition, true)
    local windDirection, windStrength = veaf.getWind(veaf.placePointOnLand(averageGroupPosition))

    message = message .. 'DROP ZONE ALT       : ' .. altitude .. " meters.\n"
    --message = message .. 'TARGET QFW       : ' .. qfeHp .. " hPa / " .. qfeinHg .. " inHg.\n"
    local windText =     'no wind.\n'
    if windStrength > 0 then
        windText = string.format(
                         'from %s at %s m/s.\n', windDirection, windStrength)
    end
    message = message .. 'WIND OVER DROP ZONE : ' .. windText

    -- send message only for the group
    trigger.action.outTextForGroup(groupId, message, 30)
end

--- add a smoke marker over the drop zone
function veafTransportMission.smokeTarget()
    veafTransportMission.logDebug("smokeTarget()")
    veafSpawn.spawnSmoke(veaf.getAveragePosition(veafTransportMission.BlueGroupName), trigger.smokeColor.Green)
	trigger.action.outText('Copy smoke requested, GREEN smoke marks the drop zone!',5)
    missionCommands.removeItem({veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Drop zone markers', 'Request smoke on drop zone'})
    missionCommands.addCommand('Drop zone is marked with GREEN smoke', veafTransportMission.targetMarkersPath, veaf.emptyFunction)
    veafTransportMission.smokeResetTaskID = mist.scheduleFunction(veafTransportMission.smokeReset,{},timer.getTime()+veafTransportMission.SecondsBetweenSmokeRequests)
end

--- Reset the smoke request radio menu
function veafTransportMission.smokeReset()
    veafTransportMission.logDebug("smokeReset()")
    missionCommands.removeItem({veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Drop zone markers', 'Drop zone is marked with GREEN smoke'})
    missionCommands.addCommand('Request smoke on drop zone', veafTransportMission.targetMarkersPath, veafTransportMission.smokeCasTargetGroup)
    trigger.action.outText('Smoke marker over drop zone available',5)
end

--- add an illumination flare over the target area
function veafTransportMission.flareTarget()
    veafTransportMission.logDebug("flareTarget()")
    veafSpawn.spawnIlluminationFlare(veaf.getAveragePosition(veafTransportMission.BlueGroupName))
	trigger.action.outText('Copy illumination flare requested, illumination flare over target area!',5)
	missionCommands.removeItem({veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Drop zone markers', 'Request illumination flare over drop zone'})
	missionCommands.addCommand('Drop zone is lit with illumination flare', veafTransportMission.targetMarkersPath, veaf.emptyFunction)
    veafTransportMission.flareResetTaskID = mist.scheduleFunction(veafTransportMission.flareReset,{},timer.getTime()+veafTransportMission.SecondsBetweenFlareRequests)
end

--- Reset the flare request radio menu
function veafTransportMission.flareReset()
    veafTransportMission.logDebug("flareReset()")
    missionCommands.removeItem({veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Drop zone markers', 'Drop zone is lit with illumination flare'})
    missionCommands.addCommand('Request illumination flare over drop zone', veafTransportMission.targetMarkersPath, veafTransportMission.flareCasTargetGroup)
    trigger.action.outText('Illumination flare over drop zone available',5)
end


--- Called from the "Skip delivery" radio menu : remove the current transport mission
function veafTransportMission.skip()
    veafTransportMission.cleanupAfterMission()
    trigger.action.outText("Transport mission cleaned up.", 5)
end

--- Cleanup after either mission is ended or aborted
function veafTransportMission.cleanupAfterMission()
    veafTransportMission.logTrace("cleanupAfterMission()")

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

    -- remove the watchdog function
    veafTransportMission.logTrace("remove the adf loop function")
    if veafTransportMission.friendlyGroupAdfLoopTaskID ~= 'none' then
        mist.removeFunction(veafTransportMission.friendlyGroupAdfLoopTaskID)
    end
    veafTransportMission.friendlyGroupAdfLoopTaskID = 'none'

            -- build menu for each player
    for name, player in pairs(mist.DBs.humansByName) do
        -- update the radio menu
        missionCommands.removeItemForGroup(player.groupId, {veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Drop zone information'})
    end

    missionCommands.removeItem({veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Skip current objective'})
    missionCommands.removeItem({veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Get current objective situation'})
    missionCommands.removeItem({veaf.RadioMenuName, veafTransportMission.RadioMenuName, 'Drop zone markers'})

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

