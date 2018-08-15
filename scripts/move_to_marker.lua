------------------------------------------------------------------------------
-- moveCommandEventHandler
-- ingame marker command: MOVE(groupName,speed)
-- ex ingame: MOVE(CVN,10)
------------------------------------------------------------------------------
function moveCommandEventHandler(event)
	params = {}
	for v in string.gmatch(event.text, '([^,\(\)]+)') do
		params[#params+1] = v
    end
	
	local groupName=params[2]
	local speed=params[3]

	local newWaypoint = {
		action = "Turning Point",
		alt = 0,
		alt_type = "BARO",
		form = "Turning Point",
		speed = speed,
		type = "Turning Point",
		x = event.pos.z,
		y = event.pos.x
	}

	local vec3={x=event.pos.z, y=event.pos.y, z=event.pos.x}
	lat, lon = coord.LOtoLL(vec3)
	llString = mist.tostringLL(lat, lon, 2)
	
	mist.goRoute(groupName, {newWaypoint})
	trigger.action.outText(groupName .. ' moving to ' .. llString .. ' at speed ' .. speed .. ' m/s' , 10)
end


------------------------------------------------------------------------------
-- detectMarkers
------------------------------------------------------------------------------
function detectMarkers(event)
   if event.id == world.event.S_EVENT_MARK_CHANGE then 
   
        vec3={x=event.pos.z, y=event.pos.y, z=event.pos.x}

		mgrs = coord.LLtoMGRS(coord.LOtoLL(vec3))
		mgrsString = mist.tostringMGRS(mgrs, 3)   
		
		lat, lon = coord.LOtoLL(vec3)
		llString = mist.tostringLL(lat, lon, 2)
	
		-- debug information
		-- msg='Marker changed: \'' .. event.text ..'\' on this position \n' 
	    -- .. 'LL: '.. llString .. '\n'
	    -- .. 'UTM: '.. mgrsString
	    -- trigger.action.outText(msg, 10)

		-- handle MOVE command
        if event.text~=nil and event.text:find('MOVE') then
			moveCommandEventHandler(event)			
		end 
   end 
end 


-- init markers event handlers
detectMarkersEventHandler=mist.addEventHandler(detectMarkers) 

-- in case of testing, remove previous handlers
-- mist.removeEventHandler(detectMarkersEventHandler)
