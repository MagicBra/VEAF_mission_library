---------------------------------------
----  Dismounts Scrip  ----
---------------------------------------
--
--	v1.0 - 5. July 2013 
--	By Marc "MBot" Marbot
-- 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	Control functions:
--
--	AddDismounts(UnitName, dm_type)
--		UnitName: string, name of group
--		dm_type: string, "MANPADS", "Mortar", "Rifle", "ZU-23"
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do
	--Table that holds all ground units that carry mounted units
	local DismountsCarrier = {}
	
	--Function to add mounted units to a carrier
	function AddDismounts(UnitName, dm_type)	--Options for dm_type: "MANPADS", "Mortar", "Rifle", "ZU-23"
		DismountsCarrier[#DismountsCarrier + 1] = {
			name = UnitName,
			countryID = Unit.getByName(UnitName):getCountry(),
			UnitID = Unit.getByName(UnitName):getID(),
			cargo = dm_type,
			cargo_status = "mounted",
		}
	end
	
	
	--Function go get a unit heading
	local function GetHeading(Pos3)
		if (Pos3.x.x > 0) and (Pos3.x.z == 0) then
			return 0
		elseif (Pos3.x.x > 0) and (Pos3.x.z > 0) then
			return math.atan(Pos3.x.z / Pos3.x.x)
		elseif (Pos3.x.x == 0) and (Pos3.x.z > 0) then
			return math.rad(90)
		elseif (Pos3.x.x < 0) and (Pos3.x.z > 0) then
			return math.rad(90) - math.atan(Pos3.x.x / Pos3.x.z)
		elseif (Pos3.x.x < 0) and (Pos3.x.z == 0) then
			return math.rad(180)
		elseif (Pos3.x.x < 0) and (Pos3.x.z < 0) then
			return math.rad(180) + math.atan(Pos3.x.z / Pos3.x.x)
		elseif (Pos3.x.x == 0) and (Pos3.x.z < 0) then
			return math.rad(270)
		elseif (Pos3.x.x > 0) and (Pos3.x.z < 0) then
			return math.rad(270) - math.atan(Pos3.x.x / Pos3.x.z)
		end
	end
	
	
	--Repeating function to steer dismounted rifle squads
	local function SetRifleWaypoint(CarrierUnitName, DMGroupName)
		local function ScheduledFunction()
			local rifle = Group.getByName(DMGroupName)
			if rifle ~= nil then
				local rifle_leader = rifle:getUnit(1)
				if rifle_leader ~= nil then
					local rifle_leader_point = rifle_leader:getPoint()	--Get current position of the rifle leader for the first waypoint
					local rifle_controller = rifle:getController()	--Get controller of the rifle group for the waypoint task
					local carrier = Unit.getByName(CarrierUnitName)
					if carrier ~= nil then
						local carrier_pos = carrier:getPosition()	--Get current position of the carrier for the second waypoint (100m in front of carrier)
						GoToTask = { 
							id = 'Mission', 
							params = { 
								route = { 
									points = { 
										[1] = {
											action = "Custom",
											x = rifle_leader_point.x,	--Current position of rifle leader
											y = rifle_leader_point.z,	--Current position of rifle leader
											speed = 3.8888888888889,
											ETA = 0,
											ETA_locked = false,
											name = "", 
											task = {
												["id"] = "ComboTask",
												["params"] = 
												{
													["tasks"] = 
													{
													}, -- end of ["tasks"]
												}, -- end of ["params"]
											},
										},
										[2] = {
											action = "Custom",
											x = carrier_pos.p.x + carrier_pos.x.x * 100,	--100m in front of carrier
											y = carrier_pos.p.z + carrier_pos.x.z * 100,	--100m in front of carrier
											speed = 3.8888888888889,
											ETA = 0,
											ETA_locked = false,
											name = "", 
											task = {
												["id"] = "ComboTask",
												["params"] = 
												{
													["tasks"] = 
													{
													}, -- end of ["tasks"]
												}, -- end of ["params"]
											}
										}
									} 
								}
							} 
						}
						Controller.setTask(rifle_controller, GoToTask)
						return timer.getTime() + 15	--Repeat after 15 seconds, until rifle_leader is not existing anymore
					end
				end
			end
		end
		timer.scheduleFunction(ScheduledFunction, nil, timer.getTime() + 15)
	end
	
	
	--Function to return the composition of the spawned group
	local function GetDmGroup(countryID, carrierUnitID, carrierPos, dmType, CarrierUnitName)
		local dmVec2 = {									--Determine the x,y Vec2 position of the dismounts (10m behind of the carrier)
			x = carrierPos.p.x + carrierPos.x.x * -10,
			y = carrierPos.p.z + carrierPos.x.z * -10,
		}
		local heading = GetHeading(carrierPos)	--Get heading of the carrier when dismounting
		if countryID == 0 or countryID == 1 or countryID == 16 or countryID == 17 or countryID == 18 or countryID == 19 then	--If eastern country
			if dmType == "MANPADS" then 	--If MANPADS
				local group = {
					["visible"] = false,
					["route"] = 
					{
						["spans"] = 
						{
						}, -- end of ["spans"]
						["points"] = 
						{
							[1] = 
							{
								["alt"] = 0,
								["type"] = "Turning Point",
								["ETA"] = 0,
								["alt_type"] = "BARO",
								["formation_template"] = "",
								["y"] = dmVec2.y,
								["x"] = dmVec2.x,
								["ETA_locked"] = true,
								["speed"] = 5.5555555555556,
								["action"] = "Off Road",
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
										}, -- end of ["tasks"]
									}, -- end of ["params"]
								}, -- end of ["task"]
								["speed_locked"] = true,
							}, -- end of [1]
						}, -- end of ["points"]
					}, -- end of ["route"]
					["groupId"] = carrierUnitID + 10000,
					["tasks"] = 
					{
					}, -- end of ["tasks"]
					["hidden"] = false,
					["units"] = 
					{
						[1] = 
						{
							["y"] = dmVec2.y,
							["type"] = "SA-18 Igla-S manpad",
							["name"] = "Dismounts_" .. carrierUnitID .. "_01",
							["unitId"] = carrierUnitID + 10000,
							["heading"] = 0,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x,
						}, -- end of [1]
						[2] = 
						{
							["y"] = dmVec2.y,
							["type"] = "SA-18 Igla-S comm",
							["name"] = "Dismounts_" .. carrierUnitID .. "_02",
							["unitId"] = carrierUnitID + 11000,
							["heading"] = 0,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x + 3,
						}, -- end of [2]
					}, -- end of ["units"]
					["y"] = dmVec2.y,
					["x"] = dmVec2.x,
					["name"] = "Dismounts_" .. carrierUnitID,
					["start_time"] = 0,
					["task"] = "Ground Nothing",
				}
				return group
			elseif dmType == "Mortar" then 	--If Mortar
				local group = {
					["visible"] = false,
					["route"] = 
					{
						["spans"] = 
						{
						}, -- end of ["spans"]
						["points"] = 
						{
							[1] = 
							{
								["alt"] = 0,
								["type"] = "Turning Point",
								["ETA"] = 0,
								["alt_type"] = "BARO",
								["formation_template"] = "",
								["y"] = dmVec2.y,
								["x"] = dmVec2.x,
								["ETA_locked"] = true,
								["speed"] = 5.5555555555556,
								["action"] = "Off Road",
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
										}, -- end of ["tasks"]
									}, -- end of ["params"]
								}, -- end of ["task"]
								["speed_locked"] = true,
							}, -- end of [1]
						}, -- end of ["points"]
					}, -- end of ["route"]
					["groupId"] = carrierUnitID + 10000,
					["tasks"] = 
					{
					}, -- end of ["tasks"]
					["hidden"] = false,
					["units"] = 
					{
						[1] = 
						{
							["y"] = dmVec2.y,
							["type"] = "2B11 mortar",
							["name"] = "Dismounts_" .. carrierUnitID .. "_01",
							["unitId"] = carrierUnitID + 12000,
							["heading"] = heading + math.rad(180),
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x,
						}, -- end of [1]
						[2] = 
						{
							["y"] = dmVec2.y -2,
							["type"] = "Infantry AK",
							["name"] = "Dismounts_" .. carrierUnitID .. "_02",
							["unitId"] = carrierUnitID + 13000,
							["heading"] = heading + math.rad(180),
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x + 2,
						}, -- end of [2]
						[3] = 
						{
							["y"] = dmVec2.y -2,
							["type"] = "Infantry AK",
							["name"] = "Dismounts_" .. carrierUnitID .. "_03",
							["unitId"] = carrierUnitID + 14000,
							["heading"] = heading + math.rad(180),
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x - 2,
						}, -- end of [3]
					}, -- end of ["units"]
					["y"] = dmVec2.y,
					["x"] = dmVec2.x,
					["name"] = "Dismounts_" .. carrierUnitID,
					["start_time"] = 0,
					["task"] = "Ground Nothing",
				}
				return group
			elseif dmType == "Rifle" then 	--If rifle squad
				local group = {
					["visible"] = false,
					["route"] = 
					{
						["spans"] = 
						{
						}, -- end of ["spans"]
						["points"] = 
						{
							[1] = 
							{
								["alt"] = 0,
								["type"] = "Turning Point",
								["ETA"] = 0,
								["alt_type"] = "BARO",
								["formation_template"] = "",
								["y"] = dmVec2.y,
								["x"] = dmVec2.x,
								["ETA_locked"] = true,
								["speed"] = 3.8888888888889,
								["action"] = "Custom",
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
										}, -- end of ["tasks"]
									}, -- end of ["params"]
								}, -- end of ["task"]
								["speed_locked"] = true,
							}, -- end of [1]
							[2] = 
							{
								["alt"] = 0,
								["type"] = "Turning Point",
								["ETA"] = 0,
								["alt_type"] = "BARO",
								["formation_template"] = "",
								["y"] = carrierPos.p.z + carrierPos.x.z * 100,
								["x"] = carrierPos.p.x + carrierPos.x.x * 100,
								["ETA_locked"] = true,
								["speed"] = 3.8888888888889,
								["action"] = "Custom",
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
										}, -- end of ["tasks"]
									}, -- end of ["params"]
								}, -- end of ["task"]
								["speed_locked"] = true,
							}, -- end of [2]
						}, -- end of ["points"]
					}, -- end of ["route"]
					["groupId"] = carrierUnitID + 10000,
					["tasks"] = 
					{
					}, -- end of ["tasks"]
					["hidden"] = false,
					["units"] = 
					{
						[1] = 
						{
							["y"] = dmVec2.y,
							["type"] = "Infantry AK",
							["name"] = "Dismounts_" .. carrierUnitID .. "_01",
							["unitId"] = carrierUnitID + 15000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x,
						}, -- end of [1]
						[2] = 
						{
							["y"] = dmVec2.y - carrierPos.z.z * 5,
							["type"] = "Paratrooper RPG-16",
							["name"] = "Dismounts_" .. carrierUnitID .. "_02",
							["unitId"] = carrierUnitID + 16000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x - carrierPos.z.x * 5,
						}, -- end of [2]
						[3] = 
						{
							["y"] = dmVec2.y + carrierPos.z.z * 5,
							["type"] = "Infantry AK",
							["name"] = "Dismounts_" .. carrierUnitID .. "_03",
							["unitId"] = carrierUnitID + 17000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x + carrierPos.z.x * 5,
						}, -- end of [3]
						[4] = 
						{
							["y"] = dmVec2.y - carrierPos.z.z * 10,
							["type"] = "Infantry AK",
							["name"] = "Dismounts_" .. carrierUnitID .. "_04",
							["unitId"] = carrierUnitID + 18000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x - carrierPos.z.x * 10,
						}, -- end of [4]
						[5] = 
						{
							["y"] = dmVec2.y + carrierPos.z.z * 10,
							["type"] = "Infantry AK",
							["name"] = "Dismounts_" .. carrierUnitID .. "_05",
							["unitId"] = carrierUnitID + 19000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x + carrierPos.z.x * 10,
						}, -- end of [5]
						[6] = 
						{
							["y"] = dmVec2.y - carrierPos.z.z * 15,
							["type"] = "Infantry AK",
							["name"] = "Dismounts_" .. carrierUnitID .. "_06",
							["unitId"] = carrierUnitID + 20000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x - carrierPos.z.x * 15,
						}, -- end of [6]
						[7] = 
						{
							["y"] = dmVec2.y + carrierPos.z.z * 15,
							["type"] = "Infantry AK",
							["name"] = "Dismounts_" .. carrierUnitID .. "_07",
							["unitId"] = carrierUnitID + 21000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x + carrierPos.z.x * 15,
						}, -- end of [7]
					}, -- end of ["units"]
					["y"] = dmVec2.y,
					["x"] = dmVec2.x,
					["name"] = "Dismounts_" .. carrierUnitID,
					["start_time"] = 0,
					["task"] = "Ground Nothing",
				}
				SetRifleWaypoint(CarrierUnitName, "Dismounts_" .. carrierUnitID)	--Launch scheduled function to refresh the wayoint of the dismounted group
				return group
			elseif dmType == "ZU-23" then 	--If ZU-23 AAA
				local group = {
					["visible"] = false,
					["route"] = 
					{
						["spans"] = 
						{
						}, -- end of ["spans"]
						["points"] = 
						{
							[1] = 
							{
								["alt"] = 0,
								["type"] = "Turning Point",
								["ETA"] = 0,
								["alt_type"] = "BARO",
								["formation_template"] = "",
								["y"] = dmVec2.y,
								["x"] = dmVec2.x,
								["ETA_locked"] = true,
								["speed"] = 5.5555555555556,
								["action"] = "Off Road",
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
										}, -- end of ["tasks"]
									}, -- end of ["params"]
								}, -- end of ["task"]
								["speed_locked"] = true,
							}, -- end of [1]
						}, -- end of ["points"]
					}, -- end of ["route"]
					["groupId"] = carrierUnitID + 10000,
					["tasks"] = 
					{
					}, -- end of ["tasks"]
					["hidden"] = false,
					["units"] = 
					{
						[1] = 
						{
							["y"] = dmVec2.y,
							["type"] = "ZU-23 Emplacement",
							["name"] = "Dismounts_" .. carrierUnitID .. "_01",
							["unitId"] = carrierUnitID + 22000,
							["heading"] = heading + math.rad(180),
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x,
						}, -- end of [1]
					}, -- end of ["units"]
					["y"] = dmVec2.y,
					["x"] = dmVec2.x,
					["name"] = "Dismounts_" .. carrierUnitID,
					["start_time"] = 0,
					["task"] = "Ground Nothing",
				}
				return group
			end
		else	--if western country
			if dmType == "MANPADS" then	--If MANPADS
				local group = {
					["visible"] = false,
					["route"] = 
					{
						["spans"] = 
						{
						}, -- end of ["spans"]
						["points"] = 
						{
							[1] = 
							{
								["alt"] = 0,
								["type"] = "Turning Point",
								["ETA"] = 0,
								["alt_type"] = "BARO",
								["formation_template"] = "",
								["y"] = dmVec2.y,
								["x"] = dmVec2.x,
								["ETA_locked"] = true,
								["speed"] = 5.5555555555556,
								["action"] = "Off Road",
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
										}, -- end of ["tasks"]
									}, -- end of ["params"]
								}, -- end of ["task"]
								["speed_locked"] = true,
							}, -- end of [1]
						}, -- end of ["points"]
					}, -- end of ["route"]
					["groupId"] = carrierUnitID + 10000,
					["tasks"] = 
					{
					}, -- end of ["tasks"]
					["hidden"] = false,
					["units"] = 
					{
						[1] = 
						{
							["y"] = dmVec2.y,
							["type"] = "Stinger manpad",
							["name"] = "Dismounts_" .. carrierUnitID .. "_01",
							["unitId"] = carrierUnitID + 23000,
							["heading"] = 0,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x,
						}, -- end of [1]
						[2] = 
						{
							["y"] = dmVec2.y,
							["type"] = "Stinger comm",
							["name"] = "Dismounts_" .. carrierUnitID .. "_02",
							["unitId"] = carrierUnitID + 24000,
							["heading"] = 0,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x + 3,
						}, -- end of [2]
					}, -- end of ["units"]
					["y"] = dmVec2.y,
					["x"] = dmVec2.x,
					["name"] = "Dismounts_" .. carrierUnitID,
					["start_time"] = 0,
					["task"] = "Ground Nothing",
				}
				return group
			elseif dmType == "Mortar" then 	--If Mortar
				local group = {
					["visible"] = false,
					["route"] = 
					{
						["spans"] = 
						{
						}, -- end of ["spans"]
						["points"] = 
						{
							[1] = 
							{
								["alt"] = 0,
								["type"] = "Turning Point",
								["ETA"] = 0,
								["alt_type"] = "BARO",
								["formation_template"] = "",
								["y"] = dmVec2.y,
								["x"] = dmVec2.x,
								["ETA_locked"] = true,
								["speed"] = 5.5555555555556,
								["action"] = "Off Road",
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
										}, -- end of ["tasks"]
									}, -- end of ["params"]
								}, -- end of ["task"]
								["speed_locked"] = true,
							}, -- end of [1]
						}, -- end of ["points"]
					}, -- end of ["route"]
					["groupId"] = carrierUnitID + 10000,
					["tasks"] = 
					{
					}, -- end of ["tasks"]
					["hidden"] = false,
					["units"] = 
					{
						[1] = 
						{
							["y"] = dmVec2.y,
							["type"] = "2B11 mortar",
							["name"] = "Dismounts_" .. carrierUnitID .. "_01",
							["unitId"] = carrierUnitID + 25000,
							["heading"] = heading + math.rad(180),
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x,
						}, -- end of [1]
						[2] = 
						{
							["y"] = dmVec2.y -2,
							["type"] = "Soldier M4",
							["name"] = "Dismounts_" .. carrierUnitID .. "_02",
							["unitId"] = carrierUnitID + 26000,
							["heading"] = heading + math.rad(180),
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x + 2,
						}, -- end of [2]
						[3] = 
						{
							["y"] = dmVec2.y -2,
							["type"] = "Soldier M4",
							["name"] = "Dismounts_" .. carrierUnitID .. "_03",
							["unitId"] = carrierUnitID + 27000,
							["heading"] = heading + math.rad(180),
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x - 2,
						}, -- end of [3]
					}, -- end of ["units"]
					["y"] = dmVec2.y,
					["x"] = dmVec2.x,
					["name"] = "Dismounts_" .. carrierUnitID,
					["start_time"] = 0,
					["task"] = "Ground Nothing",
				}
				return group
			elseif dmType == "Rifle" then 	--If rifle squad
				local group = {
					["visible"] = false,
					["route"] = 
					{
						["spans"] = 
						{
						}, -- end of ["spans"]
						["points"] = 
						{
							[1] = 
							{
								["alt"] = 0,
								["type"] = "Turning Point",
								["ETA"] = 0,
								["alt_type"] = "BARO",
								["formation_template"] = "",
								["y"] = dmVec2.y,
								["x"] = dmVec2.x,
								["ETA_locked"] = true,
								["speed"] = 3.8888888888889,
								["action"] = "Custom",
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
										}, -- end of ["tasks"]
									}, -- end of ["params"]
								}, -- end of ["task"]
								["speed_locked"] = true,
							}, -- end of [1]
							[2] = 
							{
								["alt"] = 0,
								["type"] = "Turning Point",
								["ETA"] = 0,
								["alt_type"] = "BARO",
								["formation_template"] = "",
								["y"] = carrierPos.p.z + carrierPos.x.z * 100,
								["x"] = carrierPos.p.x + carrierPos.x.x * 100,
								["ETA_locked"] = true,
								["speed"] = 3.8888888888889,
								["action"] = "Custom",
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
										}, -- end of ["tasks"]
									}, -- end of ["params"]
								}, -- end of ["task"]
								["speed_locked"] = true,
							}, -- end of [2]
						}, -- end of ["points"]
					}, -- end of ["route"]
					["groupId"] = carrierUnitID + 10000,
					["tasks"] = 
					{
					}, -- end of ["tasks"]
					["hidden"] = false,
					["units"] = 
					{
						[1] = 
						{
							["y"] = dmVec2.y,
							["type"] = "Soldier M4",
							["name"] = "Dismounts_" .. carrierUnitID .. "_01",
							["unitId"] = carrierUnitID + 28000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x,
						}, -- end of [1]
						[2] = 
						{
							["y"] = dmVec2.y - 5,
							["type"] = "Soldier M4",
							["name"] = "Dismounts_" .. carrierUnitID .. "_02",
							["unitId"] = carrierUnitID + 29000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x - 5,
						}, -- end of [2]
						[3] = 
						{
							["y"] = dmVec2.y + 5,
							["type"] = "Soldier M4",
							["name"] = "Dismounts_" .. carrierUnitID .. "_03",
							["unitId"] = carrierUnitID + 30000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x + 5,
						}, -- end of [3]
						[4] = 
						{
							["y"] = dmVec2.y - 10,
							["type"] = "Soldier M249",
							["name"] = "Dismounts_" .. carrierUnitID .. "_04",
							["unitId"] = carrierUnitID + 31000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x - 10,
						}, -- end of [4]
						[5] = 
						{
							["y"] = dmVec2.y + 10,
							["type"] = "Soldier M249",
							["name"] = "Dismounts_" .. carrierUnitID .. "_05",
							["unitId"] = carrierUnitID + 32000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x + 10,
						}, -- end of [5]
						[6] = 
						{
							["y"] = dmVec2.y - 15,
							["type"] = "Soldier M4",
							["name"] = "Dismounts_" .. carrierUnitID .. "_06",
							["unitId"] = carrierUnitID + 33000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x - 15,
						}, -- end of [6]
						[7] = 
						{
							["y"] = dmVec2.y + 15,
							["type"] = "Soldier M4",
							["name"] = "Dismounts_" .. carrierUnitID .. "_07",
							["unitId"] = carrierUnitID + 34000,
							["heading"] = heading,
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x + 15,
						}, -- end of [7]
					}, -- end of ["units"]
					["y"] = dmVec2.y,
					["x"] = dmVec2.x,
					["name"] = "Dismounts_" .. carrierUnitID,
					["start_time"] = 0,
					["task"] = "Ground Nothing",
				}
				SetRifleWaypoint(CarrierUnitName, "Dismounts_" .. carrierUnitID)	--Launch scheduled function to refresh the wayoint of the dismounted group
				return group
			elseif dmType == "ZU-23" then 	--If ZU-23 AAA
				local group = {
					["visible"] = false,
					["route"] = 
					{
						["spans"] = 
						{
						}, -- end of ["spans"]
						["points"] = 
						{
							[1] = 
							{
								["alt"] = 0,
								["type"] = "Turning Point",
								["ETA"] = 0,
								["alt_type"] = "BARO",
								["formation_template"] = "",
								["y"] = dmVec2.y,
								["x"] = dmVec2.x,
								["ETA_locked"] = true,
								["speed"] = 5.5555555555556,
								["action"] = "Off Road",
								["task"] = 
								{
									["id"] = "ComboTask",
									["params"] = 
									{
										["tasks"] = 
										{
										}, -- end of ["tasks"]
									}, -- end of ["params"]
								}, -- end of ["task"]
								["speed_locked"] = true,
							}, -- end of [1]
						}, -- end of ["points"]
					}, -- end of ["route"]
					["groupId"] = carrierUnitID + 10000,
					["tasks"] = 
					{
					}, -- end of ["tasks"]
					["hidden"] = false,
					["units"] = 
					{
						[1] = 
						{
							["y"] = dmVec2.y,
							["type"] = "ZU-23 Emplacement",
							["name"] = "Dismounts_" .. carrierUnitID .. "_01",
							["unitId"] = carrierUnitID + 35000,
							["heading"] = heading + math.rad(180),
							["playerCanDrive"] = true,
							["skill"] = "Average",
							["x"] = dmVec2.x,
						}, -- end of [1]
					}, -- end of ["units"]
					["y"] = dmVec2.y,
					["x"] = dmVec2.x,
					["name"] = "Dismounts_" .. carrierUnitID,
					["start_time"] = 0,
					["task"] = "Ground Nothing",
				}
				return group
			end
		end
	end

		
	--function to check if the dismounts carriers are moving
	local function CheckMovement()
		for n = 1, #DismountsCarrier do
			local u = Unit.getByName(DismountsCarrier[n].name)
			if u ~= nil then
				local v = u:getVelocity()	--Velocity is a Vec3
				if v.x == 0 and v.y == 0 and v.z == 0 then	--Check if speed is zero
					if DismountsCarrier[n].cargo_status == "mounted" then
						local carrierPos = u:getPosition()
						local group = GetDmGroup(DismountsCarrier[n].countryID, DismountsCarrier[n].UnitID, carrierPos, DismountsCarrier[n].cargo, DismountsCarrier[n].name)
						coalition.addGroup(DismountsCarrier[n].countryID, Group.Category.GROUND, group)
						DismountsCarrier[n].cargo_status = "dismounted"
					end
				else	--Else carrier is moving
					if DismountsCarrier[n].cargo_status == "dismounted" then
						if DismountsCarrier[n].cargo ~= "Rifle" or math.sqrt(v.x * v.x + v.z * v.z) > 5.3 then	--Remount rifle squad only when speed bigger than 5.3 m/s (19 kph). Remount everyone else immediately when moving.
							local g = Group.getByName("Dismounts_" .. DismountsCarrier[n].UnitID)
							if g ~= nil then	--Check if the group is still alive
								DismountsCarrier[n].cargo_status = "mounted"
								g:destroy()
							else
								DismountsCarrier[n].cargo_status = "lost"	--If the dismounted group is destroyed, set status of the carrier to lost to prevent it from deploying a new group
							end
						end
					end
				end
			end
		end
		return timer.getTime() + 5
	end
	timer.scheduleFunction(CheckMovement, nil, timer.getTime() + 1)
end