--***********************************************************
--** IBRRUS/Faithful and discreet slave of Tsar Vyacheslav **
--***********************************************************

if (TrailerHomeItems == nil) then TrailerHomeItems = {} end

TrailerHomeItems["appliances_cooking_01_0"] = "MovGreenOven"
TrailerHomeItems["appliances_cooking_01_1"] = "MovGreenOven"
TrailerHomeItems["appliances_cooking_01_2"] = "MovGreenOven"
TrailerHomeItems["appliances_cooking_01_3"] = "MovGreenOven"
TrailerHomeItems["appliances_cooking_01_4"] = "MovGreyOven"
TrailerHomeItems["appliances_cooking_01_5"] = "MovGreyOven"
TrailerHomeItems["appliances_cooking_01_6"] = "MovGreyOven"
TrailerHomeItems["appliances_cooking_01_7"] = "MovGreyOven"
TrailerHomeItems["appliances_cooking_01_8"] = "MovRedOven"
TrailerHomeItems["appliances_cooking_01_9"] = "MovRedOven"
TrailerHomeItems["appliances_cooking_01_10"] = "MovRedOven"
TrailerHomeItems["appliances_cooking_01_11"] = "MovRedOven"
TrailerHomeItems["appliances_cooking_01_12"] = "MovModernOven"
TrailerHomeItems["appliances_cooking_01_13"] = "MovModernOven"
TrailerHomeItems["appliances_cooking_01_14"] = "MovModernOven"
TrailerHomeItems["appliances_cooking_01_15"] = "MovModernOven"
TrailerHomeItems["appliances_cooking_01_20"] = "MovIndustrialOven"
TrailerHomeItems["appliances_cooking_01_21"] = "MovIndustrialOven"
TrailerHomeItems["appliances_cooking_01_22"] = "MovIndustrialOven"
TrailerHomeItems["appliances_cooking_01_23"] = "MovIndustrialOven"

TrailerHomeItems["appliances_cooking_01_24"] = "MovWhiteMicrowave"
TrailerHomeItems["appliances_cooking_01_25"] = "MovWhiteMicrowave"
TrailerHomeItems["appliances_cooking_01_26"] = "MovWhiteMicrowave"
TrailerHomeItems["appliances_cooking_01_27"] = "MovWhiteMicrowave"
TrailerHomeItems["appliances_cooking_01_28"] = "MovChromeMicrowave"
TrailerHomeItems["appliances_cooking_01_29"] = "MovChromeMicrowave"
TrailerHomeItems["appliances_cooking_01_30"] = "MovChromeMicrowave"
TrailerHomeItems["appliances_cooking_01_31"] = "MovChromeMicrowave"


TrailerHomeItems["appliances_refrigeration_01_0"] = "MovWhiteFridge"
TrailerHomeItems["appliances_refrigeration_01_1"] = "MovWhiteFridge"
TrailerHomeItems["appliances_refrigeration_01_2"] = "MovWhiteFridge"
TrailerHomeItems["appliances_refrigeration_01_3"] = "MovWhiteFridge"
TrailerHomeItems["appliances_refrigeration_01_4"] = "MovBlueFridge"
TrailerHomeItems["appliances_refrigeration_01_5"] = "MovBlueFridge"
TrailerHomeItems["appliances_refrigeration_01_6"] = "MovBlueFridge"
TrailerHomeItems["appliances_refrigeration_01_7"] = "MovBlueFridge"
TrailerHomeItems["appliances_refrigeration_01_8"] = "MovSteelFridge"
TrailerHomeItems["appliances_refrigeration_01_9"] = "MovSteelFridge"
TrailerHomeItems["appliances_refrigeration_01_10"] = "MovSteelFridge"
TrailerHomeItems["appliances_refrigeration_01_11"] = "MovSteelFridge"
TrailerHomeItems["appliances_refrigeration_01_12"] = "MovGreenFridge"
TrailerHomeItems["appliances_refrigeration_01_13"] = "MovGreenFridge"
TrailerHomeItems["appliances_refrigeration_01_14"] = "MovGreenFridge"
TrailerHomeItems["appliances_refrigeration_01_15"] = "MovGreenFridge"
TrailerHomeItems["appliances_refrigeration_01_28"] = "MovPlainFridge"
TrailerHomeItems["appliances_refrigeration_01_29"] = "MovPlainFridge"
TrailerHomeItems["appliances_refrigeration_01_30"] = "MovPlainFridge"
TrailerHomeItems["appliances_refrigeration_01_31"] = "MovPlainFridge"
TrailerHomeItems["appliances_refrigeration_01_32"] = "MovRedFridge"
TrailerHomeItems["appliances_refrigeration_01_33"] = "MovRedFridge"
TrailerHomeItems["appliances_refrigeration_01_34"] = "MovRedFridge"
TrailerHomeItems["appliances_refrigeration_01_35"] = "MovRedFridge"

function TCOnObjectAboutToBeRemoved(object)
	local worldSprite = object:getSprite()
	if worldSprite ~= nil then
		worldSpriteName = worldSprite:getName()
		local newItem = TrailerHomeItems[worldSpriteName]
		if newItem then
			local player = getPlayer()
			local playerInv = player:getInventory()
			local allItems = playerInv:getItemsFromType("Moveable")
			for i=0, allItems:size()-1 do
				local oldItem = allItems:get(i)
				if oldItem:getWorldSprite() == worldSpriteName then
					--print("TC: add")
					local newItem = playerInv:AddItem("Base." .. newItem);
					if newItem then
						playerInv:Remove(oldItem)
					end
					return
				end
			end
		end
	end
end

Events.OnObjectAboutToBeRemoved.Add(TCOnObjectAboutToBeRemoved)