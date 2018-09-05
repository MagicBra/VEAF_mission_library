-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF carrier command and functions for DCS World
-- By zip (2018)
--
-- Features:
-- ---------
-- * Radio menus allow starting and ending carrier operations. Carriers go back to their initial point when operations are ended
-- * Works with all current and future maps (Caucasus, NTTR, Normandy, PG, ...)
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires the base veaf.lua script library (version 1.0 or higher)
--
-- Load the script:
-- ----------------
-- 1.) Download the script and save it anywhere on your hard drive.
-- 2.) Open your mission in the mission editor.
-- 3.) Add a new trigger:
--     * TYPE   "4 MISSION START"
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of MIST and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of veaf.lua and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of this script and click OK.
--     * ACTION "DO SCRIPT"
--     * set the script command to "veafCarrierOperations.initialize()" and click OK.
-- 4.) Save the mission and start it.
-- 5.) Have fun :)
--
-- Basic Usage:
-- ------------
-- Use the F10 radio menu to start and end carrier operations for every detected carrier group
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafCarrierOperations = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafCarrierOperations.Id = "CARRIER - "

--- Version.
veafCarrierOperations.Version = "0.0.1"

--- All the carrier groups must comply with this name
veafCarrierOperations.CarrierGroupNamePattern = "^CSG-\\d+.*$"

veafCarrierOperations.RadioMenuName = "CARRIER OPS (" .. veafCarrierOperations.Version .. ")"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Radio menus paths
veafCarrierOperations.rootPath = nil

-- Humans Groups (associative array groupId => group)
veafCarrierOperations.humanGroups = {}

--- Carrier groups data, for Carrier Operations commands
veafCarrierOperations.carriers = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafCarrierOperations.logInfo(message)
    veaf.logInfo(veafCarrierOperations.Id .. message)
end

function veafCarrierOperations.logDebug(message)
    veaf.logDebug(veafCarrierOperations.Id .. message)
end

function veafCarrierOperations.logTrace(message)
    veaf.logTrace(veafCarrierOperations.Id .. message)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Carrier operations commands
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Start carrier operations ; changes the radio menu item to END and make the carrier move
function veafCarrierOperations.startCarrierOperations(groupName)
    local carrier = veafCarrierOperations.carriers[groupName]

    if not(carrier) then
        trigger.action.outText("Cannot find the carrier group "..groupName, 5)
        return
    end

    if carrier.carrier.stopMenuName then
        -- there's already a END menu, this means the air operations have already started ; should never happen but who knows...
        trigger.action.outText("The carrier group "..groupName.." is already conducting carrier air operations", 5)
        return
    end

    -- take note of the starting position
    carrier.startPosition = mist.getAvgGroupPos(groupName)

    -- make the carrier move
    local startPosition = table.unpack(carrier.startPosition)
    if startPosition ~= nil then
        startPosition.y=startPosition.y+1

        --get wind info
        local wind = atmosphere.getWind(startPosition)
        local windspeed = mist.vec.mag(wind)

        --get wind direction sorted
        local dir = math.atan2(wind.z, wind.x) * 180 / math.pi
        if dir < 0 then
            dir = dir + 360 --converts to positive numbers		
        end
        if dir <= 180 then
            dir = dir + 180
        else
            dir = dir - 180
        end

        dir = dir + 8 --to account for angle of landing deck and movement of the ship
        
        if dir > 360 then
            dir = dir - 360
        end

        local speed = 1
        local dirrad = mist.utils.toRadian(dir)
        if windspeed < 12.8611 then
            speed = 12.8611 - windspeed
        else
            -- compute a new waypoint
            local newPosition = {x = ((math.cos(dir) * 3600 * speed) + startPosition.x), z = ((math.sin(dir) * 3600 * speed) + startPosition.z), y = 0}
            veaf.moveGroup(newPosition, groupName, speed)
        end
    end

    -- change the menu

end

--- Ends carrier operations ; changes the radio menu item to START and send the carrier back to its starting point
function veafCarrierOperations.stopCarrierOperations(groupName)
end

--- Resets the carrier position ; sends the carrier to its initial position (at mission start)
function veafCarrierOperations.resetCarrierPosition(groupName)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Radio menu and help
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Build the initial radio menu
function veafCarrierOperations.buildRadioMenu()

    veafCarrierOperations.rootPath = missionCommands.addSubMenu(veafCarrierOperations.RadioMenuName, veaf.radioMenuPath)

    -- build HELP menu for each group
    for groupId, group in pairs(veafCarrierOperations.humanGroups) do
        missionCommands.addCommandForGroup(groupId, "HELP", veafCarrierOperations.rootPath, veafCarrierOperations.help)
    end

    -- find the carriers and add them to the veafCarrierOperations.carriers table, store its initial location and create the menus
    for name, group in pairs(mist.DBs.groupsByName) do
        if name:match(veafCarrierOperations.CarrierGroupNamePattern) then
            veafCarrierOperations.carriers[name] = {}
            local carrier = veafCarrierOperations.carriers[name]
            carrier.initialPosition = mist.getAvgGroupPos(name)
            carrier.startMenuName = name .. " - Start carrier air operations"
            missionCommands.addCommand(carrier.startMenuName, veafCarrierOperations.rootPath, veafCarrierOperations.startCarrierOperations, { name })
            carrier.resetMenuName = name .. " - Send carrier to its original location (at mission start)"
            missionCommands.addCommand(carrier.resetMenuName, veafCarrierOperations.rootPath, veafCarrierOperations.resetCarrierPosition, { name })
        end
    end
end

function veafCarrierOperations.help()
    local text =
        'Use the radio menus to start and end carrier operations\n' ..
        'START: carrier will find out the wind and set sail at optimum speed to achieve a 25kn headwind\n' ..
        '       the radio menu will show the recovery course and TACAN information\n' ..
        'END  : carrier will go back to its starting point (where it was when the START command was issued)\n' ..
        'RESET: carrier will go back to where it was when the mission started'

    trigger.action.outText(text, 30)
end

-- prepare humans groups
function veafCarrierOperations.buildHumanGroups() -- TODO make this player-centric, not group-centric

    veafCarrierOperations.humanGroups = {}

    -- build menu for each player
    for name, unit in pairs(mist.DBs.humansByName) do
        -- not already in groups list ?
        if veafCarrierOperations.humanGroups[unit.groupName] == nil then
            veafCarrierOperations.logInfo(string.format("human player found name=%s, unit=%s", name, unit.groupName))
            veafCarrierOperations.humanGroups[unit.groupId] = unit.groupName
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafCarrierOperations.initialize()
    veafCarrierOperations.buildHumanGroups()
    veafCarrierOperations.buildRadioMenu()
    veafMarkers.registerEventHandler(veafMarkers.MarkerChange, veafCarrierOperations.onEventMarkChange)
end

veafCarrierOperations.logInfo(string.format("Loading version %s", veafCarrierOperations.Version))

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)



