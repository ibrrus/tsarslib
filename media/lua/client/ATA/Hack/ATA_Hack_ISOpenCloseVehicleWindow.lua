
function ISOpenCloseVehicleWindow:perform()
	self.Wprotection = self.vehicle:getPartById("ATAProtection" .. self.part:getId())
	if self.Wprotection then
		if self.open then
			self.vehicle:playPartAnim(self.Wprotection, "Open")
			self.Wprotection:getDoor():setOpen(true)
			self.vehicle:playPartSound(self.Wprotection, "Open")
		else
			self.vehicle:playPartAnim(self.Wprotection, "Close")
			self.Wprotection:getDoor():setOpen(false)
			self.vehicle:playPartSound(self.Wprotection, "Close")
		end
	end
	local args = { vehicle = self.vehicle:getId(), part = self.part:getId(), open = self.open }
	sendClientCommand(self.character, 'vehicle', 'setWindowOpen', args)
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end
