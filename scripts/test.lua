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

local group = veafUnits.findGroup("tarawa")
local spawnPoint = { x = 0, y = 0, z = 0 }
placeUnitsOfGroup(spawnPoint, group, 20)

print(group.description)
for _, u in pairs(group.units) do
    print("   - " .. u.displayName)
    print("        x=" .. u.spawnPoint.x)
    print("        y=" .. u.spawnPoint.y)
end
