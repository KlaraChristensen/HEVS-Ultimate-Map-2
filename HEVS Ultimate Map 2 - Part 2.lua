zoom = 2
pi = math.pi
touchedPrevious = false
movingWaypoint = false
mapCenteredX = 0
mapCenteredY = 0
mapCentered = false
waypointsExist = false
autoPilotEnable = false
autoHoverEnable = false
radarEnabled = false
waypoints = {}
waypointExist = false
navigationInfo = false
waypointToModify = 0
touchLength = 0
useButton = false
touchscreenXPrevious = 0
tocuhscreenYPrevious = 0
justMovedWaypoint = false

function onTick() 
   screenSizeX = input.getNumber(1)
   screenSizeY = input.getNumber(2)
   touchscreenX = input.getNumber(3)
   touchscreenY = input.getNumber(4)
   touchscreen = input.getBool(1)
   GPSX = input.getNumber(5)
   GPSY = input.getNumber(6)
   heading = -input.getNumber(7) * 2 * pi
   vehicleType = property.getNumber("Vehicle Type")
   arrivalRange = property.getNumber("AP End Range")
   rangeMidCourse = property.getNumber("AP Mid Course Range")
   colorScheme = property.getNumber("Color Scheme")
   useRadar = property.getBool("Use Radar")
   useAH = property.getBool("Use Altitude")
   useAP = property.getBool("Use Auto Pilot")
   velocity = input.getNumber(8)
   nightMode = input.getBool(2)
   keypadWaypointPulse = input.getBool(3)
   keypadAltitudePulse = input.getBool(4)
   keypadWaypointX = input.getNumber(8)
   keypadWaypointY = input.getNumber(9)
   keypadAltitude = input.getNumber(10)
   emergencyLocator = input.getBool(5)

    -- If the map is set to be centered, center it on current GPS
    if mapCentered then
        mapCenteredX = GPSX
        mapCenteredY = GPSY
    end

    -- Touchscreen controls activated if clicking is within appropraite area.
	if touchscreen then onClick() end
	if (touchscreen == false and touchedPrevious == true) then offClick() end
    touchedPrevious = touchscreen

    if #waypoints > 0 then
        waypointExist = true
    else
        waypointExist = false
        autoPilotEnable = false
        autoHoverEnable = false
    end

    --Determines the total distance of all the waypoints in the system.
    totalDistance = 0
    -- PH means Place Holder
    aPH = 0
    for bPH,cPH in pairs(waypoints) do
    	if aPH == nil then
    		aPH = cPH
    		PHx = math.abs(cPH.x-GPSX)
    		PHy = math.abs(cPH.y-GPSY)
    	else
	    	PHx = math.abs(cPH.x-aPH.x)
	    	PHy = math.abs(cPH.y-aPH.y)
	    end
	    totaldistance = totaldistance + math.sqrt(PHx^2 + PHy^2)
	    aPH = cPH
    end

    --Removes waypoints when arrived
    if waypointExist and autoPilotEnable then
    	distanceToWaypoint = math.sqrt(math.abs(waypoints[1].x-GPSX)^2 + math.abs(waypoints[1].y-GPSY)^2)
    	if distanceToWaypoint <= arrivalRange then
    		if vehicleType == 3 and #waypoints == 1 then
    			table.remove(waypoints,1)
    		end
    		if vehicleType ~= 3 or #waypoints > 1 and rangeMidCourse >= distanceToWaypoint then
    			table.remove(waypoints, 1)
    		end
    	end
    end

	--keypad Waypoint addition
	if keypadWaypointPulse then
		if movingWaypoint then
			waypoints[waypointToModify] = {x = keypadWaypointX, y = keypadWaypointY, alt = waypoints[waypointToModify].alt}
			movingWaypoint = false
			return
		end
		waypoints[#waypoints+1] = {x = keypadWaypointX, y = keypadWaypointY, alt = nil}
	end

	--keypad Altitude addition
	if keypadAltitudePulse and movingWaypoint then
		waypoints[waypointToModify].alt = keypadAltitude
		movingWaypoint = false
	end
    --TODO export data

	output.setNumber(1,mapCenteredX)
	output.setNumber(2,mapCenteredY)
	output.setNumber(3,zoom)
	output.setBool(1,false)
		output.setBool(2,false)
	if autoPilotEnable then
		output.setNumber(4,waypoints[1].x)
		output.setNumber(5,waypoints[1].y)
		if waypoints[1].alt ~= nil then
			output.setNumber(6,waypoints[1].alt)
			output.setBool(2, true)
		end
		output.setBool(1,true)
	end
	output.setBool(3,#waypoints>0)
	output.setBool(4,nightMode)
	output.setBool(5,radarEnabled)
	output.setBool(6,navigationInfo)
	output.setNumber(7,totaldistance)

end

--Happens when touched is released
function offClick()
	touchLength = 0
    -- If were using a button, set to false and don't continue
	if useButton then
		useButton = false
		return
	end
	if useAP then
		-- Loop to determine waypoints to remove/modify
		pastFirst = false
		prvWaypoint = nil
		for index,retrievedWaypoint in pairs(waypoints) do
			if waypointToModify == index then 
				-- If a waypoint was just moved, set all these to false.
				if justMovedWaypoint then
					movingWaypoint = false
					waypointToModify = 0
					justMovedWaypoint = false
				end
				-- end here if there is still a waypoint to modify as to not add an extra waypoint on off click.
				return 
			end
			PHx, PHy = map.mapToScreen(mapCenteredX,mapCenteredY,zoom,screenSizeX,screenSizeY,retrievedWaypoint.x,retrievedWaypoint.y)
			if (touchscreenXPrevious >= PHx-3 and touchscreenXPrevious <= PHx+3 and tocuhscreenYPrevious >= PHy-3 and tocuhscreenYPrevious <= PHy + 3) then
				table.remove(waypoints, index)
				return
			end

			touchLocationX, touchLocationY = map.screenToMap(mapCenteredX,mapCenteredY,zoom,screenSizeX,screenSizeY,touchscreenXPrevious,tocuhscreenYPrevious)
			if pastFirst then
				dist1X = retrievedWaypoint.x - touchLocationX
				dist1Y = retrievedWaypoint.y - touchLocationY
				dist2X = prvWaypoint.x - touchLocationX
				dist2Y = prvWaypoint.y - touchLocationY
				angle1 = math.atan(dist1X/dist2Y)
				angle2 = math.atan(dist2X/dist2Y)
				if angle1 > angle2+178%360 and angle1 < angle2+182%360 then
					newIndex = index
					for i = #waypoints, -1, index do
						waypoints[i+1] = waypoints[i] 
					end
					waypoints[index] = {x = touchLocationX, y = touchLocationY, alt = nil}
				end
			end
			pastFirst = true
			prvWaypoint = retrievedWaypoint
		end
		
		PHx,PHy = map.screenToMap(mapCenteredX,mapCenteredY, zoom, screenSizeX, screenSizeY, touchscreenXPrevious, tocuhscreenYPrevious)
		waypoints[#waypoints+1] = {x=PHx, y=PHy, alt = nil}
		drag = false
		waypointToModify = 0
	end
end	


--whenever screen is being touched
function onClick()
	touchLength = touchLength + 1
	touchscreenXPrevious = touchscreenX
	tocuhscreenYPrevious = touchscreenY
	
	if (touchscreenY >= 9 and touchscreenY <= 13 and touchscreenX >= 9 and touchscreenX <=13) and not touchedPrevious and useAP then
		navigationInfo = not navigationInfo
		useButton = true
		return
	end
	
    if (touchscreenY >= screenSizeY-9 and touchscreenY <= screenSizeY-2 and touchscreenX >=2 and touchscreenX <= 9) then
    	zoom = zoom + 0.04
    	if (zoom > 20) then
    		zoom = 20
    	end
    	useButton = true
    	return
    end
    
    if (touchscreenY >= screenSizeY-9 and touchscreenY <= screenSizeY-2 and touchscreenX >=12 and touchscreenX <= 19) then
    	zoom = zoom - 0.04
    	if (zoom < 1) then
    		zoom = 1
    	end
    	useButton = true
    	return
    end
    
    if (touchscreenY >= screenSizeY-9 and touchscreenY <= screenSizeY-2 and touchscreenX >=screenSizeX-19 and touchscreenX <= screenSizeX-12) and useAP then
    	waypoints = {}
    	useButton = true
    	return
    end
    
    if (touchscreenY >= screenSizeY-9 and touchscreenY <= screenSizeY-2 and touchscreenX >=screenSizeX-9 and touchscreenX <= screenSizeX-2) then
    	mapCentered = true
    	useButton = true
    	return
    end
    
    if (touchscreenY >= screenSizeY-9 and touchscreenY <= screenSizeY-2 and touchscreenX >=22 and touchscreenX <= 29) and useRadar then
    	if not touchedPrevious then
    		radarEnabled = not radarEnabled
    	end
    	useButton = true
    	return
    end
    
    if (touchscreenY >= screenSizeY-9 and touchscreenY <= screenSizeY-2 and touchscreenX >=screenSizeX-29 and touchscreenX <= screenSizeX-22) and useAP then
    	if not touchedPrevious then
    		autoPilotEnable = not autoPilotEnable
    	end
    	useButton = true
    	return
    end
    if (touchscreenX>=0 and touchscreenX <=5 and touchscreenY>=0 and touchscreenY<=screenSizeY) then
    	mapCenteredX = mapCenteredX - 8*zoom
        moveMap()
    end
    if (touchscreenX>=screenSizeX-5 and touchscreenX <=screenSizeX and touchscreenY>=0 and touchscreenY<=screenSizeY) then
    	mapCenteredX = mapCenteredX + 8*zoom
        moveMap()
    end
    if (touchscreenX>=0 and touchscreenX <=screenSizeX and touchscreenY>=0 and touchscreenY<=4) then
    	mapCenteredY = mapCenteredY + 8*zoom
        moveMap()
    end
    if (touchscreenX>=0 and touchscreenX <=screenSizeX and touchscreenY>=screenSizeY-5 and touchscreenY<=screenSizeY) then
    	mapCenteredX = mapCenteredY - 8*zoom
        moveMap()
    end

	if useAP then
		for index,retrievedWaypoint in pairs(waypoints) do
			PHx, PHy = map.mapToScreen(mapCenteredX,mapCenteredY,zoom,screenSizeX,screenSizeY,retrievedWaypoint.x,retrievedWaypoint.y)
			if (touchscreenXPrevious >= PHx-3 and touchscreenXPrevious <= PHx+3 and tocuhscreenYPrevious >= PHy-3 and tocuhscreenYPrevious <= PHy + 3) then
				if (touchLength >= 15) then
					movingWaypoint = true
					waypointToModify = index
				return
				end
			end
		end
		
		if (movingWaypoint) then
			PHx, PHy = map.screenToMap(mapCenteredX,mapCenteredY, zoom, screenSizeX, screenSizeY, touchscreenX, touchscreenY)
			waypoints[waypointToModify] = {x=PHx, y=PHx, alt = nil}
			justMovedWaypoint = true
			return
		end
	end
end

function moveMap()
    mapCentered = false
    useButton = true
end
--Function that draws the waypoints
function drawWaypoint()
	PH1x, PH1y = map.mapToScreen(mapCenteredX,mapCenteredY,zoom,screenSizeX,screenSizeY,GPSX,GPSY)
	for index,retrievedWaypoint in pairs(waypoints) do
		PH2x, PH2y = map.mapToScreen(mapCenteredX,mapCenteredY,zoom,screenSizeX,screenSizeY,retrievedWaypoint.x,retrievedWaypoint.y)
		screen.setColor(150,150,150)
		if colorScheme == 1 or colorScheme == 3  or colorScheme == 4 then screen.setColor(20,20,20) end
		if nightMode then screen.setColor(0,60,0) end
		screen.drawLine(PH2x,PH2y,PH1x,PH1y)
		PH1x = PH2x
		PH1y = PH2y
	end
	PH1x, PH1y = map.mapToScreen(mapCenteredX,mapCenteredY,zoom,screenSizeX,screenSizeY,GPSX,GPSY)
	for index,retrievedWaypoint in pairs(waypoints) do
		PH2x, PH2y = map.mapToScreen(mapCenteredX,mapCenteredY,zoom,screenSizeX,screenSizeY,retrievedWaypoint.x,retrievedWaypoint.y)
		screen.setColor(255,0,0)
		if nightMode then screen.setColor(0,120,0) end
		if waypointToModify == index then
			screen.setColor(0,255,0)
			if nightMode then screen.setColor(120,0,0) end
		end
		screen.drawCircle(PH2x,PH2y,2)
        if retrievedWaypoint.alt ~= nil and useAH then
            screen.setColor(255,255,255,50)
            if nightMode then screen.setColor(0,255,0,50) end
            screen.drawText(PH2x+3,PH2y+2,"A")
        end
		PH1x = PH2x
		PH1y = PH2y
	end
end

function onDraw()
    -- JUST DO IT
	if useAP then
    	drawWaypoint()
	end
end
