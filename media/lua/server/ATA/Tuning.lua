-- print("Autotsar tunning load start")

local function lua_split (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

Tuning = {}
TuningUtils = {}
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

function TuningUtils.createPartInventoryItemById(part, id)
	if not part:getItemType() or part:getItemType():isEmpty() then return nil end
	local item;
	if not part:getInventoryItem() then
		local v = part:getVehicle();
		local itemType = nil
		-- print("id : ", id)
		-- print("part:getItemType():size() : ", part:getItemType():size())
		if id <= part:getItemType():size() then
			itemType = part:getItemType():get(id-1)
		end
		if not itemType then
			local chosenKey = nil
			for i=0, part:getItemType():size() - 1 do
				if ZombRand(100) > (100 - (100/part:getItemType():size())) or i == part:getItemType():size() - 1 then
					itemType = part:getItemType():get(i);
					v:getChoosenParts():put(chosenKey, itemType);
					break;
				end
			end
		end
		item = InventoryItemFactory.CreateItem(itemType);
		local conditionMultiply = 100/item:getConditionMax();
		if part:getContainerCapacity() and part:getContainerCapacity() > 0 then
			item:setMaxCapacity(part:getContainerCapacity());
		end
		item:setConditionMax(item:getConditionMax()*conditionMultiply);
		item:setCondition(item:getCondition()*conditionMultiply);
		part:setRandomCondition(item);
		part:setInventoryItem(item)
	end
	return part:getInventoryItem()
end


function Tuning.Create.NotInstallDefault(vehicle, part)
	-- print("Tuning.Create.NotInstallDefault")
	part:setInventoryItem(nil)
	part:setModelVisible("Default", false)
end

function Tuning.Create.DefaultModel(vehicle, part)
	-- print("Tuning.Create.DefaultModel")
	local item = VehicleUtils.createPartInventoryItem(part)
	if part:getInventoryItem() then
		-- print("Tuning.Create.DefaultModel: VISIBLE")
		part:setModelVisible("Default", true)
	end
end

function Tuning.Create.InstallChance15(vehicle, part)
	if ZombRand(100) < 15 then
		print("WIN!")
		Tuning.Create.DefaultModel(vehicle, part)
	else
		Tuning.Create.NotInstallDefault(vehicle, part)
	end
end

function Tuning.Create.InstallChance30(vehicle, part)
	if ZombRand(100) < 30 then
		Tuning.Create.DefaultModel(vehicle, part)
	else
		Tuning.Create.NotInstallDefault(vehicle, part)
	end
end

function Tuning.Create.InstallChance45(vehicle, part)
	if ZombRand(100) < 45 then
		Tuning.Create.DefaultModel(vehicle, part)
	else
		Tuning.Create.NotInstallDefault(vehicle, part)
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

function Tuning.InstallTest.multiRequire(vehicle, part, chr)
	if ISVehicleMechanics.cheat then return true; end
	local keyvalues = part:getTable("install")
	if not keyvalues then return false end
	if part:getInventoryItem() then return false end
	if not part:getItemType() or part:getItemType():isEmpty() then return false end
	local typeToItem = VehicleUtils.getItems(chr:getPlayerNum())
	if keyvalues.requireInstalled then
		local split = keyvalues.requireInstalled:split(";");
		for i,v in ipairs(split) do
			if not vehicle:getPartById(v) or not vehicle:getPartById(v):getInventoryItem() then return false; end
		end
	end
	if keyvalues.requireUninstalled then
		local split = keyvalues.requireUninstalled:split(";");
		for i,v in ipairs(split) do
			if vehicle:getPartById(v) and vehicle:getPartById(v):getInventoryItem() then return false; end
		end
	end
	if not VehicleUtils.testProfession(chr, keyvalues.professions) then return false end
	-- allow all perk, but calculate success/failure risk
--	if not VehicleUtils.testPerks(chr, keyvalues.skills) then return false end
	if not VehicleUtils.testRecipes(chr, keyvalues.recipes) then return false end
	if not VehicleUtils.testTraits(chr, keyvalues.traits) then return false end
	if not VehicleUtils.testItems(chr, keyvalues.items, typeToItem) then return false end
	-- if doing mechanics on this part require key but player doesn't have it, we'll check that door or windows aren't unlocked also
	if VehicleUtils.RequiredKeyNotFound(part, chr) then
		return false;
	end
	return true
end

function Tuning.UninstallTest.multiRequire(vehicle, part, chr)
	if ISVehicleMechanics.cheat then return true; end
	local keyvalues = part:getTable("uninstall")
	if not keyvalues then return false end
	if not part:getInventoryItem() then return false end
	if not part:getItemType() or part:getItemType():isEmpty() then return false end
	local typeToItem = VehicleUtils.getItems(chr:getPlayerNum())
	if keyvalues.requireInstalled then
		local split = keyvalues.requireInstalled:split(";");
		for i,v in ipairs(split) do
			if not vehicle:getPartById(v) or not vehicle:getPartById(v):getInventoryItem() then return false; end
		end
	end
	if keyvalues.requireUninstalled then
		local split = keyvalues.requireUninstalled:split(";");
		for i,v in ipairs(split) do
			if vehicle:getPartById(v) and vehicle:getPartById(v):getInventoryItem() then return false; end
		end
	end
	if not VehicleUtils.testProfession(chr, keyvalues.professions) then return false end
	-- allow all perk, but calculate success/failure risk
--	if not VehicleUtils.testPerks(chr, keyvalues.skills) then return false end
	if not VehicleUtils.testRecipes(chr, keyvalues.recipes) then return false end
	if not VehicleUtils.testTraits(chr, keyvalues.traits) then return false end
	if not VehicleUtils.testItems(chr, keyvalues.items, typeToItem) then return false end
	if keyvalues.requireEmpty and round(part:getContainerContentAmount(), 3) > 0 then return false end
	local seatNumber = part:getContainerSeatNumber()
	local seatOccupied = (seatNumber ~= -1) and vehicle:isSeatOccupied(seatNumber)
	if keyvalues.requireEmpty and seatOccupied then return false end
	-- if doing mechanics on this part require key but player doesn't have it, we'll check that door or windows aren't unlocked also
	if VehicleUtils.RequiredKeyNotFound(part, chr) then
		return false
	end
	return true
end

--***********************************************************
--**                                                       **
--**                		Roof Tent  		  	           **
--**                                                       **
--***********************************************************

function Tuning.Create.RoofTent(vehicle, part)
	Tuning.Create.NotInstallDefault(vehicle, part)
	part:setModelVisible("Close", false)
	part:setModelVisible("Open", false)
	part:getModData()["atatuning"] = {}
	part:getModData()["atatuning"].status = "close"
end

function Tuning.Init.RoofTent(vehicle, part)
	-- print("Tuning.Init.DefaultModel")
	if part:getInventoryItem() then
		-- print("Tuning.Init.DefaultModel: VISIBLE")
		part:setModelVisible("Default", true)
		if part:getModData()["atatuning"].status == "open" then
			part:setModelVisible("Close", false)
			part:setModelVisible("Open", true)
		else
			part:setModelVisible("Close", true)
			part:setModelVisible("Open", false)
		end
	end
end

function Tuning.InstallComplete.RoofTent(vehicle, part)
	local item = part:getInventoryItem()
	if not item then return end
	part:setModelVisible("Default", true)
	part:setModelVisible("Close", true)
	part:setModelVisible("Open", false)
	part:getModData()["atatuning"].status = "close"
	vehicle:doDamageOverlay()
end

function Tuning.UninstallComplete.RoofTent(vehicle, part, item)
	if not item then return end
	part:setModelVisible("Default", false)
	part:setModelVisible("Close", false)
	part:setModelVisible("Open", false)
	part:getModData()["atatuning"] = {}
	vehicle:doDamageOverlay()
end

function Tuning.Use.RoofTent(vehicle, part, open)
	if open then
		part:setModelVisible("Close", false)
		part:setModelVisible("Open", true)
		part:getModData()["atatuning"].status = "open"
		VehicleUtils.createPartInventoryItem(vehicle:getPartById("SeatMiddleLeft"))
		VehicleUtils.createPartInventoryItem(vehicle:getPartById("SeatMiddleRight"))
	else
		part:setModelVisible("Close", true)
		part:setModelVisible("Open", false)
		vehicle:getPartById("SeatMiddleLeft"):setInventoryItem(nil)
		vehicle:getPartById("SeatMiddleRight"):setInventoryItem(nil)
		part:getModData()["atatuning"].status = "close"
	end
end

--***********************************************************
--**                                                       **
--**                	 Common bamper  	  	           **
--**                                                       **
--***********************************************************

function Tuning.CommonBamper(vehicle, part, item)
	print("Tuning.CommonBamper")
	if item then
		print("item +")
		print(item:getModData()["ataModel"])
		print(item:getModData()["ataAnotherModel"])
		if item:getModData()["ataModel"] then
			for i, anotherModel in ipairs(item:getModData()["ataAnotherModel"]:split(";")) do
				part:setModelVisible(anotherModel, false)
			end
			part:setModelVisible(item:getModData()["ataModel"], true)
		end
	else
		if item:getModData()["ataModel"] then
			for i, anotherModel in ipairs(item:getModData()["ataAnotherModel"]:split(";")) do
				part:setModelVisible(anotherModel, false)
			end
			part:setModelVisible(item:getModData()["ataModel"], false)
		end
	end
end

function Tuning.Create.CommonBamper(vehicle, part)
	local item = VehicleUtils.createPartInventoryItem(part)
	Tuning.CommonBamper(vehicle, part, item)
	vehicle:doDamageOverlay()
end

function Tuning.Create.CommonBamperNull(vehicle, part)
	part:setInventoryItem(nil)
	Tuning.CommonBamper(vehicle, part, nil)
	vehicle:doDamageOverlay()
end

function Tuning.Create.CommonBamperFirstTwo(vehicle, part)
	local item = nil
	if ZombRand(100) < 30 then
		item = TuningUtils.createPartInventoryItemById(part, 2)
	else
		item = TuningUtils.createPartInventoryItemById(part, 1)
	end
	Tuning.CommonBamper(vehicle, part, item)
	vehicle:doDamageOverlay()
end

function Tuning.Init.CommonBamper(vehicle, part)
	print(" Tuning.Init.BusBullbar")
	Tuning.CommonBamper(vehicle, part, part:getInventoryItem())
	vehicle:doDamageOverlay()
end

function Tuning.InstallComplete.CommonBamper(vehicle, part)
-- print(" Tuning.InstallComplete.BusBullbar")
	Tuning.CommonBamper(vehicle, part, part:getInventoryItem())
	vehicle:doDamageOverlay()
	Tuning.InstallComplete.CommonProtection(vehicle, part)
end

function Tuning.UninstallComplete.CommonBamper(vehicle, part, item)
-- print(" Tuning.UninstallComplete.BusBullbar")
	Tuning.CommonBamper(vehicle, part)
	vehicle:doDamageOverlay()
	Tuning.UninstallComplete.CommonProtection(vehicle, part, item)
end

--***********************************************************
--**                                                       **
--**                 	Common Protection  	               **
--**                                                       **
--***********************************************************

function Tuning.UninstallComplete.Door(vehicle, part, item)
	Vehicles.UninstallComplete.Door(vehicle, part, item)
	if not part:getModData().atatuning or not part:getModData().atatuning.health then return end
	item:setCondition(part:getModData().atatuning.health)
	part:getModData().atatuning.health = nil
end

function Tuning.UninstallComplete.Window(vehicle, part, item)
	Vehicles.UninstallComplete.Default(vehicle, part, item)
	if not part:getModData().atatuning or not part:getModData().atatuning.health then return end
	item:setCondition(part:getModData().atatuning.health)
	part:getModData().atatuning.health = nil
end

function Tuning.InstallComplete.CommonProtection(vehicle, part)
-- print("Tuning.InstallComplete.Protection")
	local item = part:getInventoryItem();
	if not item then return; end
	Tuning.InstallComplete.DefaultModel(vehicle, part)
	if not vehicle:getModData().atatuning then
		vehicle:getModData().atatuning = {}
	end
	if part:getParent() then
		local savePart = part:getParent()
		if savePart and savePart:getInventoryItem() then
			if not savePart:getModData().atatuning then
				savePart:getModData().atatuning = {}
			end
			savePart:getModData().atatuning.health = savePart:getCondition()
			savePart:setCondition(100)
		end
	elseif item:getModData()["ataProtection"] then
		local partNames = item:getModData()["ataProtection"]:split(";");
		for k, partName in ipairs(partNames) do 
			local savePart = vehicle:getPartById(partName)
			if savePart and savePart:getInventoryItem() then
				if not savePart:getModData().atatuning then
					savePart:getModData().atatuning = {}
				end
				savePart:getModData().atatuning.health = savePart:getCondition()
				savePart:setCondition(100)
			end
		end
	end
end

function Tuning.UninstallComplete.CommonProtection(vehicle, part, item)
-- print("Tuning.UninstallComplete.Protection")
	if not item then return end
	Tuning.UninstallComplete.DefaultModel(vehicle, part, item)
	if not vehicle:getModData().atatuning then return end
	if part:getParent() then
		local savePart = part:getParent()
		if savePart then
			if not savePart:getModData().atatuning or not savePart:getModData().atatuning.health then return end
			savePart:setCondition(savePart:getModData().atatuning.health)
			savePart:getModData().atatuning.health = nil
		end
	elseif item:getModData()["ataProtection"] then
		local partNames = item:getModData()["ataProtection"]:split(";");
		for k, partName in ipairs(partNames) do 
			-- print(vehicle:getModData().atatuning[partName].health)
			local savePart = vehicle:getPartById(partName)
			if savePart then
				if not savePart:getModData().atatuning or not savePart:getModData().atatuning.health then return end
				savePart:setCondition(savePart:getModData().atatuning.health)
				savePart:getModData().atatuning.health = nil
			end
		end
	end
end

function Tuning.Update.CommonProtection(vehicle, part, elapsedMinutes)
	-- print("Tuning.Update.Protection")
	local item = part:getInventoryItem();
	if not item then return; end

	local areaCenter = vehicle:getAreaCenter(part:getArea())
	if not areaCenter then return nil end
	local square = getCell():getGridSquare(areaCenter:getX(), areaCenter:getY(), vehicle:getZ())
	if part:getCondition() == 0 then
		part:setInventoryItem(nil);
		square:AddWorldInventoryItem(item, 0.5, 0.5, 0)
		Tuning.UninstallComplete.Protection(vehicle, part, item)
	else
		local redoCond = false
		if part:getParent() then
			local savePart = part:getParent()
			if savePart:getInventoryItem() then
				if not savePart:getModData().atatuning then
					savePart:getModData().atatuning = {}
				end
				if not savePart:getModData().atatuning.health then
					savePart:getModData().atatuning.health = savePart:getCondition()
				end
				if (savePart:getCondition() < 80) then
					redoCond = true
					savePart:setCondition(100)
				end
				if string.match(savePart:getId(), "Tire") and savePart:getContainerContentAmount() < 10 then
					savePart:setContainerContentAmount(20, false, true);
				end
			end
		elseif item:getModData()["ataProtection"] then
			local partNames = item:getModData()["ataProtection"]:split(";");
			for k, partName in ipairs(partNames) do 
				local savePart = vehicle:getPartById(partName)
				if savePart:getInventoryItem() then
					if not savePart:getModData().atatuning then
						savePart:getModData().atatuning = {}
					end
					if not savePart:getModData().atatuning.health then
						savePart:getModData().atatuning.health = savePart:getCondition()
					end
					if (savePart:getCondition() < 80) then
						redoCond = true
						savePart:setCondition(100)
					end
					if string.match(savePart:getId(), "Tire") and savePart:getContainerContentAmount() < 10 then
						savePart:setContainerContentAmount(20, false, true);
					end
				end
			end
		end
		if redoCond then
			part:setCondition(part:getCondition()-1)
		end
	end
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
--**                	ATAInteractiveTrunk	               **
--**                                                       **
--***********************************************************

function Tuning.ATAInteractiveTrunk(part)
	local interactiveItemsTable = part:getTable("interactiveItems")
	if part:getInventoryItem() then
		part:setModelVisible(interactiveItemsTable.Base, true)
		if part:getItemContainer():getItems():isEmpty() then
			for itemName, k in pairs(interactiveItemsTable) do
				if type(k) == "table" then
					for i, modelName in ipairs(k) do
						part:setModelVisible(modelName, false)
					end
				end
			end
		else
			for i, modelName in pairs(interactiveItemsTable.fullness) do
				if i <= (math.floor((part:getItemContainer():getContentsWeight() / part:getItemContainer():getCapacity()) / (1/#interactiveItemsTable.fullness)) + 1) then
					part:setModelVisible(modelName, true)
				else
					part:setModelVisible(modelName, false)
				end
			end
			for itemName, k in pairs(interactiveItemsTable) do
				if not (itemName == "fullness") and type(k) == "table" then
					local itemcount = 0
					if string.match(itemName, "#") then
						for i, itemNameNew in ipairs(itemName:split("#")) do
							itemcount = itemcount + part:getItemContainer():getCountType(itemNameNew)
						end
					else
						itemcount = part:getItemContainer():getCountType(itemName)
					end
					if itemcount > 0 then
						if itemcount > #k then
							itemcount = #k
						end
						for _id, modelName in ipairs(k) do
							if _id <= itemcount then
								part:setModelVisible(modelName, true)
							else
								part:setModelVisible(modelName, false)
							end
						end
					else
						for _id, modelName in ipairs(k) do
							part:setModelVisible(modelName, false)
						end
					end
				end
			end
		end
	else
		part:setModelVisible(interactiveItemsTable.fullness[1], true)
		for itemName, k in pairs(interactiveItemsTable) do
			if type(k) == "table" then
				for i, modelName in ipairs(k) do
					part:setModelVisible(modelName, false)
				end
			end
		end
	end
end


function Tuning.ContainerAccess.ATAInteractiveTrunk(vehicle, part, chr)
	Tuning.ATAInteractiveTrunk(part)
	if chr:getVehicle() then return false end
	if not vehicle:isInArea(part:getArea(), chr) then return false end
	return true
end

function Tuning.Create.ATAInteractiveTrunk(vehicle, part)
	part:setInventoryItem(nil)
	Tuning.ATAInteractiveTrunk(part)
end

function Tuning.Init.ATAInteractiveTrunk(vehicle, part)
	Tuning.ATAInteractiveTrunk(part)
end

function Tuning.InstallComplete.ATAInteractiveTrunk(vehicle, part)
	local item = part:getInventoryItem()
	if not item then return end
	Tuning.ATAInteractiveTrunk(part)
end

function Tuning.UninstallComplete.ATAInteractiveTrunk(vehicle, part, item)
	if not item then return end
	Tuning.ATAInteractiveTrunk(part)
	vehicle:doDamageOverlay()
end

--***********************************************************
--**                                                       **
--**                		Protection  	               **
--**                                                       **
--***********************************************************

function Tuning.InstallComplete.Protection(vehicle, part)
-- print("Tuning.InstallComplete.Protection")
	local invItem = part:getInventoryItem();
	if not invItem then return; end
	Tuning.InstallComplete.DefaultModel(vehicle, part)
	if not vehicle:getModData().tuning then
		vehicle:getModData().tuning = {}
	end
	local partNames = part:getTable("install");
	for k, partName in ipairs(partNames) do 
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
	local partNames = part:getTable("install");
	for k, partName in ipairs(partNames) do 
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
	-- print("Tuning.Update.Protection")
	local invItem = part:getInventoryItem();
	if not invItem then return; end
	
	local areaCenter = vehicle:getAreaCenter(part:getArea())
	if not areaCenter then return nil end
	local square = getCell():getGridSquare(areaCenter:getX(), areaCenter:getY(), vehicle:getZ())
	if part:getCondition() == 0 then
		part:setInventoryItem(nil);
		square:AddWorldInventoryItem(invItem, 0.5, 0.5, 0)
		Tuning.UninstallComplete.Protection(vehicle, part, invItem)
	else
		local redoCond = false
		local partNames = part:getTable("install");
		for k, partName in ipairs(partNames) do 
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
			elseif (savePart:getCondition() < 80) then
				redoCond = true
				savePart:setCondition(100)
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


--***********************************************************
--**                                                       **
--**                		Lights 		 	               **
--**                                                       **
--***********************************************************

function Tuning.Create.ATALight(vehicle, part)
	-- local item = VehicleUtils.createPartInventoryItem(part)
	-- xOffset,yOffset,distance,intensity,dot,focusing
	-- NOTE: distance,intensity,focusing values are ignored, instead they are
	-- set based on part condition.
	Tuning.Create.NotInstallDefault(vehicle, part)
	if part:getId() == "ATARoofLampLeft" then
		part:createSpotLight(4.5, -1, 0.1, 0.1, 1.4, 200) -- (2, -0.8, 0.1, 0.1, 2, 200)
	elseif part:getId() == "ATARoofLampRight" then
		part:createSpotLight(-4.5, -1, 0.1, 0.1, 1.4, 200)
	elseif part:getId() == "ATARoofLampRear" then
		part:createSpotLight(0, -4.5, 0.1, 0.1, 1.35, 100)	
	elseif part:getId() == "ATARoofLampFront" then
		part:createSpotLight(0, 2.0, 8.0+ZombRand(16.0), 0.75, 0.96, ZombRand(200))
	end
end


-- print("Autotsar tunning loaded")