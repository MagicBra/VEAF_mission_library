mist = {}
veaf = {}
env = {}
missionCommands = {}

function env.setErrorMessageBoxEnabled()
end

function missionCommands.addSubMenu(radioMenuName, radioMenuPath)
end

function missionCommands.addCommand()
end

function mist.dynAdd(param)
end

math.randomseed(os.time())

function veaf.logInfo(text)
  print("INFO VEAF - " .. text)
end

function veaf.logDebug(text)
  print("DEBUG VEAF - " .. text)
end

function veaf.logTrace(text)
  print("TRACE VEAF - " .. text)
end

function veaf.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function veaf.findPointInZone(spawnSpot, dispersion, isShip)
    return spawnSpot   
end

function veaf.placePointOnLand(spawnSpot)
    return spawnSpot   
end

dofile("dcsUnits.lua")
dofile("veafUnits.lua")
dofile("veafSpawn.lua")
dofile("veafCasMission.lua")

--veafCasMission.initialize()

function veaf.vecToString(vec)
    local result = ""
    if vec.x then
        result = result .. string.format(" x=%.1f", vec.x)
    end
    if vec.y then
        result = result .. string.format(" y=%.1f", vec.y)
    end
    if vec.z then
        result = result .. string.format(" z=%.1f", vec.z)
    end
    return result
end

--- Generates an infantry group along with its manpad units and tranport vehicles
function veafCasMission.generateInfantryGroup2(groupId, spawnSpot, defense, armor)
    local group = {}
    group.units = {}
    group.disposition = { h = 4, w = 3}
    group.description = "Random Infantry Group #" .. groupId
    
    -- generate an infantry group
    local groupCount = math.random(3, 7)
    local dispersion = (groupCount+1) * 5 + 25
    for i = 1, groupCount do
        group.units[i] = veafUnits.findUnit("INF Soldier AK")
    end

    -- add a transport vehicle
    if armor > 0 then
        group.units[groupCount+1] =  veafUnits.findUnit("IFV BTR-80")
    else
        group.units[groupCount+1] =  veafUnits.findUnit("Truck GAZ-3308")
    end
    group.units[groupCount+1].cell = 11

    -- add manpads if needed
    if defense > 3 then
        -- for defense = 4-5, spawn a full Igla-S team
        group.units[groupCount+2] =  veafUnits.findUnit("SA-18 Igla-S comm")
        group.units[groupCount+3] =  veafUnits.findUnit("SA-18 Igla-S manpad")
    elseif defense > 0 then
        -- for defense = 1-3, spawn a single Igla soldier
        group.units[groupCount+2] =  veafUnits.findUnit("SA-18 Igla manpad")
    else
        -- for defense = 0, don't spawn any manpad
    end

    return group
end

--- Generates an infantry group along with its manpad units and tranport vehicles
function veafCasMission.generateInfantryGroup3(groupId, spawnSpot, defense, armor, skill)
    local group = {}
    group.units = {}
    group.disposition = { h = 5, w = 5}
    group.description = "Random Infantry Group #" .. groupId
    
    -- generate an infantry group
    local groupCount = math.random(15, 22)
    local dispersion = (groupCount+1) * 5 + 25
    for i = 1, groupCount do
        group.units[i] = veafUnits.findUnit("INF Soldier AK")
    end

    return group
end


function veafUnits.checkPositionForUnit(spawnPosition, unit)
    return true
end

local spawnPosition = {x=500, y=0, z=250}
local a = veaf.vecToString(spawnPosition)

local speed = 10
local heading = 0
local spacing = 500

veafCasMission.generateCasMission(spawnPosition, 5, 5, 5, 5, true)

--local group = veafUnits.findGroup("sa6")
--local group = veafCasMission.generateInfantryGroup(1, spawnPosition, 4, 1, "Random")
--local group, cells = veafUnits.placeGroup(group, spawnPosition, spacing)
--veafUnits.debugGroup(group, cells)
--veafSpawn.spawnUnit(spawnPosition, "sa9")
--local unit = veafUnits.findUnit("sa9")
--spawnPoint = veafUnits.correctPositionForUnit(spawnPosition, unit)
--for _, u in pairs(group.units) do
--  veafUnits.debugUnit(u)
--end
