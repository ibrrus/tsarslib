local old_ISEnterVehicle_start = ISEnterVehicle.start
local old_ISEnterVehicle_stop = ISEnterVehicle.stop

-- part TCLConfig
-- {
    -- table TCLConfig
    -- {
        -- animType = vanilla,
    -- }
-- }

function ISEnterVehicle:start()
    if self.vehicle and self.vehicle:getPartById("TCLConfig") and self.vehicle:getPartById("TCLConfig"):getTable("TCLConfig") then
        if self.vehicle:getPartById("TCLConfig"):getTable("TCLConfig").animType then
            self.character:SetVariable("TCLAnimType", self.vehicle:getPartById("TCLConfig"):getTable("TCLConfig").animType)
        end
    end
    old_ISEnterVehicle_start(self)
    if self.seat == 0 then
        self.character:setVariable("TCLIsDriver", true)
    else
        self.character:setVariable("TCLIsDriver", false)
    end
end

function ISEnterVehicle:stop()
    self.character:ClearVariable("TCLAnimType")
    self.character:ClearVariable("TCLIsDriver")
    old_ISEnterVehicle_stop(self)
end

local function switchVehicleSeat(player)
    if not player then
        player = getPlayer()
    end
    local vehicle = player:getVehicle()
    if vehicle and vehicle:getPartById("TCLConfig") and vehicle:getPartById("TCLConfig"):getTable("TCLConfig") and vehicle:getPartById("TCLConfig"):getTable("TCLConfig").animType then
        player:SetVariable("TCLAnimType", vehicle:getPartById("TCLConfig"):getTable("TCLConfig").animType)
        local seat = vehicle:getSeat(player)
        if not seat then return end
        if seat == 0 then
            player:setVariable("TCLIsDriver", true)
        else
            player:setVariable("TCLIsDriver", false)
        end
    end
end

Events.OnExitVehicle.Add(function(player)
    player:ClearVariable("TCLAnimType")
    player:ClearVariable("TCLIsDriver")
end);

Events.OnSwitchVehicleSeat.Add(switchVehicleSeat)
Events.OnGameStart.Add(switchVehicleSeat)