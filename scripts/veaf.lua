-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF root script library for DCS Workd
-- By zip (2018)
--
-- Features:
-- ---------
-- Contains all the constants and utility functions required by the other VEAF script libraries
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
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
--     * OPEN --> Browse to the location where you saved the script and click OK.
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veaf = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the root VEAF constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veaf.Id = "VEAF - "

--- Version.
veaf.Version = "1.1.0"

--- Enable logDebug ==> give more output to DCS log file.
veaf.Debug = true
--- Enable logTrace ==> give even more output to DCS log file.
veaf.Trace = true

veaf.RadioMenuName = "VEAF"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veaf.radioMenuPath = nil

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veaf.logError(message)
    env.error(veaf.Id .. message)
end

function veaf.logInfo(message)
    env.info(veaf.Id .. "I - " .. message)
end

function veaf.logDebug(message)
    if veaf.Debug then
        env.info(veaf.Id .. "D - " .. message)
    end
end

function veaf.logTrace(message)
    if veaf.Trace then
        env.info(veaf.Id .."T - " ..  message)
    end
end

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


--- Simple round
function veaf.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

--- Return the height of the land at the coordinate.
function veaf.getLandHeight(vec3)
    veaf.logTrace(string.format("getLandHeight: vec3  x=%.1f y=%.1f, z=%.1f", vec3.x, vec3.y, vec3.z))
    local vec2 = {x = vec3.x, y = vec3.z}
    veaf.logTrace(string.format("getLandHeight: vec2  x=%.1f z=%.1f", vec3.x, vec3.z))
    -- We add 1 m "safety margin" because data from getlandheight gives the surface and wind at or below the surface is zero!
    local height = math.floor(land.getHeight(vec2) + 1)
    veaf.logTrace(string.format("getLandHeight: result  height=%.1f",height))
    return height
end

--- Return a point at the same coordinates, but on the surface
function veaf.placePointOnLand(vec3)
    if not vec3.y then
        vec3.y = 0
    end
    
    veaf.logTrace(string.format("getLandHeight: vec3  x=%.1f y=%.1f, z=%.1f", vec3.x, vec3.y, vec3.z))
    local height = veaf.getLandHeight(vec3)
    veaf.logTrace(string.format("getLandHeight: result  height=%.1f",height))
    local result={x=vec3.x, y=height, z=vec3.z}
    veaf.logTrace(string.format("placePointOnLand: result  x=%.1f y=%.1f, z=%.1f", result.x, result.y, result.z))
    return result
end

--- Trim a string
function veaf.trim(s)
    local a = s:match('^%s*()')
    local b = s:match('()%s*$', a)
    return s:sub(a,b-1)
end

--- Split string. C.f. http://stackoverflow.com/questions/1426954/split-string-in-lua
function veaf.split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

--- Break string around a separator
function veaf.breakString(str, sep)
    local regex = ("^([^%s]+)%s(.*)$"):format(sep, sep)
    local a, b = str:match(regex)
    if not a then a = str end
    local result = {a, b}
    return result
end

--- Get the average center of a group position (average point of all units position)
function veaf.getAveragePosition(groupName)
	local count

	local totalPosition = {x = 0,y = 0,z = 0}
	local group = Group.getByName(groupName)
	if group then
		local units = Group.getUnits(group)
		for count = 1,#units do
			if units[count] then 
				totalPosition = mist.vec.add(totalPosition,Unit.getPosition(units[count]).p)
			end
		end
		if #units > 0 then
			return mist.vec.scalar_mult(totalPosition,1/#units)
		else
			return nil
		end
	else
		return nil
	end
end

function veaf.emptyFunction()
end

--- Returns the wind direction (from) and strength.
function veaf.getWind(point)

    -- Get wind velocity vector.
    local windvec3  = atmosphere.getWind(point)
    local direction = math.floor(math.deg(math.atan2(windvec3.z, windvec3.x)))
    
    if direction < 0 then
      direction = direction + 360
    end
    
    -- Convert TO direction to FROM direction. 
    if direction > 180 then
      direction = direction-180
    else
      direction = direction+180
    end
    
    -- Calc 2D strength.
    local strength=math.floor(math.sqrt((windvec3.x)^2+(windvec3.z)^2))
    
    -- Debug output.
    veaf.logTrace(string.format("Wind data: point x=%.1f y=%.1f, z=%.1f", point.x, point.y,point.z))
    veaf.logTrace(string.format("Wind data: wind  x=%.1f y=%.1f, z=%.1f", windvec3.x, windvec3.y,windvec3.z))
    veaf.logTrace(string.format("Wind data: |v| = %.1f", strength))
    veaf.logTrace(string.format("Wind data: ang = %.1f", direction))
    
    -- Return wind direction and strength km/h.
    return direction, strength, windvec3
  end

--- Find a suitable point for spawning a unit in a <dispersion>-sized circle around a spot
function veaf.findPointInZone(spawnSpot, dispersion, isShip)
    local unitPosition
    local tryCounter = 1000
    
    repeat -- Place the unit in a "dispersion" ft radius circle from the spawn spot
        unitPosition = mist.getRandPointInCircle(spawnSpot, dispersion)
        local landType = land.getSurfaceType(unitPosition)
        tryCounter = tryCounter - 1
    until ((isShip and landType == land.SurfaceType.WATER) or (not(isShip) and (landType == land.SurfaceType.LAND or landType == land.SurfaceType.ROAD or landType == land.SurfaceType.RUNWAY))) or tryCounter == 0
    if tryCounter == 0 then
        return nil
    else
        return unitPosition
    end
end

--- Add a unit to the <group> on a suitable point in a <dispersion>-sized circle around a spot
function veaf.addUnit(group, spawnSpot, dispersion, unitType, unitName, skill)
    local unitPosition = veaf.findPointInZone(spawnSpot, dispersion, false)
    if unitPosition ~= nil then
        table.insert(
            group,
            {
                ["x"] = unitPosition.x,
                ["y"] = unitPosition.y,
                ["type"] = unitType,
                ["name"] = unitName,
                ["heading"] = 0,
                ["skill"] = skill
            }
        )
    else
        veaf.logInfo("cannot find a suitable position for unit "..unitType)
    end
end

--- Makes a group move to a waypoint set at a specific heading and at a distance covered at a specific speed in an hour
function veaf.moveGroupAt(groupName, heading, speed)
	local unitGroup = Group.getByName(groupName)
    if unitGroup == nil then
        veaf.logError("veaf.moveGroupAt: " .. groupName .. ' not found')
		return false
	end
    
    local length = speed * 3600 -- m travelled in an hour
    veafCarrierOperations.logTrace("length="..length)

    local headingRad = mist.utils.toRadian(heading)
    veafCarrierOperations.logTrace("headingRad="..headingRad)
    local fromPosition = veaf.getAvgGroupPos(groupName)
    local waypointPos = {x = fromPosition.x + length * math.cos(headingRad), z = fromPosition.z + length  * math.sin(headingRad)}
    veafCarrierOperations.logTrace("waypointPos="..veaf.vecToString(waypointPos))

    -- new route point
	local newWaypoint = {
		["action"] = "Turning Point",
		["alt"] = 0,
		["alt_type"] = "BARO",
		["form"] = "Turning Point",
		["speed"] = speed,
		["type"] = "Turning Point",
		["x"] = waypointPos.x,
		["y"] = waypointPos.z,
	}

	-- order group to new waypoint
    return veaf.moveGroupTo(groupName, newWaypoint, speed)
end

-- Makes a group move to a specific waypoint at a specific speed
function veaf.moveGroupTo(groupName, pos, speed)
    
	local unitGroup = Group.getByName(groupName)
    if unitGroup == nil then
        veaf.logError("veaf.moveGroupTo: " .. groupName .. ' not found')
		return false
	end
    
	-- new route point
	local newWaypoint = {
		["action"] = "Turning Point",
		["alt"] = 0,
		["alt_type"] = "BARO",
		["form"] = "Turning Point",
		["speed"] = speed,
		["type"] = "Turning Point",
		["x"] = pos.x,
		["y"] = pos.z,
	}

	-- order group to new waypoint
	mist.goRoute(groupName, {newWaypoint})

    return true
end

function veaf.getAvgGroupPos(groupName) -- stolen from Mist and corrected
	local group = groupName -- sometimes this parameter is actually a group
	if type(groupName) == 'string' and Group.getByName(groupName) and Group.getByName(groupName):isExist() == true then
		group = Group.getByName(groupName)
	end
	local units = {}
	for i = 1, group:getSize() do
		table.insert(units, group:getUnit(i):getName())
	end

	return mist.getAvgPos(units)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Radio menu methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Build the initial radio menu
function veaf.buildRadioMenu()
    veaf.radioMenuPath = missionCommands.addSubMenu(veaf.RadioMenuName)
    missionCommands.addCommand('Visit us at http://www.veaf.org', veaf.radioMenuPath, veaf.emptyFunction)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- initialize the random number generator to make it almost random
math.random(); math.random(); math.random()

veaf.buildRadioMenu()

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)

veaf.logInfo(string.format("Loading version %s", veaf.Version))
