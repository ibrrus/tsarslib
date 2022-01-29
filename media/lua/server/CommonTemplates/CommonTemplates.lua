-- require 'CommonTemplates/CommonTemplates.lua'


--***********************************************************
--**             			iBrRus        				   **
--***********************************************************

CommonTemplates = {}
CommonTemplates.CheckEngine = {}
CommonTemplates.CheckOperate = {}
CommonTemplates.ContainerAccess = {}
CommonTemplates.Create = {}
CommonTemplates.Init = {}
CommonTemplates.InstallComplete = {}
CommonTemplates.InstallTest = {}
CommonTemplates.UninstallComplete = {}
CommonTemplates.UninstallTest = {}
CommonTemplates.Update = {}
CommonTemplates.Use = {}

CommonUtils = {}


local OvenBatteryChange = -0.000500
local FridgeBatteryChange = -0.000020
local MicrowaveBatteryChange = -0.000200

seatNameTable = {"FrontLeft", "FrontRight", "MiddleLeft", "MiddleRight", "RearLeft", "RearRight"}

--***********************************************************
--**                                                       **
--**                         Common                        **
--**                                                       **
--***********************************************************
function CommonTemplates.createActivePart(part)
	if not part:getLight() then
		part:createSpotLight(1000, 1000, 0.001, 0, 100, 0)
	end
end

function CommonUtils.PartInCabin(vehicle, part)
	if vehicle:getPartById("InCabin" .. seatNameTable[vehicle:getSeat(playerObj)+1]) then
		return true
	else
		return false
	end
end

function CommonTemplates.InstallTest.PartInCabin(vehicle, part, playerObj)
	if ISVehicleMechanics.cheat then return true; end
	if not vehicle:getPartById("InCabin" .. seatNameTable[vehicle:getSeat(playerObj)+1]) then return false end
	return Vehicles.InstallTest.Default(vehicle, part, playerObj)
end

function CommonTemplates.UninstallTest.PartInCabin(vehicle, part, playerObj)
	if ISVehicleMechanics.cheat then return true end
	if vehicle:getSeat(playerObj) == -1 then return false end
	if not vehicle:getPartById("InCabin" .. seatNameTable[vehicle:getSeat(playerObj)+1]) then return false end
	return Vehicles.UninstallTest.Default(vehicle, part, playerObj)
end

function CommonTemplates.InstallTest.PartNotInCabin(vehicle, part, playerObj)
	if ISVehicleMechanics.cheat then return true; end
	if vehicle:getSeat(playerObj) == -1 then return false end
	if vehicle:getPartById("InCabin" .. seatNameTable[vehicle:getSeat(playerObj)+1]) then return false end
	return Vehicles.InstallTest.Default(vehicle, part, playerObj)
end

function CommonTemplates.UninstallTest.PartNotInCabin(vehicle, part, playerObj)
	if ISVehicleMechanics.cheat then return true; end
	if vehicle:getSeat(playerObj) == -1 then return false end
	if vehicle:getPartById("InCabin" .. seatNameTable[vehicle:getSeat(playerObj)+1]) then return false end
	return Vehicles.UninstallTest.Default(vehicle, part, playerObj)
end

function CommonTemplates.ContainerAccess.ContainerByArea(transport, part, playerObj)
	if not part:getInventoryItem() then return false; end
	if playerObj:getVehicle() == transport then
		local script = transport:getScript()
		local seat = transport:getSeat(playerObj)
		local seatname = 'Seat'..script:getPassenger(seat):getId()
		return part:getArea() == seatname
	else
		return false
	end
end

function CommonTemplates.Init.Repair(vehicle, part)
	if part then
		part:setCondition(100)
        vehicle:transmitPartCondition(part)
	end
end

--***********************************************************
--**                                                       **
--**                    Fridge n Freezer                   **
--**                                                       **
--***********************************************************
function CommonTemplates.Create.Freezer(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("freezer")
	end
	CommonTemplates.createActivePart(part)
end

function CommonTemplates.Create.Fridge(vehicle, part)
	--print("CommonTemplates.Create.Fridge")
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("fridge")
	end
	CommonTemplates.createActivePart(part)
end

function CommonTemplates.Use.Fridge(vehicle, part, player)
	if not part:getModData().tsarslib then part:getModData().tsarslib = {} end
	if part:getModData().tsarslib.active then
		part:getModData().tsarslib.active = false
		player:getEmitter():playSound("ToggleStove")
		part:setLightActive(false)
		-- part:getModData().timePassed = 0
	else
		part:getModData().tsarslib.active = true
		part:setLightActive(true)
		player:getEmitter():playSound("ToggleStove")
	end
    vehicle:transmitPartModData(part)
end

function CommonTemplates.Init.Freezer(vehicle, part)
	-- print("CommonTemplates.Init.Freezer")
	if not part:getModData().tsarslib then 
		part:getModData().tsarslib = {}
	end
	if not part:getModData().tsarslib.freezer then 
		part:getModData().tsarslib.freezer = {}
	end
	
	if part:getInventoryItem() and part:getItemContainer() then
		if part:getModData().tsarslib.active and vehicle:getBatteryCharge() > 0.00010 then
			part:getItemContainer():setCustomTemperature(0.2)
			-- part:getItemContainer():setActive(true)
			local foodItems = part:getItemContainer():getItemsFromCategory("Food")
			for i=1, foodItems:size() do
				local item = foodItems:get(i-1)
				if item:canBeFrozen() then
					item:setFreezingTime(100)
					item:freeze()
					-- print("Init FREEZE")
				end
			end
			-- part:getItemContainer():setActive(true)
			part:setLightActive(true)
		else		
			part:getItemContainer():setCustomTemperature(1.0)
			-- part:getItemContainer():setActive(false)
			part:setLightActive(false)
		end
		-- print("Freezer currentTemp: ", part:getItemContainer():getTemprature())
	end
    vehicle:transmitPartModData(part)
end

function CommonTemplates.Init.Fridge(vehicle, part)
	-- print("CommonTemplates.Init.Fridge")
	if not part:getModData().tsarslib then part:getModData().tsarslib = {} end
	if part:getInventoryItem() and part:getItemContainer() then
		if part:getModData().tsarslib.active and vehicle:getBatteryCharge() > 0.00010 then
			part:getItemContainer():setCustomTemperature(0.2)
			-- part:getItemContainer():setActive(true)
			part:setLightActive(true)
		else		
			part:getItemContainer():setCustomTemperature(1.0)
			-- part:getItemContainer():setActive(false)
			part:setLightActive(false)
		end
		-- print("Fridge currentTemp: ", part:getItemContainer():getTemprature())
	end
    vehicle:transmitPartModData(part)
end

function CommonTemplates.Update.Fridge(vehicle, part, elapsedMinutes)
	-- print("CommonTemplates.Update.Fridge")
	local currentTemp = part:getItemContainer():getTemprature()
	-- print("Fridge currentTemp: ", currentTemp)
	local minTemp = 0.2
	local maxTemp = 1.0
	if part:getInventoryItem() and part:getItemContainer() then
		if part:getModData().tsarslib and part:getModData().tsarslib.active and vehicle:getBatteryCharge() > 0.00010 then
			part:setLightActive(true)
			if currentTemp < minTemp then
				part:getItemContainer():setCustomTemperature(minTemp)
			elseif currentTemp > minTemp then
				part:getItemContainer():setCustomTemperature(currentTemp - (0.04 * elapsedMinutes))
			end
			VehicleUtils.chargeBattery(vehicle, FridgeBatteryChange * elapsedMinutes)
		else
			if currentTemp < maxTemp then
				part:getItemContainer():setCustomTemperature(currentTemp + (0.04 * elapsedMinutes))
			elseif currentTemp >= maxTemp then
				part:getItemContainer():setCustomTemperature(maxTemp)
				part:setLightActive(false)
			end
		end
	end
end

function CommonTemplates.Update.Freezer(vehicle, part, elapsedMinutes)
	-- print("CommonTemplates.Update.Freezer")
	local currentTemp = part:getItemContainer():getTemprature()
	-- print("Freezer currentTemp: ", currentTemp)
	local minTemp = 0.2
	local maxTemp = 1.0
	if part:getInventoryItem() and part:getItemContainer() then
		if part:getModData().tsarslib and part:getModData().tsarslib.active and vehicle:getBatteryCharge() > 0.00010 then
			part:setLightActive(true)
			if currentTemp <= minTemp then
				local foodItems = part:getItemContainer():getItemsFromCategory("Food")
				local newFreezerTable = {}
				for i=1, foodItems:size() do
					local item = foodItems:get(i-1)
					if item:canBeFrozen() then
						local prevAge = part:getModData().tsarslib.freezer[item:getID()]
						if item:getFreezingTime() < 95 and not prevAge then
							item:setFreezingTime(item:getFreezingTime() + (elapsedMinutes)/50 * 100.0)
						else
							if prevAge then
								item:setAge(prevAge + (item:getAge() - prevAge) * 0.02)
							end
							item:freeze()
							item:setFreezingTime(100)
							newFreezerTable[item:getID()] = item:getAge()
						end
					end
				end
				part:getModData().tsarslib.freezer = newFreezerTable
                vehicle:transmitPartModData(part)
			elseif currentTemp > minTemp then
				part:getItemContainer():setCustomTemperature(currentTemp - (0.04 * elapsedMinutes))
			end
			VehicleUtils.chargeBattery(vehicle, FridgeBatteryChange * elapsedMinutes)
		else
			if currentTemp < maxTemp then
				part:getItemContainer():setCustomTemperature(currentTemp + (0.04 * elapsedMinutes))
			elseif currentTemp >= maxTemp then
				part:getItemContainer():setCustomTemperature(maxTemp)
				part:setLightActive(false)
			end
		end
	end
end

--***********************************************************
--**                                                       **
--**                    Oven n Microwave                   **
--**                                                       **
--***********************************************************
function CommonTemplates.Create.Oven(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("stove")
	end
	part:getModData().timer = 0
	part:getModData().timePassed = 0
	part:getModData().maxTemperature = 0
    vehicle:transmitPartModData(part)
	CommonTemplates.createActivePart(part)
end

function CommonTemplates.Use.DefaultDevice(vehicle, part, player)
	if part:getItemContainer():isActive() then
		part:getItemContainer():setActive(false)
		player:getEmitter():playSound("ToggleStove")
		part:getModData().timePassed = 0
        vehicle:transmitPartModData(part)
	else
		part:getItemContainer():setActive(true)
		part:setLightActive(true)
		player:getEmitter():playSound("ToggleStove")
	end
end

function CommonTemplates.Init.Oven(vehicle, part)
	part:setModelVisible("test", true)
	if part:getInventoryItem() and part:getItemContainer() 
			and part:getItemContainer():isActive() and vehicle:getBatteryCharge() > 0.00200 then
		part:getItemContainer():setCustomTemperature(2.0)
	else		
		part:getItemContainer():setCustomTemperature(1.0)
	end
end
a = 0
function CommonTemplates.Update.Oven(vehicle, part, elapsedMinutes)
	-- print("CommonTemplates.Update.Oven")
	local currentTemp = part:getItemContainer():getTemprature()
	-- print(currentTemp)
	local minTemp = 1.0
	local maxTemp = (part:getModData().maxTemperature + 100) / 100
	local contType = part:getItemContainer():getType()
	local emi = vehicle:getEmitter()
	if part:getInventoryItem() and part:getItemContainer() then
		if part:getItemContainer():isActive() and vehicle:getBatteryCharge() > 0.00200 then
			if currentTemp < maxTemp then
				part:getItemContainer():setCustomTemperature(currentTemp + 0.2)
			elseif currentTemp >= maxTemp then
				part:getItemContainer():setCustomTemperature(maxTemp)
			end
			VehicleUtils.chargeBattery(vehicle, OvenBatteryChange)
			if part:getModData().timer > 0 then
				if part:getModData().timePassed < part:getModData().timer then
					part:getModData().timePassed = part:getModData().timePassed + 1
				else 
					emi:playSound("StoveTimerExpired")
					part:getModData().timer = 0
					part:getModData().timePassed = 0
				end
			end
		else
			part:getModData().timePassed = 0
			if currentTemp > minTemp then
				part:getItemContainer():setCustomTemperature(currentTemp - 0.2)
			elseif currentTemp <= minTemp then
				part:getItemContainer():setCustomTemperature(minTemp)
				part:setLightActive(false)
			end
		end
        vehicle:transmitPartModData(part)
	end
end
--***********************************************************
--**                                                       **
--**                        Microwave                      **
--**                                                       **
--***********************************************************

function CommonTemplates.Create.Microwave(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("portablemicrowave")
	end
	part:getModData().timer = 0
	part:getModData().timePassed = 0
	part:getModData().maxTemperature = 0
    vehicle:transmitPartModData(part)
	CommonTemplates.createActivePart(part)
end

function CommonTemplates.Use.Microwave(vehicle, part, player, on)
	if part:getItemContainer():isActive() and not on then
		part:getItemContainer():setActive(false)
		vehicle:getEmitter():stopSoundByName("NewMicrowaveRunning")
		vehicle:getEmitter():playSound("MicrowaveTimerExpired")
		part:getModData().timer = 0
		part:getModData().timePassed = 0
	elseif part:getModData().timer > 0 and on then
		part:getModData().timePassed = 0.001
		part:getItemContainer():setActive(true)
		part:setLightActive(true)
		vehicle:getEmitter():playSound("ToggleStove")
		if not vehicle:getEmitter():isPlaying("NewMicrowaveRunning") then
			vehicle:getEmitter():playSoundLooped("NewMicrowaveRunning")
		end
	end
    vehicle:transmitPartModData(part)
end

function CommonTemplates.Update.Microwave(vehicle, part, elapsedMinutes)
	--print("CommonTemplates.Update.Microwave")
	local currentTemp = part:getItemContainer():getTemprature()
	local minTemp = 1.0
	local maxTemp = (part:getModData().maxTemperature + 100) / 100
	if part:getInventoryItem() and part:getItemContainer() then
		if part:getItemContainer():isActive() and vehicle:getBatteryCharge() > 0.00200 then
			if currentTemp < maxTemp then
				part:getItemContainer():setCustomTemperature(currentTemp + 0.5)
			elseif currentTemp >= maxTemp then
				part:getItemContainer():setCustomTemperature(maxTemp)
			end
			VehicleUtils.chargeBattery(vehicle, MicrowaveBatteryChange)
			if part:getModData().timer > 0 then
				if part:getModData().timePassed < part:getModData().timer then
					part:getModData().timePassed = part:getModData().timePassed + 1
				else 
					vehicle:getEmitter():stopSoundByName("NewMicrowaveRunning")
					vehicle:getEmitter():playSound("MicrowaveTimerExpired")
					part:getItemContainer():setActive(false)
					part:getModData().timer = 0
					part:getModData().timePassed = 0
				end
			else
				vehicle:getEmitter():stopSoundByName("NewMicrowaveRunning")
				vehicle:getEmitter():playSound("MicrowaveTimerExpired")
				part:getItemContainer():setActive(false)
				part:getModData().timer = 0
				part:getModData().timePassed = 0
			end
		else
			part:getModData().timePassed = 0
			if currentTemp > minTemp then
				part:getItemContainer():setCustomTemperature(currentTemp - 0.5)
			elseif currentTemp <= minTemp then
				part:getItemContainer():setCustomTemperature(minTemp)
				part:setLightActive(false)
			end
		end
        vehicle:transmitPartModData(part)
	end
end
--***********************************************************
--**                                                       **
--**                         Light                         **
--**                                                       **
--***********************************************************
function CommonTemplates.Create.LightApi(boat, part)
	local item = VehicleUtils.createPartInventoryItem(part)
	if part:getId() == "HeadlightLeft" then
		part:createSpotLight(0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	elseif part:getId() == "HeadlightRight" then
		part:createSpotLight(-0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	elseif part:getId() == "HeadlightRearRight" then
		CommonTemplates.createActivePart(part)
	end
	part:setInventoryItem(nil)
    vehicle:transmitPartItem(part)
end

function CommonTemplates.Init.LightApi(boat, part)
	part:setModelVisible("test", true)
end

function CommonTemplates.Update.LightApi(boat, part, elapsedMinutes)
	local light = part:getLight()
	if not light then return end
	local active = boat:getHeadlightsOn()
	if active and (not part:getInventoryItem() or boat:getBatteryCharge() <= 0.0) then
		active = false
	end
	part:setLightActive(active)
	if active and not boat:isEngineRunning() then
		VehicleUtils.chargeBattery(boat, -0.000025 * elapsedMinutes)
	end
end

function CommonTemplates.Create.Light(boat, part)
	local item = VehicleUtils.createPartInventoryItem(part)
	-- if part:getId() == "LightFloodlightLeft" then
		-- part:createSpotLight(0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	-- elseif part:getId() == "LightFloodlightRight" then
		-- part:createSpotLight(-0.5, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	-- end
end

function CommonTemplates.Init.Light(vehicle, part)
	part:setModelVisible("test", true)
end

function CommonTemplates.InstallComplete.Light(vehicle, part)
	-- print("CommonTemplates.InstallComplete.Light")
	
end

function CommonTemplates.UninstallComplete.Light(vehicle, part)
	-- print("CommonTemplates.UninstallComplete.Light")
	if part:getId() == "LightCabin" then
		vehicle:getPartById("HeadlightRearRight"):setInventoryItem(nil)
	elseif part:getId() == "LightFloodlightLeft" then
		vehicle:getPartById("HeadlightLeft"):setInventoryItem(nil)
	elseif part:getId() == "LightFloodlightRight" then
		vehicle:getPartById("HeadlightRight"):setInventoryItem(nil) 
	end
    vehicle:transmitPartItem(part)
end

--***********************************************************
--**                                                       **
--**                    Battery Heater                     **
--**                                                       **
--***********************************************************

function CommonTemplates.Create.BatteryHeater(vehicle, part)
	-- print("CommonTemplates.Create.BatteryHeater")
	CommonTemplates.createActivePart(part)
	part:setLightActive(false)
end

function CommonTemplates.Use.BatteryHeater(vehicle, on, temp)
	local part = vehicle:getPartById("BatteryHeater")
	if on then
		vehicle:getEmitter():playSound("ToggleStove")
		part:setLightActive(true)
		part:getModData().active = on;
		part:getModData().temperature = temp;
		vehicle:transmitPartModData(part)
	else
		vehicle:getEmitter():playSound("ToggleStove")
		-- part:setLightActive(false)
		part:getModData().active = on;
		part:getModData().temperature = 0;
		vehicle:transmitPartModData(part)
	end
end

function CommonTemplates.Update.BatteryHeater(vehicle, part, elapsedMinutes)
	-- print("CommonTemplates.Update.BatteryHeater")
	if not Vehicles.elaspedMinutesForHeater[vehicle:getId()] then
		Vehicles.elaspedMinutesForHeater[vehicle:getId()] = 0;
	end
	local pc = vehicle:getPartById("PassengerCompartment")
	local battery = vehicle:getPartById("Battery")
	if not pc or not battery then return end
	local pcData = pc:getModData()
	if not tonumber(pcData.temperature) then
		pcData.temperature = 0.0
	end
	local partData = part:getModData()
	if not tonumber(partData.temperature) then
		partData.temperature = 0
	end
	
	if not battery:getInventoryItem() or 
			battery:getInventoryItem():getUsedDelta() < 0.01 then
		part:getModData().active = false;
		vehicle:transmitPartModData(part);
		-- part:setLightActive(false)
		return
	end
	-- print(pcData.temperature)
	local tempInc = 2
	local previousTemp = pcData.temperature;
	
	if partData.active then
		VehicleUtils.chargeBattery(vehicle, -0.000035 * elapsedMinutes)
	else
		tempInc = 4
		if pcData.temperature == 0 then
			part:setLightActive(false)
		end
	end
	
	if ((partData.temperature > 0 and pcData.temperature <= partData.temperature) or (partData.temperature < 0 and pcData.temperature >= partData.temperature)) then
		if partData.temperature > 0 then
			pcData.temperature = math.min(pcData.temperature + tempInc * elapsedMinutes, partData.temperature)
		else
			pcData.temperature = math.max(pcData.temperature - tempInc * elapsedMinutes, partData.temperature)
		end
		if partData.temperature > 0 and pcData.temperature > partData.temperature then
			pcData.temperature = partData.temperature
		end
		if partData.temperature < 0 and pcData.temperature < partData.temperature then
			pcData.temperature = partData.temperature
		end
	else
		if pcData.temperature > 0 then
			pcData.temperature = math.max(pcData.temperature - tempInc * elapsedMinutes, 0)
		else
			pcData.temperature = math.min(pcData.temperature + tempInc * elapsedMinutes, 0)
		end
	end
	

	
	Vehicles.elaspedMinutesForHeater[vehicle:getId()] = Vehicles.elaspedMinutesForHeater[vehicle:getId()] + elapsedMinutes;
	if isServer() and VehicleUtils.compareFloats(previousTemp, pcData.temperature, 2) and Vehicles.elaspedMinutesForHeater[vehicle:getId()] > 2 then
		Vehicles.elaspedMinutesForHeater[vehicle:getId()] = 0;
		vehicle:transmitPartModData(pc);
	end
end

--***********************************************************
--**                                                       **
--**                           TV                          **
--**                                                       **
--***********************************************************
function CommonTemplates.Create.TV(vehicle, part)
	local deviceData = part:createSignalDevice()
	local invItem = VehicleUtils.createPartInventoryItem(part);

	local text2 = invItem:getType()

	deviceData:setIsTwoWay( invItem:getDeviceData():getIsTwoWay() )
	deviceData:setTransmitRange( invItem:getDeviceData():getTransmitRange() )
	deviceData:setMicRange( invItem:getDeviceData():getMicRange() )
	deviceData:setBaseVolumeRange( invItem:getDeviceData():getBaseVolumeRange() )
	deviceData:setIsPortable(false)
	deviceData:setIsTelevision( invItem:getDeviceData():getIsTelevision() )
	deviceData:setMinChannelRange( invItem:getDeviceData():getMinChannelRange() )
	deviceData:setMaxChannelRange( invItem:getDeviceData():getMaxChannelRange() )
	deviceData:setIsBatteryPowered(false)
	deviceData:setIsHighTier(false)
	deviceData:setUseDelta(0.007)
	deviceData:generatePresets()
	deviceData:setRandomChannel()
end

--***********************************************************
--**                                                       **
--**                     BatteryCharger                    **
--**                                                       **
--***********************************************************

function CommonTemplates.Create.BatteryCharger(trailer, part)
	local item = VehicleUtils.createPartInventoryItem(part);
	part:setInventoryItem(nil)
    trailer:transmitPartItem(part)
end

function CommonTemplates.Update.BatteryCharger(trailer, part, elapsedMinutes)
	-- print("CommonTemplates.Update.BatteryCharger")
	if part:getInventoryItem() then
		local chargeOld = part:getInventoryItem():getUsedDelta()
		-- print(chargeOld)
		local charge = chargeOld
		-- Running the engine charges the battery
		if elapsedMinutes > 0 and trailer:isEngineRunning() then
			charge = math.min(charge + elapsedMinutes * 0.001, 1.0)
		end
		if charge ~= chargeOld then
			part:getInventoryItem():setUsedDelta(charge)
			if VehicleUtils.compareFloats(chargeOld, charge, 2) then
				trailer:transmitPartUsedDelta(part)
			end
		end
	end
end



--***********************************************************
--**                                                       **
--**                        Another                        **
--**                                                       **
--***********************************************************

function CommonTemplates.ContainerAccess.ContainerByName(transport, part, playerObj)
	if not part:getInventoryItem() then return false; end
	if playerObj:getVehicle() == transport then
		local script = transport:getScript()
		local seat = transport:getSeat(playerObj)
		local seatname = script:getPassenger(seat):getId()
		if string.match(part:getId(), seatname) then return true end
	else
		return false
	end
end

function CommonTemplates.Create.Counter(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("counter")
	end
end

function CommonTemplates.Create.Shelve(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("shelves")
	end
end

function CommonTemplates.Create.Drawer(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("sidetable")
	end
end

function CommonTemplates.Create.Cupboard(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("wardrobe")
	end
end

function CommonTemplates.Create.Medicine(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("medicine")
	end
end

function CommonTemplates.Create.SeatBoxWooden(vehicle, part)
	local invItem = VehicleUtils.createPartInventoryItem(part);
	if part:getInventoryItem() and part:getItemContainer() then
		part:getItemContainer():setType("seatboxwooden")
	end
end




