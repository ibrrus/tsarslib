--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ATAISAnimatedPartOpen = ISBaseTimedAction:derive("ATAISAnimatedPartOpen")

function ATAISAnimatedPartOpen:isValid()
	return self.part and self.part:getDoor() and not self.part:getDoor():isOpen()
end

function ATAISAnimatedPartOpen:update()
	if self.character:getSpriteDef():isFinished() then
--	if self.door:isAnimationFinished() then
		self:forceComplete()
	end
end

function ATAISAnimatedPartOpen:start()
	-- TODO: sync part animation + sound
	self.vehicle:playPartAnim(self.part, "Open")
	self.vehicle:playPartSound(self.part, self.character, "Open")
	-- Set this here to negate the effects of injuries, negative moodles, etc.
	self.action:setTime(5)
end

function ATAISAnimatedPartOpen:stop()
	-- TODO: interrupted, close door again?
	ISBaseTimedAction.stop(self)
end

function ATAISAnimatedPartOpen:perform()
	local args = { vehicle = self.vehicle:getId(), part = self.part:getId(), open = true }
	sendClientCommand(self.character, 'vehicle', 'setDoorOpen', args)
	-- FIXME: due to network delay, we should wait until the server tells the client the door is open before finishing
	self.part:getDoor():setOpen(true)
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ATAISAnimatedPartOpen:new(character, vehicle, part)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.vehicle = vehicle
	o.part = part
	o.maxTime = -1
	return o
end

