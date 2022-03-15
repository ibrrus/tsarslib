local old_ISVehicleDashboard_prerender = ISVehicleDashboard.prerender

function ISVehicleDashboard:prerender()
    old_ISVehicleDashboard_prerender(self)
    -- self.doorTex:setVisible(self.vehicle:getPartById("TruckBed") ~= nil)
    if self.vehicle then
        self.heaterTex:setVisible(self.vehicle:getHeater() ~= nil)
        if self.vehicle:getPartById("TCLConfig") and self.vehicle:getPartById("TCLConfig"):getTable("TCLConfig") then
            if self.vehicle:getPartById("TCLConfig"):getTable("TCLConfig").disableDoorLocker == "1" then
                self.doorTex:setVisible(false)
                return
            end
        end
        self.doorTex:setVisible(true)
    end
end