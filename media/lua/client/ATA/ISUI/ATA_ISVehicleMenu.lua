if not ATA_ISVehicleMenu then ATA_ISVehicleMenu = {} end

ATA_ISVehicleMenu.old_ISVehicleMenu_FillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
ATA_ISVehicleMenu.old_ISVehicleMenu_showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside
ATA_ISVehicleMenu.old_ISVehiclePartMenu_onSmashWindow = ISVehiclePartMenu.onSmashWindow

function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
-- print("ISVehicleMenu.FillMenuOutsideVehicle")
	local playerObj = getSpecificPlayer(player)
	if vehicle then
		local part = vehicle:getPartById("ATARoofTent");
		if part and part:getInventoryItem() then
			if part:getModData()["atatuning"] then
				if part:getModData()["atatuning"].status == "close" then
					context:addOption(getText("ContextMenu_OpenTent"), playerObj, ATA_ISVehicleMenu.openTent, vehicle, part, true);
				elseif part:getModData()["atatuning"].status == "open" then
					context:addOption(getText("ContextMenu_CloseTent"), playerObj, ATA_ISVehicleMenu.openTent, vehicle, part, false);
				end
			end
		end
		ATA_ISVehicleMenu.old_ISVehicleMenu_FillMenuOutsideVehicle(player, context, vehicle, test)
	end
end

function ISVehicleMenu.showRadialMenuOutside(playerObj)
	ATA_ISVehicleMenu.old_ISVehicleMenu_showRadialMenuOutside(playerObj)
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
					menu:addSlice(getText("ContextMenu_OpenTent"), getTexture("media/ui/commonlibrary/UI_commonlib_open_tent.png"), ATA_ISVehicleMenu.openTent, playerObj, vehicle, part, true);
				elseif part:getModData()["atatuning"].status == "open" then
					menu:addSlice(getText("ContextMenu_CloseTent"), getTexture("media/ui/commonlibrary/UI_commonlib_close_tent.png"), ATA_ISVehicleMenu.openTent, playerObj, vehicle, part, false);
				end
			end
		end
        -- local part = vehicle:getClosestWindow(playerObj);
        -- if part then
            -- local window = part:getWindow()
            -- if not window:isDestroyed() and not window:isOpen() then
                -- if part:getTable("uninstall").requireUninstalled then
                    -- local partProtection = vehicle:getPartById(part:getTable("uninstall").requireUninstalled);
                    -- if partProtection and partProtection:getInventoryItem() then
                        -- menu:updateSliceTsar(
                            -- getText("ContextMenu_Vehicle_Smashwindow", getText("IGUI_VehiclePart" .. part:getId())),
                            -- getText("ContextMenu_Vehicle_For_Smashwindow_Uninstall_Protection"),
                            -- getTexture("media/ui/commonlibrary/cant_vehicle_smash_window.png"),
                            -- false
                        -- )
                    -- end
                -- end
            -- end
        -- end
	end
end

function ATA_ISVehicleMenu.openTent(playerObj, vehicle, part, open)
	if part and (open or (ATATuning.UninstallTest.RoofClose(vehicle, part, playerObj) and ATATuning.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleLeft"), playerObj) and ATATuning.UninstallTest.RoofClose(vehicle, vehicle:getPartById("SeatMiddleRight"), playerObj))) then
		ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
		ISTimedActionQueue.add(ATAISOpenTent:new(playerObj, vehicle, part, open, 500))
	else
		playerObj:Say(getText("IGUI_PlayerText_ATA_TentDontOpen"))
	end
end

function ISVehiclePartMenu.onSmashWindow(playerObj, part, open)
    if part then
        local window = part:getWindow()
        if part:getTable("uninstall").requireUninstalled then
            local partProtection = part:getVehicle():getPartById(part:getTable("uninstall").requireUninstalled);
            if partProtection and partProtection:getInventoryItem() then
                processSayMessage(getText("IGUI_PlayerText_TRUEA_cant_vehicle_smash_window"))
                return
            end
        end
    end
    ATA_ISVehicleMenu.old_ISVehiclePartMenu_onSmashWindow(playerObj, part, open)
end