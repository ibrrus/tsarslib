local old_ISVehicleMenu_onConfirmSleep = ISVehicleMenu.onConfirmSleep

function ISVehicleMenu.onConfirmSleep(this, button, player, bed)
	local chr = getPlayer()
	local vehicle = chr:getVehicle()
	if button.internal == "YES" and vehicle:getPartById("Mattress") then
		-- print("Mattress!!!")
		ISWorldObjectContextMenu.onSleepWalkToComplete(player, "RV")
	end
	-- print("No Mattress!")
	old_ISVehicleMenu_onConfirmSleep(this, button, player, bed)
end

function ISWorldObjectContextMenu.onConfirmSleep(this, button, player, bed)
	if button.internal == "YES" then
		local playerObj = getSpecificPlayer(player)
		ISTimedActionQueue.clear(playerObj)
		if bed then
			if AdjacentFreeTileFinder.isTileOrAdjacent(playerObj:getCurrentSquare(), bed:getSquare()) then
				ISWorldObjectContextMenu.onSleepWalkToComplete(player, bed)
			else
				local adjacent = AdjacentFreeTileFinder.Find(bed:getSquare(), playerObj)
				if adjacent ~= nil then
					local action = ISWalkToTimedAction:new(playerObj, adjacent)
					action:setOnComplete(ISWorldObjectContextMenu.onSleepWalkToComplete, player, bed)
					ISTimedActionQueue.add(action)
				end
			end
		else
			ISWorldObjectContextMenu.onSleepWalkToComplete(player, bed)
		end
    end
end

function ISWorldObjectContextMenu.onSleepWalkToComplete(player, bed)
	local playerObj = getSpecificPlayer(player)
	ISTimedActionQueue.clear(playerObj)
	local bedType = "badBed";
	if bed == "RV" then
		bedType =  "averageBed";
	elseif bed then
		bedType = bed:getProperties():Val("BedType") or "averageBed";
	else
		bedType = "floor";
	end
	if isClient() and getServerOptions():getBoolean("SleepAllowed") then
		playerObj:setAsleepTime(0.0)
		playerObj:setAsleep(true)
		UIManager.setFadeBeforeUI(player, true)
		UIManager.FadeOut(player, 1)
		return
    end

    --playerObj:setBed(bed);
    --playerObj:setBedType(bedType);
	local modal = nil;
    local sleepFor = ZombRand(playerObj:getStats():getFatigue() * 10, playerObj:getStats():getFatigue() * 13) + 1;
    if bedType == "goodBed" then
        sleepFor = sleepFor -1;
    end
    if bedType == "badBed" then
        sleepFor = sleepFor +1;
    end
	if bedType == "floor" then
		sleepFor = sleepFor * 0.7;
	end
    if playerObj:HasTrait("Insomniac") then
        sleepFor = sleepFor * 0.5;
    end
    if sleepFor > 16 then sleepFor = 16; end
    if sleepFor < 3 then sleepFor = 3; end
    --    print("GONNA SLEEP " .. sleepHours .. " HOURS" .. " AND ITS " .. GameTime.getInstance():getTimeOfDay())
    local sleepHours = sleepFor + GameTime.getInstance():getTimeOfDay()
    if sleepHours >= 24 then
        sleepHours = sleepHours - 24
    end
    playerObj:setForceWakeUpTime(tonumber(sleepHours))
    playerObj:setAsleepTime(0.0)
    playerObj:setAsleep(true)
    getSleepingEvent():setPlayerFallAsleep(playerObj, sleepFor);

    UIManager.setFadeBeforeUI(playerObj:getPlayerNum(), true)
    UIManager.FadeOut(playerObj:getPlayerNum(), 1)

    if IsoPlayer.allPlayersAsleep() then
        UIManager.getSpeedControls():SetCurrentGameSpeed(3)
        save(true)
    end
end
