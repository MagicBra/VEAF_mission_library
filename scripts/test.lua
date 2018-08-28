dofile("C:\\Users\\dpierron001\\dev\\private\\VEAF_mission_library\\scripts\\veafUnits.lua")

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

local group = veafUnits.findGroup("tarawa")

print(group)