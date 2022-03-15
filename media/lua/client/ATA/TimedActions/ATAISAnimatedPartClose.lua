--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ATAISAnimatedPartClose = ISBaseTimedAction:derive("ATAISAnimatedPartClose")

function ATAISAnimatedPartClose:isValid()
	return self.part and self.part:getDoor() and self.part:getDoor():isOpen()
end

function ATAISAnimatedPartClose:update()
	if self.character:getSpriteDef():isFinished() then
		self:forceComplete()
	end
end

function ATAISAnimatedPartClose:start()
	-- TODO: sync part animation + sound
	self.vehicle:playPartAnim(self.part, "Close")
	self.vehicle:playPartSound(self.part, self.character, "Close")
	-- Set this here to negate the effects of injuries, negative moodles, etc.
	self.action:setTime(4)
end

function ATAISAnimatedPartClose:stop()
	-- TODO: interrupted, close door again?
	ISBaseTimedAction.stop(self)
end

function ATAISAnimatedPartClose:perform()
	local args = { vehicle = self.vehicle:getId(), part = self.part:getId(), open = false }
	sendClientCommand(self.character, 'vehicle', 'setDoorOpen', args)
	-- FIXME: due to network delay, we should wait until the server tells the client the door is closed before finishing
	self.part:getDoor():setOpen(false)
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ATAISAnimatedPartClose:new(character, vehicle, part)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.vehicle = vehicle
	o.part = part
	o.maxTime = -1
	return o
end

