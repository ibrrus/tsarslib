-- print("Autotsar tunning load start")
if not ATATuning then ATATuning = {} end
if not ATATuningUtils then ATATuningUtils = {} end
if not ATATuning.CheckEngine then ATATuning.CheckEngine = {} end
if not ATATuning.CheckOperate then ATATuning.CheckOperate = {} end
if not ATATuning.ContainerAccess then ATATuning.ContainerAccess = {} end
if not ATATuning.Create then ATATuning.Create = {} end
if not ATATuning.Init then ATATuning.Init = {} end
if not ATATuning.InstallComplete then ATATuning.InstallComplete = {} end
if not ATATuning.InstallTest then ATATuning.InstallTest = {} end
if not ATATuning.UninstallComplete then ATATuning.UninstallComplete = {} end
if not ATATuning.UninstallTest then ATATuning.UninstallTest = {} end
if not ATATuning.Update then ATATuning.Update = {} end
if not ATATuning.Use then ATATuning.Use = {} end
--[[
	Example code in the script:
			itemType = Base.Bumper1Item;Base.Bumper2Item;Base.Bumper3Item;Base.Bumper4Item,
			table ataItemSpawnChance 
			{
				1 = 50, 
				2 = 50, 
				3 = 0, 
				4 = 0, 
			}
]]--
function ATATuningUtils.createPartInventoryItem(part)
	if part:getTable("ataSpawnChance") then
		if not part:getItemType() or part:getItemType():isEmpty() then return nil end
		local item;
		if not part:getInventoryItem() then
			if #part:getTable("ataItemSpawnChance") == part:getItemType():size() then
				local v = part:getVehicle();
				local itemType = nil
				local previousChance = 0
				local newChanceTable = {}
				for id, chance in pairs(part:getTable("ataItemSpawnChance")) do
					if tonumber(chance) > 0 then
						newChanceTable[id] = previousChance + chance
						previousChance = newChanceTable[id]
					end
				end
				if previousChance > 0 then
					local luck = ZombRand(previousChance)
					for id, checkLuck in pairs(newChanceTable) do
						if luck <= checkLuck then
							itemType = part:getItemType():get(id - 1);
							break
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
			else
				print("ATA ERROR: For part " .. part:getId() .. "the spawn table 'ataItemSpawnChance' is set incorrectly. The number of elements in the table (now " .. #part:getTable("ataItemSpawnChance") .. ") must equal the number of possible items (now " .. part:getItemType():size() .. ").")
				part:throwError()
			end
		end
		return part:getInventoryItem()
	else
		return VehicleUtils.createPartInventoryItem(part)
	end
end

function ATATuning.ContainerAccess.BlockSeat(vehicle, part, playerObj)
	return false
end

--[[

Example code in the script
			model ATAJeepBumper1
			{
				file = ATA_Jeep_Bumper_1,
			}
			model ATAJeepBumper2
			{
				file = ATA_Jeep_Bumper_2,
			}
			model ATAJeepBumper3
			{
				file = ATA_Jeep_Bumper_3,
			}
			model ATAJeepBumper4
			{
				file = ATA_Jeep_Bumper_4,
			}
			table ataModels 
			{
				ATAJeepBumper1Item = ATAJeepBumper1,
				ATAJeepBumper2Item = ATAJeepBumper2,
				ATAJeepBumper3Item = ATAJeepBumper3,
				ATAJeepBumper4Item = ATAJeepBumper4,
			}
]]--

function ATATuning.ModelByItemName(vehicle, part, item)
-- print("ATATuning.ModelByItemName")
	if not part:getItemType() or part:getItemType():isEmpty() then
		part:setModelVisible("Default", true)
		part:setModelVisible("StaticPart", true)
	else
		if part:getTable("ataModels") then
			local modelVisibleList = {}
			if item then
				part:setModelVisible("StaticPart", true)
				for itemName, oneModel in pairs(part:getTable("ataModels")) do
					if item:getType() == itemName then
						-- print("setModelVisible: ", oneModel)
						part:setModelVisible(oneModel, true)
						modelVisibleList[oneModel] = true
					else
						if not modelVisibleList[oneModel] then
							part:setModelVisible(oneModel, false)
						end
					end
				end
			else
				part:setModelVisible("StaticPart", false)
				for itemName, oneModel in pairs(part:getTable("ataModels")) do
					part:setModelVisible(oneModel, false)
				end
			end
		else
			if item then
				part:setModelVisible("Default", true)
				part:setModelVisible("StaticPart", true)
			else
				part:setModelVisible("Default", false)
				part:setModelVisible("StaticPart", false)
			end
		end
	end
end

function ATATuning.Create.DefaultModel(vehicle, part)
	local item = ATATuningUtils.createPartInventoryItem(part)
	ATATuning.ModelByItemName(vehicle, part, item)
    vehicle:transmitPartCondition(part)
	vehicle:transmitPartItem(part)
	vehicle:doDamageOverlay()
end

function ATATuning.Init.DefaultModel(vehicle, part)
	ATATuning.ModelByItemName(vehicle, part, part:getInventoryItem())
	vehicle:doDamageOverlay()
end

function ATATuning.InstallComplete.DefaultModel(vehicle, part)
-- print("ATATuning.InstallComplete.DefaultModel")
	ATATuning.ModelByItemName(vehicle, part, part:getInventoryItem())
	vehicle:doDamageOverlay()
end

function ATATuning.UninstallComplete.DefaultModel(vehicle, part, item)
-- print("ATATuning.UninstallComplete.DefaultModel")
	ATATuning.ModelByItemName(vehicle, part)
	vehicle:doDamageOverlay()
end

function ATATuning.Create.Chance0(vehicle, part)
	part:setInventoryItem(nil)
    vehicle:transmitPartItem(part)
	ATATuning.ModelByItemName(vehicle, part)
	vehicle:doDamageOverlay()
end

function ATATuning.Create.Chance5(vehicle, part)
	if ZombRand(100) <= 5 then
		ATATuning.Create.DefaultModel(vehicle, part)
	else
		ATATuning.Create.Chance0(vehicle, part)
	end
end

function ATATuning.Create.Chance15(vehicle, part)
	if ZombRand(100) <= 15 then
		ATATuning.Create.DefaultModel(vehicle, part)
	else
		ATATuning.Create.Chance0(vehicle, part)
	end
end

function ATATuning.Create.Chance30(vehicle, part)
	if ZombRand(100) <= 30 then
		ATATuning.Create.DefaultModel(vehicle, part)
	else
		ATATuning.Create.Chance0(vehicle, part)
	end
end

function ATATuning.Create.Chance45(vehicle, part)
	if ZombRand(100) <= 45 then
		ATATuning.Create.DefaultModel(vehicle, part)
	else
		ATATuning.Create.Chance0(vehicle, part)
	end
end

--***********************************************************
--**                                                       **
--**     					Wheels					       **
--**                                                       **
--***********************************************************

function ATATuning.Create.Tire(vehicle, part)
	Vehicles.Create.Tire(vehicle, part)
	ATATuning.ModelByItemName(vehicle, part, part:getInventoryItem())
end

function ATATuning.Init.Tire(vehicle, part)
	Vehicles.Init.Tire(vehicle, part)
	ATATuning.ModelByItemName(vehicle, part, part:getInventoryItem())
end

function ATATuning.InstallComplete.Tire(vehicle, part)
	Vehicles.InstallComplete.Tire(vehicle, part)
	ATATuning.ModelByItemName(vehicle, part, part:getInventoryItem())
end

function ATATuning.UninstallComplete.Tire(vehicle, part, item)
	Vehicles.UninstallComplete.Tire(vehicle, part, item)
	ATATuning.ModelByItemName(vehicle, part)
end

--***********************************************************
--**                                                       **
--**      Multi Require Install and Uninstall table	       **
--**                                                       **
--***********************************************************

function ATATuning.InstallTest.multiRequire(vehicle, part, chr)
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

function ATATuning.UninstallTest.multiRequire(vehicle, part, chr)
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

function ATATuning.Create.RoofTent(vehicle, part)
	ATATuning.Create.Chance0(vehicle, part)
	part:setModelVisible("Close", false)
	part:setModelVisible("Open", false)
	part:getModData()["atatuning"] = {}
	part:getModData()["atatuning"].status = "close"
    vehicle:transmitPartModData(part)
end

function ATATuning.ContainerAccess.RoofTent(vehicle, part, chr)
	if chr:getVehicle() == vehicle then
		local seat = vehicle:getSeat(chr)
		return seat == 2 or seat == 3;
	else
		return false
	end
end

function ATATuning.Init.RoofTent(vehicle, part)
	-- print("ATATuning.Init.DefaultModel")
	if part:getInventoryItem() then
		-- print("ATATuning.Init.DefaultModel: VISIBLE")
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

function ATATuning.InstallComplete.RoofTent(vehicle, part)
	local item = part:getInventoryItem()
	if not item then return end
	part:setModelVisible("Default", true)
	part:setModelVisible("Close", true)
	part:setModelVisible("Open", false)
	part:getModData()["atatuning"].status = "close"
    vehicle:transmitPartModData(part)
	vehicle:doDamageOverlay()
end

function ATATuning.UninstallComplete.RoofTent(vehicle, part, item)
	if not item then return end
	part:setModelVisible("Default", false)
	part:setModelVisible("Close", false)
	part:setModelVisible("Open", false)
	part:getModData()["atatuning"] = {}
    vehicle:transmitPartModData(part)
	vehicle:doDamageOverlay()
end

function ATATuning.UninstallTest.RoofTent(vehicle, part, chr)
	if ATATuning.UninstallTest.multiRequire(vehicle, part, chr) then
		return ATATuning.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleLeft"), chr) and
		ATATuning.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleRight"), chr)
	else
		return false
	end
end

function ATATuning.Use.RoofTent(vehicle, part, open)
	if open then
		part:setModelVisible("Close", false)
		part:setModelVisible("Open", true)
		part:getModData()["atatuning"].status = "open"
        vehicle:transmitPartModData(part)
		VehicleUtils.createPartInventoryItem(vehicle:getPartById("SeatMiddleLeft"))
		vehicle:getPartById("SeatMiddleLeft"):setContainerContentAmount(0)
		VehicleUtils.createPartInventoryItem(vehicle:getPartById("SeatMiddleRight"))
		vehicle:getPartById("SeatMiddleRight"):setContainerContentAmount(0)
	else
		part:setModelVisible("Close", true)
		part:setModelVisible("Open", false)
		vehicle:getPartById("SeatMiddleLeft"):setInventoryItem(nil)
		vehicle:getPartById("SeatMiddleRight"):setInventoryItem(nil)
        vehicle:transmitPartItem(vehicle:getPartById("SeatMiddleLeft"))
        vehicle:transmitPartItem(vehicle:getPartById("SeatMiddleRight"))
		part:getModData()["atatuning"].status = "close"
        vehicle:transmitPartModData(part)
	end
end

function ATATuning.UninstallTest.RoofClose(vehicle, part, chr)
	-- if not part:getInventoryItem() then return false end
	-- if not part:getItemType() or part:getItemType():isEmpty() then return false end
	-- local typeToItem = VehicleUtils.getItems(chr:getPlayerNum())
	if round(part:getContainerContentAmount(), 3) > 0 then return false end
	local seatNumber = part:getContainerSeatNumber()
	local seatOccupied = (seatNumber ~= -1) and vehicle:isSeatOccupied(seatNumber)
	if seatOccupied then return false end
	return true
end

--************************************************************
--**                                                       	**
--**              		 Engine Door 	  	          		**
--**                                                       	**
--************************************************************

function ATATuning.Init.Door(vehicle, part)
	Vehicles.Init.Door(vehicle, part)
	ATATuning.ModelByItemName(vehicle, part, part:getInventoryItem())
end

function ATATuning.InstallComplete.Door(vehicle, part)
	Vehicles.InstallComplete.Door(vehicle, part)
	ATATuning.ModelByItemName(vehicle, part, part:getInventoryItem())
end

function ATATuning.UninstallComplete.Door(vehicle, part, item)
	Vehicles.UninstallComplete.Door(vehicle, part, item)
	ATATuning.ModelByItemName(vehicle, part)
	if not part:getModData().atatuning or not part:getModData().atatuning.health then return end
	item:setCondition(part:getModData().atatuning.health)
	part:getModData().atatuning.health = nil
    vehicle:transmitPartModData(part)
end

--***********************************************************
--**                                                       **
--**                 	Common Protection  	               **
--**                                                       **
--***********************************************************

function ATATuning.UninstallComplete.Window(vehicle, part, item)
	Vehicles.UninstallComplete.Default(vehicle, part, item)
	if not part:getModData().atatuning or not part:getModData().atatuning.health then return end
	item:setCondition(part:getModData().atatuning.health)
	part:getModData().atatuning.health = nil
    vehicle:transmitPartModData(part)
end

function ATATuning.InstallComplete.CommonProtection(vehicle, part)
-- print("ATATuning.InstallComplete.Protection")
	local item = part:getInventoryItem();
	if not item then return; end
	ATATuning.InstallComplete.DefaultModel(vehicle, part)
	if part:getParent() then
        -- print("PARENT")
		local savePart = part:getParent()
		if savePart and savePart:getInventoryItem() then
			if not savePart:getModData().atatuning then
				savePart:getModData().atatuning = {}
			end
			savePart:getModData().atatuning.health = savePart:getCondition()
            vehicle:transmitPartModData(savePart)
			savePart:setCondition(100)
            vehicle:transmitPartCondition(savePart)
		end
	elseif item:getModData()["ataProtection"] then
		local partNames = item:getModData()["ataProtection"]:split(";");
		for k, partName in ipairs(partNames) do
            -- print(partName)
            if partName ~= "Engine" then -- защита кода от "защиты двигателя"
                local savePart = vehicle:getPartById(partName)
                if savePart and savePart:getInventoryItem() then
                    if not savePart:getModData().atatuning then
                        savePart:getModData().atatuning = {}
                    end
                    savePart:getModData().atatuning.health = savePart:getCondition()
                    vehicle:transmitPartModData(savePart)
                    savePart:setCondition(100)
                    vehicle:transmitPartCondition(savePart)
                end
            end
		end
	end
end

function ATATuning.UninstallComplete.CommonProtection(vehicle, part, item)
-- print("ATATuning.UninstallComplete.Protection")
	if not item then return end
	ATATuning.UninstallComplete.DefaultModel(vehicle, part, item)
	if part:getParent() then
    -- print("PARENT")
		local savePart = part:getParent()
		if savePart then
			if not savePart:getModData().atatuning or not savePart:getModData().atatuning.health then return end
            print(savePart:getModData().atatuning.health)
			savePart:setCondition(savePart:getModData().atatuning.health)
			savePart:getModData().atatuning.health = nil
            vehicle:transmitPartCondition(savePart)
            vehicle:transmitPartModData(savePart)
		end
	elseif item:getModData()["ataProtection"] then
		local partNames = item:getModData()["ataProtection"]:split(";");
		for k, partName in ipairs(partNames) do 
            -- print(partName)
            if partName ~= "Engine" then  -- защита кода от "защиты двигателя"
                local savePart = vehicle:getPartById(partName)
                if savePart then
                    if not savePart:getModData().atatuning or not savePart:getModData().atatuning.health then return end
                    print(savePart:getModData().atatuning.health)
                    savePart:setCondition(savePart:getModData().atatuning.health)
                    savePart:getModData().atatuning.health = nil
                    vehicle:transmitPartCondition(savePart)
                    vehicle:transmitPartModData(savePart)
                end
            end
		end
	end
end

function ATATuning.Update.CommonProtection(vehicle, part, elapsedMinutes)
	-- print("ATATuning.Update.Protection")
	local item = part:getInventoryItem();
	if not item then return; end

	local areaCenter = vehicle:getAreaCenter(part:getArea())
	if not areaCenter then return nil end
	local square = getCell():getGridSquare(areaCenter:getX(), areaCenter:getY(), vehicle:getZ())
	if part:getCondition() == 0 then
		part:setInventoryItem(nil);
        vehicle:transmitPartItem(part)
		square:AddWorldInventoryItem(item, 0.5, 0.5, 0)
		ATATuning.UninstallComplete.CommonProtection(vehicle, part, item)
	else
		-- local redoCond = false
        local savePart = part:getParent()
		if savePart then
			if savePart and savePart:getInventoryItem() then
				if not savePart:getModData().atatuning then
					savePart:getModData().atatuning = {}
				end
				if not savePart:getModData().atatuning.health then
					savePart:getModData().atatuning.health = savePart:getCondition()
				end
				if (savePart:getCondition() < 80) then
					-- redoCond = true
					part:setCondition(part:getCondition()-1)
					savePart:setCondition(100)
                    vehicle:transmitPartCondition(part)
                    vehicle:transmitPartCondition(savePart)
				end
				if string.match(savePart:getId(), "Tire") and savePart:getContainerContentAmount() < 10 then
					savePart:setContainerContentAmount(20, false, true);
				end
                vehicle:transmitPartModData(savePart)
			end
		elseif item:getModData()["ataProtection"] then
			local partNames = item:getModData()["ataProtection"]:split(";");
			for k, partName in ipairs(partNames) do
                if partName ~= "Engine" then -- защита кода от "защиты двигателя"
                    savePart = vehicle:getPartById(partName)
                    if savePart and savePart:getInventoryItem() then
                        if not savePart:getModData().atatuning then
                            savePart:getModData().atatuning = {}
                        end
                        if not savePart:getModData().atatuning.health then
                            savePart:getModData().atatuning.health = savePart:getCondition()
                        end
                        if (savePart:getCondition() < 80) then
                            -- redoCond = true
                            part:setCondition(part:getCondition()-1)
                            savePart:setCondition(100)
                            vehicle:transmitPartCondition(part)
                            vehicle:transmitPartCondition(savePart)
                        end
                        if string.match(savePart:getId(), "Tire") and savePart:getContainerContentAmount() < 10 then
                            savePart:setContainerContentAmount(20, false, true);
                        end
                        vehicle:transmitPartModData(savePart)
                    end
                end
			end
		end
	end
end

--***********************************************************
--**                                                       **
--**                	ATAInteractiveTrunk	               **
--**                                                       **
--***********************************************************

function ATATuning.ATAInteractiveTrunk(part)
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


function ATATuning.ContainerAccess.ATAInteractiveTrunk(vehicle, part, chr)
	ATATuning.ATAInteractiveTrunk(part)
	if chr:getVehicle() then return false end
	if not vehicle:isInArea(part:getArea(), chr) then return false end
	return true
end

function ATATuning.Create.ATAInteractiveTrunk(vehicle, part)
	part:setInventoryItem(nil)
    vehicle:transmitPartItem(part)
	ATATuning.ATAInteractiveTrunk(part)
end

function ATATuning.Init.ATAInteractiveTrunk(vehicle, part)
	ATATuning.ATAInteractiveTrunk(part)
end

function ATATuning.InstallComplete.ATAInteractiveTrunk(vehicle, part)
	local item = part:getInventoryItem()
	if not item then return end
	ATATuning.ATAInteractiveTrunk(part)
end

function ATATuning.UninstallComplete.ATAInteractiveTrunk(vehicle, part, item)
	if not item then return end
	ATATuning.ATAInteractiveTrunk(part)
	vehicle:doDamageOverlay()
end

--***********************************************************
--**                                                       **
--**                		Lights 		 	               **
--**                                                       **
--***********************************************************

function ATATuning.Create.ATALight(vehicle, part)
	-- local item = VehicleUtils.createPartInventoryItem(part)
	-- xOffset,yOffset,distance,intensity,dot,focusing
	-- NOTE: distance,intensity,focusing values are ignored, instead they are
	-- set based on part condition.
	ATATuning.Create.Chance0(vehicle, part)
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

--***********************************************************
--**                                                       **
--**                	Wheels Protection  	               **
--**                                                       **
--***********************************************************

function ATATuning.WheelsProtection(vehicle, part)
	if part:getInventoryItem() then
		if vehicle:getPartById("TireFrontLeft"):getInventoryItem() then
			vehicle:getPartById("TireFrontLeft"):setModelVisible("ATAProtection", true);
		else
			vehicle:getPartById("TireFrontLeft"):setModelVisible("ATAProtection", false);
		end
		if vehicle:getPartById("TireFrontRight"):getInventoryItem() then
			vehicle:getPartById("TireFrontRight"):setModelVisible("ATAProtection", true);
		else
			vehicle:getPartById("TireFrontRight"):setModelVisible("ATAProtection", false);
		end
		if vehicle:getPartById("TireRearLeft"):getInventoryItem() then
			vehicle:getPartById("TireRearLeft"):setModelVisible("ATAProtection", true);
		else
			vehicle:getPartById("TireRearLeft"):setModelVisible("ATAProtection", false);
		end
		if vehicle:getPartById("TireRearRight"):getInventoryItem() then
			vehicle:getPartById("TireRearRight"):setModelVisible("ATAProtection", true);
		else
			vehicle:getPartById("TireRearRight"):setModelVisible("ATAProtection", false);
		end
	else
		vehicle:getPartById("TireFrontLeft"):setModelVisible("ATAProtection", false);
		vehicle:getPartById("TireFrontRight"):setModelVisible("ATAProtection", false);
		vehicle:getPartById("TireRearLeft"):setModelVisible("ATAProtection", false);
		vehicle:getPartById("TireRearRight"):setModelVisible("ATAProtection", false);
	end
end

function ATATuning.Init.WheelsProtection(vehicle, part)
	ATATuning.WheelsProtection(vehicle, part)
end

function ATATuning.InstallComplete.WheelsProtection(vehicle, part)
-- print(" ATATuning.InstallComplete.BusBullbar")
	ATATuning.WheelsProtection(vehicle, part)
    ATATuning.InstallComplete.CommonProtection(vehicle, part)
end

function ATATuning.UninstallComplete.WheelsProtection(vehicle, part, item)
-- print(" ATATuning.UninstallComplete.BusBullbar")
	ATATuning.WheelsProtection(vehicle, part)
    ATATuning.UninstallComplete.CommonProtection(vehicle, part, item)
end

-- print("Autotsar tunning loaded")