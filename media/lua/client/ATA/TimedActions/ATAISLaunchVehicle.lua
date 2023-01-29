require "TimedActions/ISBaseTimedAction"

ATAISLaunchVehicle = ISBaseTimedAction:derive("ATAISLaunchVehicle")


function ATAISLaunchVehicle:isValid()
    return self.trailer and not self.trailer:isRemovedFromWorld();
end

function ATAISLaunchVehicle:update()
    self.character:faceThisObject(self.trailer)
    -- speed 1 = 1, 2 = 5, 3 = 20, 4 = 40
    self.character:setMetabolicTarget(Metabolics.HeavyWork);
end

function ATAISLaunchVehicle:start()
    setGameSpeed(1)
    self:setActionAnim("Loot")
    self.trailer:getEmitter():playSound("ATAVehicleWrecker")
end

function ATAISLaunchVehicle:stop()
    self.trailer:getEmitter():stopSoundByName("ATAVehicleWrecker")
    ISBaseTimedAction.stop(self)
end

function ATAISLaunchVehicle:perform()
    sendClientCommand(self.character, 'commonlib', 'launchVehicle', {trailer = self.trailer:getId(), x = self.square:getX(), y = self.square:getY()})
    local playerNum = self.character:getPlayerNum()
    setGameSpeed(1)
    -- self.trailer:getEmitter():stopSoundByName("boat_launching")
    ISBaseTimedAction.perform(self)
end


function ATAISLaunchVehicle:new(character, trailer, sq)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.trailer = trailer
    o.square = sq
    o.isFadeOut = false
    o.maxTime = 330;
    if character:isTimedActionInstant() then o.maxTime = 10 end
    return o
end

