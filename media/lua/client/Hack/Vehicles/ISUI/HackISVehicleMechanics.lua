local oldISVehicleMechanics_doMenuTooltip = ISVehicleMechanics.doMenuTooltip

function ISVehicleMechanics:doMenuTooltip(part, option, lua, name)
	oldISVehicleMechanics_doMenuTooltip(self, part, option, lua, name)
	-- uninstall stuff
	local vehicle = part:getVehicle();
	local keyvalues = part:getTable(lua);
	if not keyvalues then return; end
	if not part:getItemType() then return; end
	if keyvalues.requireUninstalled and string.match(keyvalues.requireUninstalled, ";") then
		local split = keyvalues.requireUninstalled:split(";");
		for i,v in ipairs(split) do
			if vehicle:getPartById(v) and vehicle:getPartById(v):getInventoryItem() then 
				option.toolTip.description = option.toolTip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_requireUnistalled", getText("IGUI_VehiclePart" .. v)) .. " <LINE>";
			end
		end
	end
end