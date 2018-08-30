mist = {}
veaf = {}

function veaf.logInfo(text)
  print(" I " .. text)
end

function veaf.logDebug(text)
  print(" D " .. text)
end

function veaf.logTrace(text)
  print(" T " .. text)
end

dofile("C:\\Users\\dpierron001\\dev\\private\\VEAF_mission_library\\scripts\\dcsUnits.lua")
dofile("C:\\Users\\dpierron001\\dev\\private\\VEAF_mission_library\\scripts\\veafUnits.lua")
veafUnits.initialize()

veafCasMission = {}

--- Generates an infantry group along with its manpad units and tranport vehicles
function veafCasMission.generateInfantryGroup(groupId, spawnSpot, defense, armor, skill)
    local group = {}

    -- generate an infantry group
    local groupCount = math.random(3, 7)
    local dispersion = (groupCount+1) * 5 + 25
    local unit = veafUnits.findUnit
    for i = 1, groupCount do
        veaf.addUnit(infantryGroup, spawnSpot, dispersion, "Soldier AK", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " unit #" .. i, skill)
    end

    -- add a transport vehicle
    if armor > 0 then
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, "BTR-80", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " APC", skill)
    else
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, "GAZ-3308", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " truck", skill) -- TODO check if tranport type is correct
    end

    -- add manpads if needed
    if defense > 3 then
        -- for defense = 4-5, spawn a full Igla-S team
        veaf.addUnit(infantryGroup, spawnSpot, dispersion, "SA-18 Igla-S comm", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad COMM soldier", skill)
        veaf.addUnit(infantryGroup, spawnSpot, dispersion, "SA-18 Igla-S manpad", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad launcher soldier", skill)
    elseif defense > 0 then
        -- for defense = 1-3, spawn a single Igla soldier
        veaf.addUnit(infantryGroup, spawnSpot, dispersion, "SA-18 Igla manpad", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad launcher soldier", skill)
    else
        -- for defense = 0, don't spawn any manpad
    end

    return vehiclesGroup, infantryGroup
end

local group = veafUnits.findGroup("tarawa")
local spawnPoint = { x = 0, y = 0, z = 0 }
placeUnitsOfGroup(spawnPoint, group, 20)

print(group.description)
for _, u in pairs(group.units) do
    print("   - " .. u.displayName)
    print("        x=" .. u.spawnPoint.x)
    print("        y=" .. u.spawnPoint.y)
end
