local oldOnTakeEngineParts = ISVehicleMechanics.onTakeEngineParts
local oldOnRepairEngine = ISVehicleMechanics.onRepairEngine

function ISVehicleMechanics.onTakeEngineParts(playerObj, part)
	if not part:getVehicle():getModData().tuning or not part:getVehicle():getModData().tuning[part:getId()] then
		oldOnTakeEngineParts(playerObj, part)
	elseif part:getVehicle():getModData().tuning[part:getId()].health then
		playerObj:Say(getText("IGUI_PlayerText_ATA_Engine"))
	end
end


function ISVehicleMechanics.onRepairEngine(playerObj, part)
	if not part:getVehicle():getModData().tuning or not part:getVehicle():getModData().tuning[part:getId()] then
		oldOnRepairEngine(playerObj, part)
	elseif part:getVehicle():getModData().tuning[part:getId()].health then
		playerObj:Say(getText("IGUI_PlayerText_ATA_Engine"))
	end
end