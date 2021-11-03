local old_ISVehicleMenu_onConfirmSleep = ISVehicleMenu.onConfirmSleep

if ISCommonMenu == nil then ISCommonMenu = {} end

function ISVehicleMenu.onConfirmSleep(this, button, player, bed)
	local playerObj = getSpecificPlayer(player)
	local vehicle = playerObj:getVehicle()
	if button.internal == "YES" and vehicle:getPartById("Mattress") then
		-- print("Mattress!!!")
		ISCommonMenu.onSleepWalkToComplete(player, "RV")
	end
	-- print("No Mattress!")
	old_ISVehicleMenu_onConfirmSleep(this, button, player, bed)
end

function ISCommonMenu.onSleepWalkToComplete(player, bed)
	local playerObj = getSpecificPlayer(player)
	ISTimedActionQueue.clear(playerObj)
	bedType =  "averageBed";
	
	if isClient() and getServerOptions():getBoolean("SleepAllowed") then
		playerObj:setAsleepTime(0.0)
		playerObj:setAsleep(true)
		UIManager.setFadeBeforeUI(player, true)
		UIManager.FadeOut(player, 1)
		return
    end

    --playerObj:setBed(bed);
    playerObj:setBedType(bedType);
	local modal = nil;
    local sleepFor = ZombRand(playerObj:getStats():getFatigue() * 10, playerObj:getStats():getFatigue() * 13) + 1;
    if playerObj:HasTrait("Insomniac") then
        sleepFor = sleepFor * 0.5;
    end
    if playerObj:HasTrait("NeedsLessSleep") then
        sleepFor = sleepFor * 0.75;
    end
    if playerObj:HasTrait("NeedsMoreSleep") then
        sleepFor = sleepFor * 1.18;
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
