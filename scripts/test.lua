mist = {}
veaf = {}
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

dofile("dcsUnits.lua")
dofile("veafUnits.lua")

veafCasMission = {}

--- Generates an infantry group along with its manpad units and tranport vehicles
function veafCasMission.generateInfantryGroup(groupId, spawnSpot, defense, armor, skill)
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
function veafCasMission.generateInfantryGroup2(groupId, spawnSpot, defense, armor, skill)
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

--- checks if position is correct for the unit type
function veafUnits.correctPositionForUnit(spawnPosition, unit)
    if spawnPosition then
        if unit.air then -- if the unit is a plane or helicopter
            if spawnPosition.z <= 10 then -- if lower than 10m don't spawn unit
                spawnPosition = nil
            end
        elseif unit.naval then -- if the unit is a naval unit
            local landType = land.getSurfaceType(spawnPosition)
            if landType ~= land.SurfaceType.WATER then -- don't spawn over anything but water
                spawnPosition = nil 
            else -- place the point on the surface
                spawnPosition = veaf.placePointOnLand(spawnPosition)
            end
        else 
                spawnPosition = veaf.placePointOnLand(spawnPosition)
        end
    end
    return spawnPosition
end

local spawnPoint = {x=-321835.9, y=562.0, z=888712.0}
local spacing = 10
local group = veafUnits.findGroup("infsec")
--local group = veafCasMission.generateInfantryGroup(1, spawnPoint, 4, 1, "Random")
local group, cells = veafUnits.placeGroup(group, spawnPoint, spacing)
veafUnits.debugGroup(group, cells)
--local unit = veafUnits.findUnit("sa9")
--spawnPoint = veafUnits.correctPositionForUnit(spawnPoint, unit)

