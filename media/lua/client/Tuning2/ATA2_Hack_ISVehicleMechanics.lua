local old_ISVehicleMechanics_doMenuTooltip = ISVehicleMechanics.doMenuTooltip

-- Debug reload
-- old_ISVehicleMechanics_doMenuTooltip = old_ISVehicleMechanics_doMenuTooltip
-- if not old_ISVehicleMechanics_doMenuTooltip then
    -- old_ISVehicleMechanics_doMenuTooltip = ISVehicleMechanics.doMenuTooltip
-- end

function ISVehicleMechanics:doMenuTooltip(part, option, lua, name)
    old_ISVehicleMechanics_doMenuTooltip(self, part, option, lua, name)
    -- uninstall stuff
    local vehicle = part:getVehicle();
    local keyvalues = part:getTable(lua);
    if not keyvalues then return; end
    if not part:getItemType() then return; end
    if keyvalues.requireInstalled and string.match(keyvalues.requireInstalled, ";") then
        local split = keyvalues.requireInstalled:split(";");
        for i,partName in ipairs(split) do
            if vehicle:getPartById(partName) and vehicle:getPartById(partName):getInventoryItem() then 
                option.toolTip.description = option.toolTip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_requireInstalled", getText("IGUI_VehiclePart" .. partName)) .. " <LINE>";
            end
        end
    end
    if keyvalues.requireUninstalled and string.match(keyvalues.requireUninstalled, ";") then
        local split = keyvalues.requireUninstalled:split(";");
        for i,partName in ipairs(split) do
            if vehicle:getPartById(partName) and vehicle:getPartById(partName):getInventoryItem() then 
                option.toolTip.description = option.toolTip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_requireUnistalled", getText("IGUI_VehiclePart" .. partName)) .. " <LINE>";
            end
        end
    end
    if lua == "uninstall" then
        if part:getModData().tuning2 and part:getModData().tuning2.protectionRequireUninstalled then
            for partName,value in pairs(part:getModData().tuning2.protectionRequireUninstalled) do
                if value 
                        and vehicle:getPartById(partName) 
                        and vehicle:getPartById(partName):getInventoryItem() 
                        and (not keyvalues.requireUninstalled or not string.match(keyvalues.requireUninstalled, partName)) then -- избегаем дублирования информации
                    option.toolTip.description = option.toolTip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_requireUnistalled", getText("IGUI_VehiclePart" .. partName)) .. " <LINE>";
                    option.notAvailable = true;
                end
            end
        end
    end
end