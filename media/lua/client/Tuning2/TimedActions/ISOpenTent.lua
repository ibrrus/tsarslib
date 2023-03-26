--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISOpenTent = ISBaseTimedAction:derive("ISOpenTent")

function ISOpenTent:isValid()
-- print("ISOpenTent:isValid()")
	if self.part:getInventoryItem() and (self.open or (ATATuning.UninstallTest.RoofClose(self.vehicle, self.vehicle:getPartById("SeatMiddleLeft"), self.character) and ATATuning.UninstallTest.RoofClose(self.vehicle, self.vehicle:getPartById("SeatMiddleRight"), self.character))) then
		return true
	else
		return false
	end	

end

function ISOpenTent:waitToStart()
-- print("ISOpenTent:waitToStart()")
	self.character:faceThisObject(self.vehicle)
	return self.character:shouldBeTurning()
end

function ISOpenTent:update()
-- print("ISOpenTent:update()")
	self.character:faceThisObject(self.vehicle)
    self.character:setMetabolicTarget(Metabolics.MediumWork);
end

function ISOpenTent:start()
-- print("ISOpenTent:start()")
	self:setActionAnim("VehicleWorkOnMid")
--	self:setOverrideHandModels(nil, nil)
end

function ISOpenTent:stop()
    ISBaseTimedAction.stop(self)
end

function ISOpenTent:perform()
-- print("ISOpenTent:perform()")
	-- ATATuning2.Use.RoofTent(self.vehicle, self.part, self.open)
    sendClientCommand(self.character, 'atatuning2', 'usePart', {vehicle = self.vehicle:getId(), partName = self.part:getId(),})
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISOpenTent:new(character, vehicle, part, open, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.vehicle = vehicle
	o.part = part
	o.open = open
	o.maxTime = time - (character:getPerkLevel(Perks.Mechanics) * (time/15));
	if character:isTimedActionInstant() then
		o.maxTime = 1;
	end
	if ISVehicleMechanics.cheat then o.maxTime = 1; end
	return o
end

