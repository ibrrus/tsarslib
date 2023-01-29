require "TimedActions/ISBaseTimedAction"

ATAISLoadVehicle = ISBaseTimedAction:derive("ATAISLoadVehicle")


function ATAISLoadVehicle:isValid()
    return self.trailer and not self.trailer:isRemovedFromWorld() and not self.trailer:getCharacter(0);
end

function ATAISLoadVehicle:update()
    self.character:faceThisObject(self.trailer)
    -- speed 1 = 1, 2 = 5, 3 = 20, 4 = 40
    self.character:setMetabolicTarget(Metabolics.HeavyWork);
end

function ATAISLoadVehicle:start()
    setGameSpeed(1)
    self:setActionAnim("Loot")
    self.trailer:getEmitter():playSound("ATAVehicleWrecker")
end

function ATAISLoadVehicle:stop()
    self.trailer:getEmitter():stopSoundByName(ATAVehicleWrecker)
    ISBaseTimedAction.stop(self)
end

function ATAISLoadVehicle:perform()
    if self.vehicle:getCharacter(0) then
        self:stop()
    else
        if self.vehicle:isKeysInIgnition() then
            self.character:getInventory():AddItem(self.vehicle:createVehicleKey())
        end
        sendClientCommand(self.character, 'commonlib', 'loadVehicle', {trailer = self.trailer:getId(), vehicle = self.vehicle:getId()})
    end
    setGameSpeed(1)
    self.trailer:getEmitter():stopSoundByName("ATAVehicleWrecker")
    ISBaseTimedAction.perform(self)
end


function ATAISLoadVehicle:new(character, trailer, vehicle)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.trailer = trailer
    o.vehicle = vehicle
    o.maxTime = 330;
    
    if character:isTimedActionInstant() then o.maxTime = 10 end
    return o
end

