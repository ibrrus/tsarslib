--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ATAISOpenTent = ISBaseTimedAction:derive("ATAISOpenTent")

function ATAISOpenTent:isValid()
	return self.part:getInventoryItem() and self.vehicle:canUninstallPart(self.character, self.part)
end

function ATAISOpenTent:waitToStart()
	self.character:faceThisObject(self.vehicle)
	return self.character:shouldBeTurning()
end

function ATAISOpenTent:update()
	self.character:faceThisObject(self.vehicle)
    self.character:setMetabolicTarget(Metabolics.MediumWork);
end

function ATAISOpenTent:start()
	self:setActionAnim("VehicleWorkOnMid")
--	self:setOverrideHandModels(nil, nil)
end

function ATAISOpenTent:stop()
    ISBaseTimedAction.stop(self)
end

function ATAISOpenTent:perform()
	Tuning.Use.RoofTent(self.vehicle, self.part, self.open)
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ATAISOpenTent:new(character, vehicle, part, open, time)
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

