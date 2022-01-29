if not LiqudTanker then LiqudTanker = {} end

LiqudTanker.LiquidTypes = {
	["Water"] = true,
	["Gasoline"] = true,
}

if not LiqudTanker.old_ISVehicleMenu_FillPartMenu then
	LiqudTanker.old_ISVehicleMenu_FillPartMenu = ISVehicleMenu.FillPartMenu
end

function ISVehicleMenu.FillPartMenu(playerIndex, context, slice, vehicle)	
	local playerObj = getSpecificPlayer(playerIndex);
	local typeToItem = VehicleUtils.getItems(playerIndex)
	local fuel_truck_source = FindVehicleGas(playerObj, vehicle)
	for i=1,vehicle:getPartCount() do
		local part = vehicle:getPartByIndex(i-1)		
		if part:isContainer() and part:getContainerContentType() == "Gasoline Storage" then
			if typeToItem["Base.PetrolCan"] and part:getContainerContentAmount() < part:getContainerCapacity() then
				if slice then
					slice:addSlice(getText("ContextMenu_Add_Gasoline_To_Gasoline_Storage_Tank"), getTexture("Item_Petrol"), ISVehiclePartMenu.onAddGasoline, playerObj, part)
				else
					context:addOption(getText("ContextMenu_Add_Gasoline_To_Gasoline_Storage_Tank"), playerObj,ISVehiclePartMenu.onAddGasoline, part)
				end
			end
			if part:getContainerContentAmount() > 0 then
				if ISVehiclePartMenu.getGasCanNotFull(playerObj, typeToItem) then
					if slice then
						slice:addSlice(getText("ContextMenu_Remove_Gasoline_From_Gasoline_Storage_Tank"), getTexture("Item_Petrol"), ISVehiclePartMenu.onTakeGasoline, playerObj, part)
					else
						context:addOption(getText("ContextMenu_Remove_Gasoline_From_Gasoline_Storage_Tank"), playerObj, ISVehiclePartMenu.onTakeGasoline, part)
					end
				else 
					if slice then
					else
						context:addOption(getText("ContextMenu_For_get_Gasoline_Need_Gas_Can"), nil, nil, nil)
					end
				end
			end
			local fuelStation = LiqudTanker.getNearbyFuelPumpForTank(vehicle)
			if fuelStation then
				local square = fuelStation:getSquare();
				if square and ((SandboxVars.AllowExteriorGenerator and square:haveElectricity()) or (SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier)) then
					if square and part:getContainerContentAmount() < part:getContainerCapacity() then
						-- print("2 +")
						if slice then
							-- print("3 +")
							slice:addSlice(getText("ContextMenu_Fill_Gasoline_Storage_Tank_From_Pump"), getTexture("media/ui/vehicles/vehicle_refuel_from_pump.png"), LiqudTanker.onPumpGasolineForTank, playerObj, part)
						else
							-- print("4 +")
							context:addOption(getText("ContextMenu_Fill_Gasoline_Storage_Tank_From_Pump"), playerObj, LiqudTanker.onPumpGasolineForTank, part)
						end
					end
				end
			end
			--local square = ISVehiclePartMenu.getNearbyFuelPump(vehicle)
			if fuel_truck_source and fuel_truck_source:getContainerContentAmount() > 0 and part:getContainerContentAmount() < part:getContainerCapacity() then
				--if square and part:getContainerContentAmount() < part:getContainerCapacity() then
					if slice then
						slice:addSlice(getText("ContextMenu_Fill_Gasoline_Storage_Tank_From_Fuel_Truck"), getTexture("media/ui/vehicles/vehicle_gas_hose.png"), ISVehiclePartMenu.onPumpGasolineFromTruck, playerObj, part, fuel_truck_source)
					else
						context:addOption(getText("ContextMenu_Fill_Gasoline_Storage_Tank_From_Fuel_Truck"), playerObj, ISVehiclePartMenu.onPumpGasolineFromTruck, part, fuel_truck_source)
					end
				--end
			end	
		end	

		-- Any liquid storage
		-- if part:isContainer() and part:getContainerContentType() 
				-- and string.match(part:getContainerContentType(), "Storage")
				-- and LiqudTanker.LiquidTypes[string.match(part:getContainerContentType(), "%a+")] then 
			-- if slice then
				-- slice:addSlice("Empty tanker")
			-- else
				-- context:addOption("Empty tanker")
			-- end
		-- end


		-- Fuel vehicle from tanker
		if not vehicle:isEngineStarted() and part:isContainer() and part:getContainerContentType() == "Gasoline" then
			if fuel_truck_source and fuel_truck_source:getContainerContentAmount() > 0 and part:getContainerContentAmount() < part:getContainerCapacity() then
				--if square and part:getContainerContentAmount() < part:getContainerCapacity() then
					if slice then
						slice:addSlice(getText("ContextMenu_Remove_Gasoline_From_Fuel_Truck"), getTexture("media/ui/vehicles/vehicle_gas_hose.png"), ISVehiclePartMenu.onPumpGasolineFromTruck, playerObj, part, fuel_truck_source)
					else
						context:addOption(getText("ContextMenu_Remove_Gasoline_From_Fuel_Truck"), playerObj, ISVehiclePartMenu.onPumpGasolineFromTruck, part, fuel_truck_source)
					end
				--end
			end			
		end
	end
	LiqudTanker.old_ISVehicleMenu_FillPartMenu(playerIndex, context, slice, vehicle)
end

function LiqudTanker.onPumpGasolineForTank(playerObj, part)
	if playerObj:getVehicle() then
		ISVehicleMenu.onExit(playerObj)
	end
	local fuelStation = LiqudTanker.getNearbyFuelPumpForTank(part:getVehicle())
	if fuelStation then
		local square = fuelStation:getSquare();
		if square then
			local action = ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea())
			action:setOnFail(ISVehiclePartMenu.onPumpGasolinePathFail, playerObj)
			ISTimedActionQueue.add(action)
			ISTimedActionQueue.add(ISRefuelFromGasPump:new(playerObj, part, fuelStation, 100))
		end
	end
end

function LiqudTanker.getNearbyFuelPumpForTank(vehicle)
	local part = vehicle:getPartById("GasTank") or vehicle:getPartById("500FuelTank") or vehicle:getPartById("1000FuelTank")
	if not part then return nil end
	local areaCenter = vehicle:getAreaCenter(part:getArea())--print(getPlayer():getVehicle():getPartById("GasTank"):getArea())
	if not areaCenter then return nil end
	local square = getCell():getGridSquare(areaCenter:getX(), areaCenter:getY(), vehicle:getZ())
	if not square then return nil end
	for dy=-2.5,2.5 do
		for dx=-2.5,2.5 do
			-- TODO: check line-of-sight between 2 squares
			local square2 = getCell():getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
			for i=0, square2:getObjects():size()-1 do
				local obj = square2:getObjects():get(i);
				if obj:getPipedFuelAmount() > 0 then
					return obj
				end
			end
		end
	end
end


function FindVehicleGas(playerObj, playerVehicle)
	--print("TEST")
	local radius = 5
	local player = getPlayer()
	local cell = playerObj:getCell()
	local vehicleList = cell:getVehicles()
	--for b,vehicle in pairs(vehicleList) do
	for index=0, vehicleList:size()-1 do
		local vehicle = vehicleList:get(index)
		for i=1,vehicle:getPartCount() do
			local part = vehicle:getPartByIndex(i-1)	
			if part:isContainer() and part:getContainerContentType() == "Gasoline Storage" and part:getContainerContentAmount() > 0 and vehicle ~= playerVehicle then
				--print("FUEL")
				local square = vehicle:getSquare()
					x = math.abs(vehicle:getX()-playerObj:getX())
					y = math.abs(vehicle:getY()-playerObj:getY())
					if x < radius and y < radius then
						return part
					end
			end
		end
	end
	return false
end

function ISVehiclePartMenu.onPumpGasolineFromTruck(playerObj, part, source_Tank)
	if playerObj:getVehicle() then
		ISVehicleMenu.onExit(playerObj)
	end
	local square = source_Tank:getVehicle():getSquare()
	if square then
		local action = ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea())
		action:setOnFail(ISVehiclePartMenu.onPumpGasolinePathFail, playerObj)
		ISTimedActionQueue.add(action)
		ISTimedActionQueue.add(ISRefuelFromLiqudTanker:new(playerObj, part, square, 100, source_Tank))
	end
end