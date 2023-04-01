function ISVehicleMechanics:update()
    if self.vehicle and self.chr:DistToProper(self.vehicle) > 6 then
        self:close()
    elseif not self.vehicle or not self.vehicle:getSquare() or self.vehicle:getSquare():getMovingObjects():indexOf(self.vehicle) < 0 then
        self:close() -- handle vehicle being removed by admin/cheat command
    else
        self:recalculGeneralCondition();
    end
end