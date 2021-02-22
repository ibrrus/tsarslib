function ISRefuelFromGasPump:start()
	self.tankStart = self.part:getContainerContentAmount()
	-- Pumps start with 100 units of fuel.  8 pump units = 1 PetrolCan according to ISTakeFuel.
	--self.pumpStart = tonumber(self.square:getProperties():Val("fuelAmount"))
	--print("GAS IN PUMP: " .. tostring(self.pumpStart))
	self.pumpStart = 500
	local pumpLitresAvail = self.pumpStart * (Vehicles.JerryCanLitres / 8)
	local tankLitresFree = self.part:getContainerCapacity() - self.tankStart
	local takeLitres = math.min(tankLitresFree, pumpLitresAvail)
	self.tankTarget = self.tankStart + takeLitres
	self.pumpTarget = self.pumpStart - takeLitres / (Vehicles.JerryCanLitres / 8)
	self.amountSent = self.tankStart

	self.action:setTime(takeLitres * 50)

	self:setActionAnim("fill_container_tap")
	self:setOverrideHandModels(nil, nil)
end
