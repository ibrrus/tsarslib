
local old_ISEnterVehicle_start = ISEnterVehicle.start
local old_ISEnterVehicle_stop = ISEnterVehicle.stop
local old_ISEnterVehicle_perform = ISEnterVehicle.perform

local old_ISExitVehicle_start = ISExitVehicle.start
local old_ISExitVehicle_stop = ISExitVehicle.stop
local old_ISExitVehicle_perform = ISExitVehicle.perform

local old_ISSwitchVehicleSeat_start = ISSwitchVehicleSeat.start
local old_ISSwitchVehicleSeat_perform = ISSwitchVehicleSeat.perform

function ISEnterVehicle:start()
    old_ISEnterVehicle_start(self)
    local motoInfo = nil
    if self.vehicle and self.vehicle:getPartById("AMCConfig") then
        motoInfo = self.vehicle:getPartById("AMCConfig"):getTable("AMCConfig")
    end
    if motoInfo then
        self.character:setVariable("ATVehicleType", motoInfo.type .. self.seat)
    end
    if isClient() and self.character:isLocalPlayer() then
        ModData.getOrCreate("tsaranimations")[self.character:getOnlineID()] = true
        ModData.transmit("tsaranimations")
    end
    sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.vehicle:getId(), seatId = self.seat, status = "enter",})
end

function ISEnterVehicle:stop()
    self.character:ClearVariable("ATVehicleType")
    if isClient() then
        ModData.getOrCreate("tsaranimations")[self.character:getOnlineID()] = nil
        ModData.transmit("tsaranimations")
    end
    sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.vehicle:getId(), seatId = self.seat, status = "none",})
    old_ISEnterVehicle_stop(self)
end

function ISEnterVehicle:perform()
    sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.vehicle:getId(), seatId = self.seat, status = "stop",})
    old_ISEnterVehicle_perform(self)
end


function ISExitVehicle:start()
    old_ISExitVehicle_start(self)
    sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.character:getVehicle():getSeat(self.character), status = "exit",})
end

function ISExitVehicle:stop()
    sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.character:getVehicle():getSeat(self.character), status = "stop",})
    old_ISExitVehicle_stop(self)
end

function ISExitVehicle:perform()
    self.character:clearVariable("ATVehicleType")
	self.character:clearVariable("ATVehicleStatus")
	self.character:clearVariable("ATPassengerStatus")
    if isClient() then
        ModData.getOrCreate("tsaranimations")[self.character:getOnlineID()] = nil
        ModData.transmit("tsaranimations")
    end
    sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.character:getVehicle():getSeat(self.character), status = "none",})
    old_ISExitVehicle_perform(self)
end

-- Смена сиденья не успевает синхронизироваться
-- function ISSwitchVehicleSeat:start()
    -- old_ISSwitchVehicleSeat_start(self)
    -- sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.seatTo, status = "switchseat",})
-- end

function ISSwitchVehicleSeat:perform()
    sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.character:getVehicle():getSeat(self.character), status = "none",})
    local motoInfo = nil
    if self.character:getVehicle() and self.character:getVehicle():getPartById("AMCConfig") then
        motoInfo = self.character:getVehicle():getPartById("AMCConfig"):getTable("AMCConfig")
    end
    if motoInfo then
        self.character:setVariable("ATVehicleType", motoInfo.type .. self.seatTo)
    end
    old_ISSwitchVehicleSeat_perform(self)
    sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.seatTo, status = "stop",})
end