
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
    if self.vehicle and self.vehicle:getPartById("AMCConfig") then
        local motoInfo = self.vehicle:getPartById("AMCConfig"):getTable("AMCConfig")
        if motoInfo then
            self.character:setVariable("ATVehicleType", motoInfo.type .. self.seat)
            if motoInfo.hideWeapon == "1" then
                self.character:setHideWeaponModel(true)
            end
            if isClient() and self.character:isLocalPlayer() then
                ModData.getOrCreate("tsaranimations")[self.character:getOnlineID()] = true
                ModData.transmit("tsaranimations")
            end
            sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.vehicle:getId(), seatId = self.seat, status = "enter",})
        end
    end
end

function ISEnterVehicle:stop()
    if self.vehicle and self.vehicle:getPartById("AMCConfig") then
        local motoInfo = self.vehicle:getPartById("AMCConfig"):getTable("AMCConfig")
        if motoInfo then
            self.character:ClearVariable("ATVehicleType")
            self.character:setHideWeaponModel(false)
            if isClient() then
                ModData.getOrCreate("tsaranimations")[self.character:getOnlineID()] = nil
                ModData.transmit("tsaranimations")
            end
            sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.vehicle:getId(), seatId = self.seat, status = "none",})
        end
    end
    old_ISEnterVehicle_stop(self)
end

function ISEnterVehicle:perform()
    if self.vehicle and self.vehicle:getPartById("AMCConfig") then
        local motoInfo = self.vehicle:getPartById("AMCConfig"):getTable("AMCConfig")
        if motoInfo then
            sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.vehicle:getId(), seatId = self.seat, status = "stop",})
        end
    end
    old_ISEnterVehicle_perform(self)
end


function ISExitVehicle:start()
    old_ISExitVehicle_start(self)
    if self.character:getVehicle() and self.character:getVehicle():getPartById("AMCConfig") then
        local motoInfo = self.character:getVehicle():getPartById("AMCConfig"):getTable("AMCConfig")
        if motoInfo then
            sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.character:getVehicle():getSeat(self.character), status = "exit",})
        end
    end
end

function ISExitVehicle:stop()
    if self.character:getVehicle() and self.character:getVehicle():getPartById("AMCConfig") then
        local motoInfo = self.character:getVehicle():getPartById("AMCConfig"):getTable("AMCConfig")
        if motoInfo then
            sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.character:getVehicle():getSeat(self.character), status = "stop",})
        end
    end
    old_ISExitVehicle_stop(self)
end

function ISExitVehicle:perform()
    if self.character:getVehicle() and self.character:getVehicle():getPartById("AMCConfig") then
        local motoInfo = self.character:getVehicle():getPartById("AMCConfig"):getTable("AMCConfig")
        if motoInfo then
            self.character:setHideWeaponModel(false)
            self.character:clearVariable("ATVehicleType")
            self.character:clearVariable("ATVehicleStatus")
            self.character:clearVariable("ATPassengerStatus")
            if isClient() then
                ModData.getOrCreate("tsaranimations")[self.character:getOnlineID()] = nil
                ModData.transmit("tsaranimations")
            end
            sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.character:getVehicle():getSeat(self.character), status = "none",})
        end
    end
    old_ISExitVehicle_perform(self)
end

-- Смена сиденья не успевает синхронизироваться
-- function ISSwitchVehicleSeat:start()
    -- old_ISSwitchVehicleSeat_start(self)
    -- sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.seatTo, status = "switchseat",})
-- end

function ISSwitchVehicleSeat:perform()
    local motoInfo = nil
    if self.character:getVehicle() and self.character:getVehicle():getPartById("AMCConfig") then
        motoInfo = self.character:getVehicle():getPartById("AMCConfig"):getTable("AMCConfig")
    end
    if motoInfo then
        sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.character:getVehicle():getSeat(self.character), status = "none",})
        self.character:setVariable("ATVehicleType", motoInfo.type .. self.seatTo)
    end
    old_ISSwitchVehicleSeat_perform(self)
    if motoInfo then
        sendClientCommand(self.character, 'autotsaranim', 'updateVariables', {vehicle = self.character:getVehicle():getId(), seatId = self.seatTo, status = "stop",})
    end
end