AMCTickControl = {}

function AMCTickControl.setLocalVariables(playerObj, vehicle, vehicleInfo)
    playerObj:setHideWeaponModel(true)
    local seatId = vehicle:getSeat(playerObj)
    if playerObj:getVariableString("ATVehicleType") ~= vehicleInfo.type .. seatId then
        playerObj:setVariable("ATVehicleType", vehicleInfo.type .. seatId);
        if isClient() and playerObj:isLocalPlayer() then
            ModData.getOrCreate("tsaranimations")[playerObj:getOnlineID()] = true
            ModData.transmit("tsaranimations")
        end
    end
    if vehicle:isDriver(playerObj) then
        local playerStatus = nil
        if vehicle:getPartForSeatContainer(0) then
            playerStatus = vehicle:getPartForSeatContainer(0):getModData()["tsaranimation"]
        end
        local passengerStatus = nil
        if vehicle:getPartForSeatContainer(1) then
            passengerStatus = vehicle:getPartForSeatContainer(1):getModData()["tsaranimation"]
        end
        if not passengerStatus then
            passengerStatus = "none"
        end
        playerObj:setVariable("ATPassengerStatus", passengerStatus)
        if playerStatus and playerStatus ~= "enter" and playerStatus ~= "exit" then
            local vehicleSpeedKPH = vehicle:getCurrentSpeedKmHour()
            if vehicleSpeedKPH > tonumber(vehicleInfo.speedDelta) then 
                if playerObj:getVariableString("ATVehicleStatus") ~= "forward" then
                    playerObj:setVariable("ATVehicleStatus", "forward");
                    sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = vehicle:getId(), seatId = seatId, status = "forward",})
                end
            elseif vehicleSpeedKPH < (0 - tonumber(vehicleInfo.speedDelta)) then
                if playerObj:getVariableString("ATVehicleStatus") ~= "backward" then
                    playerObj:setVariable("ATVehicleStatus", "backward");
                    sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = vehicle:getId(), seatId = seatId, status = "backward",})
                end
            else
                if playerObj:getVariableString("ATVehicleStatus") ~= "stop" then
                    playerObj:setVariable("ATVehicleStatus", "stop");
                    sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = vehicle:getId(), seatId = seatId, status = "stop",})
                end
            end
        end
    else
        local passengerStatus = nil
        if vehicle:getPartForSeatContainer(0) then
            passengerStatus = vehicle:getPartForSeatContainer(0):getModData()["tsaranimation"]
        end
        if not passengerStatus then
            passengerStatus = "none"
        end
        playerObj:setVariable("ATPassengerStatus", passengerStatus);
        
        if isClient() and passengerStatus == "crash" then
            sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = vehicle:getId(), seatId = 0, status = "none",})
            sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = vehicle:getId(), seatId = seatId, status = "none",})
            vehicle:exit(playerObj)
            triggerEvent("OnExitVehicle", playerObj)
            playerObj:setKnockedDown(true)
            return
        end
        if vehicle:getDriver() then
            if passengerStatus and passengerStatus ~= "exit" and passengerStatus ~= "enter" then
                playerObj:setVariable("ATVehicleStatus", passengerStatus);
            else
                playerObj:setVariable("ATVehicleStatus", "stop");
            end
        else
            if passengerStatus == "none" then
                if playerObj:getVariableString("ATVehicleStatus") ~= "stop" then
                    playerObj:setVariable("ATVehicleStatus", "stop");
                    sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = vehicle:getId(), seatId = seatId, status = "stop",})
                end
            end
        end
    end
end


function AMCTickControl.setAvatarVariables(playerObj, vehicle, vehicleInfo)
-- print("setAvatarVariables")
    local seatId = vehicle:getSeat(playerObj)
    if playerObj:getVariableString("ATVehicleType") ~= vehicleInfo.type .. seatId then
        playerObj:setVariable("ATVehicleType", vehicleInfo.type .. seatId);
    end
    
    local vehicleSpeedKPH = vehicle:getCurrentSpeedKmHour()
    if vehicle:isDriver(playerObj) then
        if vehicle:getPartForSeatContainer(1) then
            playerObj:setVariable("ATPassengerStatus", vehicle:getPartForSeatContainer(1):getModData()["tsaranimation"]); -- passengerStatus
        else
            playerObj:setVariable("ATPassengerStatus", "none")
        end
        local driverStatus = nil
        if vehicle:getPartForSeatContainer(vehicle:getSeat(playerObj)) then
            driverStatus = vehicle:getPartForSeatContainer(vehicle:getSeat(playerObj)):getModData()["tsaranimation"]
        end
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
        if vehicle:getPartForSeatContainer(0) then
            playerObj:setVariable("ATPassengerStatus", vehicle:getPartForSeatContainer(0):getModData()["tsaranimation"]); -- passengerStatus
        else
            playerObj:setVariable("ATPassengerStatus", "none")
        end
        if vehicle:getDriver() then
            if vehicleSpeedKPH < (0 - tonumber(vehicleInfo.speedDelta)) then
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

function AMCTickControl.fallControl(playerObj, vehicle, fallDelta)
    if not playerObj:getModData()["mototsar"] then
        playerObj:getModData()["mototsar"] = {}
    end
    local generalCondition = getClassFieldVal(vehicle, getClassField(vehicle, 61)) + getClassFieldVal(vehicle, getClassField(vehicle, 62))
    -- currentFrontEndDurability
    -- currentRearEndDurability
    
    
    if not playerObj:getModData()["mototsar"].health then
        -- print("health none")
        playerObj:getModData()["mototsar"].health = generalCondition
    end
    
    if (playerObj:getModData()["mototsar"].health - generalCondition) >= fallDelta then
        -- playerObj:setVariable("isMotoCrash", true);
        sendClientCommand(playerObj, 'autotsaranim', 'updateVariables', {vehicle = vehicle:getId(), seatId = vehicle:getSeat(playerObj), status = "crash",})
        playerObj:getModData()["mototsar"].health = nil
        vehicle:exit(playerObj)
        triggerEvent("OnExitVehicle", playerObj)
        playerObj:setKnockedDown(true)
        return
    end
    playerObj:getModData()["mototsar"].health = generalCondition
end

local tickControl = 3 -- Сокращает количество срабатываний скрипта. Больше число - меньше срабатываний
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
            local vehicle = playerLocal:getVehicle()
            if vehicle and vehicle:getPartById("AMCConfig") then
                local vehicleInfo = vehicle:getPartById("AMCConfig"):getTable("AMCConfig")
                if vehicleInfo then
                    if vehicle:isDriver(playerLocal) and vehicleInfo.fallDelta then
                        AMCTickControl.fallControl(playerLocal, vehicle, tonumber(vehicleInfo.fallDelta))
                    end
                    AMCTickControl.setLocalVariables(playerLocal, vehicle, vehicleInfo)
                end
            end
            -- print(playersWithAnim)
            for playerId, _ in pairs(playersWithAnim) do
                player = getPlayerByOnlineID(playerId)
                if player and not player:isLocalPlayer() and not player:isDead() then
                    local vehicle = player:getVehicle()
                    if vehicle and vehicle:getPartById("AMCConfig") then
                        local vehicleInfo = vehicle:getPartById("AMCConfig"):getTable("AMCConfig")
                        if vehicleInfo then
                            local x = player:getX()
                            local y = player:getY()
                            if ((plLocX >= x - 60 and plLocX <= x + 60 and
                                    plLocY >= y - 60 and plLocY <= y + 60)) then
                                AMCTickControl.setAvatarVariables(player, vehicle, vehicleInfo)
                            end
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
                    local vehicle = playerObj:getVehicle()
                    if vehicle and vehicle:getPartById("AMCConfig") then
                        local vehicleInfo = vehicle:getPartById("AMCConfig"):getTable("AMCConfig")
                        if vehicleInfo then
                            if vehicleInfo.fallDelta then
                                AMCTickControl.fallControl(playerObj, vehicle, tonumber(vehicleInfo.fallDelta))
                            end
                            AMCTickControl.setLocalVariables(playerObj, vehicle, vehicleInfo)
                        elseif playerObj:getModData()["mototsar"] and playerObj:getModData()["mototsar"].health then
                            playerObj:getModData()["mototsar"].health = nil
                        end
                    end
                end
            end
        end
    end
end

local function onCreatePlayer(id)
    local playerObj = getSpecificPlayer(id)
    playerObj:getModData()["mototsar"] = {}
    playerObj:getModData()["mototsar"].health = nil
    if playerObj:getVehicle() then
        local motoInfo = playerObj:getVehicle():getPartById("AMCConfig"):getTable("AMCConfig")
        if motoInfo and (motoInfo.hideWeapon == "1") then
            playerObj:setHideWeaponModel(true)
            return
        end
    end
    playerObj:setHideWeaponModel(false)
end

-- Events.OnTileRemoved.Add(AMCTickControl.checkWaterBuild)
Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnTick.Add(AMCTickControl.main)
-- Events.OnPlayerDeath.Add(onPlayerDeathStopSwimSound)