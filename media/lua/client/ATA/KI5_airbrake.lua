--***********************************************************
--**                          KI5                          **
--***********************************************************

local braked = true

local function airbrake(player)
    local vehicle = player:getVehicle()
    if vehicle and vehicle:getPartById("TCLConfig") then
        if vehicle:getPartById("TCLConfig"):getTable("TCLConfig").airbrake == "true" then
            if (vehicle:isEngineRunning() and vehicle:getCurrentSpeedKmHour() == 0) and not braked then
                braked = true
                vehicle:playSound("tsl_osh2Brake")
            end
            if (vehicle:isEngineRunning() and vehicle:getCurrentSpeedKmHour() ~= 0) and braked then
                braked = false
            end
        end
    end
end

Events.OnPlayerUpdate.Add(airbrake)