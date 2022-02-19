AMCTickControl = {}

function AMCTickControl.setLocalVariables(playerObj, moto, motoInfo)
    local seatId = moto:getSeat(playerObj)
    if playerObj:getVariableString("ATVehicleType") ~= motoInfo.type .. seatId then
        playerObj:setVariable("ATVehicleType", motoInfo.type .. seatId);
        if isClient() and playerObj:isLocalPlayer() then
            ModData.getOrCreate("tsaranimations")[playerObj:getOnlineID()] = true
            ModData.transmit("tsaranimations")
        end
    end
    if moto:isDriver(playerObj) then
        local playerStatus = moto:getPartForSeatContainer(0):getModData()["tsaranimation"]
        local passengerStatus = moto:getPartForSeatContainer(1):getModData()["tsaranimation"]
        playerObj:setVariable("ATPassengerStatus", passengerStatus);
        if playerStatus ~= "enter" and playerStatus ~= "exit" then
            local motoSpeedKPH = moto:getCurrentSpeedKmHour()
            if motoSpeedKPH > tonumber(motoInfo.speedDelta) then 
                if playerObj:getVariableString("ATVehicleStatus") ~= "forward" then
                    playerObj:setVariable("ATVehicleStatus", "forward");
                    sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = moto:getId(), seatId = seatId, status = "forward",})
                end
            elseif motoSpeedKPH < (0 - tonumber(motoInfo.speedDelta)) then
                if playerObj:getVariableString("ATVehicleStatus") ~= "backward" then
                    playerObj:setVariable("ATVehicleStatus", "backward");
                    sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = moto:getId(), seatId = seatId, status = "backward",})
                end
            else
                if playerObj:getVariableString("ATVehicleStatus") ~= "stop" then
                    playerObj:setVariable("ATVehicleStatus", "stop");
                    sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = moto:getId(), seatId = seatId, status = "stop",})
                end
            end
        end
    else
        local passengerStatus = moto:getPartForSeatContainer(0):getModData()["tsaranimation"]
        playerObj:setVariable("ATPassengerStatus", passengerStatus);
        
        if isClient() and passengerStatus == "crash" then
            sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = moto:getId(), seatId = 0, status = "none",})
            sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = moto:getId(), seatId = seatId, status = "none",})
            moto:exit(playerObj)
            triggerEvent("OnExitVehicle", playerObj)
            playerObj:setKnockedDown(true)
            return
        end
        if moto:getDriver() then
            if passengerStatus and passengerStatus ~= "exit" and passengerStatus ~= "enter" then
                playerObj:setVariable("ATVehicleStatus", passengerStatus);
            else
                playerObj:setVariable("ATVehicleStatus", "stop");
            end
        else
            if passengerStatus == "none" then
                if playerObj:getVariableString("ATVehicleStatus") ~= "stop" then
                    playerObj:setVariable("ATVehicleStatus", "stop");
                    sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = moto:getId(), seatId = seatId, status = "stop",})
                end
            end
        end
    end
end


function AMCTickControl.setAvatarVariables(playerObj, moto, motoInfo)
print("setAvatarVariables")
    local seatId = moto:getSeat(playerObj)
    if playerObj:getVariableString("ATVehicleType") ~= motoInfo.type .. seatId then
        playerObj:setVariable("ATVehicleType", motoInfo.type .. seatId);
    end
    
    local motoSpeedKPH = moto:getCurrentSpeedKmHour()
    if moto:isDriver(playerObj) then
        local passengerStatus = moto:getPartForSeatContainer(1):getModData()["tsaranimation"]
        playerObj:setVariable("ATPassengerStatus", passengerStatus);
        
        local driverStatus = moto:getPartForSeatContainer(moto:getSeat(playerObj)):getModData()["tsaranimation"]
        if driverStatus == "exit" then
            playerObj:SetVariable("bExitingVehicle", "true")
        elseif driverStatus == "enter" then
            playerObj:SetVariable("bEnteringVehicle", "true")
        else
            if playerObj:GetVariable("ExitAnimationFinished") == "true" or 
                    playerObj:GetVariable("EnterAnimationFinished") == "true" then 
                playerObj:ClearVariable("ExitAnimationFinished")
                playerObj:ClearVariable("bExitingVehicle")
                playerObj:ClearVariable("EnterAnimationFinished")
                playerObj:ClearVariable("bEnteringVehicle")
            end
            playerObj:setVariable("ATVehicleStatus", driverStatus);
        end
    else
        local passengerStatus = moto:getPartForSeatContainer(0):getModData()["tsaranimation"]
        playerObj:setVariable("ATPassengerStatus", passengerStatus);
        
        if moto:getDriver() then
            if motoSpeedKPH < (0 - tonumber(motoInfo.speedDelta)) then
                playerObj:setVariable("ATVehicleStatus", "backward");
            else
                playerObj:setVariable("ATVehicleStatus", "forward");
            end
        else
            -- playerObj:setVariable("ATPassengerStatus", "none");
            playerObj:setVariable("ATVehicleStatus", "stop");
        end
    end
end

function AMCTickControl.fallControl(playerObj, moto)
    if not playerObj:getModData()["mototsar"] then
        playerObj:getModData()["mototsar"] = {}
    end
    local generalCondition = getClassFieldVal(moto, getClassField(moto, 62)) + getClassFieldVal(moto, getClassField(moto, 63))
    -- print(generalCondition)
    if not playerObj:getModData()["mototsar"].health then
        -- print("health none")
        playerObj:getModData()["mototsar"].health = generalCondition
    end
    if (playerObj:getModData()["mototsar"].health - generalCondition) >= 3 then
        -- playerObj:setVariable("isMotoCrash", true);
        sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = moto:getId(), seatId = moto:getSeat(playerObj), status = "crash",})
        playerObj:getModData()["mototsar"].health = nil
        moto:exit(playerObj)
        triggerEvent("OnExitVehicle", playerObj)
        playerObj:setKnockedDown(true)
        return
    end
    playerObj:getModData()["mototsar"].health = generalCondition
end

local tickControl = 10 -- Сокращает количество срабатываний скрипта. Больше число - меньше срабатываний
local tickStart = 0

function AMCTickControl.main()
    tickStart = tickStart + 1
    if tickStart % tickControl == 0 then
        tickStart = 0
        if isClient() then
            local playerLocal = getPlayer()
            local plLocX = playerLocal:getX()
            local plLocY = playerLocal:getY()
            local playersWithAnim = ModData.getOrCreate("tsaranimations")
            local moto = playerLocal:getVehicle()
            local motoInfo = nil
            if moto and moto:getPartById("AMCConfig") then
                motoInfo = moto:getPartById("AMCConfig"):getTable("AMCConfig")
            end
            if motoInfo then
                if moto:isDriver(playerLocal) and motoInfo.fall then
                    AMCTickControl.fallControl(playerLocal, moto)
                end
                AMCTickControl.setLocalVariables(playerLocal, moto, motoInfo)
            end
            -- print(playersWithAnim)
            for playerId, _ in pairs(playersWithAnim) do
                player = getPlayerByOnlineID(playerId)
                if player and not player:isLocalPlayer() and not player:isDead() then
                    local moto = player:getVehicle()
                    local motoInfo = nil
                    if moto and moto:getPartById("AMCConfig") then
                        motoInfo = moto:getPartById("AMCConfig"):getTable("AMCConfig")
                    end
                    if motoInfo then
                        local x = player:getX()
                        local y = player:getY()
                        if ((plLocX >= x - 60 and plLocX <= x + 60 and
                                plLocY >= y - 60 and plLocY <= y + 60)) then
                            AMCTickControl.setAvatarVariables(player, moto, motoInfo)
                        end
                    end
                end
            end
        else
            local playersSum = getNumActivePlayers()
            for playerNum = 0, playersSum - 1 do
                -- print(playerNum)
                local playerObj = getSpecificPlayer(playerNum)
                if playerObj then
                    local moto = playerObj:getVehicle()
                    local motoInfo = nil
                    if moto and moto:getPartById("AMCConfig") then
                        motoInfo = moto:getPartById("AMCConfig"):getTable("AMCConfig")
                    end
                    if motoInfo then
                        if motoInfo.fall then
                            AMCTickControl.fallControl(playerObj, moto)
                        end
                        AMCTickControl.setLocalVariables(playerObj, moto, motoInfo)
                    elseif playerObj:getModData()["mototsar"] and playerObj:getModData()["mototsar"].health then
                        playerObj:getModData()["mototsar"].health = nil
                    end
                end
            end
        end
    end
end

-- Events.OnTileRemoved.Add(AMCTickControl.checkWaterBuild)
Events.OnTick.Add(AMCTickControl.main)
-- Events.OnPlayerDeath.Add(onPlayerDeathStopSwimSound)