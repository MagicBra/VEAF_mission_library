--[[ Overall Documentation: 
	These pretty much all require MiST.
	Some arguments have weird names to deconflict. These names aren't visible to the end user,
	so its NBD.
	
	Not a ton of documentation, as this was really just meant for me. The functions are basically
	mixtures of other (mostly MiST) functions.
	Notes are mostly to remind me how they work without having to read them.
	Recommend loading with 
		assert(loadfile("C:\\Users\\willt\\Saved Games\\DCS.openbeta\\Missions\\Scripts\\WrenchFunctions.lua"))()
	in case edits need to be made mid mission.
	this will have to be changed to "DO SCRIPT FILE" prior to release.
]]
--[[ Respawn
	wrench_respawn will manually respawn a group, and they will go about their business.
	Call will look like
	wrench_respawn(string group name, boolean drone) i.e.
	wrench_respawn('groupname',false) or wrench_respawn('groupname',true)
	
	wrench_randomrespawn will manually respawn a group randomly in a zone or zones.
	Call will look like:
	wrench_randomrespawn(string group name, boolean drone, table zones) i.e.
	wrench_randomrespawn('groupname',false,{'zone1'}) or wrench_randomrespawn('groupname',true,{'zone1'})
	
	Auto Respawn 
	auto calls wrench_respawns.
	Will call respawn if zones is nil, randomrespawn if it isn't.
	arguments are:
	wrench_randomrespawn(string group name, boolean drone,table zones *or nil*)
	something like:
	wrench_autorespawn('groupname',false) or wrench_autorespawn('groupname',true,{'zone1'}) or any of the permutations.
]]
function wrench_respawn(group, drone)
	local msg = {}
	msg.text = "Respawning "..group
	msg.displayTime = 30
	msg.msgFor = {coa = {'all'}}
	mist.message.add(msg)
	mist.respawnGroup(group, true)
	if drone == true then
		local con = Group.getByName(group):getController()
		con:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
		con:setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
		con:setOption(AI.Option.Air.id.PROHIBIT_AA, true)
	end
	end
function wrench_randomrespawn(group, drone, zones)
	local msg = {}
	msg.text = "Respawning "..group
	msg.displayTime = 10
	msg.msgFor = {coa = {'all'}}
	mist.message.add(msg)
	mist.respawnInZone(group, zones, true, 0)
	if drone == true then
		local con = Group.getByName(group):getController()
		con:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
		con:setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
		con:setOption(AI.Option.Air.id.PROHIBIT_AA, true)
		end
end
function wrench_autorespawn(group,drone,zones)
if not Group.getByName(group) then
	if zones == nil then
		wrench_respawn(group, drone)
	else
		wrench_randomrespawn(group, drone, zones)
	end
end
end
--[[ Random Activation
	Activates a group after random time. 
	wrench_activater will automatically call wrench_activeategroup.
	Call would be like
	wrench_activater(groupname,min,max) i.e.
	wrench_activater('bf109',0,120)
]]
function wrench_activeategroup(group)
trigger.action.activateGroup(group)
end
function wrench_activater(unitname,tmin,tmax)
local group = Unit.getGroup(Unit.getByName(unitname))
waittime = mist.random(tmin,tmax)
mist.scheduleFunction(wrench_activeategroup,{group} , timer.getTime() + waittime , 10 ,timer.getTime() + waittime+1 )
end
--[[ Wrench CSAR **UNTESTED IN FUNCTION FORM**
	This one is a little more complicated.
	Call wrench_csar, which will: 
	Determine when a unit is near enough to the distressed unit: 
		-set a flag (chosen in arguments)
			-for him to pop a flare
			-for the player to get the radio option
		-set a special case flag
		-for the helo to find the unit himself
	This call will look like:
	wrench_csar(distressed unit,rescue helicopter, Coalition of player,flag to set when near enough, flag to set if helo finds CSAR by himself, radius to detect, special radius for helo, ,flag to stop search, interval time to check)
	
	when the flag is triggered, in the ME have a radio item activated to signal the unit has been found.
		when that radio item is triggered, call wrench_csar_dispatch.
			this will look like:
			wrench_csar_dispatch(distressed unit,rescue helicopter)
	Special Case flags for when the helo finds the unit himself, will shortcut the radio item and
		call wrench_csar_dispatch.
	Stop flag should be set the the flag that calls wrench_csar_dispatch, so that it won't continuously pop flares and
		add a million radio items.
]]
function wrench_csar_dispatch(csar,rescue)
local pos = Unit.getByName(csar):getPosition().p
local helo = Unit.getByName(rescue)
local poshelo = Unit.getByName(rescue):getPosition().p
local heligroup = Unit.getGroup(helo)
local posn = {}
posn.x = mist.utils.deepCopy(pos.x + 500)
posn.z = mist.utils.deepCopy(pos.z + 500)
local poss = {}
poss.x = mist.utils.deepCopy(pos.x - 500)
poss.z = mist.utils.deepCopy(pos.z - 500)

local path = {} 
			path[#path + 1] = mist.heli.buildWP(poshelo , 'flyOverPoint' ,108 ,300 ,"BARO" )
			path[#path + 1] = mist.heli.buildWP(posn , 'flyOverPoint' ,108 ,300 ,"BARO" )
			path[#path + 1] = mist.heli.buildWP(poss , 'flyOverPoint' ,1 ,75 ,"BARO" )
mist.goRoute(heligroup ,path)
end
function wrench_csar(csar,rescue,coa,flg,specialflag,radus,specialradius,stpFlg,intvl)
coaplanes = mist.makeUnitTable({tostring('['..coa..']'..'[plane]')})
coahelo = mist.makeUnitTable({tostring('['..coa..']'..'[helicopter]')})
csartable = mist.makeUnitTable({tostring(csar)})
varsplayer = 
 {
 units = coaplanes, 
 zone_units = csartable, 
 flag = flg, 
 radius = radus,
 stopFlag = stpFlg, 
 zone_type = 'cylinder', 
 req_num = 1, 
 interval = intvl, 
 toggle = true,
 }
 varshelo = 
 {
 units = coahelo, 
 zone_units = csartable, 
 flag = flg, 
 radius = radus,
 stopFlag = stpFlg, 
 zone_type = 'cylinder', 
 req_num = 1, 
 interval = intvl, 
 toggle = true,
 }
 varsrescue = 
 {
 units = redhelo, 
 zone_units = csartable, 
 flag = specialflag, 
 radius = specialradius,
 zone_type = 'cylinder', 
 req_num = 1, 
 interval = intvl, 
 toggle = false,
 }
mist.flagFunc.units_in_moving_zones(varsplayer)
mist.flagFunc.units_in_moving_zones(varshelo)
mist.flagFunc.units_in_moving_zones(varsrescue)
end
--[[ In Table
	used by other functions.
]]
function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return true
    end
end
end
--[[ Is Target Detected **UNTESTED IN FUNCTION FORM**
	
	This is a big one...
	
	Must set "detectedseconds = 0" prior to function call.
	Will set a flag if the units in a table of groups are detected by a unit for a specified amount of time.
	playergroups is a table of group names of playable aircraft prefaced with [g].
		i.e. {'[g]players #001','[g]players','[g]players #002'}
			look up mist.makeunittable for details on this.
		This must be passed as a table, with the {}.
		This will (in effect)be trimmed down by the function to only include units occupied by players,
		so pass all groups with PLAYER or CLIENT spot(s)
			
	awacs is the name of the AWACS unit. i.e. 'usawacs'
	mapzone is a table with the name of a zone which will encompass the whole map, used to make a table needed by the function.
		i.e. {'wholemap'}
		This must be passed as a table, with the {}.
	coa_enum
		0 = neutral
		1 = red
		2 = blue
	dettype is the type of detection to be used. Will be one of:
		VISUAL
		OPTIC
		RADAR
		IRST
		RWR
		DLINK
	flag_num is the flag to set to true (1) when the units are detected long enough. is a number, i.e. 100
	dettime is how long they must be detected for, in seconds. i.e. 60
		this will also count backwards, at 1/10 speed, when they are not detected. Will not go <1.
	mesg Boolean, whether or not to notify players they are being detected.
	
	The whole shebang might look something like:
	detectedseconds = 0
	wrench_countdetectedseconds({'[g]players #001','[g]players','[g]players #002'},"usawacs",{'wholemap'},1,RADAR,100,60,true)
]]
function wrench_countdetectedseconds(playergroups,awacs,mapzone,coa_enum,dettype,flag_num,dettime,mesg)
	stopflag = trigger.misc.getUserFlag(flag_num)
if stopflag == 0 then 
	playerplanes = mist.makeUnitTable(playergroups)
	playerplanes["processed"] = nil
	ewrUnit = Unit.getByName(awacs)
	ewrCtrl = Unit.getController(ewrUnit)

	activeunits = mist.getUnitsInZones(playerplanes ,mapzone)
	playerslist = coalition.getPlayers(coa_enum)
	numberofplayers = #playerslist
	if numberofplayers < 1 then
		numberofplayers = 1
	end
	DetectedTargets = {}
	for i=1,#activeunits do
		local visible = {}
		local detected = {}
		detected, visible = Controller.isTargetDetected(ewrUnit, activeunits[i] , dettype)
		if visible == true then
			detectedseconds = detectedseconds + 1
		else
			if detectedseconds > 1 then 
				detectedseconds = detectedseconds + -0.1
			end
		end
	end
		if (detectedseconds) > dettime then
			trigger.action.setUserFlag(flag_num, 1 )
		end

	if mesg then
		trigger.action.outText(tostring(detectedseconds), 1 , true)
	end
local myLog = mist.Logger:new('Detected Seconds')
myLog:msg('count ' .. detectedseconds)
end
end
