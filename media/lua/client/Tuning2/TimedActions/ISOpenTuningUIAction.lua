--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISOpenTuningUIAction = ISBaseTimedAction:derive("ISOpenTuningUIAction")

function ISOpenTuningUIAction:isValid()
	return true;
end

function ISOpenTuningUIAction:waitToStart()
	if self.character:getVehicle() then return false end
	self.character:faceThisObject(self.vehicle)
	return self.character:shouldBeTurning()
end

function ISOpenTuningUIAction:update()
	self.character:faceThisObject(self.vehicle)
end

function ISOpenTuningUIAction:start()
	self:setActionAnim("ExamineVehicle");
	self:setOverrideHandModels(nil, nil)
end

function ISOpenTuningUIAction:stop()
	ISBaseTimedAction.stop(self)
end

function ISOpenTuningUIAction:perform()
	local ui = getPlayerTuningUI(self.character:getPlayerNum());
	ui.vehicle = self.vehicle;
	ui:setVisible(true, JoypadState.players[self.character:getPlayerNum()+1])
	ui:addToUIManager()
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISOpenTuningUIAction:new(character, vehicle, usedHood)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.vehicle = vehicle
	o.usedHood = usedHood
	o.maxTime = 75 - (character:getPerkLevel(Perks.Mechanics) * (75/15));
	if vehicle:getScript() and vehicle:getScript():getWheelCount() == 0 then
		o.maxTime = 1
	end
	local cheat = getCore():getDebug() and getDebugOptions():getBoolean("Cheat.Vehicle.MechanicsAnywhere")
	if ISVehicleMechanics.cheat or cheat or character:isTimedActionInstant() then
		o.maxTime = 1
	end
	return o
end

