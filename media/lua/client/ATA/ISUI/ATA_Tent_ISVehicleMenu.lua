if not ATATuning then ATATuning = {} end

ATATuning.old_ISVehicleMenu_FillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle

function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
	local playerObj = getSpecificPlayer(player)
	if vehicle then
		local part = vehicle:getPartById("ATARoofTent");
		if part and part:getInventoryItem() then
			if part:getModData()["atatuning"] then
				if part:getModData()["atatuning"].status == "close" then
					context:addOption(getText("ContextMenu_OpenTent"), playerObj, ATATuning.openTent, vehicle, part, true);
				elseif part:getModData()["atatuning"].status == "open" then
					context:addOption(getText("ContextMenu_CloseTent"), playerObj, ATATuning.openTent, vehicle, part, false);
				end
			end
		end
		ATATuning.old_ISVehicleMenu_FillMenuOutsideVehicle(player, context, vehicle, test)
	end
end

function ATATuning.openTent(playerObj, vehicle, part, open)
	if part then
		ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
		ISTimedActionQueue.add(ATAISOpenTent:new(playerObj, vehicle, part, open, 500))
	end
end