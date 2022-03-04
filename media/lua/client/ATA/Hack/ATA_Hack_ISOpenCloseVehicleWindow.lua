local old_ISOpenCloseVehicleWindow_perform = ISOpenCloseVehicleWindow.perform

function ISOpenCloseVehicleWindow:perform()
    self.Wprotection = self.vehicle:getPartById("ATAProtection" .. self.part:getId())
    if self.Wprotection then
        if self.open then
            self.vehicle:playPartAnim(self.Wprotection, "Open")
            local args = { vehicle = self.vehicle:getId(), part = self.Wprotection:getId(), open = true }
            sendClientCommand(self.character, 'vehicle', 'setDoorOpen', args)
        else
            self.vehicle:playPartAnim(self.Wprotection, "Close")
            local args = { vehicle = self.vehicle:getId(), part = self.Wprotection:getId(), open = false }
            sendClientCommand(self.character, 'vehicle', 'setDoorOpen', args)
        end
    end
    old_ISOpenCloseVehicleWindow_perform(self)
end
