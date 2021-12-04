if not ATA_Tent then ATA_Tent = {} end

ATA_Tent.old_ISVehicleMenu_FillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
ATA_Tent.old_ISVehicleMenu_showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside

function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
	local playerObj = getSpecificPlayer(player)
	if vehicle then
		local part = vehicle:getPartById("ATARoofTent");
		if part and part:getInventoryItem() then
			if part:getModData()["atatuning"] then
				if part:getModData()["atatuning"].status == "close" then
					context:addOption(getText("ContextMenu_OpenTent"), playerObj, ATA_Tent.openTent, vehicle, part, true);
				elseif part:getModData()["atatuning"].status == "open" then
					context:addOption(getText("ContextMenu_CloseTent"), playerObj, ATA_Tent.openTent, vehicle, part, false);
				end
			end
		end
		ATA_Tent.old_ISVehicleMenu_FillMenuOutsideVehicle(player, context, vehicle, test)
	end
end

function ISVehicleMenu.showRadialMenuOutside(playerObj)
	ATA_Tent.old_ISVehicleMenu_showRadialMenuOutside(playerObj)
	if playerObj:getVehicle() then return end
	local playerIndex = playerObj:getPlayerNum()
	local menu = getPlayerRadialMenu(playerIndex)
	if menu:isReallyVisible() then
		if menu.joyfocus then
			setJoypadFocus(playerIndex, nil)
		end
		menu:undisplay()
		return
	end
	local vehicle = ISVehicleMenu.getVehicleToInteractWith(playerObj)
	if vehicle then
		local part = vehicle:getPartById("ATARoofTent");
		if part and part:getInventoryItem() then
			if part:getModData()["atatuning"] then
				if part:getModData()["atatuning"].status == "close" then
					menu:addSlice(getText("ContextMenu_OpenTent"), getTexture("media/ui/commonlibrary/UI_commonlib_open_tent.png"), ATA_Tent.openTent, playerObj, vehicle, part, true);
				elseif part:getModData()["atatuning"].status == "open" then
					menu:addSlice(getText("ContextMenu_CloseTent"), getTexture("media/ui/commonlibrary/UI_commonlib_close_tent.png"), ATA_Tent.openTent, playerObj, vehicle, part, false);
				end
			end
		end
	end
end


function ATA_Tent.openTent(playerObj, vehicle, part, open)
	if part and (open or (ATATuning.UninstallTest.RoofClose(vehicle, part, playerObj) and ATATuning.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleLeft"), playerObj) and ATATuning.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleRight"), playerObj))) then
		ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
		ISTimedActionQueue.add(ATAISOpenTent:new(playerObj, vehicle, part, open, 500))
	else
		playerObj:Say(getText("IGUI_PlayerText_ATA_TentDontOpen"))
	end
end