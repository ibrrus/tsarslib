-- print("Autotsar tunning load start")

Tuning = {}
Tuning.CheckEngine = {}
Tuning.CheckOperate = {}
Tuning.ContainerAccess = {}
Tuning.Create = {}
Tuning.Init = {}
Tuning.InstallComplete = {}
Tuning.InstallTest = {}
Tuning.UninstallComplete = {}
Tuning.UninstallTest = {}
Tuning.Update = {}
Tuning.Use = {}

function Tuning.Create.NotInstallDefault(vehicle, part)
	-- print("Tuning.Create.NotInstallDefault")
	-- local invItem = VehicleUtils.createPartInventoryItem(part)
	part:setInventoryItem(nil)
	part:setModelVisible("Default", false)
	-- vehicle:transmitPartItem(part);
end

function Tuning.Create.DefaultModel(vehicle, part)
	-- print("Tuning.Create.DefaultModel")
	local invItem = VehicleUtils.createPartInventoryItem(part)
	if part:getInventoryItem() then
		-- print("Tuning.Create.DefaultModel: VISIBLE")
		part:setModelVisible("Default", true)
	end
end

function Tuning.Init.DefaultModel(vehicle, part)
	-- print("Tuning.Init.DefaultModel")
	if part:getInventoryItem() then
		-- print("Tuning.Init.DefaultModel: VISIBLE")
		part:setModelVisible("Default", true)
	end
end

function Tuning.InstallComplete.DefaultModel(vehicle, part)
	local item = part:getInventoryItem()
	if not item then return end
	part:setModelVisible("Default", true)
	vehicle:doDamageOverlay()
end

function Tuning.UninstallComplete.DefaultModel(vehicle, part, item)
	if not item then return end
	part:setModelVisible("Default", false)
	vehicle:doDamageOverlay()
end


--***********************************************************
--**                                                       **
--**                		BusBullbar  	               **
--**                                                       **
--***********************************************************

function Tuning.BusBullbar(vehicle, part)
	-- print(getPlayer():getVehicle():getPartById("ATABullbar"):setModelVisible("Bullbar2", false))
	-- print(part:getId())
	part = vehicle:getPartById("ATABullbar")
	local item = part:getInventoryItem()
	if item then
		-- print(item:getType())
		if item:getType() == "ATA_Bus_Kengur_1_Item" then
			part:setModelVisible("Bullbar1", true)
			part:setModelVisible("Bullbar2", false)
			part:setModelVisible("Bullbar3", false)
		elseif item:getType() == "ATA_Bus_Kengur_2_Item" then
			part:setModelVisible("Bullbar1", false)
			part:setModelVisible("Bullbar2", true)
			part:setModelVisible("Bullbar3", false)
		else
			part:setModelVisible("Bullbar1", false)
			part:setModelVisible("Bullbar2", false)
			part:setModelVisible("Bullbar3", true)
		end
	else
		-- print("not visible")
		part:setModelVisible("Bullbar1", false)
		part:setModelVisible("Bullbar2", false)
		part:setModelVisible("Bullbar3", false)
	end
end

function Tuning.Create.BusBullbar(vehicle, part)
	-- print("Tuning.Create.BusBullbar")
	part:setInventoryItem(nil)
	Tuning.BusBullbar(vehicle, part, nil)
	vehicle:doDamageOverlay()
end

function Tuning.Init.BusBullbar(vehicle, part)
	-- print(" Tuning.Init.BusBullbar")
	Tuning.BusBullbar(vehicle, part)
	vehicle:doDamageOverlay()
end

function Tuning.InstallComplete.BusBullbar(vehicle, part)
-- print(" Tuning.InstallComplete.BusBullbar")
	Tuning.BusBullbar(vehicle, part)
	vehicle:doDamageOverlay()
	Tuning.InstallComplete.Protection(vehicle, part)
end

function Tuning.UninstallComplete.BusBullbar(vehicle, part, item)
-- print(" Tuning.UninstallComplete.BusBullbar")
	Tuning.BusBullbar(vehicle, part)
	vehicle:doDamageOverlay()
	Tuning.UninstallComplete.Protection(vehicle, part, item)
end


--***********************************************************
--**                                                       **
--**                		BusRoofRack  	               **
--**                                                       **
--***********************************************************

function Tuning.BusRoofRack(part)
	if part:getInventoryItem() then
		part:setModelVisible("Fench", true)
		if part:getItemContainer():getItems():isEmpty() then
			part:setModelVisible("Barrel1", false)
			part:setModelVisible("Barrel2", false)
			part:setModelVisible("GasCan1", false)
			part:setModelVisible("GasCan2", false)
			part:setModelVisible("Pipes", false)
			part:setModelVisible("Pipes1", false)
			part:setModelVisible("Pipes2", false)
			part:setModelVisible("Tent", false)
			part:setModelVisible("TentBox", false)
		else
			part:setModelVisible("TentBox", true)
			if part:getItemContainer():containsType("Base.Tarp") then
				part:setModelVisible("Tent", true)
			else
				part:setModelVisible("Tent", false)
			end
			if (part:getItemContainer():getCountType("Base.Pipe") + 
					part:getItemContainer():getCountType("Base.MetalPipe")  + 
					part:getItemContainer():getCountType("Base.LeadPipe")) > 0 then
				if (part:getItemContainer():getCountType("Base.Pipe") + 
						part:getItemContainer():getCountType("Base.MetalPipe")  + 
						part:getItemContainer():getCountType("Base.LeadPipe")) > 2 then
					part:setModelVisible("Pipes", true)
					part:setModelVisible("Pipes1", true)
					part:setModelVisible("Pipes2", true)
				elseif (part:getItemContainer():getCountType("Base.Pipe") + 
						part:getItemContainer():getCountType("Base.MetalPipe")  + 
						part:getItemContainer():getCountType("Base.LeadPipe")) == 2 then	
					part:setModelVisible("Pipes", true)
					part:setModelVisible("Pipes1", true)
					part:setModelVisible("Pipes2", false)
				else
					part:setModelVisible("Pipes", true)
					part:setModelVisible("Pipes1", false)
					part:setModelVisible("Pipes2", false)
				end
			else
				part:setModelVisible("Pipes", false)
				part:setModelVisible("Pipes1", false)
				part:setModelVisible("Pipes2", false)
			end
			if part:getItemContainer():getCountType("Base.MetalDrum") == 1 then
				part:setModelVisible("Barrel1", true)
				part:setModelVisible("Barrel2", false)
			elseif part:getItemContainer():getCountType("Base.MetalDrum") > 1 then
				part:setModelVisible("Barrel1", true)
				part:setModelVisible("Barrel2", true)
			else
				part:setModelVisible("Barrel1", false)
				part:setModelVisible("Barrel2", false)
			end
			if (part:getItemContainer():getCountType("Base.PetrolCan") +  
					part:getItemContainer():getCountType("Base.EmptyPetrolCan")) == 1 then
				part:setModelVisible("GasCan1", true)
				part:setModelVisible("GasCan2", false)
			elseif (part:getItemContainer():getCountType("Base.PetrolCan") +  
					part:getItemContainer():getCountType("Base.EmptyPetrolCan")) > 1 then
				part:setModelVisible("GasCan1", true)
				part:setModelVisible("GasCan2", true)
			else
				part:setModelVisible("GasCan1", false)
				part:setModelVisible("GasCan2", false)
			end
		end
	else
		part:setModelVisible("Barrel1", false)
		part:setModelVisible("Barrel2", false)
		part:setModelVisible("Fench", false)
		part:setModelVisible("GasCan1", false)
		part:setModelVisible("GasCan2", false)
		part:setModelVisible("Pipes", false)
		part:setModelVisible("Pipes1", false)
		part:setModelVisible("Pipes2", false)
		part:setModelVisible("Tent", false)
		part:setModelVisible("TentBox", false)
	end
end


function Tuning.ContainerAccess.BusRoofRack(vehicle, part, chr)
	Tuning.BusRoofRack(part)
	if chr:getVehicle() then return false end
	if not vehicle:isInArea(part:getArea(), chr) then return false end
	return true
end

function Tuning.Create.BusRoofRack(vehicle, part)
	part:setInventoryItem(nil)
	Tuning.BusRoofRack(part)
end

function Tuning.Init.BusRoofRack(vehicle, part)
	Tuning.BusRoofRack(part)
end

function Tuning.InstallComplete.BusRoofRack(vehicle, part)
	local item = part:getInventoryItem()
	if not item then return end
	Tuning.BusRoofRack(part)
end

function Tuning.UninstallComplete.BusRoofRack(vehicle, part, item)
	if not item then return end
	Tuning.BusRoofRack(part)
	vehicle:doDamageOverlay()
end

--***********************************************************
--**                                                       **
--**                		Protection  	               **
--**                                                       **
--***********************************************************


local ProtectionTable = {
	DoorProtection = {"WindowFrontRight",},
	WindowsFrontProtection = {"Windshield",},
	WindowsRightProtection = {"WindowRearRight","WindowMiddleRight"},
	WindowsLeftFullProtection = {"WindowRearLeft","WindowMiddleLeft","WindowFrontLeft",},
	WindowsLeftLiteProtection = {"WindowFrontLeft",},
	ATABullbar = {"EngineDoor","Engine","GasTank","TireFrontLeft","TireFrontRight"},
	WheelsProtection = {"TireRearLeft","TireRearRight"}
}

function Tuning.InstallComplete.Protection(vehicle, part)
-- print("Tuning.InstallComplete.Protection")
	local invItem = part:getInventoryItem();
	if not invItem then return; end
	Tuning.InstallComplete.DefaultModel(vehicle, part)
	if not vehicle:getModData().tuning then
		vehicle:getModData().tuning = {}
	end
	for k, partName in pairs(ProtectionTable[part:getId()]) do 
		local savePart = vehicle:getPartById(partName)
		if not vehicle:getModData().tuning[partName] then
			vehicle:getModData().tuning[partName] = {}
		end
		vehicle:getModData().tuning[partName].health = savePart:getCondition()
		savePart:setCondition(100)
		-- print("CONDITION SAVED")
	end
end

function Tuning.UninstallComplete.Protection(vehicle, part, item)
-- print("Tuning.UninstallComplete.Protection")
	if not item then return end
	Tuning.UninstallComplete.DefaultModel(vehicle, part, item)
	if not vehicle:getModData().tuning then return end
	for k, partName in pairs(ProtectionTable[part:getId()]) do 
		-- print(vehicle:getModData().tuning[partName].health)
		local savePart = vehicle:getPartById(partName)
		if not vehicle:getModData().tuning[partName] then return end
		savePart:setCondition(vehicle:getModData().tuning[partName].health)
		vehicle:getModData().tuning[partName] = nil
	end
end

-- local function checkProtection (vehicle, part, savePart)
	-- if savePart:getCondition() == 0 then
		-- local areaCenter = vehicle:getAreaCenter(part:getArea())
		-- if not areaCenter then return nil end
		-- local square = getCell():getGridSquare(areaCenter:getX(), areaCenter:getY(), vehicle:getZ())
		-- part:setInventoryItem(nil);
		-- square:AddWorldInventoryItem(invItem, 0.5, 0.5, 0)
	-- elseif (savePart:getCondition() < 10) then
		-- savePart:setCondition(10)
		-- part:setCondition(part:getCondition()-1)
	-- end
-- end
function Tuning.Update.Protection(vehicle, part, elapsedMinutes)
	local invItem = part:getInventoryItem();
	if not invItem then return; end
	-- print("Tuning.Update.Protection")
	-- print(part:getId())
	local areaCenter = vehicle:getAreaCenter(part:getArea())
	if not areaCenter then return nil end
	local square = getCell():getGridSquare(areaCenter:getX(), areaCenter:getY(), vehicle:getZ())
	if part:getCondition() == 0 then
		part:setInventoryItem(nil);
		square:AddWorldInventoryItem(invItem, 0.5, 0.5, 0)
		Tuning.UninstallComplete.Protection(vehicle, part, invItem)
	else
		local redoCond = false
		for k, partName in pairs(ProtectionTable[part:getId()]) do 
			local savePart = vehicle:getPartById(partName)
			if not vehicle:getModData().tuning then
				vehicle:getModData().tuning = {}
			end
			if not vehicle:getModData().tuning[partName] then
				vehicle:getModData().tuning[partName] = {}
				vehicle:getModData().tuning[partName].health = savePart:getCondition()
			end
			if (not savePart:getInventoryItem() and not (partName == "Engine")) or savePart:getCondition() == 0 then
				redoCond = true
				VehicleUtils.createPartInventoryItem(savePart)
				savePart:setCondition(100)
				-- print(savePart:getContainerContentAmount())
				-- part:setInventoryItem(nil);
				-- part:setInventoryItem(nil);
				-- square:AddWorldInventoryItem(invItem, 0.5, 0.5, 0)
			elseif (savePart:getCondition() < 80) then
				redoCond = true
				savePart:setCondition(100)
				-- print(savePart:getContainerContentAmount())
			end
			if string.match(savePart:getId(), "Tire") and savePart:getContainerContentAmount() < 10 then
				savePart:setContainerContentAmount(20, false, true);
			end
		end
		if redoCond then
			part:setCondition(part:getCondition()-1)
		end
	end
end

-- function Tuning.Update.WindowMiddle(vehicle, part, elapsedMinutes)
	-- if part:getId() == "WindowMiddleLeft" then
		-- local rearWindow = vehicle:getPartById("WindowRearLeft")
		-- if not part:getInventoryItem() then
			-- VehicleUtils.createPartInventoryItem(part)
		-- end
		-- part:setCondition(rearWindow:getCondition())
	-- else
		-- local rearWindow = vehicle:getPartById("WindowRearRight")
		-- if not part:getInventoryItem() then
			-- VehicleUtils.createPartInventoryItem(part)
		-- end
		-- part:setCondition(rearWindow:getCondition())
	-- end
	-- if part:getCondition() == 0 then
		-- part:setInventoryItem(nil)
	-- end
-- end

-- print("Autotsar tunning loaded")