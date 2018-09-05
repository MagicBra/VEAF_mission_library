--getwind.lua by Wrench
--update to calculate boatspeed appropriately
--[[ MINIMUM ME SETUP:
	MISSION START		-					DOSCRIPTFILE MIST
											DOSCRIPTFILE GETWIND
											wrench_wind_setup('unit1', distip, cycletime, tanker)
	
	CARRIER "TRIGGERED ACTIONS" Must have as index 1, "ACTIVATE TACAN"
********NOTES********
Even if the wind is over 25 knots, the carrier will always travel at least 5 knots, or else it will endlessly travel in circles.
	You might have luck getting it a bit lower, but will require some testing.
	
The arguments for wrench_wind_setup are as follows:
	The name of the carrier unit (must have quotes i.e. '' or "")
	The maximum distance the carrier will travel before returning to it's IP from the ME.
		Note that the father you set this, the longer it will take for the carrier to turn around, but the longer it will be before you get	
		ideal wind conditions again.
	The cycle time (optional) this will override the distip in favor of a cycle time. This is the time from recovery to recovery, in other 
		words ,including the return trip (estimated)
	The tanker is the name of a unit you'd like to orbit the carrier, and follow it on it's route. This allows a tanker to follow the carrier's
		path, without getting left behind as it moves.
		One minor issue is that it will go until it runs out of fuel and crashes. I'm too lazy at present to add a bingo fuel script.
		
Note that if you want to use distip and the tanker, the script would read something like
	wrench_wind_setup('carrier', 87000, nil, 'tanker1')
		
I haven't finished bullet-proofing this yet, so You'll get error messages if you make a mistake editing the mission, or creating your own.
Thanks to many members of the community (largely Grimes) for helping my stumble my way through the code.
Thanks again to Grimes, and to Speed for MiST, which is used in many parts of this script.
]]
local myLog = mist.Logger:new('Carrier Script')
CarScript = missionCommands.addSubMenu('Carrier Script' ,nil)
function wrench_ship_from_ip(unit1, distip)
	local pos1 = _G[unit1]:getPosition().p
	if mist.utils.get2DDist(pos1 ,_G[unit1 .. 'startpos']) > distip then
		wrench_carrier_to_ip(unit1)
	end
end
function wrench_shipshore(unit1,flg)
	local unittable = mist.makeUnitTable({unit1})
	local safearea = { [1] = { ["y"] = 239569.86742857, ["x"] = -57480.918857144, }, [2] = { ["y"] = 308546.84542857, ["x"] = -88450.174285716, }, [3] = { ["y"] = 426793.09342857, ["x"] = -172911.78, }, [4] = { ["y"] = 487323.91085715, ["x"] = -213265.65828572, }, [5] = { ["y"] = 542223.95457143, ["x"] = -236257.98428572, }, [6] = { ["y"] = 590085.53114286, ["x"] = -288342.64114286, }, [7] = { ["y"] = 590085.53114286, ["x"] = -324004.208, }, [8] = { ["y"] = 560054.738, ["x"] = -365296.54857143, }, [9] = { ["y"] = 499054.68942857, ["x"] = -396735.03514286, }, [10] = { ["y"] = 444623.87685715, ["x"] = -384065.79428572, }, [11] = { ["y"] = 347962.26142857, ["x"] = -413627.35628572, }, [12] = { ["y"] = 183262.13028572, ["x"] = -337611.91114286, }, [13] = { ["y"] = 76277.429714289, ["x"] = -305704.19342857, }, [14] = { ["y"] = -76222.691714283, ["x"] = -309927.27371429, }, [15] = { ["y"] = -181799.69885714, ["x"] = -344181.14714286, }, [16] = { ["y"] = -243268.97857143, ["x"] = -388758.10571429, }, [17] = { ["y"] = -320692.11714285, ["x"] = -388758.10571429, }, [18] = { ["y"] = -412192.19, ["x"] = -372335.01571429, }, [19] = { ["y"] = -464276.84685714, ["x"] = -334327.29314286, }, [20] = { ["y"] = -480699.93685714, ["x"] = -278488.78714286, }, [21] = { ["y"] = -417822.96371428, ["x"] = -202942.57314286, }, [22] = { ["y"] = -396707.56228571, ["x"] = -106280.95771429, }, [23] = { ["y"] = -318345.96142857, ["x"] = -63111.69257143, }, [24] = { ["y"] = -299107.48457143, ["x"] = 23696.068857141, }, [25] = { ["y"] = -260630.53085714, ["x"] = 97834.589428571, }, [26] = { ["y"] = -174761.23171428, ["x"] = 65457.640571428, }, [27] = { ["y"] = -179922.77428571, ["x"] = 9619.134571428, }, [28] = { ["y"] = -125491.96171428, ["x"] = -44811.678000001, }, [29] = { ["y"] = -117515.03228571, ["x"] = -86573.249714286, }, [30] = { ["y"] = -8653.4071428555, ["x"] = -113319.42485714, }, [31] = { ["y"] = 88477.439428573, ["x"] = -56073.225428572, }, [32] = { ["y"] = 170592.88942857, ["x"] = -40119.366571429, }, }
	local vars = 
		{
		units = unittable, 
		zone = safearea, 
		flag = flg,
		stopFlag = nil, 
		maxalt = 200, 
		req_num = 1, 
		interval = 1, 
		toggle = true,
		}
	mist.flagFunc.units_in_polygon(vars)
end
function wrench_carrier_to_ip(unit1)
	_G[unit1 .. 'returning'] = true
	_G[unit1 .. 'ET'] = 0
	local pos1 = _G[unit1]:getPosition().p
	local group1 = Unit.getGroup((_G[unit1]))
	local path = {} 
	path[#path + 1] = mist.ground.buildWP(pos1, 'Diamond', 30.3522)
	path[#path + 1] = mist.ground.buildWP(_G[unit1 .. 'startpos'], 'Diamond', 30.3522)
	mist.goRoute(group1 ,path)
end
function wrench_get_wind(unit1, distip)
if _G[unit1 .. 'stop'] then 
	trigger.action.groupStopMoving(_G[unit1 .. 'group'])
else
if	trigger.misc.getUserFlag(_G[unit1]["id_"]+0.1) == 1 then
		_G[unit1 .. 'returning'] = false
	end
if not _G[unit1 .. 'returning'] then
	local wind = {}
	local windspeed = {}
	if _G[unit1] then
		local pos1 = _G[unit1]:getPosition().p
		if pos1 ~= nil then
			pos1.y=pos1.y+1
			--get wind info
			wind = atmosphere.getWind(pos1)
			windspeed = mist.vec.mag(wind)
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
			_G[unit1..'dir'] = math.floor(dir-7)
			local dirrad = mist.utils.toRadian(dir)
			if windspeed < 12.8611 then
				speed = 12.8611 - windspeed
				wrench_go_direction(unit1,dirrad,speed)
			else
				wrench_go_direction(unit1,dirrad,1)
			end
				if not _G[unit1 .. 'override'] then
					if _G[unit1 .. 'LARC'] then
						wrench_LARC(unit1)
						wrench_shipshore (unit1,_G[unit1]["id_"])
					else
						wrench_ship_from_ip(unit1, distip)
						wrench_shipshore (unit1,_G[unit1]["id_"])
					end
				end
			end
	else
		trigger.action.outText('unit not detected', 2)
	end
	if	trigger.misc.getUserFlag(_G[unit1]["id_"]) == 0 then
		wrench_carrier_to_ip(unit1)
	end
else
--trigger.action.outText(unit1 .. ' is returning.', 2)
end
end
end
function wrench_LARC(unit1)
	_G[unit1 .. 'ET'] = _G[unit1 .. 'ET'] + 10
	local pos1 = _G[unit1]:getPosition().p
	_G[unit1 .. 'Traveled'] = mist.utils.get3DDist(pos1 ,_G[unit1 .. 'startpos'])
	_G[unit1 .. 'estimated retun time'] = (_G[unit1 .. 'Traveled']/12.8611)+240
	myLog:msg(_G[unit1 .. 'Traveled'])
	myLog:msg(_G[unit1 .. 'estimated retun time'])
	if _G[unit1 .. 'ET'] + _G[unit1 .. 'estimated retun time'] >= _G[unit1 .. 'LARC'] then
		wrench_carrier_to_ip(unit1)
	end
end
function wrench_go_direction(unit1,dir,speed)
	local pos1 = _G[unit1]:getPosition().p
	if pos1 ~= nil then
		local group1 = Unit.getGroup((_G[unit1]))
		local new = {}
		local new = {x = ((math.cos(dir) * 1000) + pos1.x), z = ((math.sin(dir) * 1000) + pos1.z), y = 0}
		local path = {} 
		path[#path + 1] = mist.ground.buildWP(pos1, 'Diamond', speed)
		path[#path + 1] = mist.ground.buildWP(new, 'Diamond', speed)
		mist.goRoute(group1 ,path)
	end
end
function wrench_carrier_at_ip(unit1)
	local unittable = mist.makeUnitTable({unit1})
	local ipzone = {}
	ipzone[1] = {x = ((math.cos(0) * 500) + _G[unit1 .. 'startpos'].x), z = ((math.sin(0) * 500) + _G[unit1 .. 'startpos'].z), y = 0}
	ipzone[2] = {x = ((math.cos(1.5708) * 500) + _G[unit1 .. 'startpos'].x), z = ((math.sin(1.5708) * 500) + _G[unit1 .. 'startpos'].z), y = 0}
	ipzone[3] = {x = ((math.cos(3.14159) * 500) + _G[unit1 .. 'startpos'].x), z = ((math.sin(3.14159) * 500) + _G[unit1 .. 'startpos'].z), y = 0}
	ipzone[4] = {x = ((math.cos(4.71239) * 500) + _G[unit1 .. 'startpos'].x), z = ((math.sin(4.71239) * 500) + _G[unit1 .. 'startpos'].z), y = 0}
	local vars = 
		{
		units = unittable, 
		zone = ipzone, 
		flag = _G[unit1]["id_"]+0.1,
		stopFlag = nil, 
		maxalt = 200, 
		req_num = 1, 
		interval = 1, 
		toggle = true,
		}
	mist.flagFunc.units_in_polygon(vars)
end
function wrench_querymode(unit1)
	if _G[unit1 .. 'returning'] then 
		trigger.action.outText(unit1 .. ' is returning.', 2)
	end
	if _G[unit1 .. 'override'] then
		trigger.action.outText(unit1 .. ' is on manual override mode.', 2)
	end
	if (not _G[unit1 .. 'override']) and (not _G[unit1 .. 'returning']) then
		trigger.action.outText(unit1 .. ' is ready for recovery.', 2)
	end
	if _G[unit1 .. 'stop'] then
		trigger.action.outText(unit1 .. ' is stopped.', 2)
	end
end
function wrench_orbit_carrier(carrier,tanker)
	_G[tanker] = Unit.getByName(tanker)
	local carpos = Unit.getByName(carrier):getPosition().p
	local airpos = Unit.getByName(tanker):getPosition().p	
	local group1 = Unit.getGroup(_G[tanker])
	local track = {}
	local path = {}
	track[1] = {x = ((math.cos(0) * 37040) + carpos.x), z = ((math.sin(0) * 37040) + carpos.z), y = 6096}
	track[2] = {x = ((math.cos(1.5708) * 37040) + carpos.x), z = ((math.sin(1.5708) * 37040) + carpos.z), y = 6096}
	track[3] = {x = ((math.cos(3.14159) * 37040) + carpos.x), z = ((math.sin(3.14159) * 37040) + carpos.z), y = 6096}
	track[4] = {x = ((math.cos(4.71239) * 37040) + carpos.x), z = ((math.sin(4.71239) * 37040) + carpos.z), y = 6096}
	_G[tanker .. 'zone'] = {}
	_G[tanker .. 'zone'][1] = {x = ((math.cos(0) * 1000) + track[4].x), z = ((math.sin(0) * 1000) + track[4].z), y = 0}
	_G[tanker .. 'zone'][2] = {x = ((math.cos(1.5708) * 1000) + track[4].x), z = ((math.sin(1.5708) * 1000) + track[4].z), y = 0}
	_G[tanker .. 'zone'][3] = {x = ((math.cos(3.14159) * 1000) + track[4].x), z = ((math.sin(3.14159) * 1000) + track[4].z), y = 0}
	_G[tanker .. 'zone'][4] = {x = ((math.cos(4.71239) * 1000) + track[4].x), z = ((math.sin(4.71239) * 1000) + track[4].z), y = 0}
	for i = 1, #track do
		path[i] = mist.fixedWing.buildWP(track[i], 'turningpoint' ,180.056 ,6096 ,'Baro' )			  
	end
	--myLog:msg(path)
	mist.goRoute(group1 ,path)
	_G[tanker .. 'flag'] = _G[tanker]["id_"]
	local unittable = mist.makeUnitTable({tanker})
	local vars = 
		{
		units = unittable, 
		zone = _G[tanker .. 'zone'], 
		flag = _G[tanker .. 'flag'],
		stopFlag = _G[tanker .. 'flag'], 
		maxalt = 1000000000, 
		req_num = 1, 
		interval = 1, 
		toggle = true,
		}
	mist.flagFunc.units_in_polygon(vars)
end
function wrench_tanker_checkflag(carrier,tanker)
	if	trigger.misc.getUserFlag(_G[tanker .. 'flag']) == 1 then
		trigger.action.setUserFlag(_G[tanker .. 'flag'], 0 )
		wrench_orbit_carrier(carrier,tanker)
	end
end
function wrench_wind_setup(unit1, distip, LARC, tanker)
	_G[unit1] = Unit.getByName(unit1)
	trigger.action.setUserFlag(_G[unit1]["id_"], 1)
	trigger.action.setUserFlag(_G[unit1]["id_"]+0.1, 1)
	--VARS
	_G[unit1 .. 'startpos'] = _G[unit1]:getPosition().p
	_G[unit1 .. 'returning'] = false
	_G[unit1 .. 'override'] = false	
	_G[unit1 .. 'stop'] = false
	_G[unit1 .. 'coa'] = Unit.getCoalition(_G[unit1])
	_G[unit1 .. 'group'] = Unit.getGroup(_G[unit1])--:getName()
	if LARC then
		_G[unit1 .. 'LARC'] = LARC
	end
	_G[unit1 .. 'ET'] = 0
	--MENU
	_G[unit1 .. 'menu'] = missionCommands.addSubMenuForCoalition(_G[unit1 .. 'coa'],unit1 ,CarScript)
	missionCommands.addCommandForCoalition(_G[unit1 .. 'coa'],('Get BRC for ' .. unit1), _G[unit1 .. 'menu'],function() trigger.action.outText('BRC for ' .. unit1 .. " is " .. _G[unit1..'dir'].. '.', 10) end, nil)
	missionCommands.addCommandForCoalition(_G[unit1 .. 'coa'],(unit1 .. ' Automatic'), _G[unit1 .. 'menu'],function() _G[unit1 .. 'override'] = false _G[unit1 .. 'stop'] = false trigger.action.outText(unit1 .. ' Automatic.', 2) end, nil)
	missionCommands.addCommandForCoalition(_G[unit1 .. 'coa'],(unit1 .. ' Override'), _G[unit1 .. 'menu'],function() _G[unit1 .. 'override'] = true _G[unit1 .. 'returning'] = false _G[unit1 .. 'stop'] = false trigger.action.outText(unit1 .. ' Override.', 2) end, nil)
	missionCommands.addCommandForCoalition(_G[unit1 .. 'coa'],(unit1 .. ' Stop'), _G[unit1 .. 'menu'],function() trigger.action.groupStopMoving(_G[unit1 .. 'group']) _G[unit1 .. 'stop'] = true trigger.action.outText(unit1 .. ' Stopped.', 2) end, nil)
	missionCommands.addCommandForCoalition(_G[unit1 .. 'coa'],(unit1 .. ' Query'), _G[unit1 .. 'menu'],function() wrench_querymode(unit1) end, nil)
	--CALLS
	wrench_carrier_at_ip(unit1)
	wrench_shipshore(unit1,3)
	wrench_get_wind(unit1, 5000)
	mist.scheduleFunction(wrench_get_wind, {unit1, distip}, timer.getTime() + 10, 10, timer.getTime() + 100000)
	local cargroup = Unit.getGroup(_G[unit1]):getName()
	cargroup = Group.getByName(cargroup)
	--myLog:msg(unit1 .. ' ' .. _G[unit1 .. 'coa'])
	mist.scheduleFunction(trigger.action.pushAITask,{cargroup, 1} ,timer.getTime() + 1 , 60 ,timer.getTime() + 100000)
	--TANKER STUFF
	if tanker then
		wrench_orbit_carrier(unit1,tanker)
		mist.scheduleFunction(wrench_orbit_carrier, {unit1, tanker}, timer.getTime() + 5, 1, timer.getTime() + 10)
		mist.scheduleFunction(wrench_tanker_checkflag, {unit1, tanker}, timer.getTime() + 10, 1, timer.getTime() + 100000)
	end
end
--[[CHANGELOG
Added BRC to F10>Carrier Script
Added TACAN Bug fix
Removed 'dist' argument
Changed trigger system to dynamic variable system, so multiple carriers can be used.
Added Manual Override
Made menus Coalition Specific
Removed extraneous comments
Added stop menu option
Added Query Menu option
Added Time-Based Option
Added Tanker Script
]]--
--[[todo

]]--