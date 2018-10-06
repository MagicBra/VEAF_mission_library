mist = {}
mist.utils = {}

--- Converts angle in degrees to radians.
-- @param angle angle in degrees
-- @return angle in degrees
function mist.utils.toRadian(angle)
    return angle*math.pi/180
end

	function mist.utils.toDegree(angle)
		return angle*180/math.pi
	end

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

function veaf.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

dofile("dcsUnits.lua")
dofile("veafUnits.lua")
dofile("veafSpawn.lua")

veafCasMission = {}

function veafUnits.checkPositionForUnit(spawnPosition, unit)
    return true
end





local spawnPosition = {x=0, y=0, z=0}
local speed = 10
local heading = 0
local spacing = 0

--- Generates an enemy defense group on the way to the drop zone
--- defenseLevel = 1 : 3-7 soldiers, GAZ-3308 transport
--- defenseLevel = 2 : 3-7 soldiers, BTR-80 APC
--- defenseLevel = 3 : 3-7 soldiers, BMP-1 IFV, Igla manpad
--- defenseLevel = 4 : 3-7 soldiers, BMP-1 IFV, Igla-S manpad, ZU-23 on a truck
--- defenseLevel = 5 : 3-7 soldiers, BMP-1 IFV, Igla-S manpad, ZSU-23-4 Shilka
function generateEnemyDefenseGroup(groupPosition, groupName, defenseLevel)
    local groupDefinition = {
            disposition = { h = 6, w = 6},
            units = {},
            description = groupName,
            groupName = groupName,
        }

    -- generate an infantry group
    local groupCount = math.random(3, 7)
    for _ = 1, groupCount do
        local rand = math.random(3)
        local unitType = nil
        if rand == 1 then
            unitType = 'Soldier RPG'
        elseif rand == 2 then
            unitType = 'Soldier AK'
        else
            unitType = 'Infantry AK'
        end
        table.insert(groupDefinition.units, { unitType })
    end

    -- add a transport vehicle or an APC/IFV
    if defenseLevel > 2 then
        table.insert(groupDefinition.units, { "BMP-1", cell=11, random })
    elseif defenseLevel > 1 then
        table.insert(groupDefinition.units, { "BTR-80", cell=11, random })
    else
        table.insert(groupDefinition.units, { "GAZ-3308", cell=11, random })
    end

    -- add manpads if needed
    if defenseLevel > 3 then
        -- for defenseLevel = 4-5, spawn a modern Igla-S team
        table.insert(groupDefinition.units, { "SA-18 Igla-S comm", random })
        table.insert(groupDefinition.units, { "SA-18 Igla-S manpad", random })
    elseif defenseLevel > 2 then
        -- for defenseLevel = 3, spawn an older Igla team
        table.insert(groupDefinition.units, { "SA-18 Igla comm", random })
        table.insert(groupDefinition.units, { "SA-18 Igla manpad", random })
    else
        -- for defenseLevel = 0, don't spawn any manpad
    end

    -- add an air defenseLevel vehicle
    if defenseLevel > 4 then
        -- defenseLevel = 3-5 : add a Shilka
        table.insert(groupDefinition.units, { "ZSU-23-4 Shilka", cell = 3, random })
    elseif defenseLevel > 3 then
        -- defenseLevel = 1 : add a ZU23 on a truck
        table.insert(groupDefinition.units, { "Ural-375 ZU-23", cell = 3, random })
    end

    groupDefinition = veafUnits.processGroup(groupDefinition)
    local group, cells = veafUnits.placeGroup(groupDefinition, {x = 0, y = 0, z = 0}, 5, 0)
    veafUnits.debugGroup(group, cells)

end


generateEnemyDefenseGroup(groupPosition, "toto", 2)
doSpawnGroup(groupPosition, "US infgroup", "USA", 0, 0, 0, 10, "group name", true)
local group = veafUnits.findGroup("US infgroup")
--local group = veafCasMission.generateInfantryGroup(1, spawnPosition, 4, 1, "Random")
local group, cells = veafUnits.placeGroup(group, spawnPosition, spacing, heading)
veafUnits.debugGroup(group, cells)
--veafSpawn.spawnUnit(spawnPosition, "sa9")
--local unit = veafUnits.findUnit("sa9")
--spawnPoint = veafUnits.correctPositionForUnit(spawnPosition, unit)
for _, u in pairs(group.units) do
    veafUnits.debugUnit(u)
end
